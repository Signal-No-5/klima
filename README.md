# Klima

Klima is a flat monorepo assembled from the five original
`Signal-No-5` repositories. The component trees are vendored in-tree, not
included as Git submodules.

## Layout and provenance

| Path | Source repository | Imported revision |
|------|-------------------|-------------------|
| `backend/` | `Signal-No-5/klima-api` | `main` (`d9daa6f`) |
| `frontend/` | `Signal-No-5/klima-lgu-dashboard` | `main` (`995fd9d`) |
| `data/` | `Signal-No-5/klima-data` | `main` (`8a45435`) |
| `mobile/` | `Signal-No-5/klima-mobile` | `main` (`6551d32`) |
| `docs/` | `Signal-No-5/klima-docs` | `main` (`103e690`) |

Each directory is an exact snapshot of its source repository at the revision
shown above.

## Current source state

- `backend/` contains the FastAPI API and its existing pipeline.
- `mobile/` contains the Flutter application.
- `frontend/`, `data/`, and `docs/` currently contain only the files tracked by
  their source repositories (`.gitignore` and `LICENSE`). They are intentionally
  not replaced with generated scaffolds.

Future work should happen in this monorepo after this import is accepted.

## Checks

```bash
# Layout provenance
python3 -m pytest -q tests/test_monorepo_layout.py

# Backend API smoke tests
cd backend
uv sync --extra test
uv run pytest -q
```

GitHub Actions runs the same jobs on every push/PR (`.github/workflows/ci.yml`).
See [`docs/CI.md`](./docs/CI.md).

