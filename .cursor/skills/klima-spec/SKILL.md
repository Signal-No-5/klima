---
name: klima-spec
description: >-
  Drift control for Klima. Use when checking README/STATUS/contracts against
  code, or when requirements change mid-implementation.
---

# Klima Spec Compliance

Paraphrased from the personal `specification-compliance` skill.

## Contracts in this repo

There is no single `SPEC.md` yet. Until one exists, treat these as SoT:

1. `README.md` — layout + provenance tips
2. `AGENTS.md` — agent guardrails
3. `docs/SOURCE_HISTORY.md` — history rewrite facts
4. OpenAPI from a running backend (`/openapi.json`) for HTTP shapes
5. Flutter models under `mobile/lib/models/` for mobile payloads

If you introduce `SPEC.md`, put it at the repo root and update it **before** code when requirements change.

## Drift report

Flag:

- Features in code missing from docs (accidental scope)
- Docs promising auth/RBAC/channel bots/dashboard that are not implemented
- API response fields that diverge from mobile models without a migration note

## Validation

Every checklist claim needs a command:

```bash
cd backend && uv run pytest -q
cd mobile && flutter test
python3 -m pytest -q tests/test_monorepo_layout.py
```
