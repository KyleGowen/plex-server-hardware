---
name: update-bazarr
description: Check for and apply updates to Kyle's Bazarr Docker container, recreate only Bazarr when its configured image digest changes, verify stack health, and update Bazarr documentation and the service version ledger. Use when the user asks to check, update, upgrade, pull, or install Bazarr.
---

# Update Bazarr

Use `GPT-5.4 Mini` with `medium` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run `powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-bazarr\scripts\Update-DockerService.ps1 -ServiceName bazarr -Json`.
2. For an update request, run that command once with `-Apply`; it checks the digest before changing anything.
3. When `updated` is true, read `docs/services/bazarr.md`, then use `apply_patch` to update version/image details and append a dated update-history entry. The helper updates `docs/service_versions.json`.
4. When already current, do not read or edit the service document.

Do not write subtitles, alter providers, change media paths, or touch the absent `/tv/tv2` root. If the helper fails, report the concise failure and stop.
