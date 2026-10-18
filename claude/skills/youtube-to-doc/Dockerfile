FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg ca-certificates nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    "yt-dlp[default]>=2024.08.06" \
    "curl_cffi>=0.7.0" \
    "langdetect>=1.0.9"

WORKDIR /work
COPY scripts/extract.py /app/extract.py

ENTRYPOINT ["python", "/app/extract.py"]
