#!/usr/bin/env bash
set -euo pipefail

# Delegate to backend script in packages/backend
exec ./packages/backend/backend.sh "$@"
