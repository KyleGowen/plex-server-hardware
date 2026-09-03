# Docker Desktop

## Purpose

Docker Desktop supplies the Windows-hosted Docker engine used by the containerized Plex ecosystem services. Plex Media Server and qBittorrent remain native Windows applications.

## Deployment

| Item | Value |
|---|---|
| Deployment | Native Windows runtime |
| Docker Desktop version | `4.89.0` |
| Docker Engine version | `29.7.2` |
| Release channel | Stable |
| Package ID | `Docker.DockerDesktop` |
| Compose project | `plex-media-stack` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |

## Operational Rules

- Wait for `docker info` to succeed after an update before trusting container state.
- Run the `plex-stack-health-check` after Docker Desktop updates.
- Confirm `I:\torrentfiles` on Windows and `/downloads` inside Sonarr, Radarr, and Unpackerr after Docker or WSL restarts.
- Do not reset Docker data, change WSL storage, prune volumes, or rewrite compose settings as part of a routine update.
- Keep the optional `legacy-jackett` profile disabled unless it is intentionally needed.

## Update History

### 2026-09-03

- Updated Docker Desktop from `4.74.0` to `4.89.0` through the stable WinGet package.
- Verified Docker Engine `29.7.2` and passed the complete Plex stack health check after restart.
