#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load variables
source .env

# Stop containers (ignore missing)
for container in "$CONTAINER_OPENRESTY" "$CONTAINER_STREAMLIT" "$CONTAINER_FASTAPI" "$CONTAINER_CELERY" \
                  "$CONTAINER_PGADMIN" "$CONTAINER_MINIO" "$CONTAINER_REDIS" "$CONTAINER_POSTGRES" ; do
    if docker ps -a --format '{{.Names}}' | grep -wq "$container"; then
        echo "Stopping and removing container: $container"
        docker stop "$container" >/dev/null
    else
        echo "Container $container does not exist. Skipping."
    fi
done

# Loop through volumes and ask before removal
VOLUMES_LIST="$VOLUME_MINIO $VOLUME_POSTGRES $VOLUME_PGADMIN4"
for volume in $VOLUMES_LIST; do
    if docker volume ls --format '{{.Name}}' | grep -wq "$volume"; then
        read -p "Do you want to remove the volume '$volume'? (y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "Removing volume: $volume"
            docker volume rm "$volume"
        else
            echo "Keeping volume: $volume"
        fi
    else
        echo "Volume $volume does not exist. Skipping."
    fi
done

# Ask before removing network
if docker network ls --format '{{.Name}}' | grep -wq "$NETWORK_NAME"; then
    read -p "Do you want to remove the network '$NETWORK_NAME'? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "Removing network: $NETWORK_NAME"
        docker network rm "$NETWORK_NAME"
    else
        echo "Keeping network: $NETWORK_NAME"
    fi
else
    echo "Network $NETWORK_NAME does not exist. Skipping."
fi
