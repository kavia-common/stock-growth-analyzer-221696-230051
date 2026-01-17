#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
mkdir -p "$WS/scripts" "$WS/backend"
# write start script
cat > "$WS/scripts/start_backend.sh" <<'SH'
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
SH
chmod +x "$WS/scripts/start_backend.sh"
# write stop script
cat > "$WS/scripts/stop_backend.sh" <<'SH'
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
SH
chmod +x "$WS/scripts/stop_backend.sh"
# also create a small wrapper to run start for the agent
"$WS/scripts/start_backend.sh"
