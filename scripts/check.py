#!/usr/bin/env python3
# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""Run the shared instruction preflight and this repository's established gate."""

import argparse
import subprocess
from pathlib import Path

from check_library_rules import main as check_library_rules

ROOT = Path(__file__).resolve().parents[1]
COMMANDS = [
    ["gleam", "test"],
    ["gleam", "format", "--check", "src", "test"],
    ["py", "-3.14", "scripts/verify_catalog.py"],
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
            subprocess.run(command, cwd=ROOT, check=True)
        except subprocess.CalledProcessError as failure:
            return failure.returncode
        except OSError:
            print("REFUSED: gate command unavailable: " + command[0])
            return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
