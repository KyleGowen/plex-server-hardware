# qBittorrent

## Purpose

qBittorrent is the torrent download client for the Docker media stack. Sonarr and Radarr send approved releases to it, and completed downloads are imported back into TV/movie folders.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `qbittorrent` |
| Image | `lscr.io/linuxserver/qbittorrent:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\qbittorrent` |
| Web UI | `http://localhost:8080` |
| Torrent port | `6881/tcp` and `6881/udp` |
| Docker restart policy | `unless-stopped` |

## Reads From

| Source | Purpose |
|---|---|
| Sonarr | TV download requests |
| Radarr | Movie download requests |
| Torrent swarms/trackers | Downloads content |
| qBittorrent config | Credentials, paths, categories, resume data |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| `/downloads` | Default completed download path mapped from `I:\torrentfiles` |
| `/downloads/incomplete` | Incomplete download path |
| Sonarr/Radarr APIs | Queue/download status is read by Arr apps |
| Unpackerr | Unpackerr reads completed archived downloads from shared paths |

## Categories

| Category | Used by |
|---|---|
| `tv-sonarr` | Sonarr |
| `radarr` | Radarr |

## Startup Mount Rule

Before trusting qBittorrent after boot, crash, drive reconnect, Docker restart, or WSL restart:

```powershell
Test-Path I:\torrentfiles
docker exec qbittorrent sh -c "df -h /downloads"
```

Healthy output should show `/downloads` mounted from `I:\` with multi-terabyte capacity. If Docker reports a tiny full filesystem, follow [../qbittorrent_startup_recovery.md](../qbittorrent_startup_recovery.md).

## Operational Rules

- Treat Web UI credentials, session cookies, tracker URLs, passkeys, hashes, and magnet links as secrets unless the user explicitly asks to inspect one locally.
- Do not start, stop, remove, delete, move, or recheck torrents until categories, save paths, incomplete paths, and root-folder mappings are confirmed.
- Do not keep restarting only qBittorrent when `/downloads` is a stale bad mount; restart Docker/WSL per the runbook.

## Current Gaps

- Confirm Web UI credentials are changed from defaults.
- Confirm category behavior with one controlled Sonarr/Radarr grab.
- Add a startup guard if desired so torrents do not resume before `/downloads` is verified.
