import os
from pathlib import Path

# Warehouse dir: override with KLIMA_DATA_DIR (e.g. a mounted volume in a
# container); otherwise default to backend/data/ next to the API package.
_DEFAULT = Path(__file__).resolve().parents[2] / "data"
DATA_DIR = Path(os.environ.get("KLIMA_DATA_DIR", _DEFAULT))

BRONZE = DATA_DIR / "bronze.duckdb"
SILVER = DATA_DIR / "silver.duckdb"
GOLD = DATA_DIR / "gold.duckdb"
