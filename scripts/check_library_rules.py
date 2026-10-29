#!/usr/bin/env python3
# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""Check library instructions against the reviewed REPO_SEED checkout."""

import os
import subprocess
import sys
from pathlib import Path


# reason: this gate adapter delegates policy to its owner rather than copying it.
def main() -> int:
    source = Path(os.environ.get("REPO_SEED", ""))
    checker = source / "scripts" / "sync_agents_block.py"
    if not source.is_absolute() or not checker.is_file():
        print(
            "REFUSED: set REPO_SEED to an absolute reviewed repo-seed checkout "
            "containing scripts/sync_agents_block.py",
            file=sys.stderr,
        )
        return 2
    arguments = [
        sys.executable,
        str(checker),
        "--repo",
        str(Path(__file__).resolve().parents[1]),
        "--block",
        "library-family",
        "--check",
    ]
    try:
        subprocess.run(arguments, check=True)
    except subprocess.CalledProcessError as failure:
        return failure.returncode
    except OSError:
        print(
            "REFUSED: cannot execute the shared library-rules checker", file=sys.stderr
        )
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
