# Docs site quickstart

This VitePress site lives in `docs/`.

From `docs/package.json`:

- Package manager: `pnpm@9.15.0`
- Scripts: `docs:dev`, `docs:build`, `docs:preview`

## Install and develop

```bash
cd docs
pnpm install
pnpm docs:dev
```

## Build

```bash
cd docs
pnpm docs:build
```

Output goes to `docs/.vitepress/dist` (gitignored).

## Planning markdown

`docs/mvp/` and `docs/handoffs/` stay in the git tree for agents and humans, but are **excluded from the VitePress build** (`srcExclude` in `.vitepress/config.mts`) so product docs stay focused and handoff templates do not break the Vue markdown pipeline.
