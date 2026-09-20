$ErrorActionPreference = "Stop"

# Refresh only the curated stable Matt Pocock skills used by this repository.
# The skills CLI writes/updates skills-lock.json and copies into .agents/skills.
$skills = @(
    "ask-matt",
    "code-review",
    "codebase-design",
    "diagnosing-bugs",
    "domain-modeling",
    "grill-me",
    "grill-with-docs",
    "grilling",
    "handoff",
    "implement",
    "improve-codebase-architecture",
    "prototype",
    "research",
    "resolving-merge-conflicts",
    "setup-matt-pocock-skills",
    "tdd",
    "teach",
    "to-questionnaire",
    "to-spec",
    "to-tickets",
    "triage",
    "wait-what",
    "wayfinder",
    "wizard",
    "writing-for-agents"
)

$args = @(
    "skills@latest",
    "add",
    "mattpocock/skills",
    "--agent", "codex",
    "--copy",
    "--yes"
)

foreach ($skill in $skills) {
    $args += @("--skill", $skill)
}

& npx --yes @args
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Skills refreshed. Review changes under .agents/skills/ and skills-lock.json before committing."
