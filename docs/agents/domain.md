# Domain Docs

How engineering skills should consume project knowledge when exploring this fork.

## Layout

This repository uses a **single-context** domain model:

```text
/
├── CONTEXT.md              # created/evolved lazily when domain vocabulary becomes useful
├── docs/
│   ├── adr/                # architectural decisions, created as real decisions are made
│   └── agents/             # operational/living agent context
└── ...
```

Do not create empty `CONTEXT.md` or ADR files merely to satisfy the layout. The `domain-modeling`, `grill-with-docs`, and architecture workflows should create or update them when terminology or durable decisions actually need to be recorded.

## Before exploring

Read, when present and relevant:

- root `CONTEXT.md`
- ADRs under `docs/adr/`
- the applicable living operational docs under `docs/agents/`

The roles are different:

- `CONTEXT.md` defines shared domain language and durable conceptual relationships.
- `docs/adr/` records durable architectural decisions and their rationale.
- `docs/agents/` records operational context that can change more frequently: current priorities, hardware/runtime assumptions, optimization history, issue-tracker configuration, and plugin/update procedures.
- root `AGENTS.md` is the stable project operating contract.

## Use the project's vocabulary

When an output names a domain concept, prefer terminology already defined in `CONTEXT.md`.

If an important concept has no established term, that may be a real domain-modeling gap. Resolve it through `domain-modeling` rather than inventing multiple competing names.

## ADR conflicts

If proposed work conflicts with an existing ADR, surface that explicitly. Do not silently override a durable architectural decision.

## What belongs where

Use this test:

- enduring mission, constraints, engineering behavior -> root `AGENTS.md`
- stable domain vocabulary -> `CONTEXT.md`
- durable architectural decision -> `docs/adr/`
- changing project state/history/tooling context -> `docs/agents/`
