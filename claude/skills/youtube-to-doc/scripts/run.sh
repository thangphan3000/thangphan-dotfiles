#!/usr/bin/env bash
# Build (if needed) and run the yt-dlp extractor in a one-shot container.
# Usage: run.sh <youtube-url> <out_dir>
set -euo pipefail

URL="${1:?youtube url required}"
OUT_DIR="${2:?output dir required}"

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="youtube-to-doc:local"
CONTAINER="youtube-to-doc-$$"

mkdir -p "$OUT_DIR"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "[run] building image $IMAGE" >&2
  docker build -t "$IMAGE" "$SKILL_DIR" >&2
fi

echo "[run] starting container $CONTAINER" >&2
docker run --rm \
  --name "$CONTAINER" \
  -v "$(cd "$OUT_DIR" && pwd):/work" \
  "$IMAGE" "$URL"

echo "[run] container finished and removed (--rm)" >&2
