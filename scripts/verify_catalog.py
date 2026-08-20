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
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
CITATION = re.compile(r"\(?(src/gunit/[a-z_0-9]+\.gleam):(\d+)\)?")
OPAQUE = re.compile(r"^pub opaque type (\w+)", re.M)
TEST_FN = re.compile(r"^pub fn (\w+_test)\s*\(", re.M)
FACTOR_CONST = re.compile(r"^const (\w+_factor) = ([0-9_.eE+-]+)", re.M)
ENTRY_ID = re.compile(r"^feat\.units\.([a-z_0-9]+)\.v\d+$")
REQUIRED = ("schema_version", "id", "status", "intensity", "intent", "acceptance", "brands")
CALC_REQUIRED = ("units", "factors", "golden_tests", "provenance")
STATUSES = {"pending", "in-progress", "completed", "deprecated", "superseded"}
# A retired ID is never reused or deleted, so it outlives the module it described.
RETIRED = {"deprecated", "superseded"}


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


def main() -> int:
    cat_dir = REPO / "docs" / "features"
    if not cat_dir.is_dir():
        print(f"FAIL {cat_dir} does not exist", file=sys.stderr)
        return 1

    src_lines: dict[str, list[str]] = {}
    brands: set[str] = set()
    # (file, line) -> (const name, literal value). Keyed by position so a citation must
    # land ON the constant it claims, and named so coverage is by IDENTITY. Counting
    # claims against counting constants let one factor be documented twice while another
    # was silently dropped: the totals still matched.
    factor_at: dict[tuple[str, int], tuple[str, str]] = {}
    families: set[str] = set()
    for path in sorted((REPO / "src" / "gunit").glob("*.gleam")):
        text = path.read_text(encoding="utf-8")
        rel = f"src/gunit/{path.name}"
        families.add(path.stem)
        src_lines[rel] = text.splitlines()
        brands |= set(OPAQUE.findall(text))
        for n, line in enumerate(src_lines[rel], 1):
            if m := FACTOR_CONST.match(line):
                factor_at[(rel, n)] = (m.group(1), m.group(2))

    test_path = REPO / "test" / "gunit_test.gleam"
    tests = set(TEST_FN.findall(test_path.read_text(encoding="utf-8"))) if test_path.exists() else set()

    entries = sorted(cat_dir.glob("*.toml"))
    print(f"{len(entries)} entries | source: {len(brands)} brands, {len(factor_at)} factor consts, {len(tests)} tests\n")

    ok = True
    claimed: set[str] = set()
    described: set[str] = set()
    covered: dict[str, int] = {}
    documented = resolved = 0

    for path in entries:
        problems: list[str] = []
        try:
            entry = tomllib.loads(path.read_text(encoding="utf-8"))
        except tomllib.TOMLDecodeError as exc:
            print(f"  FAIL {path.name}: does not parse - {exc}")
            ok = False
            continue

        problems += [f"missing required field {f}" for f in REQUIRED if f not in entry]
        if (status := entry.get("status")) not in STATUSES:
            problems.append(f"status {status!r} is not one of {sorted(STATUSES)}")
        if entry.get("id") != path.stem:
            problems.append(f"id {entry.get('id')!r} does not match filename {path.stem!r}")
        if m := ENTRY_ID.fullmatch(path.stem):
            described.add(m.group(1))
            if m.group(1) not in families and status not in RETIRED:
                problems.append(f"entry describes src/gunit/{m.group(1)}.gleam, which does not exist")
        else:
            problems.append(f"filename {path.stem!r} is not feat.units.<family>.vN, so it names no module")
        if entry.get("intensity") == "calc":
            problems += [f"intensity=calc but {f} is missing or empty" for f in CALC_REQUIRED if not entry.get(f)]

        claimed |= set(entry.get("brands", []))
        problems += [f"brand {b} exists in no module" for b in entry.get("brands", []) if b not in brands]

        for claim in entry.get("factors", []):
            documented += 1
            m = CITATION.search(claim)
            if not m:
                problems.append(f"factor has no file:line citation: {claim[:60]}")
                continue
            rel, lineno = m.group(1), int(m.group(2))
            if rel not in src_lines:
                problems.append(f"citation names a missing file: {rel}")
                continue
            if not 1 <= lineno <= len(src_lines[rel]):
                problems.append(f"citation {rel}:{lineno} is past end of file")
                continue
            if (rel, lineno) not in factor_at:
                problems.append(
                    f"{rel}:{lineno} is not a factor constant - line is: "
                    f"{src_lines[rel][lineno - 1].strip()[:70]}"
                )
                continue
            const_name, value = factor_at[(rel, lineno)]
            covered[const_name] = covered.get(const_name, 0) + 1
            if not claims_value(claim, value):
                problems.append(f"{const_name} is {value}, which the claim does not state: {claim[:70]}")
            else:
                resolved += 1

        for cited in entry.get("golden_tests", []):
            name = cited.split()[0].split("(")[0].strip()
            if name and name not in tests:
                problems.append(f"cited test does not exist: {name}")

        if problems:
            ok = False
            print(f"  FAIL {path.name}")
            for p in problems:
                print(f"        {p}")
        else:
            print(f"  ok   {path.name}  ({entry.get('intensity')}, {len(entry.get('factors', []))} factors)")

    if uncovered := sorted(brands - claimed):
        print(f"\n  FAIL {len(uncovered)} brands have no entry: {uncovered}")
        ok = False

    if unlabelled := sorted(families - described):
        print(f"\n  FAIL {len(unlabelled)} modules have no catalog entry: {unlabelled}")
        ok = False

    # Coverage is per-constant, not a total. Comparing totals let one factor be claimed
    # twice while another was dropped, because 25 still equalled 25.
    for const_name, _ in sorted(factor_at.values()):
        seen = covered.get(const_name, 0)
        if seen == 0:
            print(f"\n  FAIL {const_name} is defined in source and documented nowhere")
            ok = False
        elif seen > 1:
            print(f"\n  FAIL {const_name} is documented {seen} times; each factor is claimed once")
            ok = False

    print(f"\nfactor claims: {documented} documented, {resolved} matched the cited constant's exact value")
    print("Direction is NOT machine-checked: a claim that reverses unit and base still passes.")
    print("PASS" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
