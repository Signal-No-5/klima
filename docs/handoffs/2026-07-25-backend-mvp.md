# HANDOFF — Backend MVP (#5)

**Status:** Planned  
**Branch:** `feat/mvp-backend`  
**Issue(s):** #5  
**Last updated:** 2026-07-25

## Bottom line
Backend boots, health/metrics live, mobile contract endpoints schema-backed and tested; reads fixtures/bronze via `data/` where applicable.

## Current state
- FastAPI app with mobile contract routes + fixtures (today under `web/api`)
- Tests: `tests/test_klima_endpoints.py`
- ETL still beside API pipeline

## Hook points
- `backend/app/main.py`, routes, services
- schema package integration (#4)
- data paths for DuckDB (#8)

## How to verify
```bash
cd backend
uv sync
uv run uvicorn app.main:app --reload --port 8000
uv run pytest tests/test_klima_endpoints.py -q
curl -s localhost:8000/hazard/latest | head
```

## Done means
- [ ] Documented quickstart works on clean checkout
- [ ] Contract tests green
