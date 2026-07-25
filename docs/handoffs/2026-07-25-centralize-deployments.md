# HANDOFF — Centralize deployments (#9)

**Status:** Implemented (repo-side)  
**Branch:** `feat/mvp-deploy-9` (stacks on `feat/mvp-flatten`)  
**Issue(s):** #9  
**Last updated:** 2026-07-25

## Bottom line

One documented deploy SoT: **Fly** for FastAPI, **Vercel** for Next.js +
VitePress, **Compose** for local backend. Legacy `backend/vercel.json`
(`builds`/`routes`) removed — no invented serverless API path.

## Current state

- `backend/Dockerfile` + `backend/fly.toml` + `.dockerignore`
- `frontend/vercel.json`, `docs/vercel.json` (zero-config; no `builds`/`routes`)
- Root `docker-compose.yml`, `deploy/README.md`, `deploy/.env.example`
- Path-filtered CI: `.github/workflows/ci-{backend,frontend,docs,compose}.yml`
- Docs page: `docs/deploy.md`
- Fly/Vercel projects **not** created under Signal — dashboard follow-ups listed

## Hook points

- `deploy/README.md` (operator SoT)
- `docker-compose.yml`
- `.github/workflows/ci-*.yml`
- Per-app platform configs next to each package

## How to verify

```bash
docker compose config
docker compose build backend
fly config validate -c backend/fly.toml
cd docs && pnpm install && pnpm docs:build
cd frontend && pnpm install && pnpm build
```

## Done means

- [x] Single documented primary deploy path per surface
- [x] CI builds the right package on path change
- [x] Env/secrets matrix at `deploy/.env.example` (no secrets committed)
- [ ] Fly app + secrets + first deploy (dashboard/CLI)
- [ ] Vercel projects + Root Directory for frontend/docs (dashboard)

## Dashboard-only leftovers

1. `fly apps create klima-api` + secrets + `fly deploy`
2. Vercel projects with Root Directory `frontend` / `docs`
3. Optional CD tokens in GitHub Actions
