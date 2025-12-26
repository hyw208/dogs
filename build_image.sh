#!/bin/bash
# This script builds the Docker image for the FastAPI backend only.

set +e

IMAGE_NAME="dogs-app:latest"
DOCKERFILE_PATH="packages/Dockerfile"
CONTEXT_DIR="packages"

# Build the Docker image
echo "Building Dogs App Docker image..."
docker build -t $IMAGE_NAME -f $DOCKERFILE_PATH $CONTEXT_DIR
# docker build --no-cache -t $IMAGE_NAME -f $DOCKERFILE_PATH $CONTEXT_DIR

status=$?
echo "Exit code: $status"

if [ $status -ne 0 ]; then
    echo "Docker image build failed."
    exit $status
else
    echo "Docker image '$IMAGE_NAME' built successfully."
    exit 0
fi
