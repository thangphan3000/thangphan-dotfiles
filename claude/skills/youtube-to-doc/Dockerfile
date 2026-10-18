FROM python:3.12-slim@sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1

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
