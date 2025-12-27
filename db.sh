#!/usr/bin/env bash
# This script manages the PostgreSQL database container using Docker.
# For macOS users, Colima is the recommended environment for running Docker.
# Please ensure Colima is started (`colima start`) before using this script.

set -euo pipefail

# --- Configuration ---
DB_CONTAINER="db"
DB_NAME="dogs"
DB_USER="user"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# --- Helper Functions ---
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function check_docker() {
  if ! command_exists docker || ! command_exists docker-compose; then
    echo "Error: docker and docker-compose are required. Please install them."
    exit 1
  fi
}

function container_is_running() {
  docker-compose ps -q db | grep -q .
}

# --- Commands ---
function start() {
  echo "Starting PostgreSQL container..."
  docker-compose up -d db
  echo "Waiting for PostgreSQL to be ready..."
  until docker exec "$DB_CONTAINER" pg_isready -q -U "$DB_USER" -d "$DB_NAME"; do
    sleep 1
  done
  echo "PostgreSQL is ready."
}

function stop() {
  echo "Stopping PostgreSQL container..."
  docker-compose stop db
  echo "Container stopped."
}

function delete_db() {
  echo "This will permanently delete the database container and all its data."
  read -p "Are you sure? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    stop
    echo "Removing container and volumes..."
    docker-compose down -v
    echo "Database deleted."
  else
    echo "Operation cancelled."
  fi
}

function backup() {
  if ! container_is_running; then
    echo "Error: The database container is not running. Please start it with './db.sh start'."
    exit 1
  fi
  mkdir -p "$BACKUP_DIR"
  local backup_file="$BACKUP_DIR/backup_$TIMESTAMP.sql"
  echo "Creating backup at $backup_file..."
  docker exec "$DB_CONTAINER" pg_dumpall -U "$DB_USER" > "$backup_file"
  echo "Backup complete."
}

function usage() {
  echo "Usage: $0 {start|stop|delete|backup}"
  echo "  start   - Start the PostgreSQL container."
  echo "  stop    - Stop the PostgreSQL container."
  echo "  delete  - Stop and delete the container and all data."
  echo "  backup  - Create a backup of the database."
}

# --- Main ---
check_docker

cmd=${1:-}
case "$cmd" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  delete)
    delete_db
    ;;
  backup)
    backup
    ;;
  *)
    usage
    exit 1
    ;;
esac
