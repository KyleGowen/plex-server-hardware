---
name: update-qbittorrent
description: Check for and install stable qBittorrent updates on Kyle's native Windows media downloader, verify its required download root and Web UI, and update the qBittorrent service documentation and version ledger. Use when the user asks to check, update, upgrade, or install qBittorrent.
---

# Update qBittorrent

Use `GPT-5.4 Mini` with `high` reasoning when selecting a model for this task. A skill cannot switch its own model; do not stop solely because the task was launched on another capable model.

## Workflow

1. For a check-only request, run and report:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\update-qbittorrent\scripts\Update-qBittorrent.ps1 -Json
```

2. For an update or install request, run the same helper once with `-Apply -Json`; it checks before changing anything.
3. If `updated` is true, read `docs/services/qbittorrent.md`, then use `apply_patch` to update the version row and append a dated maintenance-log entry. The script updates `docs/service_versions.json` itself.
4. If already current, do not read or edit the service document.

The helper uses the stable `winget` package, requires `I:\torrentfiles`, preserves whether qBittorrent was running, and verifies the native Web UI after an update. Do not start, stop, remove, move, recheck, or inspect individual torrents. Never expose Web UI credentials, cookies, tracker URLs, hashes, magnets, or passkeys.

If the helper fails, report the concise failure and stop instead of improvising package or torrent operations.
