---
name: klima-improvement
description: >-
  Test/lint fix loop for Klima. Use when iterating on failures; records lessons
  in .agents/LEARNINGS.md.
---

# Klima Continuous Improvement

Paraphrased from the personal `continuous-improvement` skill.

## Loop

1. **Load** `.agents/LEARNINGS.md` if present — treat entries as hard constraints.
2. **Reproduce** with the package’s real command (`uv run pytest`, `flutter test`, layout pytest).
3. **Patch small** — one failure class at a time.
4. **Re-run** after each patch.
5. **Record** the trap and the fix in `.agents/LEARNINGS.md`.

## LEARNINGS entry shape

```markdown
### YYYY-MM-DD — short title
- Symptom:
- Command:
- Cause:
- Fix:
- Guardrail:
```

## Pair with

- `klima-simplification` — do not grow abstractions while fixing
- `klima-provenance` — do not “fix” sparse packages by inventing apps
