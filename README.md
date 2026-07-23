# Klima

Hackathon weather-resilience platform: citizen reporting (Flutter), backend API + bronze pipeline (FastAPI), and honest stubs for LGU dashboard / docs / data packaging.

This repository is a **single monorepo**. Packages live in-tree (not git submodules).

## Layout

| Path | Role | Status |
|------|------|--------|
| `mobile/` | Flutter citizen/responder app | Present (hackathon MVP) |
| `web/api/` | FastAPI backend + DuckDB pipeline | Present |
| `web/api/pipeline/` | ETL assets (e.g. PAGASA bronze) | Present — **canonical ETL** |
| `web/dashboard/` | LGU web dashboard | **Scaffold / stub** |
| `web/docs/` | VitePress docs site | **Scaffold / stub** |
| `data/` | Pointer package for ETL (no duplicated pipeline) | **Scaffold / stub** |

See [`STATUS.md`](./STATUS.md) for present vs stub vs promised.

## Notes

- Historical split repos under `Signal-No-5/*` remain for reference; **this repo is the source of truth**.
- ETL lives in `web/api/pipeline` (not under `data/`). Run via `web/api/scripts/run_pipeline.py`.
- Mobile talks to root-level API paths (`/hazard/latest`, `/reports`, …) on `web/api`.

## Quick start (API)

```bash
cd web/api
uv sync
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

```bash
cd web/api
uv run pytest tests/test_klima_endpoints.py -q
```
