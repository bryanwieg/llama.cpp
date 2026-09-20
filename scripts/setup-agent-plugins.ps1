$ErrorActionPreference = "Stop"

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "'$Name' is required but was not found on PATH."
    }
}

Require-Command "node"
Require-Command "codex"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $RepoRoot
try {
    $marketplaces = (& codex plugin marketplace list 2>&1 | Out-String)
    if ($marketplaces -notmatch "llama-cpp-local") {
        Write-Host "Registering the repository-local plugin marketplace..."
        & codex plugin marketplace add .
        if ($LASTEXITCODE -ne 0) { throw "Failed to register the local marketplace." }
    }

    foreach ($Plugin in @("ponytail", "mattpocock-skills")) {
        Write-Host "Installing $Plugin from llama-cpp-local..."
        & codex plugin add "$Plugin@llama-cpp-local"
        if ($LASTEXITCODE -ne 0) { throw "Failed to install $Plugin." }
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Repository-local agent plugins are installed."
Write-Host "Open /hooks in Codex and review/trust Ponytail's lifecycle hooks."
