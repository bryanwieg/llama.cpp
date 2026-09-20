$ErrorActionPreference = "Stop"

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "'$Name' is required but was not found on PATH."
    }
}

Require-Command "git"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Dest = Join-Path $RepoRoot "third_party/ponytail"
$Temp = Join-Path ([System.IO.Path]::GetTempPath()) ("ponytail-" + [guid]::NewGuid().ToString("N"))

try {
    & git clone --depth 1 https://github.com/DietrichGebert/ponytail.git $Temp
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone DietrichGebert/ponytail."
    }

    $Revision = (& git -C $Temp rev-parse HEAD).Trim()

    if (Test-Path $Dest) {
        Remove-Item -Recurse -Force $Dest
    }
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $Dest "assets") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $Dest "scripts") | Out-Null

    Copy-Item -Recurse (Join-Path $Temp ".codex-plugin") $Dest
    Copy-Item -Recurse (Join-Path $Temp "hooks") $Dest
    Copy-Item -Recurse (Join-Path $Temp "skills") $Dest
    Copy-Item (Join-Path $Temp "AGENTS.md") $Dest
    Copy-Item (Join-Path $Temp "LICENSE") $Dest
    Copy-Item (Join-Path $Temp "package.json") $Dest
    Copy-Item (Join-Path $Temp "scripts/uninstall.js") (Join-Path $Dest "scripts/uninstall.js")
    Copy-Item (Join-Path $Temp "assets/logo-dark.svg") (Join-Path $Dest "assets/logo-dark.svg")

    $ManifestPath = Join-Path $Dest ".codex-plugin/plugin.json"
    $Manifest = [System.IO.File]::ReadAllText($ManifestPath)
    $Manifest = $Manifest.Replace("./assets/logo.png", "./assets/logo-dark.svg")
    [System.IO.File]::WriteAllText($ManifestPath, $Manifest, [System.Text.UTF8Encoding]::new($false))

    [System.IO.File]::WriteAllText(
        (Join-Path $Dest "UPSTREAM_REVISION"),
        $Revision + [Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false)
    )

    $VendorNote = @"
# Vendored Ponytail plugin

Source: https://github.com/DietrichGebert/ponytail

Upstream revision: `$Revision`

This directory contains Ponytail's Codex runtime payload: its native plugin manifest,
lifecycle hooks, six skills, package metadata, license, upstream AGENTS.md, uninstall
helper, and logo asset.

The runtime files are copied from upstream unchanged except for one packaging-only
manifest adjustment: the icon paths use the upstream `assets/logo-dark.svg` instead
of `assets/logo.png`. This avoids carrying a large binary asset while leaving all
skills and executable hook behavior unchanged.

Refresh with `scripts/update-ponytail.ps1` or `scripts/update-ponytail.sh`, then
review the full diff before committing.
"@
    [System.IO.File]::WriteAllText(
        (Join-Path $Dest "VENDORED.md"),
        $VendorNote,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "Ponytail vendored at upstream revision $Revision"
    Write-Host "Review: git diff -- third_party/ponytail"
    Write-Host "Restart Codex/ChatGPT after accepting the update so the local plugin cache refreshes."
}
finally {
    if (Test-Path $Temp) {
        Remove-Item -Recurse -Force $Temp
    }
}
