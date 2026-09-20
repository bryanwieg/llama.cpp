#!/usr/bin/env bash
set -euo pipefail

command -v git >/dev/null 2>&1 || { echo "git is required but was not found on PATH." >&2; exit 1; }

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dest="$repo_root/third_party/ponytail"
tmp="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

git clone --depth 1 https://github.com/DietrichGebert/ponytail.git "$tmp/src"
revision="$(git -C "$tmp/src" rev-parse HEAD)"

rm -rf "$dest"
mkdir -p "$dest/assets" "$dest/scripts"

cp -R "$tmp/src/.codex-plugin" "$dest/"
cp -R "$tmp/src/hooks" "$dest/"
cp -R "$tmp/src/skills" "$dest/"
cp "$tmp/src/AGENTS.md" "$dest/"
cp "$tmp/src/LICENSE" "$dest/"
cp "$tmp/src/package.json" "$dest/"
cp "$tmp/src/scripts/uninstall.js" "$dest/scripts/"
cp "$tmp/src/assets/logo-dark.svg" "$dest/assets/"

python3 - "$dest/.codex-plugin/plugin.json" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
p.write_text(s.replace("./assets/logo.png", "./assets/logo-dark.svg"), encoding="utf-8")
PY

printf '%s\n' "$revision" > "$dest/UPSTREAM_REVISION"

cat > "$dest/VENDORED.md" <<EOF
# Vendored Ponytail plugin

Source: https://github.com/DietrichGebert/ponytail

Upstream revision: `$revision`

This directory contains Ponytail's Codex runtime payload: its native plugin manifest,
lifecycle hooks, six skills, package metadata, license, upstream AGENTS.md, uninstall
helper, and logo asset.

The runtime files are copied from upstream unchanged except for one packaging-only
manifest adjustment: the icon paths use the upstream `assets/logo-dark.svg` instead
of `assets/logo.png`. This avoids carrying a large binary asset while leaving all
skills and executable hook behavior unchanged.

Refresh with `scripts/update-ponytail.ps1` or `scripts/update-ponytail.sh`, then
review the full diff before committing.
EOF

echo "Ponytail vendored at upstream revision $revision"
echo "Review: git diff -- third_party/ponytail"
echo "Restart Codex/ChatGPT after accepting the update so the local plugin cache refreshes."
