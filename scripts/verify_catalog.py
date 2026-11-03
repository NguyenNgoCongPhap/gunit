#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Cong Phap
"""Verify the feature catalog against the source it claims to describe.

The catalog is authoritative for what each unit family promises, so a wrong entry
misleads every reader that trusts it. Three ways an entry goes wrong while still
reading perfectly well:

1. **An invented or rounded conversion factor.** The prose is fluent and the number is
   plausible, so nothing but resolving the cited `file:line` and matching the digits
   catches it. A silent kip-versus-kN factor is the bug class this library exists to
   prevent; the catalog must not reintroduce it in documentation.
2. **A brand that does not exist, or a real brand with no entry.** Both look like a
   complete list from the inside. Pairing is also checked one level up, per module:
   brand coverage alone cannot see a family module that declares no opaque type, nor an
   entry that names no family, so either could ship unlabelled behind a green gate.
3. **A cited golden test that is not in the test file.** An empty list is honest; a dead
   citation reads as verified and is not.

Nothing here trusts the catalog's own claims: every assertion is re-derived from source.

Run: python3 scripts/verify_catalog.py
"""

from __future__ import annotations

import re
import sys
import tomllib
from collections import Counter
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
CITATION = re.compile(r"\(?(src/gunit/[a-z_0-9]+\.gleam):(\d+)\)?")
OPAQUE = re.compile(r"^pub opaque type (\w+)", re.M)
TEST_FN = re.compile(r"^pub fn (\w+_test)\s*\(", re.M)
FACTOR_CONST = re.compile(r"^const (\w+_factor) = ([0-9_.eE+-]+)", re.M)
GENERATED_CONSTRUCTOR = re.compile(r"^pub fn from_(\w+)\(")
GENERATED_FACTOR = re.compile(r"\s*case input >\. maximum_float /\. ([0-9_.eE+-]+) \{")
ENTRY_ID = re.compile(r"^feat\.units\.([a-z_0-9]+)\.v\d+$")
REQUIRED = ("schema_version", "id", "status", "intensity", "intent", "acceptance", "brands")
CALC_REQUIRED = ("units", "factors", "golden_tests", "provenance")
STATUSES = {"pending", "in-progress", "completed", "deprecated", "superseded"}
# A retired ID is never reused or deleted, so it outlives the module it described.
RETIRED = {"deprecated", "superseded"}


def source_factors(lines: list[str], module: str) -> dict[int, tuple[str, str]]:
    """Map source lines to (factor identity, literal), including Rust-emitted guards."""
    generated = any("Generated from Rust unit declarations. Do not edit." in line for line in lines)
    constructor = ""
    factors: dict[int, tuple[str, str]] = {}
    for number, line in enumerate(lines, 1):
        if constant := FACTOR_CONST.match(line):
            factors[number] = constant.group(1), constant.group(2)
        elif generated and (name := GENERATED_CONSTRUCTOR.match(line)):
            constructor = name.group(1)
        elif generated and constructor and (factor := GENERATED_FACTOR.fullmatch(line)):
            factors[number] = f"{module}.{constructor}_factor", factor.group(1)
            constructor = ""
    return factors


def normalize(value: str) -> str:
    """Gleam writes 1_000_000.0; a claim may write it either way. Compare without them."""
    return value.replace("_", "")


def claims_value(claim: str, value: str) -> bool:
    """Is `value` present in `claim` as a WHOLE number, not as a substring?

    Substring matching is why the first version of this check was worthless: `9.806`
    sits inside `9.80665`, so a truncated factor resolved against the correct source
    line and passed. Require a numeric token with nothing numeric adjacent.
    """
    wanted = normalize(value)
    for token in re.findall(r"[0-9_][0-9_.eE+-]*", claim):
        if normalize(token).rstrip(".") == wanted.rstrip("."):
            return True
    return False


@dataclass
class SourceInventory:
    """Paths and one-based lines map to factor identities and exact source literals."""

    lines: dict[str, list[str]] = field(default_factory=dict)
    brands: set[str] = field(default_factory=set)
    families: set[str] = field(default_factory=set)
    factors: dict[tuple[str, int], tuple[str, str]] = field(default_factory=dict)
    tests: set[str] = field(default_factory=set)


@dataclass
class Claims:
    brands: set[str] = field(default_factory=set)
    families: set[str] = field(default_factory=set)
    factors: Counter[str] = field(default_factory=Counter)
    documented: int = 0
    resolved: int = 0


def source_inventory() -> SourceInventory:
    """Read real module brands, factor definitions and golden test names."""
    inventory = SourceInventory()
    for path in sorted((REPO / "src/gunit").glob("*.gleam")):
        text = path.read_text(encoding="utf-8")
        relative = f"src/gunit/{path.name}"
        inventory.lines[relative] = text.splitlines()
        inventory.families.add(path.stem)
        inventory.brands.update(OPAQUE.findall(text))
        inventory.factors.update(
            {
                (relative, number): factor
                for number, factor in source_factors(inventory.lines[relative], path.stem).items()
            }
        )
    test_path = REPO / "test/gunit_test.gleam"
    if test_path.exists():
        inventory.tests.update(TEST_FN.findall(test_path.read_text(encoding="utf-8")))
    return inventory


def factor_problem(claim: str, inventory: SourceInventory, claims: Claims) -> str:
    """Check one exact source-number citation and count coverage by factor identity."""
    claims.documented += 1
    citation = CITATION.search(claim)
    if citation is None:
        return f"factor has no file:line citation: {claim[:60]}"
    relative, number = citation.group(1), int(citation.group(2))
    if relative not in inventory.lines:
        return f"citation names a missing file: {relative}"
    if not 1 <= number <= len(inventory.lines[relative]):
        return f"citation {relative}:{number} is past end of file"
    if (relative, number) not in inventory.factors:
        return f"{relative}:{number} is not a factor definition"
    name, value = inventory.factors[(relative, number)]
    claims.factors[name] += 1
    if not claims_value(claim, value):
        return f"{name} is {value}, which the claim does not state: {claim[:70]}"
    claims.resolved += 1
    return ""


def entry_problems(
    path: Path, entry: dict, inventory: SourceInventory, claims: Claims
) -> list[str]:
    """Keep every label bound to its actual module, brands, factors and named tests."""
    problems = [f"missing required field {name}" for name in REQUIRED if name not in entry]
    status = entry.get("status")
    if status not in STATUSES:
        problems.append(f"status {status!r} is not one of {sorted(STATUSES)}")
    if entry.get("id") != path.stem:
        problems.append(f"id {entry.get('id')!r} does not match filename {path.stem!r}")
    family = ENTRY_ID.fullmatch(path.stem)
    if family is None:
        problems.append(f"filename {path.stem!r} names no family module")
    else:
        claims.families.add(family.group(1))
        if family.group(1) not in inventory.families and status not in RETIRED:
            problems.append(f"entry describes missing src/gunit/{family.group(1)}.gleam")
    if entry.get("intensity") == "calc":
        problems.extend(
            f"intensity=calc but {name} is missing or empty"
            for name in CALC_REQUIRED
            if not entry.get(name)
        )
    claims.brands.update(entry.get("brands", []))
    problems.extend(
        f"brand {name} exists in no module"
        for name in entry.get("brands", [])
        if name not in inventory.brands
    )
    for claim in entry.get("factors", []):
        problem = factor_problem(claim, inventory, claims)
        if problem:
            problems.append(problem)
    for cited in entry.get("golden_tests", []):
        name = cited.split()[0].split("(")[0].strip()
        if name and name not in inventory.tests:
            problems.append(f"cited test does not exist: {name}")
    return problems


def coverage_problems(inventory: SourceInventory, claims: Claims) -> list[str]:
    """Require every current module, brand and factor exactly once where applicable."""
    problems = []
    if missing := sorted(inventory.brands - claims.brands):
        problems.append(f"brands have no entry: {missing}")
    if missing := sorted(inventory.families - claims.families):
        problems.append(f"modules have no catalog entry: {missing}")
    for name, _ in sorted(inventory.factors.values()):
        seen = claims.factors[name]
        if seen == 0:
            problems.append(f"{name} is defined in source and documented nowhere")
        elif seen > 1:
            problems.append(f"{name} is documented {seen} times; each factor is claimed once")
    return problems


def check_catalog() -> int:
    """Check every entry and aggregate real source coverage without inferring factor direction."""
    directory = REPO / "docs/features"
    if not directory.is_dir():
        raise ValueError("catalog directory does not exist")
    inventory, claims = source_inventory(), Claims()
    entries = sorted(directory.glob("*.toml"))
    print(
        f"{len(entries)} entries | source: {len(inventory.brands)} brands, "
        f"{len(inventory.factors)} factor definitions, {len(inventory.tests)} tests"
    )
    problems = []
    for path in entries:
        try:
            entry = tomllib.loads(path.read_text(encoding="utf-8"))
            found = entry_problems(path, entry, inventory, claims)
        except (ValueError, TypeError, KeyError, AttributeError) as error:
            found = [f"entry refused: {error}"]
        if found:
            problems.extend(f"{path.name}: {problem}" for problem in found)
        else:
            print(f"  ok   {path.name}")
    problems.extend(coverage_problems(inventory, claims))
    for problem in problems:
        print("FAIL " + problem)
    print(
        f"factor claims: {claims.documented} documented, "
        f"{claims.resolved} matched the cited definition's exact value"
    )
    print("Direction is NOT machine-checked: a claim that reverses unit and base still passes.")
    print("FAILED" if problems else "PASS")
    return 1 if problems else 0


def main() -> int:
    """Return a clear refusal for unreadable or invalid catalog/source inputs."""
    try:
        return check_catalog()
    except (OSError, ValueError, TypeError) as error:
        print(f"FAIL catalog inputs refused: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
