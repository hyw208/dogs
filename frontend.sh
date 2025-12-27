#!/usr/bin/env bash
set -euo pipefail

# Delegate to frontend script in packages/frontend
exec ./packages/frontend/frontend.sh "$@"
