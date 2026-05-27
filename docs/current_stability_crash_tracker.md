# Current Stability And Crash Tracker

## Purpose

Track the unresolved randomly timed crashing on the rebuilt Plex server.

This file is for evidence and non-destructive diagnostics only. Do not claim a root cause until the pattern is supported by logs, observations, or repeatable tests.

---

# Current Problem Statement

| Item | Current state |
|---|---|
| Issue | Randomly timed crashing |
| Status | Improved under soak after removing broken-power-pin HDD; not yet closed |
| Affected system | Rebuilt MSI PRO Z790-A WiFi II / Intel Core i5-14500 Windows 10 Plex server |
| Known service state | Plex and Docker media stack can run |
| Current evidence level | Multiple crash timestamps captured before drive removal; no new crash observed during first overnight soak after broken-pin drive was removed |

---

# Known Rebuild / Driver Context

| Area | Known state |
|---|---|
| Windows | Windows 10 Home build 19045, 64-bit |
| Motherboard | MSI PRO Z790-A WIFI II |
| CPU | Intel Core i5-14500 |
| GPU | NVIDIA GeForce RTX 3050 |
| iGPU | Intel UHD Graphics 770 |
| Intel chipset INF | MSI package `10.1.20062.8627` installed |
| Wi-Fi | Realtek 8852CE driver `6001.16.172.0` installed |
| Bluetooth | Realtek Bluetooth driver `18.4032.2510.900` installed |
| Audio | Realtek package `6.0.9977.1` installed |
| NVIDIA | Studio Driver `596.36`; device driver `32.0.15.9636` |
| Intel DSA | Installed |
| Device Manager snapshot | No nonzero `ConfigManagerErrorCode` devices in the checked snapshot |
| BIOS | Updated from `M.90` to `M.A0` on 2026-05-25 |
| Wi-Fi diagnostic state | Realtek 8852CE disabled in Device Manager, then disabled in BIOS on 2026-05-25 |
| iGPU diagnostic state | User disabled unused onboard graphics settings in BIOS on 2026-05-25 to reduce variables |
| Memory speed | DDR5 currently reports `4800`; XMP does not appear active from Windows inventory |
| Crash capture | Small memory dumps enabled; automatic reboot disabled; `C:\Windows\Minidump` created on 2026-05-25 |
| Power-state hardening | Hibernation/Fast Startup disabled; PCIe Link State Power Management disabled; USB selective suspend disabled on 2026-05-25 |
| Intel ME firmware | Updated from `16.1.38.2676` to `16.1.40.2765`; verified after restart on 2026-05-25 |

Source: [driver_install_status_2026-05-22.md](driver_install_status_2026-05-22.md).

---

# Evidence To Capture

| Evidence | Why it matters | Status |
|---|---|---|
| Exact crash timestamps | Required to correlate Event Viewer and service logs | Needed |
| Crash behavior | Distinguishes reboot, power loss, freeze, BSOD, display-driver reset, sleep/wake issue | Needed |
| Event Viewer System log | Finds Kernel-Power, bugcheck, WHEA, driver, storage, or service events | Needed |
| Reliability Monitor | Summarizes Windows hardware/application failures | Needed |
| Minidump presence | Supports BSOD/debug path if bugchecks occur | Needed |
| BIOS memory/XMP state | RAM profile instability is a common post-rebuild variable | Needed |
| Temperatures | Checks CPU/GPU/storage thermal correlation | Needed |
| SMART status | Checks OS SSD and HDD health | Needed |
| Workload correlation | Separates idle, Plex playback/transcode, Docker download/import, and mixed-load crashes | Needed |
| Power/sleep settings | Checks sleep, wake, USB, PCIe, and power-state behavior | Needed |

---

# Crash Timeline And Observations

| Local time | Observation | Diagnostic result |
|---|---|---|
| 2026-05-25 2:58:51 PM | Unexpected shutdown before reboot at 3:15 PM | `Kernel-Power 41`, `BugcheckCode=0`, no minidump, no `MEMORY.DMP` |
| 2026-05-25 5:29:32 PM | Post-BIOS crash sequence | `WHEA-Logger` fatal hardware error and `HAL` IOMMU error appeared |
| 2026-05-25 8:28:44 PM | Post-BIOS crash sequence | `WHEA-Logger` fatal hardware error; matching `HAL` IOMMU error at 8:28:27 PM |
| 2026-05-25 9:18:05 PM | Post-BIOS crash sequence | `WHEA-Logger` fatal hardware error; matching `HAL` IOMMU error at 9:17:48 PM |
| 2026-05-25 9:27:17 PM | Crash after Realtek Wi-Fi was disabled in Windows Device Manager | `Kernel-Power 41`, `BugcheckCode=0`, no minidump, no `MEMORY.DMP`; no new WHEA/HAL IOMMU event after Wi-Fi disable |
| 2026-05-25 9:43:09 PM | Hard freeze reported by user: screen frozen, cursor would not move, keyboard and mouse had no effect | Reboot at 10:00:33 PM; `Kernel-Power 41`, `BugcheckCode=0`; new `WHEA-Logger` fatal hardware error at 10:00:51 PM; no matching new `HAL` IOMMU Event 15 |
| 2026-05-25 10:07:39 PM | Crash after ME firmware update and controlled restart | Reboot at 10:37:47 PM; `Kernel-Power 41`, `BugcheckCode=0`; new `WHEA-Logger` fatal hardware error at 10:38:06 PM; no minidump or `MEMORY.DMP`; no matching new `HAL` IOMMU Event 15 |
| 2026-05-25 10:38:06 PM | Crash occurred before the broken-power-pin HDD was removed | Reboot at 11:00:17 PM; `Kernel-Power 41`, `BugcheckCode=0`; new `WHEA-Logger` fatal hardware error at 11:00:34 PM; no minidump or `MEMORY.DMP`; broken-pin drive was replaced only after this crash |
| 2026-05-26 10:32 AM | Overnight soak after broken-pin drive removal | Windows boot time `2026-05-25 11:00:17 PM`; uptime about 11.5 hours; no later Kernel-Power crash, WHEA, HAL, disk, NTFS, storahci, or bugcheck events found in the since-boot check beyond the previous crash record |

## 2026-05-25 Admin Hardening / Repair Pass

- Created `C:\Windows\Minidump`.
- Set crash capture to small memory dumps with `CrashDumpEnabled=3`.
- Disabled automatic reboot after crash with `AutoReboot=0` so the next BSOD should remain visible long enough to record the stop code.
- Disabled hibernation and Fast Startup with `powercfg -h off`.
- Disabled PCIe Link State Power Management for AC and DC.
- Disabled USB selective suspend for AC and DC.
- `DISM /Online /Cleanup-Image /CheckHealth` found no component store corruption.
- `DISM /Online /Cleanup-Image /RestoreHealth` completed successfully.
- `sfc /verifyonly` found integrity violations.
- `sfc /scannow` found corrupt files and successfully repaired them.
- `chkdsk C: /scan` found no file-system problems and no bad sectors.
- `Get-PhysicalDisk` reported all fixed disks as `Healthy` / `OK`.
- qBittorrent `/downloads` was verified after reboot as `I:\`, `19T` total, `16T` available.

## 2026-05-25 Intel ME Firmware Update

- Windows inventory showed Intel ME firmware `16.1.38.2676` after BIOS `M.A0`.
- MSI current BIOS notes for `7E07vMA` / BIOS `M.A0` list ME firmware `16.1.40.2765`.
- Downloaded official MSI package `ME_16.1.40.2765.zip` from `https://download.msi.com/bos_exe/mb/ME_16.1.40.2765.zip`.
- MSI wrapper signature verified as Micro-Star International; Intel updater signature verified as Intel Corporation.
- MSI updater log at `tools/ME_16.1.40.2765/ME_16.1.40.2765/FWLog.txt` reported: `Old FW Version : 16.1.38.2676, New FW Version : 16.1.40.2765 : SUCCESS`.
- User chose restart later, then performed a controlled restart.
- After the 2026-05-25 10:07 PM boot, Windows verified ME firmware `16.1.40.2765`.
- No new WHEA or HAL IOMMU errors were observed immediately after the controlled restart.

## 2026-05-25 Docker / WSL Isolation Test

- After the post-ME-update crash, Docker containers were running again after reboot.
- Verified `I:\torrentfiles` existed and qBittorrent `/downloads` was correctly mounted to `I:\` before stopping containers.
- Stopped the Docker media stack with `docker compose -f C:\plex-server\docker-compose.media.yml stop`.
- Stopped the remaining `torrent-mcp` container manually after it restarted.
- Closed Docker Desktop backend processes and ran `wsl --shutdown`.
- Confirmed no Docker Desktop, Docker backend, `vmmem`, or running Docker containers remained.
- Current test posture: native Windows/Plex only, Docker/WSL quiet. If crashes continue in this state, Docker/WSL is less likely to be the direct trigger.

## 2026-05-25 Broken-Power-Pin HDD Test

- User identified a hard drive with a broken power pin that had been mounted as `G:`.
- The crash recorded at previous shutdown `2026-05-25 10:38:06 PM` occurred before this drive was removed.
- After that crash, user removed the broken-pin drive and replaced it with an 8 TB HDD.
- Current Windows volume map after replacement shows `G:` labeled `Empty`, healthy, about 8 TB.
- Current Windows volume map no longer shows the prior `H:` / `TV 2` volume.
- The first overnight soak with the broken-pin drive absent reached about 11.5 hours without another crash.
- Current diagnosis: the removed broken-pin drive, its power connection, or related SATA/power cabling is now the strongest stability lead. Keep this as a probable cause under observation, not a final root-cause claim, until normal operation remains stable for a longer soak window.
- Do not reconnect the broken-pin drive or reuse its power/SATA cabling for normal service until there is an explicit recovery plan.
- Because `H:` / `TV 2` is absent, do not trust `/tv/tv2` imports; Docker currently shows `/tv/tv2` as a tiny full placeholder filesystem, not the missing TV drive.

## 2026-05-26 Overnight Soak And Upkeep Check

- User reported the machine stayed up overnight after the broken-pin HDD was removed and an 8 TB drive was installed.
- Windows reported current boot time `2026-05-25 11:00:17 PM`; check time `2026-05-26 10:32 AM`; uptime about 11.5 hours.
- Since-boot event check found only the records tied to the previous `2026-05-25 10:38:06 PM` crash: `Kernel-Power 41`, `EventLog 6008`, and `WHEA-Logger 1`.
- No newer matching hard-crash, HAL IOMMU, disk, NTFS, storahci, or bugcheck events were found in the since-boot filtered check.
- `Get-PhysicalDisk` reported all detected fixed disks as `Healthy` / `OK`.
- Current fixed volumes: `C:`, `D:` Movies 1, `E:` Movies 3, `F:` Movies 2, `G:` Empty, `I:` Torrent, and `J:` TV 1. `H:` / TV 2 is absent.
- `Test-Path I:\torrentfiles` returned true.
- qBittorrent container showed `/downloads` mounted from `I:\`, about `19T` total and `16T` available.
- Docker localhost checks returned HTTP 200 for Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Tautulli, and Uptime Kuma.
- Sonarr/Bazarr `/tv/tv2` currently maps to a tiny full placeholder filesystem because `H:` is missing. Treat TV 2 paths as unavailable until the storage plan is updated.

## 2026-05-25 WHEA / IOMMU Finding

- After BIOS update to `M.A0`, Windows logged `WHEA-Logger` Event ID `1`: `A fatal hardware error has occurred`.
- Matching `Microsoft-Windows-HAL` Event ID `15` said: `The iommu has detected an error`.
- HAL data included `SourceId=768`, which is PCI requester ID `0x300`.
- PCI requester `0x300` maps to PCI bus `3`, device `0`, function `0`.
- Windows mapped PCI bus `3`, device `0`, function `0` to `Realtek 8852CE WiFi 6E PCI-E NIC #2`.
- User disabled the Realtek Wi-Fi device in Device Manager, then later disabled Wi-Fi in BIOS.
- The next captured crash after Windows-level Wi-Fi disable did not log a new WHEA/HAL IOMMU event, but still hard-reset with `BugcheckCode=0`.
- Do not call the Realtek Wi-Fi the confirmed root cause yet; treat it as a strong lead that changed the event signature.

## 2026-05-26 Docker Localhost Port Proxy Incident

- User reported the Arr ecosystem was not responding.
- Docker showed Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Tautulli, Unpackerr, and Uptime Kuma containers still running.
- Windows confirmed `I:\torrentfiles` existed.
- qBittorrent container confirmed `/downloads` was correctly mounted as `I:\` with about `19T` total and `16T` available; this was not the prior tiny/full `/downloads` mount failure.
- Inside-container checks returned normal service responses from Sonarr, Radarr, and Prowlarr.
- Windows `127.0.0.1` checks against all published Docker ports returned empty replies through `com.docker.backend.exe`.
- Recovery action: `docker compose -f C:\plex-server\docker-compose.media.yml restart`.
- Post-restart validation: localhost ports responded normally again, and qBittorrent `/downloads` still mapped to `I:\`.
- Treat this as a Docker Desktop Windows port-forward/proxy incident unless repeated evidence points elsewhere.

## 2026-05-26 Arr Config Corruption And Recovery

- User asked to ensure the Arr ecosystem was up and running.
- Docker showed Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Tautulli, Unpackerr, Uptime Kuma, and `torrent-mcp` containers running.
- Windows did not show `I:\torrentfiles`; `Test-Path I:\torrentfiles` returned false.
- qBittorrent, Sonarr, Radarr, and Unpackerr all saw `/downloads` as the tiny full Docker fallback filesystem: about `137M`, `100%` used, mounted at `/downloads`.
- Windows disk inventory showed the currently visible fixed volumes as `C:`, `D:`, `E:`, `F:`, `G:`, `H:`, and `J:`. There was no visible `I:` volume to remount.
- Sonarr, Radarr, and Prowlarr `config.xml` files were present but filled with NUL bytes, so the apps accepted the files as existing but could not parse them.
- Tautulli `config.ini` was also corrupted with NUL bytes; restored it from the latest scheduled Tautulli config backup.
- Repaired Sonarr, Radarr, and Prowlarr with minimal valid `config.xml` files and new local API keys. Corrupted files were preserved with timestamped `.corrupt-*` names.
- Because the Arr API keys changed, dependent links had to be repaired:
  - Updated Prowlarr's Sonarr and Radarr application links.
  - Updated Sonarr and Radarr Prowlarr-backed Torznab indexer API keys.
  - Updated Bazarr's stored Sonarr/Radarr API keys.
  - Updated Unpackerr's Sonarr/Radarr URLs and API keys.
- Initial Unpackerr repair created duplicate TOML keys in a commented example block; corrected the config and restarted Unpackerr.
- Final validation showed Sonarr, Radarr, and Prowlarr API health checks with zero issues; Bazarr and Tautulli returned HTTP 200; Unpackerr reported one Sonarr server and one Radarr server and a clean idle queue.
- Important operational lesson: an Arr app can be "Up" in Docker while its config is corrupted or its dependencies have stale API keys. After rebuilding any Arr API key, check Prowlarr app links, Sonarr/Radarr Prowlarr indexers, Bazarr, and Unpackerr.
- Do not trust downloads or imports yet: the application layer recovered, but `/downloads` remained unsafe because `I:\torrentfiles` was still missing and Docker still showed the tiny full fallback mount.

---

# Non-Destructive Diagnostic Checklist

- [x] Record several crash times with local time.
- [x] Check Event Viewer System log around captured timestamps.
- [ ] Check Reliability Monitor for matching critical events.
- [x] Check for `C:\Windows\Minidump` files if a BSOD or bugcheck is suspected.
- [x] Record BIOS version.
- [x] Record memory profile/XMP state.
- [ ] Confirm CPU and GPU temperatures at idle and during a controlled Plex playback/transcode.
- [x] Capture Windows physical-disk health status for `C:` and all fixed media/data drives.
- [x] Confirm qBittorrent `/downloads` mount after at least one crash before resuming torrents.
- [x] Complete first overnight soak after removing the broken-pin HDD.
- [ ] Continue normal-operation soak with the broken-pin drive absent before closing the crash issue.
- [ ] Decide how to handle missing `H:` / TV 2 before allowing imports to `/tv/tv2`.
- [ ] Review Docker Desktop/WSL logs only after Windows crash evidence is collected.
- [ ] Avoid firmware, BIOS, storage-controller, or drive-letter changes until a diagnostic plan calls for them.

---

# Possible Areas To Investigate

These are hypotheses, not conclusions:

| Area | Why it is plausible |
|---|---|
| Memory stability / XMP | New DDR5 platform; memory profile state still needs recording |
| Driver/platform transition | Windows install was preserved across a major motherboard platform change |
| GPU/display driver | NVIDIA driver was updated; Plex may use GPU transcoding |
| Power delivery / PSU cabling | PSU is reused; modular cable safety remains important |
| Thermals/fan control | Reused case and fans; fan map still needs documentation |
| Removed broken-pin HDD or its cabling | Stability improved immediately after the physically damaged drive was removed; strongest current lead |
| Storage or Docker/WSL timing | qBittorrent already had a stale mount incident after `I:` was unavailable; `/tv/tv2` is now a missing-drive placeholder |
| Sleep/power states | Random timing may correlate with idle/sleep/wake if enabled |

---

# Current Rule

The crash pattern is strongly improved after removing the broken-pin HDD, but do not mark the issue solved until the server survives a longer normal-operation soak. Preserve data first, keep the broken-pin drive out of service, avoid `/tv/tv2` writes while `H:` is absent, and continue collecting evidence before making more hardware or service changes.
