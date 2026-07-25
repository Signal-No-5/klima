# `docs/` — VitePress site

MVP documentation for Klima: getting started, monorepo layout, API overview, and schema honesty notes.

## Run locally

```bash
pnpm install
pnpm docs:dev
```

## Build

```bash
pnpm docs:build
```

## Content map

| Path | In main nav? |
|------|----------------|
| `index.md`, `getting-started.md`, `layout.md` | Yes |
| `guide/*.md` | Yes (sidebar) |
| `api/overview.md`, `schema.md` | Yes |
| `mvp/`, `handoffs/` | In-repo only (`srcExclude`; not in site build) |

## Status

- Present: VitePress build with layout, quickstarts, API surface from real routes, deploy page.
- Thin / deferred: operator runbooks, generated OpenAPI embed (link out to running `/docs` instead).

## Deploy

Production docs target: Vercel with Root Directory `docs` (see `vercel.json`).
Operator SoT in-repo: `deploy/README.md` — summary on this site: [Deployments](/deploy).
