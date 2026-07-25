---
name: klima-code-review
description: >-
  Citation-first code review for Klima PRs. Use when reviewing diffs for bugs,
  security, DRY issues, or provenance violations. Requires file:line citations.
---

# Klima Code Review

Paraphrased from the personal `thorough-code-review` skill; scoped to this monorepo.

## Rules

1. Every finding cites `path:line` (or a range). No vibe-only comments.
2. Search for the same bug class elsewhere before closing the note.
3. Buckets: **Correctness**, **Security**, **Provenance**, **Consistency/DRY**, **Maintainability**.
4. End with a consolidation table of duplicated patterns.

## Klima-specific checks

- Sparse `frontend/` / `data/` / `docs/` not filled with invented scaffolds
- No second copy of `pipeline/` under `data/` while backend still owns ETL
- Secrets / tokens not committed
- Path-filtered CI still covers the touched package
- Tests added or updated for behavior changes (red→green preferred)

## Severity

- **Blocker** — wrong behavior, data loss, auth hole, provenance lie
- **Should fix** — real bug or inconsistency likely to bite
- **Nit** — style only; batch or skip if noisy

Default to fewer, higher-signal notes.
