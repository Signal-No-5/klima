# `frontend/` — LGU dashboard (MVP)

Minimal Next.js LGU / MDRRMO surface that **fetches live** from the Klima backend.

## Status

**MVP live against backend** (issue [#6](https://github.com/Signal-No-5/klima/issues/6)).

| View | Endpoint |
|------|----------|
| Latest hazards | `GET /hazard/latest` |
| Incoming reports | `GET /reports` |
| Barangay risk | `GET /risk/{barangay_id}` (default `iba-este`) |
| Safe zones | `GET /safezones` |

Server Components call the API; when the backend is down, panels show an explicit error — **no fabricated fallback data**.

Still stubbed / out of scope: interactive map, report triage mutations, auth/RBAC, generated OpenAPI TS client.

## Env

| Variable | Default | Purpose |
|----------|---------|---------|
| `NEXT_PUBLIC_KLIMA_API_URL` | `http://127.0.0.1:8000` | Backend base URL (no trailing slash) |

Copy `.env.example` → `.env.local` if you need a non-default host.

## Run locally

```bash
# terminal A — backend on :8000
cd ../backend && # follow backend README / uvicorn as usual

# terminal B
pnpm install
pnpm dev
```

Open http://localhost:3000. With the API up you should see hazard/safe-zone fixtures (and an empty reports panel until `POST /reports`). With the API down, every panel shows an error banner.

## Verify

```bash
pnpm install
pnpm lint          # tsc --noEmit
pnpm typecheck
pnpm build
```

## API contracts

Do not invent parallel TypeScript shapes.

- **Source of truth:** [`../schema/`](../schema/) (`klima_schema` Pydantic models)
- **Hand-mirrored types:** `lib/types.ts` ← `schema/exported/*.schema.json`
- **Paths:** `backend/app/api/v1/endpoints/klima.py` (also mounted at root)
- **Runtime OpenAPI:** `GET {API}/openapi.json` after backend is running
- **Field checklist:** [`../docs/mvp/schema-parity.md`](../docs/mvp/schema-parity.md)
