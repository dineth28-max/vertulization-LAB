#!/usr/bin/env bash

set -euo pipefail

NETWORK_NAME="notesapp-net"
VOLUME_NAME="notesapp_db_data"
WEB_IMAGE="notesapp-web:latest"
DB_CONTAINER="notesapp-db"
WEB_CONTAINER="notesapp-web"

read -r -p "This will permanently delete all app data. Continue? [y/N] " confirm
case "$confirm" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted."; exit 0 ;;
esac

for container in "$WEB_CONTAINER" "$DB_CONTAINER"; do
    if docker ps -a --format '{{.Names}}' | grep -qx "$container"; then
        echo "Removing container: $container"
        docker rm -f "$container" >/dev/null
    fi
done

if docker image inspect "$WEB_IMAGE" >/dev/null 2>&1; then
    echo "Removing image: $WEB_IMAGE"
    docker rmi "$WEB_IMAGE" >/dev/null
fi

if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "Removing volume: $VOLUME_NAME"
    docker volume rm "$VOLUME_NAME" >/dev/null
fi

if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Removing network: $NETWORK_NAME"
    docker network rm "$NETWORK_NAME" >/dev/null
fi

echo "Removed app."
