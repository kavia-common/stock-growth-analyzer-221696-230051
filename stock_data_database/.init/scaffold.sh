#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
mkdir -p "$WS" && cd "$WS"
# FRONTEND: prefer npx create-react-app
FRONTEND_DIR="$WS/frontend"
if [ ! -d "$FRONTEND_DIR" ]; then
  if command -v npx >/dev/null 2>&1; then
    # attempt CRA scaffold (non-fatal if fails, fallback below)
    set +e
    npx create-react-app frontend --use-npm --template cra-template-pwa >/dev/null 2>&1
    CRA_RC=$?
    set -e
    if [ "$CRA_RC" -ne 0 ]; then
      mkdir -p "$FRONTEND_DIR/src"
      cat > "$FRONTEND_DIR/package.json" <<'EOF'
{
  "name": "frontend",
  "private": true,
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "vite": "^5.0.0"
  },
  "scripts": {
    "start": "vite",
    "build": "vite build",
    "test": "jest --watchAll=false"
  }
}
EOF
      cat > "$FRONTEND_DIR/index.html" <<'EOF'
<!doctype html><html><body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body></html>
EOF
      cat > "$FRONTEND_DIR/src/main.jsx" <<'EOF'
import React from 'react'
import { createRoot } from 'react-dom/client'
function App(){ return <div>Hello</div> }
createRoot(document.getElementById('root')).render(<App />)
EOF
      (cd "$FRONTEND_DIR" && npm i --silent)
    fi
  else
    mkdir -p "$FRONTEND_DIR/src"
    cat > "$FRONTEND_DIR/package.json" <<'EOF'
{
  "name": "frontend",
  "private": true,
  "dependencies": {"react":"^18.0.0","react-dom":"^18.0.0"},
  "devDependencies": {"vite":"^5.0.0"},
  "scripts": {"start":"vite","build":"vite build","test":"jest --watchAll=false"}
}
EOF
    cat > "$FRONTEND_DIR/index.html" <<'EOF'
<!doctype html><html><body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body></html>
EOF
    cat > "$FRONTEND_DIR/src/main.jsx" <<'EOF'
import React from 'react'
import { createRoot } from 'react-dom/client'
function App(){ return <div>Hello</div> }
createRoot(document.getElementById('root')).render(<App />)
EOF
    (cd "$FRONTEND_DIR" && npm i --silent)
  fi
fi
# BACKEND scaffold (independent)
BACKEND_DIR="$WS/backend"
mkdir -p "$BACKEND_DIR"
cat > "$BACKEND_DIR/__init__.py" <<'EOF'
# backend package
EOF
cat > "$BACKEND_DIR/app.py" <<'EOF'
from fastapi import FastAPI
app = FastAPI()
@app.get('/')
def read_root():
    return {'status':'ok'}
EOF
cat > "$BACKEND_DIR/requirements.txt" <<'EOF'
fastapi
uvicorn[standard]
httpx
pytest
EOF
cat > "$BACKEND_DIR/db_check.py" <<'EOF'
import sqlite3
conn = sqlite3.connect('app.db')
conn.execute('CREATE TABLE IF NOT EXISTS sample(id INTEGER PRIMARY KEY)')
conn.commit()
print('sqlite_ok')
EOF
# create scripts directory placeholder
mkdir -p "$WS/scripts"
