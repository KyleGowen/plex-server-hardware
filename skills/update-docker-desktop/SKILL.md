---
name: update-docker-desktop
description: Check for and install stable Docker Desktop updates on Kyle's Windows Plex server, wait for the Docker engine to recover, validate the complete media stack, and update Docker runtime documentation and the version ledger. Use when the user asks to check, update, upgrade, or install Docker Desktop for the Plex ecosystem.
---

# Update Docker Desktop

Use `GPT-5.4 Mini` with `high` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run and report:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-docker-desktop\scripts\Update-DockerDesktop.ps1 -Json
```

2. For an update or install request, run the same helper once with `-Apply -Json`; it checks before changing anything.
3. If `updated` is true, read `docs/services/docker-desktop.md`, then use `apply_patch` to update Docker Desktop and engine versions and append a dated history entry. The script updates `docs/service_versions.json` itself.
4. If already current, do not read or edit the service document.

The helper uses the stable `winget` package, waits for the engine, and runs the existing `plex-stack-health-check`. Do not change compose definitions, service settings, paths, profiles, or Docker data. If the helper fails, report the concise failure and stop.
