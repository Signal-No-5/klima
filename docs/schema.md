# Schema / contracts

## Current branch (`feat/mvp-flatten` lineage)

There is **no** top-level `schema/` package in this tree yet. Wire contracts for the mobile API live in:

```text
backend/app/schemas/klima.py
```

Pydantic models used by FastAPI handlers:

| Model | Role |
|-------|------|
| `HazardOut` | Hazard feed items |
| `ReportCreate` | Create-report body |
| `ReportOut` | Report responses |
| `RiskOut` | Per-barangay risk payload |
| `SafeZoneOut` | Evacuation / safe-zone list items |
| `CommunityPostOut` | Community feed posts |

OpenAPI components for these appear at `GET /openapi.json` when the API is running (see [API overview](/api/overview)).

Mobile keeps **parallel Dart models** under `mobile/lib/models/` — they are not generated from the Python package on this branch.

## Planned central package (#4)

Epic workstream [#4](https://github.com/Signal-No-5/klima/issues/4) introduces `schema/klima_schema` as the shared SoT, with backend re-exports and optional JSON Schema export. Until that lands on the branch you are building against:

- Edit / read `backend/app/schemas/klima.py`
- Do not assume `import klima_schema` works in this checkout
- Do not document a second invented contract surface

Handoff notes (in-repo, not in the site build): [`docs/handoffs/2026-07-25-central-schema.md`](https://github.com/Signal-No-5/klima/blob/feat/mvp-docs-7/docs/handoffs/2026-07-25-central-schema.md).

## Related

- [API overview](/api/overview)
- [Backend quickstart](/guide/backend)
