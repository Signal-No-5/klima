# Klima

Hackathon weather-resilience platform: citizen reporting (Flutter), backend API (FastAPI), LGU dashboard / docs, and ETL under `data/`.

This repository is a **single flat monorepo**.

## Layout

| Path | Role | Status |
|------|------|--------|
| `mobile/` | Flutter citizen/responder app | Present (hackathon MVP) |
| `backend/` | FastAPI backend (reads DuckDB bronze) | Present |
| `data/` | Canonical ETL (`klima-data`) + DuckDB warehouse | Present — bronze ingest runnable (#8) |
| `frontend/` | LGU web dashboard | Present (MVP #6) — live API views |
| `docs/` | VitePress docs + MVP handoffs | Present (MVP getting-started / layout / API) |
| `schema/` | Central contracts (`klima_schema`) | Present (#4) — see [`schema/README.md`](./schema/README.md) |

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
# Prefer the repo venv if `uv run` resolves the wrong interpreter:
.venv/bin/python -m pytest tests/test_klima_endpoints.py -q
```

## Quick start (LGU dashboard)

```bash
# backend on :8000 first, then:
cd frontend
pnpm install
pnpm dev
```

Set `NEXT_PUBLIC_KLIMA_API_URL` (default `http://127.0.0.1:8000`). See [`frontend/README.md`](./frontend/README.md).

## Schema contracts

Central MVP models live in [`schema/`](./schema/). Backend re-exports them from `app.schemas.klima`. Field parity for Flutter / frontend: [`docs/mvp/schema-parity.md`](./docs/mvp/schema-parity.md).

```bash
cd schema
../backend/.venv/bin/python -m klima_schema.export --out exported
```

## Quick start (ETL)

```bash
cd data
uv sync
.venv/bin/python -m pipeline pagasa_warnings --offline
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
