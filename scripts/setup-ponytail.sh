#!/usr/bin/env bash
set -euo pipefail

command -v node >/dev/null 2>&1 || { echo "node is required but was not found on PATH." >&2; exit 1; }
command -v codex >/dev/null 2>&1 || { echo "codex is required but was not found on PATH." >&2; exit 1; }

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if ! codex plugin marketplace list 2>&1 | grep -q 'llama-cpp-local'; then
  echo "Registering the repository-local plugin marketplace..."
  codex plugin marketplace add .
fi

echo "Installing Ponytail from the repository-local marketplace..."
codex plugin add ponytail@llama-cpp-local

cat <<'EOF'

Ponytail is installed from third_party/ponytail.
Start Codex, open /hooks, review Ponytail's hooks, and trust them.
Ponytail's upstream default mode is full.
EOF
