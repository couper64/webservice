#!/bin/bash

# Exit immediately if a command exits with a non-zero status
# set -e # This is handled in the `docker_prepare.sh` script.

# Load variables
# source .env # This is handled in the `docker_prepare.sh` script.

# Prepare.
source docker_prepare.sh

# Start database
docker run --detach \
    --network "$NETWORK_NAME" \
    --name "$CONTAINER_POSTGRES" \
    -v "$VOLUME_POSTGRES":/var/lib/postgresql/data \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    --rm \
    postgres

# Start file storage
docker run --detach \
    --network "$NETWORK_NAME" \
    -p 9000:9000 \
    -p 9001:9001 \
    --name "$CONTAINER_MINIO" \
    -v "$VOLUME_MINIO":/data \
    -e "MINIO_ROOT_USER=$MINIO_ROOT_USER" \
    -e "MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD" \
    --rm \
    quay.io/minio/minio server /data --console-address ":9001"

# Start queue manager
docker run --detach --network "$NETWORK_NAME" --name "$CONTAINER_REDIS" --rm redis

# Start database Web UI
docker run --detach \
    --network "$NETWORK_NAME" \
    -p 8080:80 \
    --name "$CONTAINER_PGADMIN" \
    -e "PGADMIN_DEFAULT_EMAIL=$PGADMIN_DEFAULT_EMAIL" \
    -e "PGADMIN_DEFAULT_PASSWORD=$PGADMIN_DEFAULT_PASSWORD" \
    --rm \
    -v "$VOLUME_PGADMIN4":/var/lib/pgadmin \
    dpage/pgadmin4

# Start API service
docker run --detach --network "$NETWORK_NAME" --name "$CONTAINER_FASTAPI" --rm \
    -p 8000:8000 "$CONTAINER_FASTAPI"

# Start worker
docker run --detach --network "$NETWORK_NAME" --name "$CONTAINER_CELERY" --rm "$CONTAINER_CELERY"

# Start Web UI
docker run -d --network "$NETWORK_NAME" --name "$CONTAINER_STREAMLIT" --rm --publish 8501:8501 "$CONTAINER_STREAMLIT"