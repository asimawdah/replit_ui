#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

CONTAINER_PORT="${CONTAINER_PORT:-8080}"

log() { echo "[reload] $*"; }

echo "============================================"
echo "  replit.asimawdah.com — Docker deploy"
echo "============================================"
echo ""

# ---- 1. Build the static site ----
log "Building static site..."
npm run build

# ---- 2. Run the container locally ----
log "Stopping any existing container..."
docker compose down --remove-orphans 2>/dev/null || true

log "Starting container on http://127.0.0.1:${CONTAINER_PORT}..."
docker compose up -d --build

log "Waiting for container to be ready..."
for i in $(seq 1 30); do
  if curl -sf http://127.0.0.1:${CONTAINER_PORT}/ >/dev/null 2>&1; then
    log "Container is ready on port ${CONTAINER_PORT}."
    break
  fi
  sleep 1
done

if ! curl -sf http://127.0.0.1:${CONTAINER_PORT}/ >/dev/null 2>&1; then
  log "ERROR: container did not become ready on port ${CONTAINER_PORT}"
  docker compose logs --tail=50 replit.asimawdah.com
  exit 1
fi

echo ""
log "Site is live: https://replit.asimawdah.com/  (host nginx proxies 443 -> localhost:${CONTAINER_PORT})"
log "Site is live locally: http://127.0.0.1:${CONTAINER_PORT}/"
echo ""
log "Deploy complete!"
