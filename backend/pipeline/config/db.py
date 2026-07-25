from pathlib import Path

# Warehouse lives next to the API package (backend/data/), not cwd-relative.
DATA_DIR = Path(__file__).resolve().parents[2] / "data"

BRONZE = DATA_DIR / "bronze.duckdb"
SILVER = DATA_DIR / "silver.duckdb"
GOLD = DATA_DIR / "gold.duckdb"
