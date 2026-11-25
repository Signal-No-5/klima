# Issue #5 handoff — backend MVP

Branch: `feat/5-backend-mvp` (T3) → `integ/backend-mvp` (T2). Stacked on
`feat/4-central-schema`; integrate #4 first.

## Intent

Make the FastAPI backend actually serve the mobile contract. Before this change
the app exposed only `/`, `/health`, `/status`, and `/metrics` — none of the five
endpoints the Flutter client calls existed.

## What landed

Endpoints, all typed with `klima-schema` models:

| Endpoint | Backed by |
| --- | --- |
| `GET /hazard/latest` | silver `hazard_warnings` — live PAGASA |
| `POST /reports`, `GET /reports` | new `citizenreport` SQL table |
| `GET /risk/{barangay_id}`, `GET /risk` | live hazards + seed baselines |
| `GET /safezones` | `backend/data/seed/safe_zones.json` |
| `GET /community/posts` | `backend/data/seed/community_posts.json` |
| `GET /health/ready` | warehouse + seed readiness detail |

Supporting code:

- `app/services/warehouse.py` — read-only, per-request DuckDB access so the API
  can never block a pipeline run.
- `app/services/hazards.py` — silver → `HazardOut` mapping.
- `app/services/risk.py` — the scoring model.
- `app/services/seed.py` — JSON reference data, validated on load.
- `app/models/reports.py` + `app/services/reports.py` — report persistence.

Paths and query parameter names were taken from
`mobile/lib/services/api_service.dart`, not invented.

## Decisions worth reviewing

- **Seed JSON, not Python literals.** Safe zones and community posts have no
  upstream feed. They live in `backend/data/seed/` so an LGU can replace a file
  without a code change, and a malformed file fails tests rather than a request.
  The values were moved off the Flutter mock lists the app already shipped.
- **Address fields stay empty for official hazards.** PAGASA publishes per region;
  writing a province list into `province` would be a guess. Coverage lives in
  `metadata`. See `docs/backend/hazard-mapping.md`.
- **Nationwide advisories match every place query.** `Tropical Cyclone Alert` is
  scoped to `Philippine Area of Responsibility`; without this rule a live cyclone
  alert was invisible to every filtered query.
- **Expired advisories are hidden by default.** The feed therefore empties when
  nothing is active. `/health/ready` distinguishes that from an unbuilt
  warehouse, and `include_expired=true` returns history.
- **Server mints report ids.** Mobile submits `id: ""` for offline-queued reports.
- **422 on unknown fields.** Inherited from the strict contract in #4. Silent
  coercion is how client and server drift apart.

## Verified

```bash
cd backend
uv sync --extra test
uv run ruff check --no-fix app tests ../schema/klima_schema   # clean
uv run python -m pytest -q                                    # 53 passed
uv run python -m uvicorn app.main:app                         # boots
```

Probed against the live warehouse (9 real PAGASA advisories, Typhoon KIYAPO):

- `/health/ready` → `ok`, 9 active advisories, 4 safe zones, 24 baselines.
- `/hazard/latest` → 9 items, severities `high`/`critical` from real buckets.
- `/risk/calumpit-iba-este` → `high` (0.63) from the live nationwide cyclone
  alert; `flood` correctly absent because PAGASA excluded Bulacan from the flood
  advisory areas.
- `POST /reports` → `201`, id minted; `GET /reports` lists it; unknown field
  `422`; unknown barangay `404`.

## Note on the run command

Use `uv run python -m uvicorn`, not `uv run uvicorn`. A `uvicorn` binary earlier
on `PATH` (system or `~/.local/bin`) is executed against the wrong interpreter
and dies with `ModuleNotFoundError: prometheus_fastapi_instrumentator`. The
README previously suggested the broken form; it now documents the working one.

## Known gaps left open

- Reports are unauthenticated; anyone who can reach the API can post one.
- `RiskOut.safe_residents` is always `0` — no safe check-in feed exists.
- Citizen reports do not feed `hazard_score`; only official advisories count.
- Exposure and vulnerability scores are hand-assigned tiers, not census data.
- `app/api/v1/` remains empty; the README still describes an aspirational tree
  (`endpoints/klima.py`, `messenger.py`) that does not exist. Left alone to keep
  this diff reviewable.
