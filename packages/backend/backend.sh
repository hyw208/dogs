#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

export APP_ENV="${APP_ENV:-local}"
export PYTHONPATH="$ROOT_DIR/src"

usage() {
  cat <<'EOF'
Usage: backend.sh <command>

Commands:
  install     Install dependencies from pyproject.toml
  ci-install  Install from lock file (poetry.lock)
  build       Build backend artifacts (if needed)
  unit        Run pytest unit tests
  start       Start API server on 0.0.0.0:8000
  e2e         Run end-to-end tests
  stop        Stop the running API server
  clean       Remove cache and artifacts
EOF

}

install() {
  echo "Installing backend dependencies..."
  poetry install
}

ci_install() {
  echo "CI install backend dependencies..."
  poetry install --no-root --no-interaction
}

build() {
  echo "Building backend..."
  echo "Backend is interpreted (Python); no build needed."
}

unit() {
  echo "Running backend unit tests..."
  poetry run pytest tests/ -v
  return $?
}

start() {
  echo "Starting API server..."
  PID_FILE="/tmp/backend.pid"
  poetry run uvicorn src.app.main:app --host 0.0.0.0 --port 8000 &
  echo $! > "$PID_FILE"
  echo "Backend API server started (pid=$(cat $PID_FILE))"
}

e2e() {
  echo "Running backend e2e tests..."
  # TODO: implement
}

stop() {
  PID_FILE="/tmp/backend.pid"
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      rm "$PID_FILE"
      echo "Backend API server stopped (pid=$PID)"
    else
      echo "Process $PID not running"
      rm "$PID_FILE"
    fi
  else
    echo "No running API server found"
  fi
}

clean() {
  echo "Cleaning backend artifacts..."
  find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
  find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
  find . -type d -name .mypy_cache -exec rm -rf {} + 2>/dev/null || true
  find . -type f -name "*.pyc" -delete 2>/dev/null || true
  echo "Clean complete."
}

cmd=${1:-help}
case "$cmd" in
  install)
    install
    ;;
  ci-install)
    ci_install
    ;;
  build)
    build
    ;;
  unit)
    unit
    ;;
  start)
    start
    ;;
  e2e)
    e2e
    ;;
  stop)
    stop
    ;;
  clean)
    clean
    ;;
  *)
    usage
    ;;
esac
