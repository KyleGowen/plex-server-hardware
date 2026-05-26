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
| Active Docker services | Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, qBittorrent, Unpackerr |
| Optional legacy service | Jackett via `legacy-jackett` compose profile |
| Config root | `C:\media-stack\config` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Download root | `I:\torrentfiles` on Windows, `/downloads` in containers |

---

# Software Inventory

| Software | Role | Deployment | Current state | Config / data path | Port / URL | Service doc |
|---|---|---|---|---|---|---|
| Plex Media Server | Media library server, metadata manager, streaming server, transcoding engine | Native Windows | Installed: `Plex Media Server 1.43.2.10687 (x64)`; `PlexUpdateService` observed running | `C:\Users\Kyle\AppData\Local\Plex Media Server` observed | `http://localhost:32400/web` | [services/plex.md](services/plex.md) |
| Sonarr | TV monitoring, release selection, downloads, imports | Docker | Running via compose | `C:\media-stack\config\sonarr` | `http://localhost:8989` | [services/sonarr.md](services/sonarr.md) |
| Radarr | Movie monitoring, release selection, downloads, imports | Docker | Running via compose | `C:\media-stack\config\radarr` | `http://localhost:7878` | [services/radarr.md](services/radarr.md) |
| Prowlarr | Indexer management for Sonarr/Radarr | Docker | Running via compose | `C:\media-stack\config\prowlarr` | `http://localhost:9696` | [services/prowlarr.md](services/prowlarr.md) |
| Bazarr | Subtitle automation for TV and movies | Docker | Running via compose; connected to Sonarr/Radarr | `C:\media-stack\config\bazarr` | `http://localhost:6767` | [services/bazarr.md](services/bazarr.md) |
| Tautulli | Plex monitoring, stream history, usage analytics | Docker | Running via compose; first-run Plex setup still needs confirmation | `C:\media-stack\config\tautulli` | `http://localhost:8181` | [services/tautulli.md](services/tautulli.md) |
| Uptime Kuma | Service health monitoring, uptime history, outage/recovery notifications | Docker | Running via compose; monitors created and reporting healthy | `C:\media-stack\config\uptime-kuma` | `http://localhost:3001` | [services/uptime-kuma.md](services/uptime-kuma.md) |
| qBittorrent | Torrent download client | Docker | Running via compose | `C:\media-stack\config\qbittorrent` | `http://localhost:8080` | [services/qbittorrent.md](services/qbittorrent.md) |
| Unpackerr | Automated archive extraction | Docker | Running via compose; app integrations need confirmation | `C:\media-stack\config\unpackerr` | No normal Web UI | [services/unpackerr.md](services/unpackerr.md) |
| Jackett | Legacy Torznab/indexer fallback | Optional Docker profile | Disabled unless profile is used | `C:\media-stack\config\jackett` if enabled | `http://localhost:9117` if enabled | [services/jackett.md](services/jackett.md) |

---

# Current Software Connections

| Source | Reads from | Writes to / sends to | Purpose |
|---|---|---|---|
| Plex | Windows media folders | Plex clients; local metadata database | Serves libraries and streams media |
| Tautulli | Plex HTTP API | Tautulli history database; optional notifications | Tracks Plex sessions, history, users, and bandwidth |
| Uptime Kuma | Plex, Docker service HTTP endpoints | Uptime history database; optional notifications | Tracks whether services are reachable and when they recover |
| Sonarr | Prowlarr, TV root folders, qBittorrent queue | qBittorrent, TV media folders | TV acquisition and import |
| Radarr | Prowlarr, movie root folders, qBittorrent queue | qBittorrent, movie media folders | Movie acquisition and import |
| Prowlarr | Torrent indexers | Sonarr/Radarr app sync | Central indexer management |
| Bazarr | Sonarr, Radarr, media folders, subtitle providers | Subtitle files beside media | Subtitle discovery and writing |
| qBittorrent | Torrent swarms, qBittorrent config | `/downloads` | Downloads releases for Sonarr/Radarr |
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
| 7-Zip | Archive inspection/extraction | Installed |
| Notepad++ | Text/config/log editor | Installed |
| Google Chrome | Browser for local web UIs | Installed |
| CrystalDiskInfo | SMART monitoring | Not found in installed-app scan; recommended for stability/storage baseline |

---

# Current Gaps

| Area | Gap |
|---|---|
| Random crashing | Unresolved; track in [current_stability_crash_tracker.md](current_stability_crash_tracker.md) |
| Tautulli | Confirm/complete Plex first-run setup and one playback history test |
| Uptime Kuma | Add notification provider if desired |
| qBittorrent | Confirm Web UI credentials are not default; add startup mount guard if desired |
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
- Jackett is optional legacy fallback only.
- Docker download path `/downloads` maps to `I:\torrentfiles`.
- A healthy qBittorrent container must report `/downloads` as `I:\` with the real multi-terabyte capacity from inside Docker.
- Usenet tools, Overseerr/Jellyseerr, VPN tools, and dedicated backup tools are not confirmed current installs.
