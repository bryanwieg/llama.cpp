# Matt Pocock engineering skills

Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) for project-local use by Codex and other Agent Skills-compatible tools.

Source revision: `c55ee46073ed923f86ce59a5eb3b6d895095d1b7`

Installed set:

- all stable `skills/engineering/*` skills
- all stable `skills/productivity/*` skills

Intentionally not installed:

- `skills/deprecated/*`
- `skills/in-progress/*`
- `skills/misc/*`

Each skill is copied into `.agents/skills/<skill-name>/` with its support files and `agents/openai.yaml` metadata intact.

The upstream project recommends running `/setup-matt-pocock-skills` once per repository after installation to configure the issue tracker, triage labels, and documentation locations.

To refresh these vendored files later, use the upstream installer or re-vendor from a chosen upstream revision rather than assuming automatic updates.
