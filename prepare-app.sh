#!/usr/bin/env bash
# prepare-app.sh
# Builds the custom web image and creates the network + named volume
# used by the Notes App. Safe to re-run (idempotent).
set -euo pipefail

NETWORK_NAME="notesapp-net"
VOLUME_NAME="notesapp_db_data"
WEB_IMAGE="notesapp-web:latest"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Preparing app ..."

# 1. Custom bridge network so containers can resolve each other by name
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Creating network: $NETWORK_NAME"
    docker network create "$NETWORK_NAME"
else
    echo "Network $NETWORK_NAME already exists, skipping."
fi

# 2. Named volume for Postgres persistent data
if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "Creating volume: $VOLUME_NAME"
    docker volume create "$VOLUME_NAME"
else
    echo "Volume $VOLUME_NAME already exists, skipping."
fi

# 3. Build the custom web application image
echo "Building image: $WEB_IMAGE"
docker build -t "$WEB_IMAGE" "$SCRIPT_DIR/web"

# 4. Pull the database image (official, no build needed)
echo "Pulling database image: postgres:16-alpine"
docker pull postgres:16-alpine

echo "Done. Run ./start-app.sh to launch the app."
