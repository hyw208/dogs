#!/usr/bin/env bash
# This script sets up the docker db and backend API for end-to-end testing.

set -euo pipefail

echo "--- Starting E2E Backend Setup ---"

echo "1. Starting PostgreSQL database..."
./db.sh stop || true
./db.sh start

echo "2. Running Alembic database migrations..."
# Assuming db_migrate.sh can handle the 'upgrade head' command correctly.
# --env local causes db connection to use localhost to connect to docker db
./db_migrate.sh upgrade head --env local

echo "3. Starting FastAPI application locally..."
echo "FastAPI application started. Access at http://localhost:8000"

# Navigate to the backend src directory and run uvicorn in the background
cd packages/backend
PYTHONPATH=./src APP_ENV=local poetry run uvicorn src.app.main:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!
echo $SERVER_PID > fastapi_server.pid
echo "FastAPI application started in background (PID $SERVER_PID, written to fastapi_server.pid). Access at http://localhost:8000"

# Wait for the server to be ready, -s will keep trying till it gets a response
max_attempts=10
attempt=1
until curl -s http://localhost:8000/api/messages > /dev/null; do
    if [ $attempt -ge $max_attempts ]; then
        echo "FastAPI did not become ready after $max_attempts attempts. Aborting."
        exit 1
    fi
    echo "Waiting for FastAPI to be ready... (attempt $attempt/$max_attempts)"
    attempt=$((attempt + 1))
    sleep 3
done
echo "FastAPI is ready."



echo "--- E2E Backend Setup Ready ---"


echo "--- Starting E2E Backend Testing... ---"
# --- Place your E2E test commands here ---
# Example: curl -i http://localhost:8000/api/messages





# After tests, stop the FastAPI server
# if [ -f fastapi_server.pid ]; then
# 	SERVER_PID=$(cat fastapi_server.pid)
# 	echo "Stopping FastAPI application (PID $SERVER_PID from fastapi_server.pid)..."
# 	kill -9 $SERVER_PID
# 	wait $SERVER_PID 2>/dev/null
# 	rm fastapi_server.pid
# 	echo "FastAPI application stopped."
# else
# 	echo "PID file not found. FastAPI server may not have been started by this script."
# fi


echo "--- E2E Backend Testing Complete ---"