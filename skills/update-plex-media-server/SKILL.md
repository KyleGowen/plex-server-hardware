---
name: update-plex-media-server
description: Check for and install stable Plex Media Server updates on Kyle's native Windows Plex server, verify the official installer checksum and running server version, and update the Plex service documentation and version ledger. Use when the user asks to check, update, upgrade, or install Plex Media Server.
---

# Update Plex Media Server

Use `GPT-5.4 Mini` with `high` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run and report:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-plex-media-server\scripts\Update-PlexMediaServer.ps1 -Json
```

2. For an update or install request, run once with `-Apply`; the helper checks before changing anything:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-plex-media-server\scripts\Update-PlexMediaServer.ps1 -Apply -Json
```

3. If `updated` is true, read `docs/services/plex.md`, then use `apply_patch` to update the observed version and append a dated update-history entry. The script updates `docs/service_versions.json` itself.
4. If the installed version is already current, do not read or edit the service document; the apply run still records the check in the ledger.

The helper uses Plex's official Windows x64 catalog, verifies SHA-1 before installation, preserves the prior running state, and confirms the version through `/identity`. It refuses to interrupt active streams unless `-AllowActiveStreams` is explicitly approved. Do not trigger library refreshes, scans, metadata changes, or media operations.

If the helper fails, report the concise failure and stop. Do not substitute an unverified download or print the Plex token.
