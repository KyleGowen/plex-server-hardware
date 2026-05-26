# Radarr

## Purpose

Radarr manages movie acquisition and imports. It monitors wanted movies, evaluates releases through configured indexers, sends approved downloads to qBittorrent, and imports completed movies into movie library folders that Plex reads.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `radarr` |
| Image | `lscr.io/linuxserver/radarr:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\radarr` |
| Web UI | `http://localhost:7878` |
| Docker restart policy | `unless-stopped` |

## Reads From

| Source | Purpose |
|---|---|
| Prowlarr | Movie indexers synced as Torznab feeds |
| qBittorrent | Queue and download status |
| Movie root folders | Existing movie folders, files, imports |
| Radarr config/database | Movies, profiles, root folders, download clients |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| qBittorrent at `qbittorrent:8080` | Sends approved movie releases |
| qBittorrent category `radarr` | Keeps movie downloads categorized for imports and reporting |
| `/movies/movies1/Movies` | Imports to `D:\Movies` |
| `/movies/movies2/Movies` | Imports to `F:\Movies` |
| `/movies/movies3/Movies` | Imports to `E:\Movies` |
| Bazarr | Bazarr reads Radarr metadata through the Radarr API |

## Recent Movie Adds

On 2026-05-24, these movies were added or updated in Radarr as monitored `Ultra-HD` entries without triggering searches/downloads:

| Movie | Radarr ID | Path |
|---|---:|---|
| `Project Hail Mary` | 1070 | `/movies/movies1/Movies/Project Hail Mary (2026)` |
| `Avatar: Fire and Ash` | 1071 | `/movies/movies1/Movies/Avatar - Fire and Ash (2025)` |
| `Hoppers` | 1072 | `/movies/movies1/Movies/Hoppers (2026)` |
| `Scream 7` | 1073 | `/movies/movies1/Movies/Scream 7 (2026)` |
| `GOAT` | 1074 | `/movies/movies1/Movies/GOAT (2026)` |
| `Zootopia 2` | 111 | `/movies/movies1/Movies/Zootopia 2 (2025)` |

## Operational Rules

- Add movies as monitored unless the user explicitly asks otherwise.
- Do not trigger automatic searches/downloads unless the user explicitly asks for search/download behavior.
- Keep download client target as Docker-network `qbittorrent:8080`, category `radarr`, with shared `/downloads` paths.
- For bulk imports, prefer strict API-based matching and skip ambiguous remake/collection cases.
- Do not mass-edit paths until drive letters and root folders are confirmed.

## Current Gaps

- Confirm completed download handling with one controlled test.
- Keep Radarr API key and qBittorrent credentials out of repo docs and logs.
