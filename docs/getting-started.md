# Getting started

## API

```bash
cd backend
uv sync
uv run uvicorn app.main:app --reload --port 8000
```

Mobile default base URL (Android emulator): `http://10.0.2.2:8000`  
Override at build time with `--dart-define=API_BASE_URL=...`.

## Pipeline (PAGASA bronze)

```bash
cd backend
uv run python scripts/run_pipeline.py pagasa_warnings
```

## Docs site

```bash
cd docs
pnpm install
pnpm docs:dev
```

## Deploy (overview)

See [Deployments](./deploy.md) and repo [`deploy/README.md`](https://github.com/Signal-No-5/klima/blob/HEAD/deploy/README.md).
