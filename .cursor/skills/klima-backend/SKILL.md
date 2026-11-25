---
name: klima-backend
description: >-
  FastAPI conventions for Klima backend/. Use when adding or changing endpoints,
  services, warehouse reads, or backend tests. Encodes the layout that actually
  exists, not the aspirational tree in backend/README.md.
---

# Klima Backend

## Reality of `backend/`

```text
app/
  main.py       FastAPI entrypoint; routers registered here
  routes/       HTTP layer — one module per resource
  services/     business logic; where the real work goes
  models/       SQLModel tables (storage shape)
  schemas/      re-export facade over klima_schema (no model definitions)
  core/         config, prefs, Database manager
  middleware/   audit trail
pipeline/       bronze/silver DuckDB ETL — the API only reads from it
data/
  *.duckdb      warehouse, built by the pipeline
  seed/         JSON reference data with no upstream feed
tests/
```

`app/api/v1/` is empty and `backend/README.md` still describes modules that do
not exist (`endpoints/klima.py`, `messenger.py`). Add routers to `app/routes/`
and register them in `app/main.py`. Do not build out `api/v1/` to match the
README unless asked.

## Rules

1. **Never define a wire model in `backend/`.** All request/response models come
   from the `klima-schema` package; `app/schemas/klima.py` is a re-export facade.
   See the `klima-contracts` skill.
2. **Routes stay thin.** Parse and validate in `routes/`, decide in `services/`.
   A route that reads DuckDB or computes a score directly is misplaced.
3. **The API never writes to the warehouse.** `pipeline/` owns it. Read through
   `app/services/warehouse.py`, which opens read-only and per-request so a long
   lived connection cannot block a pipeline run.
4. **Missing warehouse degrades, it does not 500.** Return `[]` and let
   `/health/ready` explain why. A hazard feed that errors during a typhoon is
   worse than an empty one.
5. **Reference data with no feed goes in `data/seed/*.json`**, validated against
   the contract on load — not Python literals. An LGU must be able to replace a
   file without a code change.
6. **Do not invent location data.** PAGASA publishes per region; if a field
   cannot be derived, leave it empty and carry the real scope in `metadata`.
   See `docs/backend/hazard-mapping.md`.
7. **New SQLModel tables must be imported in `app/core/config.py`** before
   `db_manager.create_all()` runs, or the table is silently never created.
8. **Match endpoint paths to the real consumer.** Query
   `mobile/lib/services/api_service.dart` before naming a route; the contract is
   whatever the shipped client calls.

## Run and test

```bash
cd backend
uv sync --extra test
uv run python -m uvicorn app.main:app --reload
uv run ruff check --no-fix app tests ../schema/klima_schema
uv run python -m pytest -q
```

Use `python -m uvicorn`. `uv run uvicorn` picks up any `uvicorn` binary earlier
on `PATH` (system or `~/.local/bin`) and runs it against the wrong interpreter,
failing with an unrelated `ModuleNotFoundError`.

For a populated hazard feed, build the warehouse first:

```bash
uv run python -m pipeline run
curl -s localhost:8000/health/ready
```

## Test conventions

- Endpoint tests belong in `tests/test_klima_endpoints.py`, grouped per resource.
- **Never test against `backend/data/*.duckdb`.** The `silver_fixture` session
  fixture in `tests/conftest.py` builds a throwaway warehouse and patches
  `pipeline.config.db.SILVER`. Patch that attribute, not `KLIMA_DATA_DIR`, so the
  fixture is independent of module import order.
- Fixture advisories are anchored to run time (`NOW ± timedelta`) so expiry
  filtering is testable without freezing the clock.
- Validate responses through the contract model, not by poking at dict keys —
  that is what catches drift.
- Assert the negative cases: unknown field `422`, unknown resource `404`,
  out-of-range coordinates `422`.

## Verify CI locally

```bash
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
act pull_request -W .github/workflows/ci-backend.yml
```

Podman, not Docker Desktop. The socket must be active
(`systemctl --user is-active podman.socket`).

## Do not

- Add auth, rate limiting, or casbin policies as a side effect of an endpoint PR.
- Claim a data source is live when it is seed JSON — say which is which.
- Touch deployment files, `Dockerfile`, or compose as part of backend feature work.
