#!/bin/bash

# if you want any test failure to fail all, use set -e, otherwise we will collect all failures using +e
set +e
fail=0

echo "--- Waiting for FastAPI to be ready ---"
# Wait for the server to be ready, -s will keep trying till it gets a response
max_attempts=10
attempt=1
until curl -s http://localhost:8000/api/health > /dev/null; do
    if [ $attempt -ge $max_attempts ]; then
        echo "FastAPI did not become ready after $max_attempts attempts. Aborting."
        exit 1
    fi
    echo "Waiting for FastAPI to be ready... (attempt $attempt/$max_attempts)"
    attempt=$((attempt + 1))
    sleep 3
done
echo "FastAPI is ready."

echo "--- Starting E2E Testing ---"

curl -f http://localhost:8000/api/messages || fail=1
curl -f http://localhost:8000/api/messages || fail=1
curl -f http://localhost:8000/api/messages || fail=1


echo "--- E2E Testing Complete ---"

echo "#### test result: $fail"
exit $fail