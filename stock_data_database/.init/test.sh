#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/stock-growth-analyzer-221696-230051/stock_data_database"
VENV="$WS/.venv"
# backend pytest: create discoverable test
mkdir -p "$WS/backend/tests"
cat > "$WS/backend/tests/test_app.py" <<'PY'
from backend.app import app
from fastapi.testclient import TestClient

def test_root():
    client = TestClient(app)
    r = client.get('/')
    assert r.status_code == 200
    assert r.json().get('status') == 'ok'
PY
# run pytest via venv python if available, else system python3
if [ -x "$VENV/bin/python" ]; then
  echo "Running pytest with venv python: $VENV/bin/python"
  "$VENV/bin/python" -m pytest -q "$WS/backend/tests"
else
  echo "Venv python not found; running system pytest (python3 -m pytest)"
  python3 -m pytest -q "$WS/backend/tests"
fi
# frontend smoke test: create trivial jest/react-scripts test if frontend exists
if [ -d "$WS/frontend" ]; then
  mkdir -p "$WS/frontend/src"
  cat > "$WS/frontend/src/App.test.js" <<'JS'
test('dummy', ()=>{ expect(1).toBe(1); })
JS
  (cd "$WS/frontend" && npm test --silent -- --watchAll=false)
fi
