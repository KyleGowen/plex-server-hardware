---
name: update-unpackerr
description: Check for and apply updates to Kyle's Unpackerr Docker container, recreate only Unpackerr when its configured image digest changes, verify stack health and download storage, and update Unpackerr documentation and the service version ledger. Use when the user asks to check, update, upgrade, pull, or install Unpackerr.
---

# Update Unpackerr

Use `GPT-5.4 Mini` with `medium` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run `powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-unpackerr\scripts\Update-DockerService.ps1 -ServiceName unpackerr -Json`.
2. For an update request, run that command once with `-Apply`; it checks the digest before changing anything.
3. When `updated` is true, read `docs/services/unpackerr.md`, then use `apply_patch` to update version/image details and append a dated update-history entry. The helper updates `docs/service_versions.json`.
4. When already current, do not read or edit the service document.

Do not extract, delete, move, or recheck download payloads manually. Do not alter Arr API keys or download paths. If the helper fails, report the concise failure and stop.
