#!/usr/bin/env bash
# This script sets up the backend environment for unit testing.
set +e
set -o pipefail

echo "Running backend tests..."
cd packages/backend
PYTHONPATH=./src poetry run pytest

status=$?
echo "Exit code: $status"
exit $status