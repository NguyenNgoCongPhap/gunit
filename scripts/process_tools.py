# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""Load the reviewed process owner for gate-only commands and transport retries."""

import argparse
import importlib
import os
import sys
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]


class GateToolError(Exception):
    """A missing reviewed tool owner, real command refusal or exhausted network budget."""


def process_owner() -> ModuleType:
    """Resolve the explicit reviewed owner; never assume a sibling checkout or fetch tools."""
    source = Path(os.environ.get("REPO_SEED", ""))
    if not source.is_absolute() or not (source / "coordinator/process.py").is_file():
        raise GateToolError("REPO_SEED must point to an absolute reviewed repo-seed checkout")
    sys.path.insert(0, str(source))
    return importlib.import_module("coordinator.process")


# reason: run selects the existing owner's raw local capture or bounded remote runner.
def run(command: list[str], *, root: Path = ROOT, network: bool = False) -> str:
    """Run isolated argv; preserve local blob bytes and retry declared remote reads at the owner."""
    owner = process_owner()
    boundary = importlib.import_module("tiered_gate")
    try:
        if not network:
            return boundary.capture(root, command)
        scratch = ROOT / "_scratch"
        scratch.mkdir(parents=True, exist_ok=True)
        runner = owner.Runner(dict(os.environ), scratch / "commands.jsonl")
        return runner.run(root, command)
    except (owner.CoordinatorError, boundary.GateError) as error:
        kind = (
            "NETWORK"
            if network and owner.transient_remote_failure(command, str(error))
            else "REFUSED"
        )
        raise GateToolError(f"{kind}: {error}") from error


def display(output: str) -> None:
    """Print diagnostics through the same process owner's redactor."""
    process_owner()
    print(importlib.import_module("tiered_gate").redact(output), end="")


def main() -> int:
    """Run a gate command in this checkout, with explicit remote-read intent."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--network", action="store_true")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    arguments = parser.parse_args()
    if not arguments.command:
        parser.error("a command is required")
    try:
        display(run(arguments.command, network=arguments.network))
    except GateToolError as error:
        print(error)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
