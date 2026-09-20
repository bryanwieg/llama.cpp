#!/usr/bin/env bash
set -euo pipefail

command -v git >/dev/null 2>&1 || { echo "git is required but was not found on PATH." >&2; exit 1; }

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dest="$repo_root/third_party/mattpocock-skills"
tmp="$(mktemp -d)"

cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

skills=(
  ask-matt
  code-review
  codebase-design
  diagnosing-bugs
  domain-modeling
  grill-me
  grill-with-docs
  grilling
  handoff
  implement
  improve-codebase-architecture
  prototype
  research
  resolving-merge-conflicts
  setup-matt-pocock-skills
  tdd
  teach
  to-questionnaire
  to-spec
  to-tickets
  triage
  wait-what
  wayfinder
  wizard
  writing-for-agents
)

git clone --depth 1 https://github.com/mattpocock/skills.git "$tmp/src"
revision="$(git -C "$tmp/src" rev-parse HEAD)"
version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$tmp/src/package.json")"

rm -rf "$dest"
mkdir -p "$dest/skills" "$dest/.codex-plugin"

for skill in "${skills[@]}"; do
  src="$tmp/src/skills/engineering/$skill"
  if [[ ! -d "$src" ]]; then
    src="$tmp/src/skills/productivity/$skill"
  fi
  if [[ ! -d "$src" ]]; then
    echo "Promoted skill '$skill' was not found in the expected upstream buckets." >&2
    exit 1
  fi
  cp -R "$src" "$dest/skills/$skill"
done

cp "$tmp/src/LICENSE" "$dest/"

python3 - "$dest/.codex-plugin/plugin.json" "$version" <<'PY'
import json, sys
path, version = sys.argv[1], sys.argv[2]
obj = {
    "name": "mattpocock-skills",
    "version": version,
    "description": "Matt Pocock's agent skills for real engineering: grilling, spec/ticket flows, TDD, code review, domain modelling and more.",
    "author": {"name": "Matt Pocock", "url": "https://www.aihero.dev"},
    "homepage": "https://github.com/mattpocock/skills",
    "repository": "https://github.com/mattpocock/skills",
    "license": "MIT",
    "keywords": ["engineering","skills","tdd","code-review","grilling","domain-modeling","productivity"],
    "skills": "./skills/",
    "interface": {
        "displayName": "Matt Pocock Skills",
        "shortDescription": "Engineering workflow skills",
        "longDescription": "Grilling, specs, tickets, TDD, code review, domain modeling, debugging, architecture and productivity workflows.",
        "developerName": "Matt Pocock",
        "category": "Developer Tools",
    },
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(obj, f, indent=2)
    f.write("\n")
PY

printf '%s\n' "$revision" > "$dest/UPSTREAM_REVISION"

cat > "$dest/VENDORED.md" <<EOF
# Vendored Matt Pocock skill bundle

Source: https://github.com/mattpocock/skills

Upstream revision: `$revision`

This directory is a repository-local Codex packaging adapter around Matt Pocock's
promoted skill set.

Only the curated promoted skill directories are copied into the flat `skills/` tree.
Their contents are copied unchanged. The project-authored Codex manifest points at
that generated promoted-only tree.

Refresh with `scripts/update-mattpocock-skills.ps1` or
`scripts/update-mattpocock-skills.sh`, review the diff, then commit the update.
EOF

echo "Matt Pocock skills vendored at upstream revision $revision"
echo "Review: git diff -- third_party/mattpocock-skills"
echo "Restart Codex/ChatGPT after accepting the update so the local plugin cache refreshes."
