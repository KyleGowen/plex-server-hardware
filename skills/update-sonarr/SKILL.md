---
name: update-sonarr
description: Check for and apply updates to Kyle's Sonarr Docker container, recreate only Sonarr when its configured image digest changes, verify stack health, and update Sonarr documentation and the service version ledger. Use when the user asks to check, update, upgrade, pull, or install Sonarr.
---

# Update Sonarr

Use `GPT-5.4 Mini` with `medium` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run `powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-sonarr\scripts\Update-DockerService.ps1 -ServiceName sonarr -Json`.
2. For an update request, run that command once with `-Apply`; it checks the digest before changing anything.
3. When `updated` is true, read `docs/services/sonarr.md`, then use `apply_patch` to update the current version/image details and append a dated update-history entry. The helper updates `docs/service_versions.json`.
4. When already current, do not read or edit the service document.

The helper compares the registry digest without pulling in check-only mode, recreates only Sonarr, and verifies the stack. Do not trigger searches, downloads, imports, path repairs, or Plex refreshes. If it fails, report the concise failure and stop.
