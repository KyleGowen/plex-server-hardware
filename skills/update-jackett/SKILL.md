---
name: update-jackett
description: Check for and pull updates to Kyle's optional legacy Jackett Docker image while preserving whether Jackett is disabled, and update Jackett documentation and the service version ledger. Use when the user asks to check, update, upgrade, pull, or install the legacy Jackett image; never enable the service unless separately requested.
---

# Update Jackett

Use `GPT-5.4 Mini` with `medium` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run `powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-jackett\scripts\Update-DockerService.ps1 -ServiceName jackett -Json`.
2. For an update request, run that command once with `-Apply`; it checks the locally pulled image digest before changing anything.
3. When `updated` is true, read `docs/services/jackett.md`, then use `apply_patch` to update the pulled image version and append a dated update-history entry. State that the disabled service was not enabled. The helper updates `docs/service_versions.json`.
4. When already current, do not read or edit the service document.

The helper pulls the profile image but leaves a stopped or absent Jackett service stopped. Do not enable Jackett, route Arr applications through it, change indexers, or expose tracker credentials. If the helper fails, report the concise failure and stop.
