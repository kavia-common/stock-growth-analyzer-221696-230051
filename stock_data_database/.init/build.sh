#!/usr/bin/env bash
set -euo pipefail
# Headless frontend build validation
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
FRONTEND_DIR="$WS/frontend"
[ -d "$FRONTEND_DIR" ] || { echo "frontend missing" >&2; exit 4; }
cd "$FRONTEND_DIR"
# Ensure npm is available
command -v npm >/dev/null 2>&1 || { echo "npm not found on PATH" >&2; exit 6; }
# Run configured build script; fail-fast on any error
npm run build --silent
# verify artifacts
if [ -d "$FRONTEND_DIR/build" ] || [ -d "$FRONTEND_DIR/dist" ]; then
  exit 0
else
  echo "build artifacts missing" >&2
  exit 5
fi
