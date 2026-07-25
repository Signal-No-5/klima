# Klima

Hackathon weather-resilience platform: citizen reporting (Flutter), backend API + bronze pipeline (FastAPI), LGU dashboard / docs / data packaging.

This repository is a **single flat monorepo**.

## Layout

| Path | Role | Status |
|------|------|--------|
| `mobile/` | Flutter citizen/responder app | Present (hackathon MVP) |
| `backend/` | FastAPI backend + DuckDB pipeline | Present |
| `backend/pipeline/` | ETL assets (e.g. PAGASA bronze) | Present — **canonical ETL** until #8 moves it to `data/` |
| `frontend/` | LGU web dashboard | **Scaffold / stub** |
| `docs/` | VitePress docs + MVP handoffs | Present (scaffold content) |
| `data/` | Pointer package for ETL | **Scaffold / stub** (#8) |
| `schema/` | Central contracts (`klima_schema`) | Present (#4) — see [`schema/README.md`](./schema/README.md) |

See [`STATUS.md`](./STATUS.md) for present vs stub vs promised.

## Notes

- Historical split repos under `Signal-No-5/*` remain for reference; **this repo is the source of truth**.
- ETL currently lives in `backend/pipeline`. Run via `backend/scripts/run_pipeline.py`.
- Mobile talks to root-level API paths (`/hazard/latest`, `/reports`, …) on `backend`.

## Quick start (API)

```bash
cd backend
uv sync
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

```bash
cd backend
# Prefer the repo venv if `uv run` resolves the wrong interpreter:
.venv/bin/python -m pytest tests/test_klima_endpoints.py -q
```

## Schema contracts

Central MVP models live in [`schema/`](./schema/). Backend re-exports them from `app.schemas.klima`. Field parity for Flutter / frontend: [`docs/mvp/schema-parity.md`](./docs/mvp/schema-parity.md).

```bash
cd schema
../backend/.venv/bin/python -m klima_schema.export --out exported
```

## MVP

See [`docs/mvp/README.md`](./docs/mvp/README.md) and epic [#2](https://github.com/Signal-No-5/klima/issues/2).
