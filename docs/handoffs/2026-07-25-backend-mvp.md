# HANDOFF — Backend MVP (#5)

**Status:** Done (verified locally)  
**Branch:** `feat/mvp-backend-5`  
**Issue(s):** #5  
**Last updated:** 2026-07-25

## Bottom line
Backend boots with `uv`, `/health` + `/metrics` live, mobile contract endpoints are schema-backed (`klima_schema` via `app.schemas.klima`), contract tests green. Hazards read `backend/data/bronze.duckdb` when present; otherwise fixtures. Reports are in-memory for MVP demos.

## Current state
- FastAPI app under `backend/` (flat layout; no `web/api`)
- Routes: `/hazard/latest`, `/reports`, `/risk/{id}`, `/safezones`, `/community/posts` (+ `/api/v1` mirrors)
- `/health` returns `{status, service, bronze_db}`; Prometheus at `/metrics`
- Models: thin re-export from central `schema/klima_schema` (no duplicated Pydantic defs)
- Tests: `tests/test_klima_endpoints.py`, `tests/test_schema_source.py`
- ETL still beside API in `backend/pipeline` (#8 moves home to `data/`)

## Hook points
- `backend/app/main.py`, routes, services
- schema package integration (#4) — done
- data paths for DuckDB (#8)

## How to verify
```bash
cd backend
uv sync
# Prefer venv python if `uv run pytest` hits ModuleNotFoundError:
.venv/bin/python -m pytest -q
.venv/bin/python -c "from app.main import app; print('ok')"
.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
# elsewhere:
curl -s localhost:8000/health
curl -s localhost:8000/hazard/latest | head
```

## Done means
- [x] Documented quickstart works on clean checkout (`uv sync` + uvicorn)
- [x] Contract tests green (schema-validated responses)
- [x] Health endpoint live; metrics exposed
- [x] Endpoints: hazard, reports, risk, safezones, community, health

## Deliberately not built
- Persistent report store (in-memory only)
- Live geospatial risk model (fixture scores)
- Safe-zone / community CMS persistence
- Auth / LGU RBAC
- Moving DuckDB/ETL ownership to top-level `data/` (#8)
