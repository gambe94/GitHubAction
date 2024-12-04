#!/bin/bash

# Define variables
ENV_FILE="env/gabor.env"
HOST_KEY_PATH="/home/gabor/Downloads/GaborGithub/gihub.key"
CONTAINER_KEY_PATH="/tmp/secrets/server.key"
CONTAINER_NAME="my_sf_container"

# Run the Docker container with the specified environment file and volume
docker run -d -it --name $CONTAINER_NAME \
    --env-file $ENV_FILE \
    -v $HOST_KEY_PATH:$CONTAINER_KEY_PATH \
    sf_automation:latest

# Execute the login command inside the container
docker exec -it $CONTAINER_NAME \
    sf org login jwt \
    --username "$SF_TARGET_USERNAME" \
    --jwt-key-file "$SF_TARGET_JWT_PATH" \
    --client-id "$SF_TARGET_CLIENT_ID" \
    --alias "$SF_TARGET_ALIAS" \
    --set-default \
    --instance-url "$SF_TARGET_INSTANCE_URL"
