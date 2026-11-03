#!/usr/bin/env python3
# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""Run the shared instruction preflight and this repository's established gate."""

import argparse
import sys
from pathlib import Path

from check_library_rules import main as check_library_rules
from process_tools import GateToolError, display, run

ROOT = Path(__file__).resolve().parents[1]
COMMANDS = [
    [sys.executable, "scripts/unit_twin.py", "--check"],
    ["gleam", "test"],
    ["gleam", "format", "--check", "src", "test"],
    [sys.executable, "scripts/verify_catalog.py"],
    ["uvx", "--offline", "ruff@0.15.18", "check", "."],
    ["uvx", "--offline", "ruff@0.15.18", "format", "--check", "."],
    ["uvx", "--offline", "pyright@1.1.410", "--project", "."],
    [sys.executable, "-m", "unittest", "discover", "-s", "tests"],
]


# reason: this entrypoint combines the existing manual checks with their required preflight.
def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--library-rules-only",
        action="store_true",
        help="Run only the shared instruction check; no full-gate evidence.",
    )
    arguments = parser.parse_args()
    result = check_library_rules()
    if result or arguments.library_rules_only:
        return result
    for command in COMMANDS:
        print("RUN " + " ".join(command), flush=True)
        try:
            display(run(command))
        except GateToolError as failure:
            print(failure)
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
