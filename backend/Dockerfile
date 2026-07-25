# Klima FastAPI — production container (Fly / compose)
# Primary deploy path for backend. Do NOT use Vercel serverless Python.

FROM python:3.12-slim-bookworm

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY data ./data

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_PORT=8080 \
    DB_DIALECT=sqlite \
    SQLITE_FILE=/tmp/klima.db

EXPOSE 8080

# Bind 0.0.0.0 for compose; Fly proxy reaches the VM on this port.
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${APP_PORT:-8080}"]
