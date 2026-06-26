#!/usr/bin/env bash
# stop-app.sh
# Stops the running containers WITHOUT removing them, so the named volume
# and container filesystems are preserved. ./start-app.sh can bring the
# app back up later with all data and config intact.
set -euo pipefail

DB_CONTAINER="notesapp-db"
WEB_CONTAINER="notesapp-web"

echo "Stopping app ..."

for container in "$WEB_CONTAINER" "$DB_CONTAINER"; do
    if docker ps --format '{{.Names}}' | grep -qx "$container"; then
        echo "Stopping container: $container"
        docker stop "$container" >/dev/null
    else
        echo "Container $container is not running, skipping."
    fi
done

echo "App stopped. Data preserved. Run ./start-app.sh to resume."
