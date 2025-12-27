#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'EOF'
Usage: frontend.sh <command>

Commands:
  install     Install dependencies from package.json
  ci-install  Install from lock file (package-lock.json)
  build       Build production-ready static files into dist/
  unit        Run Jest unit tests
  start       Start development server at http://localhost:5173
  e2e         Run Cypress end-to-end tests
  stop        Stop the running dev server
  clean       Remove build artifacts and dependencies
EOF
}

install() {
  echo "Installing frontend dependencies..."
  npm install
}

ci_install() {
  echo "CI install frontend dependencies..."
  npm ci || npm install
}

build() {
  echo "Building frontend..."
  npm run build
}

unit() {
  echo "Running frontend unit tests..."
  npm test -- --runInBand
}

start() {
  echo "Starting dev server in background..."
  PID_FILE="/tmp/frontend.pid"
  LOG_FILE="/tmp/frontend.log"
  npm run dev -- --host --port 5173 >"$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  
  # Wait for server to be ready
  for _ in {1..30}; do
    if curl -sf http://localhost:5173 >/dev/null 2>&1; then
      echo "Dev server started (pid=$(cat $PID_FILE))"
      return 0
    fi
    sleep 1
  done
  
  # Startup failed
  echo "Dev server failed to start; see $LOG_FILE" >&2
  kill "$(cat $PID_FILE)" >/dev/null 2>&1 || true
  rm "$PID_FILE"
  return 1
}

e2e() {
  echo "Running e2e tests..."
  if [ -z "${CYPRESS_BASE_URL:-}" ]; then
    start
    trap 'kill "$(cat /tmp/frontend.pid)" >/dev/null 2>&1 || true; rm /tmp/frontend.pid' EXIT
  fi
  npm run cypress:run
}

stop() {
  PID_FILE="/tmp/frontend.pid"
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      rm "$PID_FILE"
      echo "Dev server stopped (pid=$PID)"
    else
      echo "Process $PID not running"
      rm "$PID_FILE"
    fi
  else
    echo "No running dev server found"
  fi
}

clean() {
  echo "Cleaning frontend artifacts..."
  rm -rf node_modules dist .dist .dist-ssr coverage cypress/screenshots cypress/videos
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
