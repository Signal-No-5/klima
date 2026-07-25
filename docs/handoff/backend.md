# Backend handoff

## Goal

Make the existing FastAPI backend a reliable MVP without touching frontend or
deployment work. Preserve the real PAGASA bronze/silver pipeline and derive API
contracts from real data where applicable.

## Branch contract

Three tiers, each named by prefix:

- **T1:** `main` — maintainers only; agents do not open or merge PRs to it.
- **T2:** `integ/*` — integration branch for a scope. This pass uses
  `integ/backend-mvp`; maintainers promote it to T1.
- **T3:** `feat/*` or `fix/*` — one working branch per ticket. Every agent PR
  targets the T2 branch, never `main`.
- Ticket branches may be stacked when dependencies require it. Merge them into
  T2 in documented order so later PR diffs collapse correctly.
- Agents do not merge commits or PRs.

## Scope

### In scope

- Issue #4: central schema package for hazard, report, safe-zone, community,
  and risk contracts; backend imports; schema export; mobile parity notes.
- Issue #5: runnable FastAPI backend; health/metrics; hazard, reports, risk,
  safe-zones, and community endpoints; tests; read real silver data where
  applicable.
- Backend-specific tests, documentation, and agent skills.
- Local GitHub Actions checks with `act` where feasible.

### Out of scope

- Frontend implementation or design.
- Deployment configuration, hosts, secrets, or workflows that deploy.
- Moving the canonical pipeline from `backend/pipeline/` to sparse `data/`.
- Direct changes, PRs, or merges to `main`.

## Planned order

1. **#4 central schema** — establishes contracts required by #5.
2. **#5 backend MVP** — consumes #4 and exposes tested endpoints.
3. **Backend housekeeping** — documentation/skills and bounded cleanup not
   already owned by #4/#5.

Issue #5 is stacked on #4. Merge #4 into `integ/backend-mvp` before #5; GitHub
will then show #5's remaining delta against T2.

## Verification

```bash
cd backend
uv sync --extra test
uv run ruff check --no-fix app tests
uv run python -m pytest -q
```

Where available:

```bash
act pull_request -W .github/workflows/ci-backend.yml
```

## Stop conditions

Skip only the blocked ticket and continue with independent work when:

- a required external credential or unavailable service prevents verification;
- a destructive migration needs maintainer approval;
- requirements contradict this branch/scope contract.

Record blockers and evidence in this document or the affected PR.
