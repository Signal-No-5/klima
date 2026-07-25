# Backend quickstart

FastAPI service in `backend/`. It reads the DuckDB warehouse that the [`data/` package](/guide/data) owns.

Package: `backend/pyproject.toml` (`name = "api"`, Python `>=3.12`). Dependencies locked via `uv.lock`.

## Install

```bash
cd backend
uv sync
```

Optional: copy `backend/.env.example` → `.env` and adjust. Default local dialect in the example is SQLite (`DB_DIALECT=sqlite`).

## Run the API

Script equivalent (from `backend/`):

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Entrypoint: `app.main:app` (`backend/app/main.py`).

Smoke checks:

| URL | Purpose |
|-----|---------|
| `GET /` | Liveness message |
| `GET /health` | `{"status":"ok"}` |
| `http://localhost:8000/docs` | Swagger UI |
| `http://localhost:8000/openapi.json` | OpenAPI JSON |
| `GET /metrics` | Prometheus metrics (instrumentator) |

## Tests (mobile contract)

```bash
cd backend
uv run pytest tests/test_klima_endpoints.py -q
```

## Pipeline (PAGASA bronze)

Canonical ETL lives in the `data/` package (#8). `backend/scripts/run_pipeline.py` is a thin wrapper kept for convenience.

```bash
cd data
.venv/bin/python -m pipeline pagasa_warnings --offline
```

Known asset today: `pagasa_warnings` → `pipeline.refinery.bronze.pagasa_warnings`.

DuckDB files (when produced) are expected under `backend/data/`:

```text
data/warehouse/bronze.duckdb
data/warehouse/silver.duckdb
data/warehouse/gold.duckdb
```

## What is implemented vs not

**Present:** root health routes, audit middleware, Prometheus `/metrics`, mobile contract endpoints (see [API overview](/api/overview)), PAGASA bronze asset.

**Not built here:** Messenger / Telegram / Viber channel endpoints, full Keycloak/Auth0 multi-tenant RBAC, full silver/gold orchestration schedules.

## Related

- [API overview](/api/overview)
- [Schema / contracts](/schema)
- [Data / ETL](/guide/data)
