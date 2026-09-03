# Sonarr

## Purpose

Sonarr manages TV series acquisition and imports. It monitors series, evaluates releases through configured indexers, sends approved downloads to qBittorrent, and imports completed TV episodes into the TV library folders that Plex reads.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `sonarr` |
| Image | `lscr.io/linuxserver/sonarr:latest` |
| Current version | `4.0.19.2979` (`4.0.19.2979-ls322`) |
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

## Troubleshooting Notes

### Docker Desktop backend stuck while Sonarr port is open

On 2026-08-01, Sonarr API calls timed out even though TCP port `8989` was open. `docker ps` returned `Docker Desktop is unable to start`, `wsl -l -v` showed `docker-desktop` stopped, and the port listener belonged to Docker Desktop backend processes. A clean restart of the user-level Docker Desktop processes restored the WSL engine and all Arr containers without touching media drives or qBittorrent state:

```powershell
Get-Process -Name 'Docker Desktop','com.docker.backend','com.docker.proxy','docker' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 8
Start-Process -FilePath 'C:\Program Files\Docker\Docker\Docker Desktop.exe' -WindowStyle Hidden
```

After Docker recovers, run the stack health check before trusting imports or adding media:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\Kyle\.codex\skills\plex-stack-health-check\scripts\Test-PlexStackHealth.ps1 -SummaryOnly
```

### Startup database lock during add

Immediately after Sonarr starts, startup tasks such as housekeeping, backup, database vacuum, and refresh can briefly lock `sonarr.db`. On 2026-08-01, adding `President Curtis` returned `500 Internal Server Error` and Sonarr logged `System.Data.SQLite.SQLiteException ... database is locked` while `RefreshSeries` and startup commands were still active. Check command state and wait for startup work to settle before retrying:

```powershell
$config = [xml](Get-Content -LiteralPath 'C:\media-stack\config\sonarr\config.xml' -Raw)
$headers = @{ 'X-Api-Key' = [string]$config.Config.ApiKey }
Invoke-RestMethod -Method Get -Uri 'http://127.0.0.1:8989/api/v3/command' -Headers $headers |
    Select-Object id,name,status,message
```

## Update History

### 2026-09-03

- Pulled the latest LinuxServer Sonarr image and recreated the container with existing persistent configuration.
- Verified the stack health check passed after startup and `/downloads` still mapped to `I:\`.

## Current Gaps

- Confirm completed download handling with one controlled test.
- Verify all TV root mounts before allowing any `/tv/tv2` or `/tv/tv3` imports.
- Confirm existing unmapped folders/import decisions before any bulk import.
- Keep Sonarr API key and qBittorrent credentials out of repo docs and logs.

## Current Indexer State

| Indexer | Source | RSS | Automatic search | Interactive search |
|---|---|---|---|---|
| MoreThanTV | Prowlarr | Enabled in config | Treat as unavailable | Treat as unavailable |
| SpeedCD | Prowlarr | Enabled | Enabled | Enabled |

On 2026-05-31, SpeedCD briefly caused Sonarr searches to appear empty because SpeedCD search worked but torrent grabs returned an HTML account restriction page. Sonarr suppressed SpeedCD after repeated failures. After the SpeedCD account restriction was lifted, Prowlarr torrent-download validation passed, SpeedCD was re-enabled, and a Bob's Burgers S16E10 interactive search returned SpeedCD results. See `docs/indexer_outage_2026-05-31.md`.
As of 2026-08-17, treat MoreThanTV as dead/unavailable until fresh evidence shows it has recovered; expect Sonarr searches to depend on SpeedCD unless another healthy indexer is added.
