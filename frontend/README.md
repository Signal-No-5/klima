# `frontend/` — LGU dashboard scaffold

Next.js stub for a future LGU / MDRRMO dashboard.

## Status

**Not implemented yet.** This package exists so the monorepo layout matches the product vision without inventing a fake dashboard.

## Run locally (stub page)

```bash
pnpm install
pnpm dev
```

You should see a single page stating the LGU dashboard is not implemented.

## API contracts (when implementing)

Do not invent parallel TypeScript types for Hazard / Report / Risk / SafeZone / Community.

- **Source of truth:** [`../schema/`](../schema/) (`klima_schema` Pydantic models)
- **Runtime OpenAPI:** `GET {API}/openapi.json` after backend is running
- **JSON Schema export:** `schema/exported/` (regenerate via `python -m klima_schema.export`)
- **Field checklist:** [`../docs/mvp/schema-parity.md`](../docs/mvp/schema-parity.md)
