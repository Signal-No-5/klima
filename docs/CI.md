# Klima CI

Path-filtered workflows under `.github/workflows/`:

| Workflow | Triggers on | What it runs |
|----------|-------------|--------------|
| `ci-layout.yml` | `tests/**`, `AGENTS.md`, skills, README | Provenance layout pytest |
| `ci-backend.yml` | `backend/**` | `ruff` + full pytest suite |
| `ci-mobile.yml` | `mobile/**` | `flutter analyze` + `flutter test` |
| `ci-frontend.yml` | `frontend/**` | Sparse guard / future pnpm gate |
| `ci-data.yml` | `data/**` | Sparse guard / future uv gate |
| `ci-docs.yml` | `docs/**` | Sparse + required agent docs |

## Local parity

```bash
python3 -m pytest -q tests/test_monorepo_layout.py

cd backend
uv sync --extra test
uv run ruff check --no-fix app tests
uv run pytest -q

cd ../mobile
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```
