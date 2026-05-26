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
| qBittorrent at `qbittorrent:8080` | Sends approved TV releases |
| qBittorrent category `tv-sonarr` | Keeps TV downloads categorized for imports and reporting |
| `/tv/tv1/TV Shows` | Imports to `J:\TV Shows` |
| `/tv/tv2/TV Shows` | Historically imported to `H:\TV Shows`; currently unsafe because `H:` is absent |
| Bazarr | Bazarr reads Sonarr metadata through the Sonarr API |

## Operational Rules

- Add series as monitored unless the user explicitly asks otherwise.
- Monitor normal seasons by default and leave specials/season 0 unmonitored unless requested.
- Do not trigger automatic searches/downloads unless the user explicitly asks for search/download behavior.
- Keep download client target as Docker-network `qbittorrent:8080` with shared `/downloads` paths.
- Do not mass-edit paths until drive letters and root folders are confirmed.
- Do not import, move, or repair series paths under `/tv/tv2` while `H:` / TV 2 is absent. On 2026-05-26 Docker showed `/tv/tv2` as a tiny full placeholder filesystem, not the intended TV drive.

## Current Gaps

- Confirm completed download handling with one controlled test.
- Decide the replacement/missing-drive plan for `H:` / TV 2 before allowing any `/tv/tv2` imports.
- Confirm existing unmapped folders/import decisions before any bulk import.
- Keep Sonarr API key and qBittorrent credentials out of repo docs and logs.
