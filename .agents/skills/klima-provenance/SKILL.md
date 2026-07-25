---
name: klima-provenance
description: >-
  Guardrails for Klima monorepo provenance. Use when adding packages, moving
  ETL, touching frontend/data/docs scaffolds, rewriting history, or deciding
  whether a directory may be invented versus imported from a source repo.
---

# Klima Provenance Guardrails

## Source of truth

| Prefix | Comes from | Inventing content allowed? |
|--------|------------|----------------------------|
| `backend/` | `klima-api` | Only real API/pipeline work |
| `mobile/` | `klima-mobile` | Only real Flutter work |
| `frontend/` | `klima-lgu-dashboard` | **No** until that repo has real code |
| `data/` | `klima-data` | **No** silent second pipeline |
| `docs/` | `klima-docs` | Agent notes ok; fake product site no |

## Rules

1. Sparse packages stay sparse. Presence of only `.gitignore` + `LICENSE` is intentional honesty, not a bug to “fix” with a generated Next.js/VitePress app.
2. Never `git submodule` the five sources back in; trees are vendored.
3. History under prefixes was filter-repo rewritten and merged. Do not squash it away.
4. Moving ETL from `backend/pipeline` → `data/` requires one implementation, a migration PR, and updated docs/CI — not a copy-paste.
5. Document provenance changes in `docs/SOURCE_HISTORY.md` when tips move.

## Quick checks

```bash
python3 -m pytest -q tests/test_monorepo_layout.py
git blame backend/app/main.py | head
```
