---
name: klima-simplification
description: >-
  YAGNI decision ladder for Klima. Use when pruning bloat, reviewing diffs for
  premature abstraction, or deciding whether a helper/package should exist.
---

# Klima Simplification

Paraphrased from the personal `code-simplification` skill.

## Decision ladder (before new code)

1. **Skip** — not needed for the acceptance criteria now
2. **Stdlib** — Python/`pathlib`, Dart core, etc.
3. **Already in-tree** — reuse `pipeline.utils`, existing Flutter services
4. **Existing dependency** — do not add packages casually (`uv` / `pnpm` / `pub`)
5. **Smallest custom code** — no future-proof hooks

## Review habits

- Produce a delete list (dead branches, unused imports, one-impl interfaces)
- Flag wrappers that only forward identical arguments
- Prefer deleting invented dashboards/docs over maintaining them

## Debt marker

When deliberately deferring work:

```text
# yagni: why skipped + current fallback
```

Log recurring debt in `.agents/LEARNINGS.md` when asked for health review.
