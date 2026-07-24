# HANDOFF — Frontend LGU dashboard (#6)

**Status:** Planned  
**Branch:** `feat/mvp-frontend`  
**Issue(s):** #6  
**Last updated:** 2026-07-25

## Bottom line
Minimal Next.js LGU UI: hazards, pending reports, safe zones — **live** against backend (not stub-only).

## Current state
- Next stub page under `web/dashboard` (→ `frontend/`)
- No real API client

## Hook points
- `frontend/app/`, components, `lib/api.ts`
- Env: `NEXT_PUBLIC_KLIMA_API_URL`

## How to verify
```bash
# backend on :8000
cd frontend && pnpm i && pnpm dev
# open UI; network tab shows API calls
```

## Done means
- [ ] ≥3 live views
- [ ] Empty/error states
- [ ] Env documented in README/docs
