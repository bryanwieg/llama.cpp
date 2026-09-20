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

for plugin in ponytail mattpocock-skills; do
  echo "Installing $plugin from llama-cpp-local..."
  codex plugin add "$plugin@llama-cpp-local"
done

cat <<'EOF'

Repository-local agent plugins are installed.
Open /hooks in Codex and review/trust Ponytail's lifecycle hooks.
EOF
