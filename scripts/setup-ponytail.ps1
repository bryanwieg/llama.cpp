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
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to register the repository-local marketplace."
        }
    }

    Write-Host "Installing Ponytail from the repository-local marketplace..."
    & codex plugin add ponytail@llama-cpp-local
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install the local Ponytail plugin."
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Ponytail is installed from third_party/ponytail."
Write-Host "Start Codex, open /hooks, review Ponytail's hooks, and trust them."
Write-Host "Ponytail's upstream default mode is full."
