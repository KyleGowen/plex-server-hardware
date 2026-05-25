# Plex Server Software Inventory

## Purpose

Use this file as the central software recovery list for the Windows-native Plex server.

Current deployment decision:

- Keep Plex Media Server as a native Windows install.
- Run the media automation stack in Docker: Sonarr, Radarr, Bazarr, qBittorrent, Jackett, and Unpackerr.
- Keep storage as normal Windows drive letters mounted into containers; do not change drive letters casually.

It records the known application stack, official download pages for current installers, what each tool does, what it connects to, and what must be verified before launching or repairing anything after the hardware rebuild.

---

# Recovery Safety Notes

- Do not launch Plex, Sonarr, Radarr, Bazarr, qBittorrent, Jackett, or Unpackerr until Windows drive letters are confirmed.
- Do not let any application mass-reorganize, rescan destructively, move files, or repair paths before drive-letter recovery is complete.
- Prefer reinstalling an application binary over overwriting or deleting its existing config/data folder.
- Before repairing or reinstalling an application, record:
  - Current installed version
  - Install path
  - Config/data path
  - Service vs system tray startup mode
  - Listening port / web UI URL
  - Connected apps and stored API keys, if visible
- Leave unknown values as `To verify after Windows boots`; do not guess.
- Preserve the OS SSD and search for existing application data before reinstalling Windows or Plex.

---

# Current Software Inventory

These applications are part of the confirmed Plex/media stack. Plex remains native Windows; the automation tools should be installed as Docker containers, not as separate native Windows apps.

| Software | Role | Deployment Target | Current Install State | Official Page / Image Source | Config / Data Path | Port / URL | Startup Mode | Connects To | Recovery Notes |
|---|---|---|---|---|---|---|---|---|---|
| Plex Media Server | Media library server, metadata manager, streaming server, and transcoding engine | Native Windows | Installed: `Plex Media Server 1.43.2.10687 (x64)`; `PlexUpdateService` running | [Plex Media Server downloads](https://www.plex.tv/media-server-downloads/) | `C:\Users\Kyle\AppData\Local\Plex Media Server` observed; verify before repair/reinstall | Typically `http://localhost:32400/web`; verify | Native app/service/update service | Media HDDs, Plex clients, NVIDIA GPU or Intel Quick Sync for hardware transcoding | Preserve the Plex data directory. Confirm library paths only after drive letters are restored. |
| Sonarr | TV series monitoring, release selection, download automation, and import management | Docker container | Running via `docker-compose.media.yml` | `lscr.io/linuxserver/sonarr:latest` | `C:\media-stack\config\sonarr` | `http://localhost:8989` | Docker Compose, `restart: unless-stopped` | Prowlarr, qBittorrent, TV media folders, Plex libraries | Root folders and qBittorrent client are configured. Confirm completed download handling before broad automation. |
| Radarr | Movie monitoring, release selection, download automation, and import management | Docker container | Running via `docker-compose.media.yml`; health check clean on 2026-05-24 | `lscr.io/linuxserver/radarr:latest` | `C:\media-stack\config\radarr` | `http://localhost:7878` | Docker Compose, `restart: unless-stopped` | Prowlarr, qBittorrent, movie media folders, Plex libraries | Root folders and qBittorrent client are configured. Confirm completed download handling before broad automation. |
| Prowlarr | Indexer management for Sonarr/Radarr | Docker container | Running via `docker-compose.media.yml` | `lscr.io/linuxserver/prowlarr:latest` | `C:\media-stack\config\prowlarr` | `http://localhost:9696` | Docker Compose, `restart: unless-stopped` | Sonarr, Radarr, torrent indexers | Active indexer layer for the Docker stack. MoreThanTV is configured and synced to Sonarr/Radarr; keep tracker credentials out of repo docs. |
| Bazarr | Subtitle search, language profile management, and subtitle file automation | Docker container | Running via `docker-compose.media.yml`; connected to Sonarr/Radarr | `lscr.io/linuxserver/bazarr:latest` | `C:\media-stack\config\bazarr` | `http://localhost:6767` | Docker Compose, `restart: unless-stopped` | Sonarr, Radarr, TV/movie media folders | English language profile configured. Providers enabled: `opensubtitlescom`, `podnapisi`, and `subdl`; SubDL API key configured locally. Test one controlled download before relying on automation. See `docs/bazarr_architecture.md`. |
| qBittorrent | Torrent download client | Docker container | Running via `docker-compose.media.yml`; reachable from Radarr as `qbittorrent:8080` | `lscr.io/linuxserver/qbittorrent:latest` | `C:\media-stack\config\qbittorrent` | `http://localhost:8080` | Docker Compose, `restart: unless-stopped` | Sonarr, Radarr, download folders, incomplete/completed folders | Default path `/downloads/` and incomplete path `/downloads/incomplete/` are configured. Windows host root is `I:\torrentfiles`. Before trusting qBittorrent after boot or drive reconnect, verify Docker sees `/downloads` as the real `I:\` drive with multi-terabyte capacity; see `docs/qbittorrent_startup_recovery.md`. |
| Unpackerr | Automated archive extraction for completed downloads | Docker container | Running via `docker-compose.media.yml`; app integrations not configured yet | `golift/unpackerr:latest` | `C:\media-stack\config\unpackerr` | Usually no web UI; verify container logs/config | Docker Compose, `restart: unless-stopped` | qBittorrent, Sonarr, Radarr, watched download folders, extraction destinations | Configure Sonarr/Radarr API URLs and keys before relying on extraction automation. |
| Jackett | Legacy torrent indexer aggregation and Torznab proxy | Optional Docker container profile | Not active; available as compose profile `legacy-jackett` | `lscr.io/linuxserver/jackett:latest` | `C:\media-stack\config\jackett` if enabled | `http://localhost:9117` if enabled | Docker Compose profile | Sonarr, Radarr, torrent indexers | Keep disabled unless there is a confirmed need to preserve old Jackett-specific indexer behavior. |

---

# Current Software Connections

| Source | Connects To | Purpose | Recovery Check |
|---|---|---|---|
| Plex Media Server | Media HDDs | Reads organized movie and TV library folders | Confirm drive letters and library paths before scanning. |
| Plex Media Server | Plex clients / remote access | Serves local and remote streams | Test only after library paths and network are stable. |
| Plex Media Server | NVIDIA RTX 3050 / Intel iGPU | Hardware transcoding path | Confirm driver installation and Plex hardware transcoding setting. |
| Sonarr | Prowlarr | Searches TV indexers through Torznab feeds | MoreThanTV synced from Prowlarr on 2026-05-24; indexer test passed. |
| Sonarr | qBittorrent | Sends approved TV releases to the torrent client | Configured to Docker host `qbittorrent:8080`, category `tv-sonarr`, shared `/downloads` path. |
| Sonarr | TV media folders | Imports completed TV downloads into the library | Confirm root folders after drive-letter recovery. |
| Radarr | Prowlarr | Searches movie indexers through Torznab feeds | MoreThanTV synced from Prowlarr on 2026-05-24; indexer test passed. |
| Radarr | qBittorrent | Sends approved movie releases to the torrent client | Configured on 2026-05-24 to Docker host `qbittorrent:8080`, category `radarr`, shared `/downloads` path; Radarr health reported clean. |
| Radarr | Movie media folders | Imports completed movie downloads into the library | Confirm root folders after drive-letter recovery. |
| Bazarr | Sonarr / Radarr | Syncs series/movie metadata for subtitle management | API connectivity and English language profile confirmed. |
| Bazarr | Subtitle providers | Searches external subtitle sources | `opensubtitlescom`, `podnapisi`, and `subdl` enabled; SubDL API key configured locally. Keep provider credentials secret. |
| Bazarr | TV/movie media folders | Writes external subtitle files beside media files | Confirm media write behavior with one controlled subtitle download before broad automatic searches. |
| qBittorrent | Download folders | Stores incomplete and completed torrent data | Default save path `/downloads/`; incomplete path `/downloads/incomplete/`; Windows host root `I:\torrentfiles`. If qBit starts while `I:` is missing, Docker may mount `/downloads` as a tiny full filesystem and torrents will error until Docker/WSL is restarted. |
| Unpackerr | qBittorrent / download folders | Extracts archived completed downloads | Confirm watched folders and output paths before enabling. |

---

# Recovery / Admin Software

These tools support rebuild, recovery, driver installation, diagnostics, and administration. They are not Plex workflow dependencies unless noted.

| Software | Role | Official Latest Download Page | Connects To | Recovery Notes |
|---|---|---|---|---|
| Docker Desktop | Container runtime for Sonarr, Radarr, qBittorrent, Jackett, and Unpackerr | [Docker Desktop downloads](https://www.docker.com/products/docker-desktop/) | Windows, Docker media stack | Installed: `Docker Desktop 4.74.0`. Docker Desktop processes were observed, but `com.docker.service` was stopped and the Docker API was not reachable from the CLI at last check. |
| Docker Compose | Compose orchestration for the Docker media stack | Bundled with Docker Desktop | Docker media stack | `docker-compose.exe` exists under Docker Desktop and reports `Docker Compose version v5.1.3`; `docker compose` was not available through the default `docker` CLI at last check. Use the bundled compose executable or fix Docker CLI plugin discovery. |
| MSI PRO Z790-A WIFI II drivers | Motherboard chipset, LAN, Wi-Fi, Bluetooth, audio, and board utilities | [MSI PRO Z790-A WIFI II support](https://www.msi.com/Motherboard/PRO-Z790-A-WIFI-II) | Windows 10 hardware platform | Prefer MSI board-specific drivers first, especially if network devices are missing after first boot. |
| NVIDIA GPU driver | RTX 3050 display and NVENC hardware transcoding support | [NVIDIA driver downloads](https://www.nvidia.com/Download/index.aspx) | Windows, Plex hardware transcoding | Install after Windows boots stably. Confirm Device Manager and Plex transcode behavior later. |
| Intel Driver & Support Assistant | Intel driver detection and update helper | [Intel Driver & Support Assistant](https://www.intel.com/content/www/us/en/support/detect.html) | Intel chipset, LAN/Wi-Fi/Bluetooth/iGPU components | Useful after basic network access works. MSI drivers may still be preferable for board-specific packages. |
| Web browser | Accesses local web UIs and official download pages | [Google Chrome download](https://www.google.com/chrome/) | Plex, Sonarr, Radarr, Jackett, qBittorrent web UIs | Edge is built into Windows; install another browser only if useful for recovery workflow. |
| 7-Zip | Archive extraction and inspection | [7-Zip official site](https://www.7-zip.org/) | Driver packages, app archives, backups | Use the official `7-zip.org` site, not lookalike domains. |
| Notepad++ | Text/config/log editor | [Notepad++ downloads](https://notepad-plus-plus.org/downloads/) | App config files and logs | Helpful for inspecting config files without changing formatting unnecessarily. |
| CrystalDiskInfo | HDD/SSD SMART health monitoring | [CrystalDiskInfo download](https://crystalmark.info/en/software/crystaldiskinfo/) | OS SSD and media HDDs | Recommended during rebuild to record disk health before heavy media service use. |
| Remote Desktop / remote access | Remote administration | [Microsoft Remote Desktop documentation](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/remotepc/remote-desktop-allow-access) | Windows admin access | Enable only on trusted networks. Confirm Windows edition supports hosting Remote Desktop before relying on it. |

---

# Recommended Software

These are not confirmed current installs. Add them only after the core server is recovered and stable.

| Software / Process | Recommendation | Official Page | Connects To | Notes |
|---|---|---|---|---|
| Tautulli | Recommended for Plex monitoring/history if stream analytics are useful | [Tautulli installation docs](https://docs.tautulli.com/getting-started/installation) | Plex Media Server | Tracks plays, users, bandwidth, and stream history. Not required for Plex recovery. |
| CrystalDiskInfo | Recommended for rebuild diagnostics even if it was not previously installed | [CrystalDiskInfo download](https://crystalmark.info/en/software/crystaldiskinfo/) | OS SSD and media HDDs | Use to capture SMART health for each drive after reconnecting drives safely. |
| Plex metadata and app config backup process | Recommended before major software repair or reinstall work | Built into file copy / backup workflow | Plex, Sonarr, Radarr, qBittorrent, Jackett, Unpackerr config folders | Back up existing config/data folders before changing installs. Store backups away from the OS SSD if possible. |

---

# Current Install Gap Summary

Last checked from Windows on 2026-05-23.

| Item | Status | Still Needed |
|---|---|---|
| Plex Media Server | Installed natively and running | Verify library paths, metadata health, remote access, and hardware transcoding after drive-letter checks. |
| Docker Desktop | Installed | Get Docker daemon/API reachable from the CLI and decide whether it starts automatically at login/boot. |
| Docker Compose | Bundled executable present | Make compose usable from the standard CLI or document the exact bundled executable path. |
| Docker media compose file | Created in this repo as `docker-compose.media.yml` with `.env` | Review and commit if this becomes the canonical stack definition. |
| Sonarr | Running as Docker container | TV root folders configured: `/tv/tv1/TV Shows` and `/tv/tv2/TV Shows`. qBittorrent client uses `qbittorrent:8080`, category `tv-sonarr`; still confirm completed download handling before broad automation. |
| Radarr | Running as Docker container | Movie root folders configured: `/movies/movies1/Movies`, `/movies/movies2/Movies`, and `/movies/movies3/Movies`. qBittorrent client uses `qbittorrent:8080`, category `radarr`; Radarr health was clean after the fix on 2026-05-24. |
| Bazarr | Running as Docker container | Connected to Sonarr/Radarr; English profile configured; `opensubtitlescom`, `podnapisi`, and `subdl` enabled. SubDL API key is configured locally. Still test one controlled subtitle download before relying on automation. |
| Prowlarr | Running as Docker container | Sonarr/Radarr app links configured over the Docker network. MoreThanTV configured as the active Torznab indexer and synced to both apps. |
| qBittorrent | Running as Docker container | Default container path `/downloads` maps to `I:\torrentfiles`; incomplete path is `/downloads/incomplete`. Confirm category behavior with a controlled grab before broad automation. |
| Unpackerr | Running as Docker container | Configure Sonarr/Radarr API URLs and keys; current logs show no Starr apps configured. |
| Jackett | Not active; optional compose profile only | Skip unless old Jackett indexers must be preserved. |
| 7-Zip | Installed | No action. |
| Notepad++ | Installed | No action. |
| Google Chrome | Installed | No action. |
| CrystalDiskInfo | Not found in installed-app scan | Install if SMART monitoring is wanted during this recovery pass. |

## Not Recommended For This Pass

| Software | Reason |
|---|---|
| Jackett as primary indexer | Prowlarr is now the active Docker indexer manager; keep Jackett disabled unless an old indexer requires it. |
| SABnzbd / NZBGet | Not currently used; qBittorrent is the confirmed downloader. |
| Overseerr / Jellyseerr | Not currently used; add later only if request management is wanted. |
| VPN tools | Not currently used; do not add during recovery unless there is a confirmed network requirement. |

---

# Verification Checklist

Use this checklist after Windows boots and before normal media service operation.

- [ ] Confirm Windows drive letters are restored.
- [ ] Confirm Plex data directory location.
- [ ] Confirm Plex install path and version.
- [ ] Confirm Docker Desktop daemon/API is reachable.
- [ ] Create and verify Docker compose files for Sonarr, Radarr, Bazarr, qBittorrent, Jackett, and Unpackerr.
- [ ] Confirm Sonarr container image, config volume, version, port, and restart policy.
- [ ] Confirm Radarr container image, config volume, version, port, and restart policy.
- [x] Confirm Bazarr container image, config volume, version, port, ARR connectivity, language profiles, and subtitle providers.
- [ ] Confirm Bazarr can write one downloaded subtitle beside the correct media file.
- [x] Confirm qBittorrent default and incomplete save paths.
- [x] Document qBittorrent stale Docker mount recovery after the 2026-05-25 `I:\torrentfiles` late-mount incident.
- [ ] Add or run a qBittorrent startup guard that verifies `/downloads` reports the real `I:\` drive before torrents resume.
- [ ] Confirm qBittorrent category behavior with a controlled test.
- [x] Confirm Prowlarr app sync to Sonarr/Radarr and test one configured indexer.
- [ ] Confirm Jackett container image, config volume, version, port, restart policy, and configured indexers if legacy Jackett is needed.
- [ ] Confirm Unpackerr container image, config volume, version, watched folders, and extraction destinations.
- [ ] Confirm MSI, NVIDIA, and Intel driver installation status.
- [ ] Record CrystalDiskInfo SMART status for the OS SSD and each media HDD.
- [ ] Back up Plex metadata and app config folders before major repair/reinstall work.

---

# Assumptions

- The server remains Windows 10 native.
- Docker is part of this rebuild for Sonarr, Radarr, Bazarr, qBittorrent, Jackett, and Unpackerr.
- Plex remains a native Windows install.
- Docker web UIs are published to Windows localhost through `WEBUI_HOST_IP=127.0.0.1`; qBittorrent's torrent port remains separately published for torrent traffic.
- Docker download path `/downloads` maps to `I:\torrentfiles` for qBittorrent, Unpackerr, Sonarr, and Radarr.
- A healthy qBittorrent container must report `/downloads` as `I:\` with the real multi-terabyte capacity from inside Docker. If `/downloads` reports a tiny full filesystem, restart Docker/WSL with `wsl --shutdown`, start Docker Desktop again, bring the compose stack up, then recheck/start torrents.
- Unraid, RAID, ZFS, and storage pooling are not part of this rebuild.
- qBittorrent is the only confirmed downloader.
- Prowlarr is the active Docker indexer layer; Jackett is optional legacy fallback only.
- Radarr has monitored Ultra-HD entries for the 2026 movie request made on 2026-05-24: `Project Hail Mary`, `Avatar: Fire and Ash`, `Hoppers`, `Scream 7`, `GOAT`, and `Zootopia 2`. No searches/downloads were triggered when adding them.
- `Unpacker` in earlier docs means Unpackerr.
- Usenet tools, Tautulli, Overseerr/Jellyseerr, VPN tools, and dedicated backup tools are not confirmed current installs.
