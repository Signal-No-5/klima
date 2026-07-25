# Klima

Hackathon weather-resilience platform: citizen reporting (Flutter), backend API (FastAPI), LGU dashboard / docs, and ETL under `data/`.

This repository is a **single flat monorepo**.

## Layout

| Path | Role | Status |
|------|------|--------|
| `mobile/` | Flutter citizen/responder app | Present (hackathon MVP) |
| `backend/` | FastAPI backend (reads DuckDB bronze) | Present |
| `data/` | Canonical ETL (`klima-data`) + DuckDB warehouse | Present — bronze ingest runnable (#8) |
| `frontend/` | LGU web dashboard | **Scaffold / stub** |
| `docs/` | VitePress docs + MVP handoffs | Present (scaffold content) |
| `schema/` | Central contracts | **Planned** (#4) |

See [`STATUS.md`](./STATUS.md) for present vs stub vs promised.

## Notes

- Historical split repos under `Signal-No-5/*` remain for reference; **this repo is the source of truth**.
- ETL lives in `data/pipeline`. Run: `cd data && uv sync && .venv/bin/python -m pipeline pagasa_warnings --offline`.
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

## Quick start (ETL)

```bash
cd data
uv sync
.venv/bin/python -m pipeline pagasa_warnings --offline
```

## MVP

See [`docs/mvp/README.md`](./docs/mvp/README.md) and epic [#2](https://github.com/Signal-No-5/klima/issues/2).
