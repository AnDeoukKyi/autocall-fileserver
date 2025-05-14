FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libsndfile1 git && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir transformers fastapi uvicorn python-multipart

WORKDIR /app

# 기본 포트 설정
ENV APP_PORT=10000

# ENTRYPOINT로 포트를 유연하게 처리
ENTRYPOINT ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${APP_PORT}"]