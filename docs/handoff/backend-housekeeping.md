# Backend housekeeping handoff

Branch: `chore/backend-agent-skills` (T3) → `integ/backend-mvp` (T2). Stacked
after #4 and #5; integrate last.

## Intent

Capture what the #4 and #5 work established so the next agent or contributor does
not rediscover it, and make the invariants enforceable rather than advisory.

## What landed

- `.agents/skills/klima-backend/SKILL.md` — the real `backend/` layout, the
  routes-thin/services-thick split, warehouse read rules, test conventions, and
  the working run command.
- `.agents/skills/klima-contracts/SKILL.md` — how to change a field in
  `schema/klima_schema/models.py` without breaking the Flutter client, and why
  each contract convention exists.
- Both mirrored into `.cursor/skills/`.
- `AGENTS.md` — added the `schema/` row, the branching tier table, two guardrails
  (wire models live in `schema/` only; never present seed data as live), the two
  new skills in the index, and corrected the local check commands.
- `tests/test_monorepo_layout.py` — three new assertions.

## Invariants now enforced by tests

Documentation rots; these do not:

- `.agents/skills/` and `.cursor/skills/` must be byte-identical. A stale mirror
  silently feeds the wrong rules to whichever tool reads the other copy.
- `schema/klima_schema/models.py` must exist, and
  `backend/app/schemas/klima.py` must contain no `class ` — the facade cannot grow
  its own model definitions without failing the layout suite.
- The two new skills must be present with a `SKILL.md`.

## Deliberately not done

- **`backend/README.md` structure section still lies.** It describes
  `app/api/v1/endpoints/klima.py`, `messenger.py`, `telegram.py`, `viber.py`, and
  `dashboard.py`, none of which exist; `app/api/v1/` is empty. Rewriting it is a
  standalone docs ticket, not housekeeping smuggled into a skills PR. The run
  commands and endpoint list — the parts that actively mislead someone trying to
  start the server — were fixed in #5.
- **`app/core/database.py:56` has `self.drop_all` with no call parentheses**, a
  no-op statement inside `create_all()`. Harmless today and possibly load-bearing
  if someone "fixes" it into an actual drop, so it is reported rather than
  changed. Needs an owner decision.
- **Pydantic v1 style `class Config` in `app/core/prefs.py`** raises a
  deprecation warning on every test run. A `ConfigDict` migration touches settings
  loading and deserves its own PR.
- No deployment, container, or workflow-deploy changes, per the handoff scope.

## Verify

```bash
python3 -m pytest -q tests/test_monorepo_layout.py   # 7 passed
cd backend && uv run python -m pytest -q             # 53 passed
```

`ci-layout.yml` also now triggers on `schema/**` and `backend/app/schemas/**`,
since the suite asserts on both.

### `act` caveat

`act pull_request -W .github/workflows/ci-backend.yml` runs fully green (lint, 53
tests, schema drift guard) over the Podman socket.

`ci-layout.yml` cannot be verified with `act` in this environment: the cached copy
of `actions/setup-python@v5` under `~/.cache/act/` contains `src/` but no `dist/`,
so the action fails with `Cannot find module .../dist/setup/index.js` before the
job body runs. That is a local action-cache artifact, not a workflow defect — the
pytest step it wraps passes directly on Python 3.12. Real GitHub runs resolve the
action normally.
