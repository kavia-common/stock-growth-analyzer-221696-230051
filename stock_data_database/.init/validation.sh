#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
# ensure build step artifacts exist (build step is dependency), but verify again
if [ -d "$WS/frontend/build" ] || [ -d "$WS/frontend/dist" ]; then
  :
else
  echo "frontend build artifacts missing; run build step" >&2
  exit 4
fi
# start backend (idempotent script)
"$WS/scripts/start_backend.sh"
# wait for server readiness with retry/backoff
PORT="${PORT:-8000}"
URL="http://127.0.0.1:$PORT/"
MAX_ATTEMPTS=8
SLEEP=1
i=0
while [ $i -lt $MAX_ATTEMPTS ]; do
  if curl -sSf "$URL" >/dev/null 2>&1; then
    echo "server_ok"
    break
  fi
  i=$((i+1))
  sleep $SLEEP
  SLEEP=$((SLEEP*2))
done
if [ $i -ge $MAX_ATTEMPTS ]; then
  echo "server did not respond after retries" >&2
  # print uvicorn log if present
  LOGFILE="$WS/backend/uvicorn.log"
  if [ -f "$LOGFILE" ]; then
    echo "--- uvicorn.log last 200 lines ---" >&2
    tail -n 200 "$LOGFILE" >&2 || true
  fi
  # attempt to stop
  "$WS/scripts/stop_backend.sh" || true
  exit 6
fi
# smoke test response body and code
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [ "$HTTP_CODE" != "200" ]; then
  echo "unexpected http code: $HTTP_CODE" >&2
  "$WS/scripts/stop_backend.sh" || true
  exit 7
fi
# stop backend cleanly
"$WS/scripts/stop_backend.sh"
echo "validation_ok"
