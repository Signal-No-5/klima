# HANDOFF — Frontend LGU dashboard (#6)

**Status:** Implemented (MVP) — verified `pnpm lint` / `typecheck` / `build`  
**Branch:** `feat/mvp-frontend-6`  
**Issue(s):** #6  
**Last updated:** 2026-07-25

## Bottom line
Minimal Next.js LGU UI: hazards, pending reports, barangay risk, safe zones — **live** against backend (not stub-only).

## Current state
- Dashboard under `frontend/` (App Router)
- API client: `frontend/lib/api.ts` → `NEXT_PUBLIC_KLIMA_API_URL` (default `http://127.0.0.1:8000`)
- Types hand-mirrored from `schema/exported/*.schema.json` in `frontend/lib/types.ts`
- Server Components fetch; unreachable backend → explicit error banners (no fake data)

## Hook points
- `frontend/app/`, `frontend/components/`, `frontend/lib/api.ts`
- Env: `NEXT_PUBLIC_KLIMA_API_URL` (see `frontend/.env.example`)

## How to verify
```bash
# backend on :8000
cd frontend && pnpm i && pnpm dev
# open UI; panels call /hazard/latest, /reports, /risk/iba-este, /safezones
# stop backend → error states (not fabricated lists)
```

Verified offline (2026-07-25, worktree):
```bash
cd frontend && pnpm install   # ok
pnpm lint                     # tsc --noEmit → exit 0
pnpm typecheck                # exit 0
pnpm build                    # Next.js 15.5.21 → exit 0; route `/` dynamic
```

## Done means
- [x] ≥3 live views (hazards, reports, risk, safe zones)
- [x] Empty/error states
- [x] Env documented in README/docs

## Remaining gaps
- No interactive map / triage mutations / auth
- Browser Network tab shows server-side fetches only (RSC); not client XHR
- Backend has no CORS middleware — client-side direct browser calls would need CORS or a proxy
- Reports list is empty until something `POST`s `/reports` (in-memory store)
- TS types are hand-mirrored, not codegen from OpenAPI
