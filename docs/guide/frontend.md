# Frontend quickstart

`frontend/` is a **Next.js stub**, not a working LGU dashboard.

From `frontend/package.json`:

- Package manager: `pnpm@9.15.0`
- Scripts: `dev` → `next dev`, `build` → `next build`, `start` → `next start`
- Stack: Next `^15.1.0`, React `^19.0.0`

## Run the stub

```bash
cd frontend
pnpm install
pnpm dev
```

You should see a single page stating the LGU dashboard is not implemented. There are no live risk-map, report-triage, or occupancy workflows in this package.

## Status

Do not document or assume dashboard APIs beyond what `backend/` exposes today. When the frontend grows, it should consume the same OpenAPI models as mobile (see [Schema](/schema)).

## Related

- [Backend quickstart](/guide/backend)
- [API overview](/api/overview)
