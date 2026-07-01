#!/usr/bin/env bash

set -euo pipefail

NETWORK_NAME="notesapp-net"
VOLUME_NAME="notesapp_db_data"
WEB_IMAGE="notesapp-web:latest"
DB_CONTAINER="notesapp-db"
WEB_CONTAINER="notesapp-web"
WEB_PORT="5000"
DB_PORT="5432"

DB_NAME="${DB_NAME:-notesdb}"
DB_USER="${DB_USER:-notesuser}"
DB_PASSWORD="${DB_PASSWORD:-notespass}"

echo "Running app ..."

start_or_create() {
    local name="$1"
    if docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
        echo "Starting existing container: $name"
        docker start "$name" >/dev/null
    else
        return 1
    fi
    return 0
}

# --- Database container ---
if ! start_or_create "$DB_CONTAINER"; then
    echo "Creating container: $DB_CONTAINER"
    docker run -d \
        --name "$DB_CONTAINER" \
        --network "$NETWORK_NAME" \
        --restart unless-stopped \
        -p "${DB_PORT}:5432" \
        -e POSTGRES_DB="$DB_NAME" \
        -e POSTGRES_USER="$DB_USER" \
        -e POSTGRES_PASSWORD="$DB_PASSWORD" \
        -v "${VOLUME_NAME}:/var/lib/postgresql/data" \
        postgres:16-alpine >/dev/null
fi

# --- Web container ---
if ! start_or_create "$WEB_CONTAINER"; then
    echo "Creating container: $WEB_CONTAINER"
    docker run -d \
        --name "$WEB_CONTAINER" \
        --network "$NETWORK_NAME" \
        --restart unless-stopped \
        -p "${WEB_PORT}:5000" \
        -e DB_HOST="$DB_CONTAINER" \
        -e DB_PORT="5432" \
        -e DB_NAME="$DB_NAME" \
        -e DB_USER="$DB_USER" \
        -e DB_PASSWORD="$DB_PASSWORD" \
        "$WEB_IMAGE" >/dev/null
fi

echo "Containers are up."
echo "The app is available at http://localhost:${WEB_PORT}"
