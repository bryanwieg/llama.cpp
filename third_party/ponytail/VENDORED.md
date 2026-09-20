# Vendored Ponytail plugin

Source: https://github.com/DietrichGebert/ponytail

Upstream revision: `e3ba2aa6f1e6f0bc4d69eb09c9f0d0a93af56156`

This directory contains Ponytail's Codex runtime payload: its native plugin manifest,
lifecycle hooks, six skills, package metadata, license, upstream AGENTS.md, uninstall
helper, and logo asset.

The runtime files are copied from upstream unchanged except for one packaging-only
manifest adjustment: the icon paths use the upstream `assets/logo-dark.svg` instead
of `assets/logo.png`. This avoids carrying a large binary asset while leaving all
skills and executable hook behavior unchanged.

Refresh with `scripts/update-ponytail.ps1` or `scripts/update-ponytail.sh`, then
review the full diff before committing.
