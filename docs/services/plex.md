# Plex Media Server

## Purpose

Plex is the native Windows media server. It owns the media libraries, metadata, streaming, remote access, and transcoding experience. It does not acquire media; Sonarr and Radarr manage acquisition, qBittorrent downloads, and Plex serves the organized files after import.

## Deployment

| Item | Value |
|---|---|
| Deployment | Native Windows application |
| Observed version | `Plex Media Server 1.43.2.10687 (x64)` |
| Observed data path | `C:\Users\Kyle\AppData\Local\Plex Media Server` |
| Local Web UI | `http://localhost:32400/web` |
| Update service | `PlexUpdateService` observed running |
| Library sections | TV Shows section `1`; Movies section `2` |

## Reads From

| Source | Purpose |
|---|---|
| Windows media folders | Reads organized movie and TV files through native Windows paths |
| Plex data directory | Reads metadata, libraries, preferences, databases, plug-in support files |
| Plex account/auth | Server ownership, client access, remote access |
| GPU / iGPU | Hardware transcoding when enabled and available |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Plex metadata database | Library metadata, watch state, analysis, thumbnails, settings |
| Plex clients | Serves local and remote streams |
| Transcode temporary storage | Writes temporary transcoding output when transcoding |
| Tautulli | Tautulli reads Plex API activity/history; Plex does not depend on Tautulli |

## Operational Rules

- Treat the Plex token as a secret.
- Use the Plex HTTP API directly for checks until a trustworthy Plex MCP server is selected and approved.
- Prefer read-only checks first: server identity, library sections, metadata lookup, search, active activities, and scan status.
- Do not refresh libraries, edit metadata, delete items, or change server settings without explicit user confirmation.
- If Sonarr/Radarr show media imported but Plex does not show it, check Plex activity and the relevant library before proposing a refresh.
- After a confirmed refresh, verify the expected item appears instead of assuming success.

## Current Gaps

- Confirm Plex metadata backup status.
- Confirm current library paths against drive letters.
- Confirm hardware transcoding after the random-crash issue is understood.
- Confirm remote access once system stability is acceptable.
