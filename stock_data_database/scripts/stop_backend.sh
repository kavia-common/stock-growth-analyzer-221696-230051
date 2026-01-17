#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
PIDFILE="$WS/backend/.uvicorn.pid"
if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" ) || true
  if [ -n "$PID" ]; then
    kill "$PID" >/dev/null 2>&1 || true
  fi
  rm -f "$PIDFILE" || true
fi
