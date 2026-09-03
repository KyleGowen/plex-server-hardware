# Radarr

## Purpose

Radarr manages movie acquisition and imports. It monitors wanted movies, evaluates releases through configured indexers, sends approved downloads to qBittorrent, and imports completed movies into movie library folders that Plex reads.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `radarr` |
| Image | `lscr.io/linuxserver/radarr:latest` |
| Current version | `6.3.0.10514` (`6.3.0.10514-ls314`) |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\radarr` |
| Web UI | `http://localhost:7878` |
| Docker restart policy | `unless-stopped` |

## Current Configuration

As of `2026-06-15`, Radarr runs in Docker while qBittorrent runs natively on Windows.

| Item | Value |
|---|---|
| Download client host | `host.docker.internal` |
| Download client port | `8080` |
| Download category | `radarr` |
| Remote path mapping | `I:\torrentfiles\` to `/downloads/` |
| Movies root 1 | `/movies/movies1` mapped from `D:\` |
| Movies root 2 | `/movies/movies2` mapped from `F:\` |
| Movies root 3 | `/movies/movies3` mapped from `E:\` |

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
| Native qBittorrent at `host.docker.internal:8080` | Sends approved movie releases |
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
- Keep the download client target as native qBittorrent at `host.docker.internal:8080`, category `radarr`, with the `I:\torrentfiles\` to `/downloads/` remote path mapping.
- For bulk imports, prefer strict API-based matching and skip ambiguous remake/collection cases.
- Do not mass-edit paths until drive letters and root folders are confirmed.

## Current Gaps

- Confirm completed download handling with one controlled test.
- Keep Radarr API key and qBittorrent credentials out of repo docs and logs.

## Current Indexer State

| Indexer | Source | RSS | Automatic search | Interactive search |
|---|---|---|---|---|
| MoreThanTV | Prowlarr | Enabled in config | Treat as unavailable | Treat as unavailable |
| SpeedCD | Prowlarr | Enabled | Enabled | Enabled |

Prowlarr remains the active indexer layer for Radarr. Jackett is not part of the active Radarr routing.
As of 2026-08-17, treat MoreThanTV as dead/unavailable until fresh evidence shows it has recovered; expect Radarr searches to depend on SpeedCD unless another healthy indexer is added.

## Update History

### 2026-09-03

- Updated the LinuxServer container from Radarr `6.2.1.10461` (`6.2.1.10461-ls306`) to `6.3.0.10514` (`6.3.0.10514-ls314`).
- Recreated the container with existing persistent configuration.
- Verified the stack health check passed after startup and `/downloads` still mapped to `I:\`.

### 2026-06-15

- Updated the LinuxServer container from Radarr `6.1.1.10360` (`6.1.1.10360-ls303`) to `6.2.1.10461` (`6.2.1.10461-ls306`).
- Recreated only the Radarr container with the existing persistent configuration.
- Verified zero Radarr health issues after startup.
- Verified native qBittorrent remains enabled, the `I:\torrentfiles\` to `/downloads/` remote path mapping is unchanged, and all three movie roots remain accessible.

### 2026-08-17

- Operational assumption changed: MoreThanTV is considered dead/unavailable and should not be counted as a working Radarr source.
- No Radarr or Prowlarr setting was changed by this documentation update.
