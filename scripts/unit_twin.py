# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""Materialize and verify the published pure-Gleam quantity twin and its code-derived label."""

import argparse
import hashlib
import json
import re
import tomllib
from pathlib import Path, PurePosixPath
from typing import Any

from process_tools import GateToolError, run
from verify_catalog import source_factors

ROOT = Path(__file__).resolve().parents[1]
LOCK = "unit-twin.lock.json"
SCHEMA_VERSION = 1
ARTIFACT_SUFFIXES = {".gleam", ".json"}


def repository_path(root: Path, value: str) -> Path:
    """Keep declared inputs and outputs inside the checkout without symlink traversal."""
    path = root / value
    canonical = PurePosixPath(value)
    if not canonical.parts or "\\" in value or ":" in value or canonical.as_posix() != value:
        raise ValueError("unit-twin paths must be canonical repository-relative names")
    if canonical.is_absolute() or ".." in canonical.parts:
        raise ValueError("unit-twin paths must be repository-relative")
    if not path.resolve().is_relative_to(root.resolve()):
        raise ValueError("unit-twin path escapes the checkout")
    if any(parent.is_symlink() for parent in [path, *path.parents] if parent != root):
        raise ValueError("unit-twin path traverses a symlink")
    return path


def declaration(root: Path) -> dict[str, Any]:
    """Load a default-branch declaration; resolved commits belong only in the lock."""
    document = tomllib.loads(repository_path(root, "unit-twin.toml").read_text(encoding="utf-8"))
    if (
        type(document.get("schema_version")) is not int
        or document["schema_version"] != SCHEMA_VERSION
    ):
        raise ValueError("unsupported unit-twin schema")
    if not re.fullmatch(r"https://github\.com/[\w-]+/[\w.-]+\.git", document["repository"]):
        raise ValueError("unit-twin producer must be an explicit GitHub HTTPS repository")
    if not re.fullmatch(r"[\w./-]+", document["branch"]):
        raise ValueError("unit-twin producer must declare its default branch")
    repository_path(root, document["contract"])
    repository_path(root, LOCK)
    repository_path(root, str(PurePosixPath(document["contract"]).with_name("index.md")))
    destinations = [item["destination"] for item in document["artifacts"]]
    if len(destinations) != len(ARTIFACT_SUFFIXES) or len(
        {name.casefold() for name in destinations}
    ) != len(ARTIFACT_SUFFIXES):
        raise ValueError("unit-twin artifacts must be nonempty and unique")
    if {Path(name).suffix for name in destinations} != ARTIFACT_SUFFIXES:
        raise ValueError("unit-twin stock must be pure Gleam plus generated JSON metadata")
    if not document["contract"].startswith("docs/features/") or not document["contract"].endswith(
        ".toml"
    ):
        raise ValueError("unit-twin contract must be a feature entry")
    for item in document["artifacts"]:
        repository_path(root, item["source"])
        if not item["source"].startswith("docs/generated/unit-twins/"):
            raise ValueError("unit-twin input is outside the producer's generated stock")
        prefix = "src/gunit/" if item["destination"].endswith(".gleam") else "docs/generated/"
        if not item["destination"].startswith(prefix):
            raise ValueError("unit-twin artifact destination is outside its declared ownership")
        repository_path(root, item["destination"])
    return document


def remote_head(root: Path, source: dict[str, Any]) -> str:
    """Require the actual default binding and exactly one announced commit."""
    output = run(
        ["git", "ls-remote", "--symref", source["repository"], "HEAD"], root=root, network=True
    )
    binding = f"ref: refs/heads/{source['branch']}\tHEAD"
    heads = re.findall(r"(?m)^([0-9a-f]{40})\tHEAD$", output)
    if binding not in output.splitlines() or len(heads) != 1:
        raise ValueError("unit-twin default-branch binding refused")
    return heads[0]


def producer_bytes(
    root: Path, source: dict[str, Any], head: str
) -> list[tuple[dict[str, Any], bytes, str]]:
    """Fetch only the declared published branch and prove exact LF producer blob bytes."""
    cache = repository_path(root, "_scratch/unit-producer.git")
    cache.parent.mkdir(parents=True, exist_ok=True)
    if not cache.exists():
        run(["git", "init", "--bare", "--quiet", str(cache)], root=root)
    command = ["git", "--no-replace-objects", "--git-dir", str(cache)]
    if run([*command, "rev-parse", "--is-bare-repository"], root=root).strip() != "true":
        raise ValueError("unit-twin cache must be bare")
    run(
        [
            *command,
            "fetch",
            "--depth=1",
            "--no-tags",
            "--force",
            source["repository"],
            f"refs/heads/{source['branch']}:refs/heads/producer",
        ],
        root=root,
        network=True,
    )
    if run([*command, "rev-parse", "refs/heads/producer"], root=root).strip() != head:
        raise ValueError("unit-twin producer moved during fetch")
    outputs = []
    for item in source["artifacts"]:
        reference = f"{head}:{item['source']}"
        blob = run([*command, "rev-parse", "--verify", reference], root=root).strip()
        data = run([*command, "show", reference], root=root).encode("utf-8")
        actual = hashlib.sha1(
            b"blob " + str(len(data)).encode() + b"\0" + data, usedforsecurity=False
        )
        if actual.hexdigest() != blob or b"\r" in data:
            raise ValueError("unit-twin producer blob bytes refused")
        outputs.append((item, data, blob))
    return outputs


def factor_claims(root: Path, source: dict[str, Any]) -> list[str]:
    """Derive every new factor label from actual Gleam code and verify its Rust catalog scale."""
    module = next(
        item["destination"]
        for item in source["artifacts"]
        if item["destination"].endswith(".gleam")
    )
    catalog = next(
        item["destination"] for item in source["artifacts"] if item["destination"].endswith(".json")
    )
    metadata = json.loads(repository_path(root, catalog).read_bytes())
    lines = repository_path(root, module).read_text(encoding="utf-8").splitlines()
    factors = source_factors(lines, Path(module).stem)
    labels = {f"{Path(module).stem}.{scale['name']}_factor" for scale in metadata["scales"]}
    if len(labels) != len(metadata["scales"]) or labels != {label for label, _ in factors.values()}:
        raise ValueError("unit-twin source and metadata scale sets differ")
    claims = []
    for scale in metadata["scales"]:
        name = f"{Path(module).stem}.{scale['name']}_factor"
        found = [(line, value) for line, (label, value) in factors.items() if label == name]
        if len(found) != 1 or float(found[0][1].replace("_", "")) != scale["bytes_per_unit"]:
            raise ValueError("unit-twin source factor differs from the Rust catalog")
        line, value = found[0]
        claims.append(f"{value} byte-base units per {scale['name']} input ({module}:{line})")
    return claims


def verify_local(root: Path, source: dict[str, Any]) -> dict[str, Any]:
    """Verify local bytes and code-derived facts without claiming remote freshness."""
    document = json.loads(repository_path(root, LOCK).read_bytes())
    if (
        type(document.get("schema_version")) is not int
        or document["schema_version"] != SCHEMA_VERSION
    ):
        raise ValueError("unsupported unit-twin lock schema")
    if (
        document.get("repository") != source["repository"]
        or document.get("branch") != source["branch"]
    ):
        raise ValueError("unit-twin lock and declaration differ")
    if not re.fullmatch(r"[0-9a-f]{40}", document.get("commit", "")):
        raise ValueError("unit-twin lock commit is invalid")
    if len(document["artifacts"]) != len(source["artifacts"]):
        raise ValueError("unit-twin locked artifact set differs")
    for locked, item in zip(document["artifacts"], source["artifacts"], strict=True):
        if locked["source"] != item["source"] or locked["destination"] != item["destination"]:
            raise ValueError("unit-twin locked artifact binding differs")
        data = repository_path(root, item["destination"]).read_bytes()
        if b"\r" in data or hashlib.sha256(data).hexdigest() != locked["sha256"]:
            raise ValueError(f"unit-twin output drift: {item['destination']}")
    contract = tomllib.loads(repository_path(root, source["contract"]).read_text(encoding="utf-8"))
    if contract["factors"] != factor_claims(root, source):
        raise ValueError("unit-twin generated catalog facts drift")
    index = repository_path(root, str(PurePosixPath(source["contract"]).with_name("index.md")))
    if index.read_text(encoding="utf-8") != catalog_index(index.parent):
        raise ValueError("generated catalog index drift")
    return document


def catalog_index(directory: Path) -> str:
    """Render the browsable index from source-verified contracts without a second manual list."""
    lines = [
        "# gunit feature catalog",
        "",
        "Generated from source-verified feature contracts by scripts/unit_twin.py; do not edit.",
        "",
        "| ID | Name | Status | Intensity | Intent |",
        "| --- | --- | --- | --- | --- |",
    ]
    for path in sorted(directory.glob("*.toml")):
        if path.is_symlink():
            raise ValueError("catalog entries must not be symlinks")
        entry = tomllib.loads(path.read_text(encoding="utf-8"))
        values = [
            str(entry[name]).replace("|", "\\|").replace("\n", " ")
            for name in ["id", "name", "status", "intensity", "intent"]
        ]
        values[0] = f"[{values[0]}]({path.name})"
        lines.append("| " + " | ".join(values) + " |")
    return "\n".join(lines) + "\n"


def write_contract_facts(root: Path, source: dict[str, Any]) -> None:
    """Write the machine-owned factor field and index while preserving contract prose."""
    contract = repository_path(root, source["contract"])
    index = repository_path(root, str(PurePosixPath(source["contract"]).with_name("index.md")))
    text = contract.read_text(encoding="utf-8")
    field = "factors = " + json.dumps(factor_claims(root, source))
    text, count = re.subn(r"(?ms)^factors\s*=\s*\[.*?\]", lambda _: field, text)
    if count != 1:
        raise ValueError("unit-twin contract must have exactly one generated factors field")
    contract.write_text(text, encoding="utf-8", newline="\n")
    index.write_text(catalog_index(contract.parent), encoding="utf-8", newline="\n")


def generate(root: Path, *, write: bool) -> str:
    """Resolve, write/check and read back one published twin without a local-producer fallback."""
    source = declaration(root)
    locked = {} if write else verify_local(root, source)
    head = remote_head(root, source)
    if not write and locked["commit"] != head:
        raise ValueError("unit-twin lock behind remote default head; run --write after the wave")
    outputs = producer_bytes(root, source, head)
    if remote_head(root, source) != head:
        raise ValueError("unit-twin producer moved during collection")
    document = {
        "schema_version": SCHEMA_VERSION,
        "repository": source["repository"],
        "branch": source["branch"],
        "commit": head,
        "artifacts": [
            dict(item, blob=blob, sha256=hashlib.sha256(data).hexdigest())
            for item, data, blob in outputs
        ],
    }
    if write:
        for item, data, _ in outputs:
            destination = repository_path(root, item["destination"])
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(data)
        repository_path(root, LOCK).write_text(
            json.dumps(document, indent=2) + "\n", encoding="utf-8", newline="\n"
        )
        write_contract_facts(root, source)
    if verify_local(root, source) != document:
        raise ValueError("unit-twin lock differs from published producer provenance")
    return head


def main() -> int:
    """Require explicit write/check intent and report real refusals without fabricated stock."""
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write", action="store_true")
    group.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        print("Published unit-twin provenance verified: " + generate(ROOT, write=args.write))
    except (GateToolError, OSError, ValueError, KeyError, TypeError, StopIteration) as error:
        print(f"UNIT TWIN REFUSED: {error}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
