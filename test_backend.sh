#!/bin/bash
# This script runs all backend tests using Poetry.

set -e

echo "Running backend tests..."
cd packages/backend && PYTHONPATH=./src poetry run pytest
