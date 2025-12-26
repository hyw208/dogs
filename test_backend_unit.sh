#!/bin/bash
# This script sets up the backend environment for unit testing.
set +e

echo "Running backend tests..."
cd packages/backend
PYTHONPATH=./src poetry run pytest

status=$?
echo "Exit code: $status"
exit $status