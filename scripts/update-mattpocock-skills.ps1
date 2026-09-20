$ErrorActionPreference = "Stop"

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "'$Name' is required but was not found on PATH."
    }
}

Require-Command "git"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Dest = Join-Path $RepoRoot "third_party/mattpocock-skills"
$Temp = Join-Path ([System.IO.Path]::GetTempPath()) ("mattpocock-skills-" + [guid]::NewGuid().ToString("N"))

$Skills = @(
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

try {
    & git clone --depth 1 https://github.com/mattpocock/skills.git $Temp
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone mattpocock/skills."
    }

    $Revision = (& git -C $Temp rev-parse HEAD).Trim()
    $Package = Get-Content (Join-Path $Temp "package.json") -Raw | ConvertFrom-Json
    $Version = $Package.version

    if (Test-Path $Dest) {
        Remove-Item -Recurse -Force $Dest
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $Dest "skills") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $Dest ".codex-plugin") | Out-Null

    foreach ($Skill in $Skills) {
        $Source = Join-Path $Temp "skills/engineering/$Skill"
        if (-not (Test-Path $Source)) {
            $Source = Join-Path $Temp "skills/productivity/$Skill"
        }
        if (-not (Test-Path $Source)) {
            throw "Promoted skill '$Skill' was not found in the expected upstream buckets."
        }
        Copy-Item -Recurse $Source (Join-Path $Dest "skills/$Skill")
    }

    Copy-Item (Join-Path $Temp "LICENSE") $Dest

    $Manifest = @{
        name = "mattpocock-skills"
        version = $Version
        description = "Matt Pocock's agent skills for real engineering: grilling, spec/ticket flows, TDD, code review, domain modelling and more."
        author = @{ name = "Matt Pocock"; url = "https://www.aihero.dev" }
        homepage = "https://github.com/mattpocock/skills"
        repository = "https://github.com/mattpocock/skills"
        license = "MIT"
        keywords = @("engineering","skills","tdd","code-review","grilling","domain-modeling","productivity")
        skills = "./skills/"
        interface = @{
            displayName = "Matt Pocock Skills"
            shortDescription = "Engineering workflow skills"
            longDescription = "Grilling, specs, tickets, TDD, code review, domain modeling, debugging, architecture and productivity workflows."
            developerName = "Matt Pocock"
            category = "Developer Tools"
        }
    } | ConvertTo-Json -Depth 5

    [System.IO.File]::WriteAllText(
        (Join-Path $Dest ".codex-plugin/plugin.json"),
        $Manifest + [Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false)
    )

    [System.IO.File]::WriteAllText(
        (Join-Path $Dest "UPSTREAM_REVISION"),
        $Revision + [Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false)
    )

    $Note = @"
# Vendored Matt Pocock skill bundle

Source: https://github.com/mattpocock/skills

Upstream revision: `$Revision`

This directory is a repository-local Codex packaging adapter around Matt Pocock's
promoted skill set.

Only the curated promoted skill directories are copied into the flat `skills/` tree.
Their contents are copied unchanged. The project-authored Codex manifest points at
that generated promoted-only tree.

Refresh with `scripts/update-mattpocock-skills.ps1` or
`scripts/update-mattpocock-skills.sh`, review the diff, then commit the update.
"@
    [System.IO.File]::WriteAllText(
        (Join-Path $Dest "VENDORED.md"),
        $Note,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "Matt Pocock skills vendored at upstream revision $Revision"
    Write-Host "Review: git diff -- third_party/mattpocock-skills"
    Write-Host "Restart Codex/ChatGPT after accepting the update so the local plugin cache refreshes."
}
finally {
    if (Test-Path $Temp) {
        Remove-Item -Recurse -Force $Temp
    }
}
