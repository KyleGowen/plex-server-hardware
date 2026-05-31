# Sonarr

## Purpose

Sonarr manages TV series acquisition and imports. It monitors series, evaluates releases through configured indexers, sends approved downloads to qBittorrent, and imports completed TV episodes into the TV library folders that Plex reads.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `sonarr` |
| Image | `lscr.io/linuxserver/sonarr:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\sonarr` |
| Web UI | `http://localhost:8989` |
| Docker restart policy | `unless-stopped` |

## Current Configuration

As of `2026-05-30`, Sonarr runs in Docker while qBittorrent runs natively on Windows.

| Item | Value |
|---|---|
| Download client host | `host.docker.internal` |
| Download client port | `8080` |
| Download category | `tv-sonarr` |
| Remote path mapping | `I:\torrentfiles\` to `/downloads/` |
| TV root 1 | `/tv/tv1` mapped from `J:\` |
| TV root 2 | `/tv/tv2` mapped from `H:\` |
| TV root 3 | `/tv/tv3` mapped from `G:\` |

## Reads From

| Source | Purpose |
|---|---|
| Prowlarr | TV indexers synced as Torznab feeds |
| qBittorrent | Queue and download status |
| TV root folders | Existing series folders, episode files, imports |
| Sonarr config/database | Series, profiles, root folders, download clients |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Native qBittorrent at `host.docker.internal:8080` | Sends approved TV releases |
| qBittorrent category `tv-sonarr` | Keeps TV downloads categorized for imports and reporting |
| `/tv/tv1/TV Shows` | Imports to `J:\TV Shows` |
| `/tv/tv2/TV Shows` | Imports to `H:\TV Shows` when `H:` / TV 2 is present |
| `/tv/tv3/TV Shows` | Imports to `G:\TV Shows` |
| Bazarr | Bazarr reads Sonarr metadata through the Sonarr API |

## Operational Rules

- Add series as monitored unless the user explicitly asks otherwise.
- Monitor normal seasons by default and leave specials/season 0 unmonitored unless requested.
- Do not trigger automatic searches/downloads unless the user explicitly asks for search/download behavior.
- Keep Sonarr's download client target as native qBittorrent at `host.docker.internal:8080`, category `tv-sonarr`, with the `I:\torrentfiles\` to `/downloads/` remote path mapping.
- Do not mass-edit paths until drive letters and root folders are confirmed.
- Do not import, move, or repair series paths under `/tv/tv2` while `H:` / TV 2 is absent. On 2026-05-30 `H:` is present again for the current test, but verify it after any crash/reboot before trusting imports.

## Current Gaps

- Confirm completed download handling with one controlled test.
- Verify all TV root mounts before allowing any `/tv/tv2` or `/tv/tv3` imports.
- Confirm existing unmapped folders/import decisions before any bulk import.
- Keep Sonarr API key and qBittorrent credentials out of repo docs and logs.

## Current Indexer State

| Indexer | Source | RSS | Automatic search | Interactive search |
|---|---|---|---|---|
| MoreThanTV | Prowlarr | Enabled | Enabled | Enabled |
| SpeedCD | Prowlarr | Enabled | Enabled | Enabled |

On 2026-05-31, SpeedCD briefly caused Sonarr searches to appear empty because SpeedCD search worked but torrent grabs returned an HTML account restriction page. Sonarr suppressed SpeedCD after repeated failures. After the SpeedCD account restriction was lifted, Prowlarr torrent-download validation passed, SpeedCD was re-enabled, and a Bob's Burgers S16E10 interactive search returned SpeedCD results. See `docs/indexer_outage_2026-05-31.md`.
