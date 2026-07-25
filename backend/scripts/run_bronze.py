"""Thin wrapper kept for muscle memory; delegates to the pipeline CLI.

Prefer: ``python -m pipeline run --stage bronze [--reset]``
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from pipeline.cli import main

if __name__ == "__main__":
    argv = sys.argv[1:]
    if "--summary-only" in argv:
        raise SystemExit(main(["summary", "--stage", "bronze"]))
    reset = ["--reset"] if "--reset" in argv else []
    raise SystemExit(main(["run", "--stage", "bronze", *reset]))
