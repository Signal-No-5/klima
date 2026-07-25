#!/usr/bin/env python3
"""Compatibility wrapper — canonical ETL lives in the ``klima-data`` package.

Prefer:
  cd ../data && uv sync && .venv/bin/python -m pipeline pagasa_warnings --offline
"""

from __future__ import annotations

import sys


def main() -> None:
    try:
        from pipeline.cli import main as etl_main
    except ImportError as exc:
        raise SystemExit(
            "pipeline package not found. Install klima-data into this env:\n"
            "  cd ../data && uv sync\n"
            "  # or from backend: uv sync (path-depends on ../data)\n"
            f"Import error: {exc}"
        ) from exc

    etl_main(sys.argv[1:])


if __name__ == "__main__":
    main()
