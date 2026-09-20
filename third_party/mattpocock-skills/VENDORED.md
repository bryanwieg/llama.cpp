# Vendored Matt Pocock skill bundle

Source: https://github.com/mattpocock/skills

Upstream revision: `c55ee46073ed923f86ce59a5eb3b6d895095d1b7`

This directory is a repository-local Codex packaging adapter around Matt Pocock's
promoted skill set.

Upstream intentionally does not ship a native Codex plugin because Codex currently
accepts only one recursive `skills` path while the source repository separates promoted
skills across `skills/engineering/` and `skills/productivity/` alongside non-promoted
buckets.

This vendored adapter solves that packaging constraint by copying only the 25 promoted
skill directories into one flat `skills/` tree. The skill files, support documents,
scripts, and `agents/openai.yaml` metadata are copied from upstream unchanged.

The only project-authored runtime file is `.codex-plugin/plugin.json`, which points Codex
at `./skills/`.

Refresh with `scripts/update-mattpocock-skills.ps1` or
`scripts/update-mattpocock-skills.sh`, review the diff, then commit the update.
