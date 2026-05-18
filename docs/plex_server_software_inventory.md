# Plex Server Software Inventory

## Purpose

Use this file as the central software recovery list for the Windows-native Plex server.

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

These applications are part of the confirmed existing Windows-native Plex stack.

| Software | Role | Official Latest Download Page | Install Path | Config / Data Path | Port / URL | Startup Mode | Connects To | Recovery Notes |
|---|---|---|---|---|---|---|---|---|
| Plex Media Server | Media library server, metadata manager, streaming server, and transcoding engine | [Plex Media Server downloads](https://www.plex.tv/media-server-downloads/) | To verify after Windows boots | Likely `C:\Users\<WindowsUser>\AppData\Local\Plex Media Server`; verify before reinstall | Typically `http://localhost:32400/web`; verify | To verify after Windows boots | Media HDDs, Plex clients, NVIDIA GPU or Intel Quick Sync for hardware transcoding | Search for and preserve the Plex data directory before reinstalling Plex. Confirm library paths only after drive letters are restored. |
| Sonarr | TV series monitoring, release selection, download automation, and import management | [Sonarr Windows download](https://sonarr.tv/) | To verify after Windows boots | To verify after Windows boots | Typically `http://localhost:8989`; verify | Service or tray app; verify | Jackett, qBittorrent, TV media folders, Plex libraries | Confirm root folders and download client settings before allowing imports or path edits. |
| Radarr | Movie monitoring, release selection, download automation, and import management | [Radarr Windows download](https://radarr.video/) | To verify after Windows boots | To verify after Windows boots | Typically `http://localhost:7878`; verify | Service or tray app; verify | Jackett, qBittorrent, movie media folders, Plex libraries | Confirm root folders and download client settings before allowing imports or path edits. |
| qBittorrent | Torrent download client | [qBittorrent official download](https://www.qbittorrent.org/download.php) | To verify after Windows boots | To verify after Windows boots | Web UI port unknown; verify if enabled | To verify after Windows boots | Sonarr, Radarr, download folders, incomplete/completed folders | Do not resume all torrents until default save path, incomplete path, completed path, and category paths are verified. |
| Jackett | Torrent indexer aggregation and Torznab proxy | [Jackett GitHub releases](https://github.com/Jackett/Jackett/releases) | To verify after Windows boots | To verify after Windows boots | Typically `http://localhost:9117`; verify | Service or tray app; verify | Sonarr, Radarr, torrent indexers | Confirm configured indexers and API key before changing Sonarr/Radarr indexer settings. |
| Unpackerr | Automated archive extraction for completed downloads | [Unpackerr latest release](https://unpackerr.zip/) | To verify after Windows boots | To verify after Windows boots | To verify after Windows boots | Service or scheduled/background app; verify | qBittorrent, Sonarr, Radarr, watched download folders, extraction destinations | Confirm watched folders and extraction destinations before enabling automatic extraction. |

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
- [ ] Confirm Sonarr install path, config path, version, port, and startup mode.
- [ ] Confirm Radarr install path, config path, version, port, and startup mode.
- [ ] Confirm qBittorrent install path, config path, version, Web UI status, and all save paths.
- [ ] Confirm Jackett install path, config path, version, port, startup mode, and configured indexers.
- [ ] Confirm Unpackerr install path, config path, version, startup mode, watched folders, and extraction destinations.
- [ ] Confirm MSI, NVIDIA, and Intel driver installation status.
- [ ] Record CrystalDiskInfo SMART status for the OS SSD and each media HDD.
- [ ] Back up Plex metadata and app config folders before major repair/reinstall work.

---

# Assumptions

- The server remains Windows 10 native.
- Docker, Unraid, RAID, ZFS, and storage pooling are not part of this rebuild.
- qBittorrent is the only confirmed downloader.
- Jackett remains the active indexer layer.
- `Unpacker` in earlier docs means Unpackerr.
- Usenet tools, Prowlarr, Tautulli, Bazarr, Overseerr/Jellyseerr, VPN tools, and dedicated backup tools are not confirmed current installs.
