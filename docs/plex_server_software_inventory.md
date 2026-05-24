# Plex Server Software Inventory

## Purpose

Use this file as the central software recovery list for the Windows-native Plex server.

Current deployment decision:

- Keep Plex Media Server as a native Windows install.
- Run the media automation stack in Docker: Sonarr, Radarr, qBittorrent, Jackett, and Unpackerr.
- Keep storage as normal Windows drive letters mounted into containers; do not change drive letters casually.

It records the known application stack, official download pages for current installers, what each tool does, what it connects to, and what must be verified before launching or repairing anything after the hardware rebuild.

---

# Recovery Safety Notes

- Do not launch Plex, Sonarr, Radarr, qBittorrent, Jackett, or Unpackerr until Windows drive letters are confirmed.
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
| Sonarr | TV series monitoring, release selection, download automation, and import management | Docker container | Not installed natively; no container confirmed yet | Docker image to select in compose plan | Docker config volume to define | Typically `http://localhost:8989`; verify after container creation | Docker Desktop / compose | Jackett, qBittorrent, TV media folders, Plex libraries | Install via Docker only. Confirm root folders and download client settings before allowing imports or path edits. |
| Radarr | Movie monitoring, release selection, download automation, and import management | Docker container | Not installed natively; no container confirmed yet | Docker image to select in compose plan | Docker config volume to define | Typically `http://localhost:7878`; verify after container creation | Docker Desktop / compose | Jackett, qBittorrent, movie media folders, Plex libraries | Install via Docker only. Confirm root folders and download client settings before allowing imports or path edits. |
| qBittorrent | Torrent download client | Docker container | Not installed natively; no container confirmed yet | Docker image to select in compose plan | Docker config volume to define | Web UI port to define; common default is `8080` | Docker Desktop / compose | Sonarr, Radarr, download folders, incomplete/completed folders | Install via Docker only. Do not resume all torrents until default save path, incomplete path, completed path, and category paths are verified. |
| Jackett | Torrent indexer aggregation and Torznab proxy | Docker container | Not installed natively; no container confirmed yet | Docker image to select in compose plan | Docker config volume to define | Typically `http://localhost:9117`; verify after container creation | Docker Desktop / compose | Sonarr, Radarr, torrent indexers | Install via Docker only. Confirm configured indexers and API key before changing Sonarr/Radarr indexer settings. |
| Unpackerr | Automated archive extraction for completed downloads | Docker container | Not installed natively; no container confirmed yet | Docker image to select in compose plan | Docker config volume to define | Usually no web UI; verify container logs/config | Docker Desktop / compose | qBittorrent, Sonarr, Radarr, watched download folders, extraction destinations | Install via Docker only. Confirm watched folders and extraction destinations before enabling automatic extraction. |

---

# Current Software Connections

| Source | Connects To | Purpose | Recovery Check |
|---|---|---|---|
| Plex Media Server | Media HDDs | Reads organized movie and TV library folders | Confirm drive letters and library paths before scanning. |
| Plex Media Server | Plex clients / remote access | Serves local and remote streams | Test only after library paths and network are stable. |
| Plex Media Server | NVIDIA RTX 3050 / Intel iGPU | Hardware transcoding path | Confirm driver installation and Plex hardware transcoding setting. |
| Sonarr | Jackett | Searches TV indexers through Torznab feeds | Confirm Jackett URL/API key and one test search. |
| Sonarr | qBittorrent | Sends approved TV releases to the torrent client | Confirm download client settings and category/path behavior. |
| Sonarr | TV media folders | Imports completed TV downloads into the library | Confirm root folders after drive-letter recovery. |
| Radarr | Jackett | Searches movie indexers through Torznab feeds | Confirm Jackett URL/API key and one test search. |
| Radarr | qBittorrent | Sends approved movie releases to the torrent client | Confirm download client settings and category/path behavior. |
| Radarr | Movie media folders | Imports completed movie downloads into the library | Confirm root folders after drive-letter recovery. |
| qBittorrent | Download folders | Stores incomplete and completed torrent data | Confirm all paths before resuming torrents. |
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
| Bazarr | Recommended only if subtitle automation matters | [Bazarr site](https://www.bazarr.media/) | Sonarr, Radarr, media folders | Adds subtitle search/download automation. Skip if subtitles are already handled manually or not important. |
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
| Docker media compose file | Not found in this repo | Create `docker-compose.media.yml` and matching `.env` after final path choices are confirmed. |
| Sonarr | No native install found; no container confirmed | Install as Docker container. |
| Radarr | No native install found; no container confirmed | Install as Docker container. |
| qBittorrent | No native install found; no container confirmed | Install as Docker container, then configure Web UI and safe download paths. |
| Jackett | No native install found; no container confirmed | Install as Docker container, then restore/add indexers. |
| Unpackerr | No native install found; no container confirmed | Install as Docker container, then configure watched folders and app API connections. |
| 7-Zip | Installed | No action. |
| Notepad++ | Installed | No action. |
| Google Chrome | Installed | No action. |
| CrystalDiskInfo | Not found in installed-app scan | Install if SMART monitoring is wanted during this recovery pass. |

## Not Recommended For This Pass

| Software | Reason |
|---|---|
| Prowlarr | Not part of the confirmed current stack, and the chosen recovery plan is Jackett-only. Consider later only after the existing setup is stable. |
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
- [ ] Create and verify Docker compose files for Sonarr, Radarr, qBittorrent, Jackett, and Unpackerr.
- [ ] Confirm Sonarr container image, config volume, version, port, and restart policy.
- [ ] Confirm Radarr container image, config volume, version, port, and restart policy.
- [ ] Confirm qBittorrent container image, config volume, version, Web UI status, and all save paths.
- [ ] Confirm Jackett container image, config volume, version, port, restart policy, and configured indexers.
- [ ] Confirm Unpackerr container image, config volume, version, watched folders, and extraction destinations.
- [ ] Confirm MSI, NVIDIA, and Intel driver installation status.
- [ ] Record CrystalDiskInfo SMART status for the OS SSD and each media HDD.
- [ ] Back up Plex metadata and app config folders before major repair/reinstall work.

---

# Assumptions

- The server remains Windows 10 native.
- Docker is part of this rebuild for Sonarr, Radarr, qBittorrent, Jackett, and Unpackerr.
- Plex remains a native Windows install.
- Unraid, RAID, ZFS, and storage pooling are not part of this rebuild.
- qBittorrent is the only confirmed downloader.
- Jackett remains the active indexer layer.
- `Unpacker` in earlier docs means Unpackerr.
- Usenet tools, Prowlarr, Tautulli, Bazarr, Overseerr/Jellyseerr, VPN tools, and dedicated backup tools are not confirmed current installs.
