# Klima deployments

One honest deploy path per shippable web surface. Mobile store release stays
under `mobile/.github` (link only — not part of this contract).

| Surface | Path | Primary host | Config SoT |
|---------|------|--------------|------------|
| Backend (FastAPI) | `backend/` | **Fly.io** (container) | `backend/Dockerfile`, `backend/fly.toml` |
| Frontend (Next.js) | `frontend/` | **Vercel** | `frontend/vercel.json` |
| Docs (VitePress) | `docs/` | **Vercel** (static) | `docs/vercel.json` |
| Local stack | repo root | Docker Compose | `docker-compose.yml` |

Also see the VitePress page [`/deploy`](../docs/deploy.md) once the docs site is built.

## How Vercel resolves config (monorepo lesson)

Vercel loads **exactly one** `vercel.json` per project: the file at that
project's dashboard **Root Directory**. It does **not** merge a root
`vercel.json` with a nested one.

- Create **separate** Vercel projects for `frontend` and `docs`.
- Set Root Directory to `frontend` or `docs` respectively so the matching
  `vercel.json` is the only config loaded.
- Do **not** put legacy `builds` / `routes` blocks in `vercel.json` — they
  disable zero-config install/build.
- Klima packages are standalone (not a pnpm workspace), so leave
  "Include source files outside of the Root Directory" **off** unless you
  later introduce shared packages.

## Backend is not on Vercel

The old `backend/vercel.json` used `@vercel/python` with `builds`/`routes`.
That path is **removed**. FastAPI runs as a long-lived ASGI process
(`uvicorn app.main:app`); there is no serverless handler. Primary production
target is **Fly** (or any container host). Local/dev: Compose.

## Verify locally

```bash
# Compose file parse
docker compose config

# Backend image
docker compose build backend

# Docs static build
cd docs && pnpm install && pnpm docs:build

# Frontend production build
cd frontend && pnpm install && pnpm build

# Fly config parse (no deploy)
fly config validate -c backend/fly.toml
```

## Promote path

1. Merge to the integration branch (`feat/mvp-flatten` → `main` when ready).
2. **Backend:** `fly deploy` from `backend/` (after app + secrets exist).
3. **Frontend / docs:** Vercel Git integration builds on push when Root
   Directory + project link are set (dashboard one-time).
4. CI at `.github/workflows/` builds the changed package on path filters;
   it does **not** push production deploys until secrets/hosts are wired.

## Dashboard-only follow-ups

These cannot be completed by repo files alone:

### Fly (`klima-api`)

1. `fly apps create klima-api --org <Signal-or-personal-org>`
2. `fly secrets set SECRET_KEY=… JWT_SECRET_KEY=…` (and Postgres vars if used)
3. First deploy: `fly deploy --config backend/fly.toml --dockerfile backend/Dockerfile`
4. Optional: attach a volume and set `SQLITE_FILE=/data/klima.db`, or switch to Postgres

### Vercel — frontend (`klima` or `klima-frontend`)

1. Import `Signal-No-5/klima`
2. Root Directory → `frontend`
3. Framework / install / build come from `frontend/vercel.json`
4. Env: `NEXT_PUBLIC_KLIMA_API_URL` = Fly URL (the name the dashboard code reads)
5. Enable "Skip deployments when no changes to Root Directory" if available

### Vercel — docs (`klima-docs`)

1. Separate project from the same repo
2. Root Directory → `docs`
3. Output `.vitepress/dist` via `docs/vercel.json`
4. No runtime secrets required

### GitHub

1. Ensure Actions can run on this repo
2. Optional later: add deploy secrets (`FLY_API_TOKEN`, Vercel tokens) for CD

## Env / secrets matrix

See [`deploy/.env.example`](./.env.example) and `backend/.env.example`.
Nothing sensitive belongs in `vercel.json` or `fly.toml` `[env]`.

## Mobile

Workflows remain under `mobile/.github/workflows/`. Store release automation is
out of scope for #9.
