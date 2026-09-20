# Issue tracker: GitHub

Issues and specs for this private fork live as GitHub issues in `bryanwieg/llama.cpp`.

Use the repository's normal GitHub tooling for issue operations. The Matt Pocock engineering skills may create, read, label, comment on, and close issues in this private fork when the user authorizes that workflow.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, including labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments` with appropriate filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply/remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from the local Git remote where practical.

## Pull requests as a triage surface

**PRs as a request surface: no.**

Do not treat pull requests as ordinary triage tickets unless this flag is deliberately changed later.

## When a skill says "publish to the issue tracker"

Create a GitHub issue in the private fork.

## When a skill says "fetch the relevant ticket"

Read the corresponding GitHub issue and its comments/labels.

## Wayfinding operations

Used by `wayfinder`.

- **Map**: one GitHub issue labelled `wayfinder:map`, containing Notes / Decisions-so-far / Fog.
- **Child ticket**: a GitHub sub-issue where available; otherwise a task-list child that names its parent map.
- **Blocking**: prefer GitHub native issue dependencies. If unavailable, use a `Blocked by: #n, #n` line.
- **Frontier**: open, unassigned child tickets whose blockers are closed.
- **Claim**: assign the selected ticket before beginning work.
- **Resolve**: record the resolution, close the ticket, and append a concise context pointer to the map's Decisions-so-far.

## Upstream boundary

This document describes the private fork's tracker only. It does not authorize autonomous issue/PR/comment activity against `ggml-org/llama.cpp`. For upstream contribution work, follow the upstream instructions in root `AGENTS.md`.
