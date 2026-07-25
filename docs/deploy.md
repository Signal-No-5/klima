# Deployments

Primary deploy contract for Klima web surfaces. Full detail:
[`deploy/README.md`](https://github.com/Signal-No-5/klima/blob/HEAD/deploy/README.md)
in this monorepo.

## Targets

| Surface | Host | Notes |
|---------|------|-------|
| `backend/` FastAPI | Fly.io container | `Dockerfile` + `fly.toml` — **not** Vercel |
| `frontend/` Next.js | Vercel | Root Directory `frontend` |
| `docs/` VitePress | Vercel (static) | Root Directory `docs` |
| Local | `docker compose` | Backend always; `frontend`/`docs` via `--profile web` |

## Quick verify

```bash
docker compose config
docker compose build backend
cd docs && pnpm install && pnpm docs:build
```

## Secrets

Set via Fly secrets / Vercel project env. Matrix: `deploy/.env.example`.
Never commit real values.
