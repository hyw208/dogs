#!/usr/bin/env bash
# Build multi-stage image (frontend inside Docker, backend runtime)

set -euo pipefail

IMAGE_NAME=${IMAGE_NAME:-dogs-app:latest}
DOCKERFILE_PATH=${DOCKERFILE_PATH:-packages/Dockerfile}
CONTEXT_DIR=${CONTEXT_DIR:-packages}

# Enable BuildKit for better caching and features like COPY --chmod
export DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}

echo "Building Docker image: ${IMAGE_NAME}"
echo "Dockerfile: ${DOCKERFILE_PATH}"
echo "Context: ${CONTEXT_DIR}"

docker build \
    --progress=plain \
    --no-cache \
    -t "${IMAGE_NAME}" \
    -f "${DOCKERFILE_PATH}" \
    "${CONTEXT_DIR}"

echo "Docker image '${IMAGE_NAME}' built successfully."
