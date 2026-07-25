# Klima CI + tests

Code checks for the flat monorepo after the #18 source import.

## Local

```bash
# Layout (repo root)
python3 -m pytest -q tests/test_monorepo_layout.py

# Backend
cd backend
uv sync --extra test
uv run pytest -q
```

## CI

`.github/workflows/ci.yml` runs layout + backend jobs on every push/PR to `main`.
