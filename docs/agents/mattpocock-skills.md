# Matt Pocock skills integration

This repository carries Matt Pocock's promoted engineering/productivity skills as a
**repository-local Codex plugin** under:

`third_party/mattpocock-skills/`

The plugin is exposed by the same local marketplace used for Ponytail:

`.agents/plugins/marketplace.json`

## Why this is an adapter

Upstream `mattpocock/skills` intentionally defers a native Codex plugin. Codex plugin
manifests accept one recursive `skills` path, while upstream separates promoted skills
across `skills/engineering/` and `skills/productivity/` alongside non-promoted
`misc/`, `in-progress/`, and `deprecated/` buckets.

This repository solves only that packaging constraint:

- the 25 promoted skill directories are copied into one flat `skills/` tree
- each skill directory is otherwise copied unchanged
- support documents, scripts, and `agents/openai.yaml` metadata stay with the skill
- the project-authored `.codex-plugin/plugin.json` points at `./skills/`

No skill behavior is rewritten.

## Install

Install both repository-local agent plugins with:

Windows:

```powershell
./scripts/setup-agent-plugins.ps1
```

POSIX:

```bash
./scripts/setup-agent-plugins.sh
```

This installs:

- `ponytail@llama-cpp-local`
- `mattpocock-skills@llama-cpp-local`

## Updating

Refresh Matt's promoted skill bundle from upstream with:

```powershell
./scripts/update-mattpocock-skills.ps1
```

or:

```bash
./scripts/update-mattpocock-skills.sh
```

The updater clones current upstream `main`, copies only the curated 25 promoted
skills, records the upstream commit, and regenerates the thin Codex manifest using the
upstream package version.

Always review the resulting diff before committing.

## Upstream provenance

The current source revision is recorded in:

`third_party/mattpocock-skills/UPSTREAM_REVISION`

The initial repository-local plugin migration uses:

`mattpocock/skills@c55ee46073ed923f86ce59a5eb3b6d895095d1b7`

## Previous installation model

The earlier `.agents/skills/` copies and `skills` CLI update scripts are intentionally
removed. Matt's skill set and Ponytail now share one repository-local Codex marketplace
and the same reviewable third-party dependency model.
