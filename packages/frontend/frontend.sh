#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'EOF'
Usage: frontend.sh <command>

Commands:
  ci-install  Deterministic install: try npm ci, fallback to npm install
  install   Install all npm dependencies from package.json
            Creates node_modules/ with all required packages
            
  build     Build production-ready static files into dist/
            Optimizes and bundles React app for deployment
            Output: dist/index.html, dist/assets/*.js, dist/assets/*.css
            
  dev       Start local development server at http://localhost:5173
            Enables hot module replacement for live code updates
            Press Ctrl+C to stop the server
            
  test      Run Jest unit tests for React components
            Tests are co-located with source files (*.test.tsx)
            Generates coverage reports in coverage/
            
  e2e       Run Cypress end-to-end tests in headless mode
            Automatically starts dev server, runs tests, then stops server
            Saves videos to cypress/videos/ and screenshots to cypress/screenshots/
            
  clean     Remove all build artifacts and dependencies
            Deletes: node_modules/, dist/, coverage/, cypress outputs
            Use before fresh install or to free disk space
EOF
}

start_dev_server() {
  npm run dev -- --host --port 5173 >/tmp/frontend.dev.log 2>&1 &
  DEV_PID=$!
  for _ in {1..30}; do
    if curl -sf http://localhost:5173 >/dev/null 2>&1; then
      echo "Dev server is up (pid=$DEV_PID)"
      return 0
    fi
    sleep 1
  done
  echo "Dev server failed to start; see /tmp/frontend.dev.log" >&2
  kill "$DEV_PID" >/dev/null 2>&1 || true
  return 1
}

clean() {
  echo "Removing build artifacts and test outputs..."
  rm -rf node_modules dist .dist .dist-ssr coverage cypress/screenshots cypress/videos
  echo "Clean complete."
}

cmd=${1:-help}
case "$cmd" in
  ci-install)
    npm ci || npm install
    ;;
  install)
    npm install
    ;;
  build)
    npm run build
    ;;
  dev)
    npm run dev -- --host --port 5173
    ;;
  test)
    npm test -- --runInBand
    ;;
  e2e)
    start_dev_server
    trap 'kill "$DEV_PID" >/dev/null 2>&1 || true' EXIT
    npm run cypress:run
    ;;
  clean)
    clean
    ;;
  *)
    usage
    ;;
 esac
