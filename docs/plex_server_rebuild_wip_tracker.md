# Plex Server Post-Rebuild Status Tracker

## Purpose

Track the current post-rebuild state, unresolved stability issue, service hardening work, and documentation follow-ups for the Plex media server.

The original hardware rebuild is no longer the active phase. The server has been rebuilt on the replacement Intel platform, Windows boots, drivers were installed, and the Docker media stack is running. The active problem is proving stability after the broken-power-pin HDD was removed.

---

# Current Status

| Area | Status |
|---|---|
| Hardware rebuild | Completed enough for Windows and services to run |
| Current top priority | Continue stability soak after broken-pin HDD removal |
| Operating system | Windows 10 Home build 19045, native install |
| Plex deployment | Native Windows install |
| Docker media stack | Running Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, qBittorrent, and Unpackerr |
| Optional legacy service | Jackett available through the `legacy-jackett` compose profile, not active by default |
| Storage architecture | Windows-native drive letters mounted into containers |
| Torrent root | `I:\torrentfiles` mounted as `/downloads` |
| qBittorrent mount status | Last verified healthy: Docker saw `/downloads` as `I:\` with multi-terabyte capacity |
| Current documentation priority | Keep current service docs and crash tracker up to date |

---

# Current Top Issue

Randomly timed system crashing improved after the broken-power-pin HDD was removed and replaced with an 8 TB drive. The first overnight soak reached about 11.5 hours without a new crash, but the issue should not be marked solved until normal operation remains stable for a longer soak window.

Track evidence and diagnostic steps in [current_stability_crash_tracker.md](current_stability_crash_tracker.md). Do not record a guessed root cause as fact.

## Non-Destructive Evidence To Collect

- [ ] Exact crash timestamps.
- [ ] Whether the system reboots, powers off, freezes, bluescreens, or returns to login.
- [ ] Windows Event Viewer entries around each crash.
- [ ] Reliability Monitor entries.
- [ ] Any WHEA, Kernel-Power, bugcheck, display-driver, storage, or Docker/WSL events.
- [ ] Whether crashes correlate with Plex playback, transcodes, downloads, imports, Docker activity, idle time, sleep, or fan/thermal load.
- [ ] BIOS settings relevant to stability, especially memory profile/XMP state.
- [ ] CPU, GPU, and drive temperatures during idle and load.
- [ ] SMART health for the OS SSD and media/data HDDs.
- [ ] Continued no-crash soak with the removed broken-pin drive absent.
- [ ] Decision on the missing `H:` / TV 2 path before allowing imports to `/tv/tv2`.

---

# Rebuilt Hardware Summary

| Category | Part / State |
|---|---|
| Motherboard | MSI PRO Z790-A WiFi II |
| CPU | Intel Core i5-14500 SRN3T |
| RAM | Lexar Thor Z DDR5 32GB, 2x16GB, 6000MHz |
| CPU cooler | Noctua NH-U9S chromax.black |
| Case | SilverStone GD07, reused |
| PSU | Corsair RM750e, reused |
| GPU | GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD, reused |
| OS storage | Samsung SSD 840 EVO 250GB on `C:` |
| Media/data storage | Current detected HDD volumes on `D:`, `E:`, `F:`, `G:`, `I:`, and `J:`; former `H:` / TV 2 absent after drive swap |

Detailed hardware and drive inventory lives in [plex_server_hardware_inventory.md](plex_server_hardware_inventory.md).

---

# Service Status Snapshot

| Service | Deployment | Status / Notes |
|---|---|---|
| Plex | Native Windows | Installed and running; preserve metadata and token secrecy |
| Sonarr | Docker | Running; TV root folders and qBittorrent client configured |
| Radarr | Docker | Running; movie root folders and qBittorrent client configured |
| Prowlarr | Docker | Running; active indexer manager for Sonarr/Radarr |
| Bazarr | Docker | Running; connected to Sonarr/Radarr; one controlled subtitle test still recommended |
| Tautulli | Docker | Running; first-run Plex setup still needs completion if not already done |
| qBittorrent | Docker | Running; verify `/downloads` mount after boot/crash before trusting torrents |
| Unpackerr | Docker | Running; Starr app integrations still need confirmation/configuration |
| Jackett | Optional Docker profile | Disabled by default; use only for legacy indexer needs |

Per-service docs live in [services](services).

---

# Remaining Hardening Checklist

## Stability / Crash Work

- [ ] Collect crash timestamps and Event Viewer evidence.
- [x] Record first overnight soak after removing the broken-pin HDD.
- [ ] Confirm BIOS memory settings, including whether XMP is disabled or enabled.
- [ ] Confirm CPU, GPU, and storage temperatures.
- [x] Record Windows physical-disk health for every currently detected fixed drive.
- [ ] Record detailed SMART attributes for every currently detected fixed drive.
- [ ] Confirm Windows sleep/power settings.
- [ ] Confirm whether crashes occur under idle, Plex transcode, Docker download/import, or mixed load.
- [ ] Keep removed broken-pin HDD and suspect cabling out of service during soak.
- [ ] Avoid BIOS updates, firmware changes, or storage controller changes unless explicitly chosen as part of a stability plan.

## Storage / Docker Safety

- [x] Confirm current fixed SATA drive inventory from Windows.
- [x] Confirm qBittorrent download root is `I:\torrentfiles`.
- [x] Confirm qBittorrent `/downloads` is mounted from `I:\` after the drive swap.
- [x] Document qBittorrent stale Docker bind-mount recovery.
- [ ] Do not allow Sonarr/Bazarr writes to `/tv/tv2` while `H:` is absent.
- [ ] Add or run a qBittorrent startup guard that verifies `/downloads` reports the real `I:\` drive before torrents resume.
- [ ] Document physical bay-to-drive mapping.
- [ ] Document SATA port map.
- [ ] Document PSU cable map.
- [ ] Document fan header map.

## Plex / Media Stack

- [ ] Complete or confirm Tautulli first-run Plex setup.
- [ ] Verify one controlled Plex playback appears in Tautulli active streams and history.
- [ ] Confirm qBittorrent Web UI credentials are not default.
- [ ] Confirm qBittorrent category behavior with one controlled Sonarr/Radarr grab.
- [ ] Confirm completed download handling for Sonarr and Radarr.
- [ ] Confirm Bazarr can write one downloaded subtitle beside the correct media file.
- [ ] Configure or confirm Unpackerr Sonarr/Radarr integrations.
- [ ] Keep Jackett disabled unless a specific legacy indexer requires it.

## Backups

- [ ] Back up Plex metadata.
- [ ] Back up Docker app config folders under `C:\media-stack\config`.
- [ ] Document restore procedure for Plex metadata and Docker app configs.
- [ ] Store backups somewhere other than only the OS SSD.

---

# Do Not Do

- [ ] Do not format any existing media drive.
- [ ] Do not initialize any existing media drive in Disk Management.
- [ ] Do not change drive letters without a documented reason and explicit confirmation.
- [ ] Do not repair app paths until the correct drive letters and Docker mounts are verified.
- [ ] Do not start broad automatic searches, imports, subtitle downloads, or torrent operations while qBittorrent mount status is unknown.
- [ ] Do not commit `.env`, service config files, API keys, cookies, tokens, provider credentials, tracker URLs, passkeys, or logs containing secrets.
- [ ] Do not claim the random crashes are fixed until they have stopped under observed normal operation.
