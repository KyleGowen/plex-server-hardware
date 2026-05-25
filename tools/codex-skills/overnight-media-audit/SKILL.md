---
name: overnight-media-audit
description: Check what new media downloaded, completed, imported, or got stuck overnight in Kyle's Plex Docker Arr stack. Use when the user asks variants of "what new media downloaded overnight?", "what landed last night?", "anything new in Sonarr/Radarr/qBittorrent?", or wants a concise overnight media-download report for C:\plex-server.
---

# Overnight Media Audit

## Goal

Answer with minimal discovery:

- What qBittorrent added/completed during the overnight window.
- What Sonarr/Radarr imported during the same window.
- Whether download-client auth/health blocked new media.
- Any stuck Sonarr/Radarr queue titles.

Default overnight window: from yesterday at 6:00 PM Pacific to now. If the user gives a different window, use it.

## Fast Path

Run the bundled script from `C:\plex-server`:

```powershell
powershell -ExecutionPolicy Bypass -File tools\codex-skills\overnight-media-audit\scripts\Get-OvernightMedia.ps1
```

Optional cutoff:

```powershell
powershell -ExecutionPolicy Bypass -File tools\codex-skills\overnight-media-audit\scripts\Get-OvernightMedia.ps1 -SinceLocal "2026-05-24 18:00"
```

## Reporting

Keep the final answer short:

1. State whether anything new downloaded or imported.
2. List imported media first, then qBit-only completions.
3. If no new media, say so plainly.
4. Include current blockers only if present: qBit auth failures, Arr health errors, or queue items stuck as `downloadClientUnavailable`.
5. If qBit login is unavailable, say qBit-only completion data could not be checked and rely on Sonarr/Radarr history plus health/queue.

Do not trigger searches, downloads, imports, refreshes, deletes, moves, or torrent actions. Read-only only.

## Secret Handling

The script reads Sonarr/Radarr API keys and qBittorrent credentials from local runtime/config state. Never print API keys, cookies, passkeys, tokens, or passwords. If qBit login fails, report the auth failure, not the credential.
