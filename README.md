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

Each directory matches its source repository at the revision shown above.
Source commit histories were rewritten beneath their monorepo prefixes and
merged into this repository, so blame and full path history retain the original
authors and commits. See [`docs/SOURCE_HISTORY.md`](./docs/SOURCE_HISTORY.md).

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

# Backend (API + pipeline)
cd backend
uv sync --extra test
uv run ruff check --no-fix app tests
uv run pytest -q

# Mobile
cd mobile
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

Path-filtered GitHub Actions run only when the matching package changes
(see [`docs/CI.md`](./docs/CI.md)). Agent rules: [`AGENTS.md`](./AGENTS.md).

