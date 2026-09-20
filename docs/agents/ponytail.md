# Ponytail integration

This repository carries a reviewable copy of the **official Ponytail Codex plugin**
from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail).

The canonical project copy lives at:

`third_party/ponytail/`

Codex sees it through the repository marketplace:

`.agents/plugins/marketplace.json`

This keeps Ponytail's standard architecture intact while making the exact hooks and
skills used by this project part of the repository history.

## What is vendored

The project copy includes Ponytail's Codex runtime payload:

- native `.codex-plugin/plugin.json`
- lifecycle hooks
- all six Ponytail skills
- package metadata
- upstream `AGENTS.md`
- MIT license
- uninstall helper
- upstream logo asset

The executable hook and skill files are copied from upstream unchanged.

There is one packaging-only difference: the local manifest points its cosmetic icon
fields at Ponytail's upstream `assets/logo-dark.svg` instead of the much larger PNG.
This does not change Ponytail behavior.

The exact upstream commit is recorded in:

`third_party/ponytail/UPSTREAM_REVISION`

## Install

Windows:

```powershell
./scripts/setup-ponytail.ps1
```

POSIX:

```bash
./scripts/setup-ponytail.sh
```

The setup registers this repository as a local Codex marketplace when needed and
installs:

`ponytail@llama-cpp-local`

Codex supports repository marketplaces at `.agents/plugins/marketplace.json` and
local plugin entries that point at another path in the same repository.

## Hook trust

After installation, start Codex and open:

`/hooks`

Review and trust Ponytail's hooks. Do not bypass this approval boundary.

The standard plugin then provides:

- `SessionStart`: activates Ponytail and injects the active ruleset.
- `UserPromptSubmit`: tracks `lite`, `full`, `ultra`, and `off` mode changes.
- `SubagentStart`: propagates the active ruleset to subagents.

Node.js must be available on `PATH`.

## Default mode

Ponytail's upstream default remains **full**. This repository does not override it.

## Updating

Refresh the project copy from upstream with:

Windows:

```powershell
./scripts/update-ponytail.ps1
```

POSIX:

```bash
./scripts/update-ponytail.sh
```

The updater shallow-clones current upstream `main`, replaces only the vendored
Ponytail runtime payload, records the new upstream commit, and reapplies the single
cosmetic SVG icon-path adaptation.

Always inspect the resulting hook and skill diff before committing. Ponytail updates
can change executable lifecycle code, not just prompts.

After accepting an update, restart Codex/ChatGPT so the local plugin cache refreshes
from the updated repository source.

## Relationship to Matt Pocock skills

The systems intentionally remain separate:

- Matt Pocock skills: project-local skill copies under `.agents/skills/`, managed by
  the `skills` CLI and `skills-lock.json`.
- Ponytail: a complete local Codex plugin under `third_party/ponytail/`, exposed
  through the repository marketplace.

Do not separately install Ponytail's six skills with the `skills` CLI; the plugin is
their authoritative source and also supplies their lifecycle behavior.
