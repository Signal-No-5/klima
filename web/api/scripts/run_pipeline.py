#!/usr/bin/env python3
"""Run named pipeline bronze/silver assets from the API package root.

Examples:
  uv run python scripts/run_pipeline.py
  uv run python scripts/run_pipeline.py pagasa_warnings
"""

from __future__ import annotations

import argparse
import importlib
import sys
from pathlib import Path

# Ensure web/api is on sys.path when invoked as a script
API_ROOT = Path(__file__).resolve().parents[1]
if str(API_ROOT) not in sys.path:
    sys.path.insert(0, str(API_ROOT))


# name -> import path of the asset module (module defines a same-named callable)
ASSETS = {
    "pagasa_warnings": "pipeline.refinery.bronze.pagasa_warnings",
}


def run_asset(name: str) -> None:
    if name not in ASSETS:
        known = ", ".join(sorted(ASSETS)) or "(none)"
        raise SystemExit(f"Unknown asset '{name}'. Known: {known}")

    module = importlib.import_module(ASSETS[name])
    fn = getattr(module, name, None)
    if fn is None or not callable(fn):
        raise SystemExit(f"Module {ASSETS[name]} has no callable '{name}'")

    # @asset wraps the function; call with no extra args (ctx is injected)
    print(f"Running asset: {name}")
    fn()
    print(f"Finished asset: {name}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Run Klima pipeline assets")
    parser.add_argument(
        "asset",
        nargs="?",
        default="pagasa_warnings",
        help="Asset name (default: pagasa_warnings)",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List known assets and exit",
    )
    args = parser.parse_args()

    if args.list:
        for key in sorted(ASSETS):
            print(key)
        return

    # Pipeline DBs are relative to CWD; run from API root
    import os

    os.chdir(API_ROOT)
    run_asset(args.asset)


if __name__ == "__main__":
    main()
