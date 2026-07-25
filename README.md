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
| `schema/` | Central contracts | **Planned** (#4) |

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
uv run pytest tests/test_klima_endpoints.py -q
```

## Deploy

| Surface | Primary host | Config |
|---------|--------------|--------|
| Backend | Fly.io | `backend/Dockerfile`, `backend/fly.toml` |
| Frontend | Vercel | `frontend/vercel.json` (Root Directory `frontend`) |
| Docs | Vercel | `docs/vercel.json` (Root Directory `docs`) |
| Local API | Compose | `docker compose up --build backend` |

Full contract: [`deploy/README.md`](./deploy/README.md). Vercel loads **one**
`vercel.json` per project Root Directory (no root+nested merge). Backend is
**not** on Vercel — the legacy Python `builds`/`routes` config was removed.

## MVP

See [`docs/mvp/README.md`](./docs/mvp/README.md) and epic [#2](https://github.com/Signal-No-5/klima/issues/2).
