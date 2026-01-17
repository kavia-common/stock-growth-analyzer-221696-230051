#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
cd "$WS"
# Validate required global runtimes (fail-fast)
for cmd in node npm python3 pip3 curl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required runtime '$cmd' not found on PATH" >&2; exit 2; }
done
# Persist NODE_ENV and npm global bin in /etc/profile.d if not already present
PROFILE=/etc/profile.d/zz_node_env.sh
if [ ! -f "$PROFILE" ]; then
  sudo bash -c 'cat > /etc/profile.d/zz_node_env.sh <<"EOF"
# Auto-generated: ensure NODE_ENV=development and npm global bin on PATH
export NODE_ENV=development
if [ -n "$(command -v npm 2>/dev/null)" ]; then
  NPM_GLOB="$(npm config get prefix 2>/dev/null || echo \"\")"/bin
  case ":$PATH:" in
    *":$NPM_GLOB:") ;; 
    *) export PATH="$NPM_GLOB:$PATH";;
  esac
fi
EOF'
fi
# Create idempotent venv
VENV="$WS/.venv"
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
fi
# Ensure venv python is usable
PY="$VENV/bin/python"
if [ ! -x "$PY" ]; then
  echo "ERROR: venv python not found or not executable at $PY" >&2
  exit 3
fi
# Upgrade pip/setuptools/wheel (show failures)
"$PY" -m pip install --upgrade pip setuptools wheel
# Build pip package list
PIP_PKGS=(fastapi "uvicorn[standard]" pytest httpx)
if [ "${INSTALL_PG:-}" = "yes" ] || [ -n "${POSTGRES_DSN:-}" ]; then
  PIP_PKGS+=(psycopg2-binary)
fi
# Install packages (do not hide failures)
"$PY" -m pip install --no-input "${PIP_PKGS[@]}"
# Run sqlite validation script using venv python
if [ -f "$WS/backend/db_check.py" ]; then
  "$PY" "$WS/backend/db_check.py"
else
  echo "WARNING: backend/db_check.py not present; skipping sqlite validation" >&2
fi
# Frontend: ensure node modules installed (idempotent)
if [ -d "$WS/frontend" ]; then
  (cd "$WS/frontend" && [ -d node_modules ] || npm i)
fi
# Validate key tool availability after installs
command -v "$PY" >/dev/null 2>&1 || { echo "ERROR: venv python missing after setup" >&2; exit 4; }
# End
