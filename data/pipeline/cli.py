"""CLI entrypoint for Klima ETL assets.

Examples:
  klima-etl --list
  klima-etl pagasa_warnings --offline
  python -m pipeline pagasa_warnings --offline
"""

from __future__ import annotations

import argparse
import importlib
import os
import sys

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

    print(f"Running asset: {name}")
    fn()
    print(f"Finished asset: {name}")


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Run Klima data-package ETL assets (canonical ETL SoT)."
    )
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
    parser.add_argument(
        "--offline",
        action="store_true",
        help="Skip live PAGASA fetch; load fixtures/pagasa_active_warning.json",
    )
    parser.add_argument(
        "--offline-fallback",
        action="store_true",
        help="On network failure, fall back to the offline fixture instead of exiting",
    )
    args = parser.parse_args(argv)

    if args.list:
        for key in sorted(ASSETS):
            print(key)
        return

    if args.offline:
        os.environ["KLIMA_ETL_MODE"] = "offline"
    elif args.offline_fallback:
        os.environ["KLIMA_ETL_MODE"] = "offline_fallback"
    # else: leave unset → live mode (may still fail clearly without network)

    from pipeline.config import db

    db.WAREHOUSE_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Warehouse: {db.WAREHOUSE_DIR}")
    print(f"Mode: {os.environ.get('KLIMA_ETL_MODE', 'live')}")

    run_asset(args.asset)


if __name__ == "__main__":
    main(sys.argv[1:])
