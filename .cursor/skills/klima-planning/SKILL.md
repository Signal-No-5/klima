---
name: klima-planning
description: >-
  Architecture and milestone planning for the Klima flat monorepo. Use for
  roadmaps, Mermaid flows, and task matrices across backend/mobile/frontend/data/docs.
---

# Klima Planning

Paraphrased from the personal `architectural-planning` skill.

## When to use

Multi-package changes, ETL ownership moves, deploy topology, or MVP sequencing.

## Output shape (chat-first)

1. **Context** — what exists vs sparse
2. **Architecture flow** — Mermaid only (no ASCII boxes)
3. **Task matrix** — component · path · est. hours · depends on · DoD command
4. **Non-goals** — explicit
5. **Risks** — provenance / empty packages / LFS / CI path filters

## Klima defaults

- Stack: FastAPI + DuckDB pipeline · Flutter + Provider · pnpm for any JS · uv for Python · Podman for containers
- Prefer extending `backend/` and `mobile/` before inventing `frontend/` or `docs/` sites
- Path-filtered workflows must gain a real job when a sparse package becomes real

## Storage

Default to chat. Only write `docs/` planning notes when the user asks to persist them.
