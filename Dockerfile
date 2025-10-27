# syntax=docker/dockerfile:1.7
FROM python:3.12-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m appuser
WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

ENV HOST=0.0.0.0 \
    PORT=8080 \
    DB_DIR=/app/data \
    CHROMADB_TELEMETRY=False \
    CHROMADB_DISABLE_TELEMETRY=1 \
    POSTHOG_DISABLED=1

RUN mkdir -p ${DB_DIR} && chown -R appuser:appuser ${DB_DIR}
USER appuser

EXPOSE 8080
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

