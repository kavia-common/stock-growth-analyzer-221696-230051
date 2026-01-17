#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
cd "$WS/backend"
PORT="${PORT:-8000}"
PIDFILE="$WS/backend/.uvicorn.pid"
LOGFILE="$WS/backend/uvicorn.log"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" >/dev/null 2>&1; then
  echo "uvicorn already running"
  exit 0
fi
# choose venv python if available for reproducibility
if [ -x "$WS/.venv/bin/python" ]; then
  nohup "$WS/.venv/bin/python" -m uvicorn app:app --host 0.0.0.0 --port "$PORT" >"$LOGFILE" 2>&1 &
else
  nohup uvicorn app:app --host 0.0.0.0 --port "$PORT" >"$LOGFILE" 2>&1 &
fi
echo $! > "$PIDFILE"
