#!/usr/bin/env bash
set -euo pipefail

# Refresh only the curated stable Matt Pocock skills used by this repository.
# The skills CLI writes/updates skills-lock.json and copies into .agents/skills.
npx --yes skills@latest add mattpocock/skills \
  --agent codex \
  --copy \
  --yes \
  --skill ask-matt \
  --skill code-review \
  --skill codebase-design \
  --skill diagnosing-bugs \
  --skill domain-modeling \
  --skill grill-me \
  --skill grill-with-docs \
  --skill grilling \
  --skill handoff \
  --skill implement \
  --skill improve-codebase-architecture \
  --skill prototype \
  --skill research \
  --skill resolving-merge-conflicts \
  --skill setup-matt-pocock-skills \
  --skill tdd \
  --skill teach \
  --skill to-questionnaire \
  --skill to-spec \
  --skill to-tickets \
  --skill triage \
  --skill wait-what \
  --skill wayfinder \
  --skill wizard \
  --skill writing-for-agents

echo
echo "Skills refreshed. Review changes under .agents/skills/ and skills-lock.json before committing."
