"""Materialize bronze assets into backend/data/bronze.duckdb."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import duckdb

from pipeline.config import db
from pipeline.refinery.bronze.pagasa_warnings import pagasa_warnings


def _ensure_dirs() -> None:
    db.DATA_DIR.mkdir(parents=True, exist_ok=True)


def _reset_bronze() -> None:
    path = Path(db.BRONZE)
    if path.exists():
        path.unlink()
    duckdb.connect(str(path)).close()
    print(f"Reset {path}")


def _summarize() -> None:
    with duckdb.connect(str(db.BRONZE), read_only=True) as con:
        tables = [row[0] for row in con.execute("SHOW TABLES").fetchall()]
        print(f"\nWarehouse: {Path(db.BRONZE).resolve()}")
        print(f"Tables: {tables or '(none)'}")
        for table in tables:
            rows = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            print(f"\n{table}: {rows} row(s)")
            print(
                con.execute(
                    f"""
                    SELECT hazard,
                           length(payload::VARCHAR) AS payload_bytes,
                           inserted_at,
                           substr(source_id, 1, 12) AS source_id_prefix
                    FROM {table}
                    ORDER BY inserted_at DESC, hazard
                    """
                )
                .fetchdf()
                .to_string(index=False)
            )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete bronze.duckdb before ingest (fresh snapshot).",
    )
    parser.add_argument(
        "--summary-only",
        action="store_true",
        help="Only print current bronze contents; do not fetch.",
    )
    args = parser.parse_args()

    _ensure_dirs()

    if args.summary_only:
        _summarize()
        return

    if args.reset:
        _reset_bronze()

    print("Running bronze asset: pagasa_warnings")
    pagasa_warnings()
    _summarize()


if __name__ == "__main__":
    main()
