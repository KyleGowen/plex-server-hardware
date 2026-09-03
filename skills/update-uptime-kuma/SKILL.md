---
name: update-uptime-kuma
description: Check for and apply safe updates to Kyle's Uptime Kuma Docker container within its configured v1 release line, verify container health, and update Uptime Kuma documentation and the service version ledger. Use when the user asks to check, update, upgrade, pull, or install Uptime Kuma; do not perform a v2 migration without separate approval.
---

# Update Uptime Kuma

Use `GPT-5.4 Mini` with `high` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run `powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-uptime-kuma\scripts\Update-DockerService.ps1 -ServiceName uptime-kuma -Json`.
2. For an update request, run that command once with `-Apply`; it checks the digest and enforces the configured v1 image line before changing anything.
3. When `updated` is true, read `docs/services/uptime-kuma.md`, then use `apply_patch` to update the current version and append a dated update-history entry. The helper updates `docs/service_versions.json`.
4. When already current, do not read or edit the service document.

Treat a requested v1-to-v2 move as a separate breaking migration requiring explicit approval and a backup plan. Do not change monitors, users, notifications, status pages, or stored credentials. If the helper fails, report the concise failure and stop.
