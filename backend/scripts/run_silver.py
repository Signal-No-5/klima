"""Materialize silver assets into backend/data/silver.duckdb.

Reads from bronze; run ``scripts/run_bronze.py`` first for fresh inputs.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import duckdb

from pipeline.config import db
from pipeline.refinery.silver.hazard_warnings import hazard_warnings


def _reset_silver() -> None:
    path = Path(db.SILVER)
    if path.exists():
        path.unlink()
    duckdb.connect(str(path)).close()
    print(f"Reset {path}")


def _summarize() -> None:
    with duckdb.connect(str(db.SILVER), read_only=True) as con:
        tables = [row[0] for row in con.execute("SHOW TABLES").fetchall()]
        print(f"\nWarehouse: {Path(db.SILVER).resolve()}")
        print(f"Tables: {tables or '(none)'}")
        if "hazard_warnings" in tables:
            rows = con.execute("SELECT COUNT(*) FROM hazard_warnings").fetchone()[0]
            print(f"\nhazard_warnings: {rows} row(s)")
            print(
                con.execute(
                    """
                    SELECT hazard,
                           severity_label,
                           region,
                           issued_at,
                           centroid_lat,
                           centroid_lon
                    FROM hazard_warnings
                    ORDER BY severity_rank DESC NULLS LAST, hazard, region
                    LIMIT 25
                    """
                )
                .fetchdf()
                .to_string(index=False)
            )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reset", action="store_true", help="Drop silver first.")
    parser.add_argument(
        "--summary-only",
        action="store_true",
        help="Only print current silver contents.",
    )
    args = parser.parse_args()

    db.DATA_DIR.mkdir(parents=True, exist_ok=True)

    if args.summary_only:
        _summarize()
        return

    if args.reset:
        _reset_silver()

    print("Running silver asset: hazard_warnings")
    hazard_warnings()
    _summarize()


if __name__ == "__main__":
    main()
