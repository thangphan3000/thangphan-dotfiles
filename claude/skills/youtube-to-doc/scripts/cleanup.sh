#!/usr/bin/env bash
# Remove the skill's Docker image and any dangling containers from it.
set -euo pipefail

IMAGE="youtube-to-doc:local"

# Kill any still-running containers from this image (defensive; run.sh uses --rm).
cids="$(docker ps -aq --filter "ancestor=$IMAGE" || true)"
if [ -n "$cids" ]; then
  docker rm -f $cids >/dev/null || true
fi

if docker image inspect "$IMAGE" >/dev/null 2>&1; then
  docker rmi -f "$IMAGE" >/dev/null
  echo "[cleanup] removed image $IMAGE"
else
  echo "[cleanup] image $IMAGE not present"
fi
