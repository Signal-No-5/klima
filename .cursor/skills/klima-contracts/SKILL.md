---
name: klima-contracts
description: >-
  Rules for the central klima-schema package. Use when adding or changing any
  field that crosses the wire between backend, mobile, or the dashboard, or when
  a client reports a field mismatch.
---

# Klima Contracts

`schema/klima_schema/models.py` is the single source of truth for every wire
model. Nothing else may define one.

## Where things live

| Path | Role |
| --- | --- |
| `schema/klima_schema/models.py` | the only place models are defined |
| `schema/klima_schema/export.py` | generates JSON Schema |
| `schema/exported/*.schema.json` | committed output for non-Python consumers |
| `backend/app/schemas/klima.py` | re-export facade — never a second copy |
| `docs/backend/schema-parity.md` | field parity against the Flutter models |

The backend resolves `klima-schema` as an editable path dependency
(`[tool.uv.sources]` in `backend/pyproject.toml`).

## Changing a field

1. Edit `schema/klima_schema/models.py`.
2. Re-export and confirm the diff is intentional:
   `cd backend && uv run python -m klima_schema.export --out ../schema/exported`
3. Check the Flutter model in `mobile/lib/models/` and update
   `docs/backend/schema-parity.md`.
4. Run `uv run python -m pytest -q` in `backend/`.

Backend CI triggers on `schema/**`, lints the package, and fails when the
committed exports no longer match the models. Export output is byte-stable, so a
diff means a real change.

## Conventions that are load-bearing

- **JSON is snake_case.** The Flutter serializers already read snake_case; do not
  add camelCase aliases.
- **Coordinates are flat** (`latitude`, `longitude`), because mobile converts them
  to `LatLng` itself. Do not nest them.
- **`extra="forbid"` on every model.** Unknown fields must 422. Silent tolerance
  is exactly how the backend and mobile drifted apart before this package existed.
- **Range-validate anything physical.** Latitude, longitude, and scores in
  `[0, 1]`. A coordinate of `999` should fail at the edge, not on a map.
- **Enums for closed sets** (report type/status, risk level); **plain strings for
  open sets** (hazard `type`, `severity`). PAGASA product names are open-ended —
  a new product must degrade gracefully, not 500 the feed.
- **Datetimes are timezone-aware ISO-8601.** Naive timestamps sort inconsistently
  against live data.

## Before adding a field, ask

- Does a client actually read it? Check `mobile/lib/models/` and
  `mobile/lib/services/api_service.dart`.
- Can the backend populate it honestly today? If not, leave it out or default it
  and document the gap — do not ship a field that is always empty without saying so.
- Is it derivable from an existing field? If yes, compute it client-side.
