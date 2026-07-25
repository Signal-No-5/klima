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

## Deploy

Production target: **Vercel**. Set the project Root Directory to `frontend` so
`vercel.json` is the only config loaded. Env: `NEXT_PUBLIC_API_URL` (see
`.env.example`). Full contract: [`../deploy/README.md`](../deploy/README.md).
