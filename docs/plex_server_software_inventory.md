# Plex Server Software Inventory

## Purpose

Use this file as the central software inventory for the Windows-native Plex server and Docker media stack.

Per-service details live in `docs/services/`. This file is the summary table and connection index.

---

# Current Deployment

| Area | Current decision |
|---|---|
| Plex Media Server | Native Windows install |
| Supporting media stack | Docker containers |
| Active Docker services | Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, Homarr, Unpackerr |
| Native Windows download client | qBittorrent |
| Optional legacy service | Jackett via `legacy-jackett` compose profile |
| Config root | `C:\media-stack\config` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Download root | `I:\torrentfiles` on Windows; `/downloads` in Arr/Unpackerr containers |

---

# Software Inventory

| Software | Role | Deployment | Current state | Config / data path | Port / URL | Service doc |
|---|---|---|---|---|---|---|
| Plex Media Server | Media library server, metadata manager, streaming server, transcoding engine | Native Windows | Installed: `Plex Media Server 1.43.2.10687 (x64)`; `PlexUpdateService` observed running | `C:\Users\Kyle\AppData\Local\Plex Media Server` observed | `http://localhost:32400/web` | [services/plex.md](services/plex.md) |
| Sonarr | TV monitoring, release selection, downloads, imports | Docker | Running via compose | `C:\media-stack\config\sonarr` | `http://localhost:8989` | [services/sonarr.md](services/sonarr.md) |
| Radarr | Movie monitoring, release selection, downloads, imports | Docker | Running via compose | `C:\media-stack\config\radarr` | `http://localhost:7878` | [services/radarr.md](services/radarr.md) |
| Prowlarr | Indexer management for Sonarr/Radarr | Docker | Running via compose | `C:\media-stack\config\prowlarr` | `http://localhost:9696` | [services/prowlarr.md](services/prowlarr.md) |
| Bazarr | Subtitle automation for TV and movies | Docker | Running via compose; connected to Sonarr/Radarr | `C:\media-stack\config\bazarr` | `http://localhost:6767` | [services/bazarr.md](services/bazarr.md) |
| Tautulli | Plex monitoring, stream history, usage analytics | Docker | Running via compose; first-run Plex setup notes documented, setup still needs confirmation | `C:\media-stack\config\tautulli` | `http://localhost:8181` | [services/tautulli.md](services/tautulli.md) |
| Uptime Kuma | Service health monitoring, uptime history, outage/recovery notifications | Docker | Running via compose; monitors created and reporting healthy | `C:\media-stack\config\uptime-kuma` | `http://localhost:3001` | [services/uptime-kuma.md](services/uptime-kuma.md) |
| Homarr | Local dashboard for Plex ecosystem links, widgets, and optional integrations | Docker | Running via compose; conservative no-Docker-socket deployment | `C:\media-stack\config\homarr` | `http://localhost:7575` | [services/homarr.md](services/homarr.md) |
| qBittorrent | Torrent download client | Native Windows | Running outside Docker | `%APPDATA%\qBittorrent`; tracked conservative config at `C:\plex-server\config\qbittorrent\native-conservative` | `http://localhost:8080` | [services/qbittorrent.md](services/qbittorrent.md) |
| Unpackerr | Automated archive extraction | Docker | Running via compose; app integrations need confirmation | `C:\media-stack\config\unpackerr` | No normal Web UI | [services/unpackerr.md](services/unpackerr.md) |
| Jackett | Legacy Torznab/indexer fallback | Optional Docker profile | Stopped; config may exist from 2026-05-31 SpeedCD fallback test | `C:\media-stack\config\jackett` if enabled | `http://localhost:9117` if enabled | [services/jackett.md](services/jackett.md) |

---

# Current Software Connections

| Source | Reads from | Writes to / sends to | Purpose |
|---|---|---|---|
| Plex | Windows media folders | Plex clients; local metadata database | Serves libraries and streams media |
| Tautulli | Plex HTTP API | Tautulli history database; optional notifications | Tracks Plex sessions, history, users, and bandwidth |
| Uptime Kuma | Plex, Docker service HTTP endpoints | Uptime history database; optional notifications | Tracks whether services are reachable and when they recover |
| Homarr | Plex ecosystem Web UIs and optional service APIs | Homarr app database only | Provides a single dashboard for local media-stack operation |
| Sonarr | Prowlarr, TV root folders, qBittorrent queue | qBittorrent, TV media folders | TV acquisition and import |
| Radarr | Prowlarr, movie root folders, qBittorrent queue | qBittorrent, movie media folders | Movie acquisition and import |
| Prowlarr | Torrent indexers | Sonarr/Radarr app sync | Central indexer management |
| Bazarr | Sonarr, Radarr, media folders, subtitle providers | Subtitle files beside media | Subtitle discovery and writing |
| qBittorrent | Torrent swarms, qBittorrent config | `I:\torrentfiles` | Downloads releases for Sonarr/Radarr |
| Unpackerr | Download folders and Starr app APIs | Extracted files in download paths | Extracts archived downloads for import |
| Jackett | Torrent indexers | Torznab feeds for Arr apps | Legacy fallback when Prowlarr is not enough |

---

# Recovery / Admin Software

| Software | Role | Notes |
|---|---|---|
| Docker Desktop | Container runtime for media stack | Installed and able to run the stack from CLI |
| Docker Compose | Stack orchestration | Use `docker compose -f C:\plex-server\docker-compose.media.yml ...` |
| MSI drivers | Board chipset, LAN, Wi-Fi, Bluetooth, audio | See driver install status doc |
| NVIDIA driver | RTX 3050 display and hardware transcoding support | NVIDIA Studio Driver `596.36` installed in snapshot |
| Intel Driver & Support Assistant | Intel driver detection/update helper | Installed; avoid firmware/BIOS changes unless explicitly planned |
| LibreHardwareMonitor | Hardware sensor source for thermal crash logging | Installed via winget package `LibreHardwareMonitor.LibreHardwareMonitor` version `0.9.6`; project logger writes searchable CSV/JSONL under `C:\plex-server\docs\crash_logs\thermal`; see [thermal_monitoring.md](thermal_monitoring.md) |
| Core Temp | Intel CPU core temperature source for thermal crash logging | Installed via winget package `ALCPU.CoreTemp` version `1.20.1`; project logger reads Core Temp shared memory to capture CPU core/package thermal data; see [thermal_monitoring.md](thermal_monitoring.md) |
| smartmontools / smartctl | Serial-specific SMART drive temperature source | Installed via winget package `smartmontools.smartmontools` version `7.5`; project logger records drive temperatures as `Smartctl` rows labeled by model and serial; see [thermal_monitoring.md](thermal_monitoring.md) |
| 7-Zip | Archive inspection/extraction | Installed |
| Notepad++ | Text/config/log editor | Installed |
| Google Chrome | Browser for local web UIs | Installed |
| CrystalDiskInfo | SMART monitoring | Not found in installed-app scan; recommended for stability/storage baseline |

---

# Current Gaps

| Area | Gap |
|---|---|
| Random crashing | Unresolved; track in [current_stability_crash_tracker.md](current_stability_crash_tracker.md) |
| Tautulli | Confirm/complete Plex first-run setup using [services/tautulli.md](services/tautulli.md), then run one playback activity/history test |
| Uptime Kuma | Add notification provider if desired |
| qBittorrent | Confirm Web UI credentials are not default; add startup guard for `I:\torrentfiles` if desired |
| Sonarr/Radarr | Confirm completed download handling with controlled tests |
| Bazarr | Confirm one controlled subtitle search/download/write |
| Unpackerr | Configure or confirm Sonarr/Radarr integrations |
| Backups | Create backup plan for Plex metadata and Docker app configs |
| SMART baseline | Capture current SMART state for OS SSD and all media/data HDDs |

---

# Assumptions

- Plex remains native Windows.
- qBittorrent is the only confirmed downloader.
- Prowlarr is the active indexer layer.
- Jackett is optional legacy fallback only and is currently stopped.
- Docker download path `/downloads` maps to `I:\torrentfiles` for Sonarr, Radarr, and Unpackerr.
- qBittorrent is native Windows and should be checked through `127.0.0.1:8080` plus its Windows save paths, not through Docker.
- Usenet tools, Overseerr/Jellyseerr, VPN tools, and dedicated backup tools are not confirmed current installs.
