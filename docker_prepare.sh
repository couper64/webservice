#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load variables
source .env

# Functions for better readability and error handling
function error_exit {
    echo "❌ Error: $1" >&2
    exit 1
}

function check_command {
    command -v "$1" >/dev/null 2>&1 || error_exit "$1 is not installed or not in PATH."
}

# --- Pre-flight checks ---
echo "🔍 Checking prerequisites..."
check_command docker

# --- Create volume if it doesn't exists ---
VOLUMES_LIST="$VOLUME_MINIO $VOLUME_POSTGRES $VOLUME_PGADMIN4"
for volume in $VOLUMES_LIST; do
    if ! docker volume ls --format '{{.Name}}' | grep -wq "$volume"; then
        echo "📂 Creating volume: $volume"
        docker volume create "$volume"
    else
        echo "📁 Volume $volume already exists. Skipping."
    fi
done

# --- Create Docker network if not exists ---
if ! docker network ls --format '{{.Name}}' | grep -wq "$NETWORK_NAME"; then
    echo "🌐 Creating Docker network: $NETWORK_NAME"
    docker network create "$NETWORK_NAME" || error_exit "Failed to create Docker network: $NETWORK_NAME"
else
    echo "🌍 Docker network '$NETWORK_NAME' already exists. Skipping creation."
fi

# --- Build Docker images ---
echo "🐳 Building Docker images..."
if [ -f Dockerfile.fastapi ]; then
    docker build -t "$CONTAINER_FASTAPI" -f Dockerfile.fastapi . || error_exit "Failed to build "$CONTAINER_FASTAPI" image."
else
    error_exit "Dockerfile.fastapi not found."
fi

if [ -f Dockerfile.celery ]; then
    docker build -t "$CONTAINER_CELERY" -f Dockerfile.celery . || error_exit "Failed to build "$CONTAINER_CELERY" image."
else
    error_exit "Dockerfile.celery not found."
fi

if [ -f Dockerfile.streamlit ]; then
    docker build -t "$CONTAINER_STREAMLIT" -f Dockerfile.streamlit . || error_exit "Failed to build "$CONTAINER_STREAMLIT" image."
else
    error_exit "Dockerfile.streamlit not found."
fi

echo "✅ All preparation tasks completed successfully!"
