# Source repository history

The five original repositories were imported with their `main` histories
rewritten beneath the flat monorepo prefixes:

| Monorepo prefix | Original repository | Original tip | Rewritten tip | Commits |
|---|---|---:|---:|---:|
| `backend/` | `Signal-No-5/klima-api` | `d9daa6f` | `ed0cae1` | 24 |
| `frontend/` | `Signal-No-5/klima-lgu-dashboard` | `995fd9d` | `6344077` | 1 |
| `data/` | `Signal-No-5/klima-data` | `8a45435` | `7fcaab8` | 2 |
| `mobile/` | `Signal-No-5/klima-mobile` | `6551d32` | `d444931` | 11 |
| `docs/` | `Signal-No-5/klima-docs` | `103e690` | `9614890` | 1 |

Rewriting changes commit hashes because every historical path gains its
monorepo prefix. Commit messages, authors, timestamps, and file contents remain
intact.

## Inspecting history

```bash
# Original source attribution
git blame backend/app/main.py
git blame mobile/lib/main.dart

# Include merged source histories when inspecting a path
git log --full-history -- backend/app/main.py
git log --full-history -- mobile/lib/main.dart
```

The source tips are ancestors of `main`; these are not detached archive refs or
submodules.
