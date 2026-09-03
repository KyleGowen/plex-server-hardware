---
name: update-tautulli
description: Check for and apply updates to Kyle's Tautulli Docker container, recreate only Tautulli when its configured image digest changes, verify stack health, and update Tautulli documentation and the service version ledger. Use when the user asks to check, update, upgrade, pull, or install Tautulli.
---

# Update Tautulli

Use `GPT-5.4 Mini` with `medium` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run `powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-tautulli\scripts\Update-DockerService.ps1 -ServiceName tautulli -Json`.
2. For an update request, run that command once with `-Apply`; it checks the digest before changing anything.
3. When `updated` is true, read `docs/services/tautulli.md`, then use `apply_patch` to update version/image details and append a dated update-history entry. The helper updates `docs/service_versions.json`.
4. When already current, do not read or edit the service document.

Do not expose Plex tokens, alter notification settings, or change Tautulli history. If the helper fails, report the concise failure and stop.
