# Current Stability And Crash Tracker

## Purpose

Track the unresolved randomly timed crashing on the rebuilt Plex server.

This file is for evidence and non-destructive diagnostics only. Do not claim a root cause until the pattern is supported by logs, observations, or repeatable tests.

---

# Current Problem Statement

| Item | Current state |
|---|---|
| Issue | Randomly timed crashing |
| Status | Recurred after initial post-drive-swap soak; unresolved hardware/platform fault |
| Affected system | Rebuilt MSI PRO Z790-A WiFi II / Intel Core i5-14500 Windows 10 Plex server |
| Known service state | Plex and Docker media stack can run |
| Current evidence level | Multiple hard resets with `BugcheckCode=0`; repeated fatal WHEA firmware error records; current soak has only the OS drive connected |

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
| 2026-05-26 10:12:09 PM | Unexpected shutdown after initial soak | Event logged at 10:51:09 PM; `EventLog 6008`; include in recurrence pattern |
| 2026-05-27 11:11:22 AM | Unexpected shutdown | Reboot/log at 11:39:29 AM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; no dump found |
| 2026-05-27 12:59:42 PM | Unexpected shutdown | Reboot/log at 2:07:57 PM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; no dump found |
| 2026-05-27 6:48:11 PM | Unexpected shutdown reported by user after recovery | Reboot/log at 10:57:00 PM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; no minidump or `MEMORY.DMP`; WHEA CPER decoded as fatal firmware error record references |
| 2026-05-27 10:57:14 PM | Unexpected shutdown | Reboot/log at 11:34:10 PM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; no dump found |
| 2026-05-27 11:34:23 PM | Unexpected shutdown reported after overnight recovery | Reboot/log at 2026-05-28 7:03:46 AM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; no minidump or `MEMORY.DMP`; logs persisted under `docs/crash_logs/20260528-070552` |
| 2026-05-28 10:23:59 AM | Unexpected shutdown after motherboard power-cable inspection | Reboot/log at 11:30:23 AM; `Kernel-Power 41`, `BugcheckCode=0`; no dump found; `I:` / Torrent missing after reboot and Docker `/downloads` became tiny full placeholder; logs persisted under `docs/crash_logs/20260528-113348` |
| 2026-05-28 11:44:14 AM | Unexpected shutdown before major storage/power isolation | Reboot/log at 12:23:31 PM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; no minidump or `MEMORY.DMP`; user then removed PCI SATA expansion from active path and removed legacy Molex-to-SATA power branch; logs persisted under `docs/crash_logs/20260528-123113` |
| 2026-05-28 12:23:38 PM | Unexpected shutdown before true OS-only soak began | Reboot/log at 12:50:08 PM; `Kernel-Power 41`, `BugcheckCode=0`; fatal `WHEA-Logger 1`; user clarified the OS-only drive configuration began after this recovery; logs persisted under `docs/crash_logs/20260528-125342` |

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
- The crash recurred after the first successful overnight soak, so the broken-pin drive was not the complete fix.
- Current diagnosis: the removed broken-pin drive, its power connection, or related SATA/power cabling may have been a contributor, but the recurring fatal WHEA firmware records now point more strongly at a remaining platform-level hardware/firmware/power stability problem.
- Do not reconnect the broken-pin drive or reuse its power/SATA cabling for normal service until there is an explicit recovery plan.
- On 2026-05-27, `H:` / `TV 2` was present again and Docker mapped `/tv/tv2` to `H:\` correctly. Continue verifying this after every crash or storage change.

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

## 2026-05-27 Recurrent Crash Diagnosis

- User reported another crash after the initial post-drive-swap soak.
- Current boot time at check: `2026-05-27 10:56:57 PM`; check time: `2026-05-27 10:59 PM`.
- Windows recorded unexpected shutdowns on 2026-05-26 and three times on 2026-05-27.
- The latest previous shutdown time was `2026-05-27 6:48:11 PM`, logged after boot at `2026-05-27 10:57:14 PM`.
- `Kernel-Power 41` for recent crashes showed `BugcheckCode=0`, `PowerButtonTimestamp=0`, `SleepInProgress=0`, and `ConnectedStandbyInProgress=false`.
- No `C:\Windows\Minidump` files or `C:\Windows\MEMORY.DMP` were found after the latest crash.
- Recent `WHEA-Logger` Event 1 records all had a 3552-byte CPER record with three fatal sections of type `81212a96-09ed-4996-9471-8d729c8e69ed`, which is the UEFI CPER `Firmware Error Record Reference` section type.
- The firmware error reference section reported firmware error record type `2`, defined by UEFI CPER as `SOC Firmware error record Type2`.
- This is not the earlier Realtek Wi-Fi / HAL IOMMU requester-ID signature. The latest pattern is a fatal firmware/platform hardware error persisted across resets.
- Current storage check after reboot showed `H:` / TV 2 present again, `G:` Empty present, `I:\torrentfiles` present, qBittorrent `/downloads` correctly mounted from `I:\`, and Sonarr `/tv/tv2` correctly mounted from `H:\`.
- `Get-PhysicalDisk` showed all detected disks `Healthy` / `OK`.
- RAM reported two Lexar 16 GB DIMMs in A2/B2 at `4800` configured clock; XMP still does not appear active.
- Device Manager query found no devices with nonzero `ConfigManagerErrorCode`.
- Best current diagnosis: not a normal Windows/application/Docker crash and not proven to be a single bad media drive. The evidence points to a remaining platform-level hardware/firmware/power stability fault, with motherboard/CPU/RAM/PSU cabling or power delivery now ahead of Plex/Docker/storage-service explanations.

## 2026-05-28 Crash Evidence Bundle

- User reported another crash overnight.
- Capture directory: `docs/crash_logs/20260528-070552`.
- Current boot time at capture: `2026-05-28 7:03:42 AM`.
- Latest unexpected previous shutdown: `2026-05-27 11:34:23 PM`.
- Recent unexpected shutdown records also include `2026-05-27 10:57:14 PM`, `2026-05-27 6:48:11 PM`, and `2026-05-27 12:59:42 PM`.
- Latest `Kernel-Power 41` at `2026-05-28 7:03:46 AM` again showed `BugcheckCode=0`, `PowerButtonTimestamp=0`, `SleepInProgress=0`, and `ConnectedStandbyInProgress=false`.
- Latest WHEA Event 1 at `2026-05-28 7:04:00 AM` again preserved a 3552-byte CPER record with three fatal `Firmware Error Record Reference` sections.
- No Windows minidump or `MEMORY.DMP` was present.
- Post-boot mount checks were healthy: `I:\torrentfiles` true, `H:\TV Shows` true, qBittorrent `/downloads` on `I:\`, and Sonarr `/tv/tv2` on `H:\`.
- Device Manager nonzero error-code scan was empty.
- Persisted files include native `System-last18h.evtx`, `Application-last18h.evtx`, PowerShell CLIXML event exports, `crash-summary.json`, `latest-whea.cper`, `latest-whea-decoded.json`, `mount-checks.json`, and `device-manager-errors.json`.
- Recommended next component to verify: PSU/power delivery path, including the reused Corsair RM750e and every modular PSU/SATA power cable branch feeding the drives.

## 2026-05-28 Motherboard Power Cable Inspection And New Crash

- User reported another crash after inspecting motherboard power cables and provided photos.
- Capture directory: `docs/crash_logs/20260528-113348`.
- Current boot time at capture: `2026-05-28 11:30:19 AM`.
- Latest unexpected previous shutdown: `2026-05-28 10:23:59 AM`.
- Latest `Kernel-Power 41` at `2026-05-28 11:30:23 AM` again showed `BugcheckCode=0`, `PowerButtonTimestamp=0`, `SleepInProgress=0`, and `ConnectedStandbyInProgress=false`.
- No Windows minidump or `MEMORY.DMP` was present.
- No new WHEA Event 1 was present yet for this specific reboot during the initial capture window, though the previous 2026-05-27/2026-05-28 pattern still includes fatal WHEA firmware/platform records.
- Photo review did not show obvious melting or scorching on the visible 24-pin ATX or 8-pin EPS connectors. The missing/blank position on the 24-pin connector is normal for modern ATX cables.
- The motherboard has two CPU EPS power sockets. Verify `CPU_PWR1` is fully seated with a correct CPU/EPS 4+4 cable; populate `CPU_PWR2` with a second correct CPU/EPS cable if available for isolation. Do not use a PCIe/VGA 8-pin cable in CPU power.
- PSU-side photo should be checked for full seating of both motherboard cable plugs and correct use of PSU sockets. Use only Corsair RM750e-compatible cables.
- Important new storage finding: after this crash, `I:` / Torrent was absent. `Test-Path I:\` and `Test-Path I:\torrentfiles` returned false.
- Docker started while `I:` was absent and showed qBittorrent `/downloads` as a tiny full `137M` placeholder filesystem.
- Physical disk inventory after this crash did not show the prior 20 TB Torrent drive serial `ZYE00444`.
- `H:` / TV 2, `J:` / TV 1, movie drives, OS SSD, and `G:` Empty were present and healthy.
- Current strongest component-level follow-up: verify the SATA power cable/branch feeding the `I:` Torrent drive. If that branch also touched the old broken-pin drive or carries multiple HDDs, remove it from service and move `I:` to a different confirmed RM750e-compatible SATA power cable before resuming qBittorrent.

## 2026-05-28 Torrent Drive SATA Data Cable Finding

- User found the SATA data cable had come loose from the `I:` / Torrent drive.
- User reported the cable did not sit firmly on the drive's SATA data connector pins.
- User reversed the cable, moving the formerly drive-side connector to the PCI SATA expansion card side and the formerly card-side connector to the drive side, hoping the fit is more stable.
- After this change, Windows detected `I:` / Torrent again with `I:\torrentfiles` present.
- Physical disk serial `ZYE00444` appeared again and reported `Healthy` / `OK`.
- Docker then showed qBittorrent `/downloads` correctly mounted from `I:\`, about `19T` total and `15T` available, and Sonarr showed `/downloads`, `/tv/tv1`, and `/tv/tv2` correctly mapped.
- Treat the loose SATA data cable as a confirmed storage-path fault for the disappearing `I:` drive. It does not yet prove the loose data cable caused the hard-reset crash pattern, but it is now a concrete hardware variable under soak.
- Recommended next step: replace this SATA data cable with a known-good locking SATA cable if the connector still feels loose, and avoid cable tension at the drive end.

## 2026-05-28 Major Storage And Power Isolation

- User recovered from another crash, then removed every drive except OS, Torrent, TV 1, and TV 2.
- Remaining drives are plugged directly into motherboard SATA ports.
- PCI SATA expansion card was removed from the active storage path.
- The power cable branch previously used with the broken-pin drive was removed entirely.
- User noted this branch was a legacy 4-pin peripheral/Molex-style power cable with SATA power adapter(s), used because the PSU did not come with enough native SATA power cables.
- This adapter branch had powered the broken-pin drive and other drives.
- Current detected fixed volumes after isolation: `C:`, `H:` TV 2, `I:` Torrent, and `J:` TV 1.
- Current detected physical disks after isolation: OS SSD `S1DDNWAF903275D`, TV 1 `ZVTBPM4J`, TV 2 `ZYD02EQ2`, and Torrent `ZYE00444`.
- qBittorrent `/downloads` was correctly mounted from `I:\`, and Sonarr `/tv/tv1`, `/tv/tv2`, and `/downloads` were correctly mapped.
- Current strongest component-level suspect: the removed legacy 4-pin-to-SATA adapter/power branch, especially because it fed multiple HDDs and was associated with the physically damaged broken-pin drive. Do not reuse it.
- Next soak posture: only direct motherboard SATA data paths and native RM750e-compatible modular SATA power cables. If more SATA power connectors are needed, obtain compatible Corsair RM750e SATA power cables rather than using 4-pin-to-SATA adapters.

## 2026-05-28 OS-Only SATA Storage Isolation Started

- User initially reported the soak failed again, then clarified that the true OS-only drive state began after this recovery.
- Exact active soak state as of 2026-05-28: only the OS drive is connected; all media and torrent drives are disconnected.
- The OS-only soak started on 2026-05-28.
- User removed all SATA drives/cables and unused power cables except for the OS SSD after the `2026-05-28 12:23:38 PM` unexpected shutdown.
- Capture directory: `docs/crash_logs/20260528-125342`.
- Current boot time at capture: `2026-05-28 12:50:06 PM`.
- Latest unexpected previous shutdown: `2026-05-28 12:23:38 PM`.
- Latest `Kernel-Power 41` at `2026-05-28 12:50:08 PM` again showed `BugcheckCode=0`, `PowerButtonTimestamp=0`, `SleepInProgress=0`, and `ConnectedStandbyInProgress=false`.
- Latest WHEA Event 1 at `2026-05-28 12:50:15 PM` again preserved a 3552-byte fatal hardware error record.
- No Windows minidump or `MEMORY.DMP` was present.
- Windows detected only `C:` and only physical disk serial `S1DDNWAF903275D` after the user changed to the OS-only isolation state.
- RAM still reported two Lexar 16 GB DIMMs in A2/B2 at `4800`.
- GPU still detected as NVIDIA GeForce RTX 3050, status `OK`.
- This does not yet prove the system crashes with only the OS SSD connected. The current active test is to soak in this OS-only storage state.
- If the system crashes during this OS-only soak, then the disconnected media drives, PCI SATA expansion card, loose Torrent-drive SATA data cable, and removed Molex-to-SATA adapter branch become much less likely to be the complete root cause.
- Do not move to RAM isolation until the OS-only storage soak either fails or runs long enough to change the diagnosis.

## 2026-05-28 OS-Only Soak Checkpoint

- At `2026-05-28 9:22 PM`, Windows reported boot time `2026-05-28 12:50:06 PM`, about 8.54 hours uptime.
- Windows still detected only `C:` and physical disk serial `S1DDNWAF903275D`.
- No new `Kernel-Power 41` / `EventLog 6008` crash entries appeared after the OS-only test began.
- This is a meaningful improvement compared with the dense 2026-05-28 crash cluster, but it is not yet a 24-hour proof.
- It is reasonable to begin cautious reassembly if every added component is treated as a new test variable with its own soak checkpoint.

## 2026-05-28 Reassembly Step 1 - Torrent Drive

- User connected only the `I:` / Torrent drive in addition to the OS SSD.
- User used a dedicated SATA data cable and a dedicated native power cable for the Torrent drive.
- Windows detected `C:` and `I:` only.
- `I:` was labeled `Torrent`, NTFS, about `18.19 TiB`, with about `14.67 TiB` free.
- `Test-Path I:\torrentfiles` returned `True`.
- Physical disk inventory showed OS SSD serial `S1DDNWAF903275D` and Torrent drive serial `ZYE00444`, both `Healthy` / `OK`.
- Current reassembly test posture: soak with only `C:` and `I:` connected. Do not add another drive until this step passes its soak checkpoint.

## 2026-05-28 Reassembly Step 2 - TV Drive Attempt

- User chose to reconnect TV drives for Plex viewing, with qBittorrent and Arr services left off.
- User reported the TV drives are using the same native power cable as the Torrent drive.
- Windows check after reboot showed `C:`, `H:` TV 2, and `I:` Torrent present.
- Physical disk inventory showed OS SSD `S1DDNWAF903275D`, TV 2 `ZYD02EQ2`, and Torrent `ZYE00444`, all `Healthy` / `OK`.
- `J:` / TV 1 was not visible in the checked Windows volume inventory.
- Docker check showed only `torrent-mcp` running; the main qBittorrent/Arr stack was not running at that moment.
- Current test posture: `C:` + `I:` + `H:` with TV 1 absent, no main qBittorrent/Arr stack. If a crash occurs, remove TV drives and return to `C:` + `I:` only.

## 2026-05-29 Overnight Reassembly Soak Checkpoint

- At `2026-05-29 6:48 AM`, Windows reported boot time `2026-05-28 10:11:51 PM`, about 8.62 hours uptime.
- Current visible fixed volumes: `C:`, `H:` TV 2, `I:` Torrent, and `J:` TV 1.
- Current physical disks: OS SSD `S1DDNWAF903275D`, TV 1 `ZVTBPM4J`, TV 2 `ZYD02EQ2`, and Torrent `ZYE00444`; all reported `Healthy` / `OK`.
- No new `Kernel-Power 41`, `EventLog 6008`, or WHEA Event 1 crash records appeared after the current boot. The only matching events in the 18-hour window were from the previous 2026-05-28 crash.
- This is a meaningful overnight checkpoint for the `C:` + `H:` + `I:` + `J:` reassembly state, with media automation still intended to remain quiet unless explicitly restarted.

## 2026-05-29 Controlled Docker Software Test - qBittorrent And Sonarr

- User requested a software-layer test by starting qBittorrent and Sonarr only.
- Precheck: `I:\torrentfiles` returned `True`.
- Precheck: Windows visible fixed volumes were `C:`, `H:` TV 2, `I:` Torrent, and `J:` TV 1.
- Started only `qbittorrent` and `sonarr` with `docker compose -f C:\plex-server\docker-compose.media.yml up -d qbittorrent sonarr`.
- Post-start qBittorrent `/downloads` mapped correctly to `I:\`, about `19T` total and `15T` available.
- Post-start Sonarr mounts mapped correctly: `/downloads` to `I:\`, `/tv/tv1` to `J:\`, and `/tv/tv2` to `H:\`.
- Local HTTP checks returned `200` for qBittorrent on port `8080` and Sonarr on port `8989`.
- Current software test posture: `C:` + `H:` + `I:` + `J:` drives connected, qBittorrent and Sonarr running, other Arr/media containers still intentionally stopped unless separately started.

## 2026-05-29 Stable-State Diagnostic Sweep

- At `2026-05-29 9:53 AM`, Windows reported boot time `2026-05-28 10:11:51 PM`, about 11.7 hours uptime.
- No new `Kernel-Power 41`, `EventLog 6008`, or WHEA Event 1 crash records appeared after the current boot; matching records in the 24-hour window were from prior 2026-05-28 crashes.
- Current fixed volumes: `C:`, `H:` TV 2, `I:` Torrent, and `J:` TV 1; all reported `Healthy` / `OK`.
- Current physical disks: OS SSD `S1DDNWAF903275D`, TV 1 `ZVTBPM4J`, TV 2 `ZYD02EQ2`, and Torrent `ZYE00444`; all reported `Healthy` / `OK`.
- Device Manager nonzero error-code scan returned no devices.
- Docker containers running: qBittorrent, Sonarr, and `torrent-mcp`.
- Docker mounts were healthy: qBittorrent `/downloads` on `I:\`; Sonarr `/downloads` on `I:\`, `/tv/tv1` on `J:\`, and `/tv/tv2` on `H:\`.
- New caution signal: System log had two `disk` Event ID 153 retry warnings for `Disk 1`, which maps to `J:` / TV 1, serial `ZVTBPM4J`.
- No matching new crash followed those disk retries during the checked window, but treat `J:` / TV 1's data/power path as a watch item during the next soak.
- Attempted online `chkdsk /scan` for `J:`, `I:`, and `H:`, but the current shell was not elevated and Windows returned access denied. No repair action was attempted.

## 2026-05-29 Crash After qBittorrent And Sonarr Test

- User reported another crash shortly after qBittorrent and Sonarr were started, after roughly 12 hours of apparent stability in the same drive-connected state.
- Capture directory: `docs/crash_logs/20260529-101903-qbit-sonarr`.
- Current boot time after recovery: `2026-05-29 10:19:03 AM`.
- Windows recorded previous unexpected shutdown at `2026-05-29 10:07:35 AM`.
- Latest `Kernel-Power 41` at `2026-05-29 10:19:06 AM` again showed `BugcheckCode=0`, `PowerButtonTimestamp=0`, `SleepInProgress=0`, and `ConnectedStandbyInProgress=false`.
- Latest `WHEA-Logger` Event 1 at `2026-05-29 10:19:14 AM` again preserved a 3552-byte CPER record with three fatal Firmware Error Record Reference sections.
- No minidump or `MEMORY.DMP` was found.
- Current fixed volumes after reboot: `C:`, `H:` TV 2, `I:` Torrent, and `J:` TV 1; all reported `Healthy` / `OK`.
- Current physical disks after reboot: OS SSD `S1DDNWAF903275D`, TV 1 `ZVTBPM4J`, TV 2 `ZYD02EQ2`, and Torrent `ZYE00444`; all reported `Healthy` / `OK`.
- qBittorrent log showed normal startup at about `09:27:39`, restored torrents from the configured `I:\torrentfiles` mount, and recorded at least one completed torrent before the crash. There was no clean qBittorrent shutdown before the crash.
- Sonarr log showed startup at about `09:27:42`, successful qBittorrent authentication, and a broad TV library scan across `/tv/tv1` and `/tv/tv2`; the broad scan appears to have completed around `09:34:43`.
- Later Sonarr activity was mostly RSS/indexer polling. The `prowlarr:9696` DNS errors are expected in this test because Prowlarr was intentionally not running.
- Windows did not log a pre-crash `disk`, `storahci`, or `NTFS` warning in the checked `09:20-10:07` window.
- Docker Desktop logs did not show an application panic or mount failure before the crash; they showed normal API polling and qBittorrent-related network forwarding activity.
- Interpretation: this does not prove the qBittorrent `I:\` mount is logically bad. The stronger current read is that qBittorrent plus Sonarr created storage, network, Docker/WSL, and SATA power activity that reproduced the existing hardware/platform crash.
- Because the TV drives were reported to be sharing the same power cable as the Torrent drive, treat the shared SATA power branch feeding `I:`, `H:`, and/or `J:` as the next component/path to verify.
- Keep qBittorrent and Sonarr stopped for now. Next isolation should avoid starting qBittorrent and Sonarr together; test one variable at a time only after the current hardware/power path is reviewed.

## 2026-05-29 qBittorrent-Only Recurrence

- User recovered from another crash and reported it happened right after starting qBittorrent alone.
- Capture directory: `docs/crash_logs/20260529-131946-qbittorrent-only`.
- Current boot time after recovery: `2026-05-29 1:19:46 PM`.
- Windows recorded previous unexpected shutdown at `2026-05-29 1:11:14 PM`.
- Latest `Kernel-Power 41` again showed a hard reset pattern rather than a normal application failure.
- Latest `WHEA-Logger` Event 1 at `2026-05-29 1:19:56 PM` preserved another 3552-byte `CPER` record with three fatal Firmware Error Record Reference sections.
- No minidump or `MEMORY.DMP` was found.
- qBittorrent container state after recovery was `Exited (137)` and `OOMKilled=false`.
- qBittorrent was mounted from `C:\media-stack\config\qbittorrent` to `/config` and from `I:\torrentfiles` to `/downloads`.
- qBittorrent relevant config still points downloads and incomplete downloads at `/downloads`, with TCP/UDP peer port `6881` and WebUI port `8080`.
- qBittorrent session storage contained 39 torrent/session records in `BT_backup`; this means startup is immediate restore plus peer/network/disk activity, not an idle service start.
- Windows still saw `C:`, `H:`, `I:`, and `J:` after reboot, and `I:\torrentfiles` returned `True`.
- No checked pre-crash `disk`, `storahci`, or `NTFS` warning was found; storage visibility after reboot does not rule out a transient power/data-path fault during qBittorrent load.
- Hardware monitor note: the crash-window logger initialized at `1:11:42 PM`, but the hard reset occurred before any complete JSON sensor row flushed. The file contains only BOM/header data plus NUL padding.
- Post-reboot hardware monitoring was healthy: AIDA64 export was visible, Core Temp was running, sensor rows were captured, maximum observed post-reboot GPU hotspot was about `70 C`, CPU package/cores peaked about `68 C`, `+12 V` and `+3.3 V` readings were visible, and no thermal emergency was evident.
- Interpretation: qBittorrent is now a confirmed trigger, but the root cause still looks below qBittorrent: platform/power/storage-path instability under qBittorrent's combined Docker bind mount, `I:` drive I/O, and peer/network activity.
- Current top isolation target: put `I:` / Torrent on its own known-good native Corsair RM750e SATA power cable and a known-good locking SATA data cable, ideally on a different motherboard SATA port, before another qBittorrent load test.
- If practical, repeat the next qBittorrent test with only `C:` and `I:` connected so `H:` / TV 2 and `J:` / TV 1 are not sharing the power/load path.
- Do not use the old Molex-to-SATA adapter branch or any non-RM750e modular PSU cable.
- Keep qBittorrent stopped until the next deliberate isolation test.

## 2026-05-29 Clean C + I Isolation State

- User returned with only the OS SSD and Torrent drive connected.
- User reported `C:` and `I:` are each on dedicated SATA data cables and dedicated SATA power cables.
- Check time: `2026-05-29 2:06 PM`.
- Current boot time: `2026-05-29 1:43:43 PM`.
- Windows visible fixed volumes: `C:` and `I:` only.
- `I:` is labeled `Torrent`, NTFS, about `18.19 TiB`, with about `14.67 TiB` free.
- `Test-Path I:\torrentfiles` returned `True`.
- Physical disks visible: OS SSD `S1DDNWAF903275D` and Torrent drive `ZYE00444` only; both reported `OK`.
- qBittorrent remained stopped: `Exited (137)` from the prior crash/recovery.
- This is the cleanest current test posture for isolating whether qBittorrent load can crash the machine when the TV drives and shared drive-power branch are removed from the equation.
- Next deliberate test, when accepted: start qBittorrent only, leave Sonarr and other Arr containers stopped, and watch for immediate crash. Passing this test would shift suspicion back toward the removed TV-drive/shared-power path; failing it would point at the `I:` Torrent drive path, Docker/WSL/NIC path, or platform stability under qBittorrent load.

## 2026-05-29 qBittorrent Offline Start Passed

- User approved a delayed qBittorrent start so the network could be disconnected before qBittorrent launched.
- Timer armed at `2026-05-29 2:13:26 PM`; planned qBittorrent start at `2026-05-29 2:15:26 PM`.
- Timer log: `docs/crash_logs/qbit-offline-timer/qbit-delayed-start-20260529-141326.log`.
- User returned after about one hour and reported there was no crash.
- Verification at `2026-05-29 3:20 PM`: Windows boot time was still `2026-05-29 1:43:43 PM`.
- `qbittorrent` was `Up About an hour`; Sonarr remained stopped.
- Windows visible fixed volumes remained `C:` and `I:` only.
- `I:\torrentfiles` returned `True`.
- Inside the qBittorrent container, `/downloads` mounted correctly to `I:\`, about `19T` total, `15T` available, and `20%` used.
- No new `Kernel-Power 41`, `EventLog 6008`, WHEA, disk, storahci, or NTFS warning was found in the checked window after the timer was armed.
- Interpretation: qBittorrent container start, qBittorrent session restore, Docker bind mount, and basic `I:` disk path are not sufficient by themselves to reproduce the crash in this clean `C:` + `I:` state. The next suspect is live qBittorrent network/peer traffic through Docker Desktop, WSL/Hyper-V networking, the motherboard NIC, or the LAN/internet path.
- Keep this as a major split result. The next test should reconnect network with qBittorrent already running and keep Sonarr/Arr stopped, then watch for crash timing.

## 2026-05-29 qBittorrent Network Restart Test

- User requested a qBittorrent container restart to test the network-traffic theory.
- Restart command issued at `2026-05-29 3:22:57 PM`.
- Timer/restart log: `docs/crash_logs/qbit-network-restart-test/qbit-network-restart-20260529-152257.log`.
- Restart completed at `2026-05-29 3:22:59 PM`; `qbittorrent` returned `Up Less than a second`.
- First-minute check: qBittorrent was `Up About a minute`; Sonarr remained stopped; `/downloads` still mounted to `I:\`, about `19T` total and `15T` available.
- Five-minute check: qBittorrent was `Up 5 minutes`; Sonarr remained stopped; `/downloads` still mounted to `I:\`.
- No matching new `Kernel-Power 41`, `EventLog 6008`, WHEA, disk, storahci, or NTFS events were found in the checked window after restart.
- Interpretation: qBittorrent restart with network available did not cause an immediate crash in the clean `C:` + `I:` state. This weakens the theory that mere container network initialization is sufficient. Continue watching sustained peer traffic before calling the network path safe.

## 2026-05-29 qBittorrent Networked Soak Crash

- User recovered from another crash and manually stopped the qBittorrent container in Docker.
- Bundle: `docs/crash_logs/20260529-160028-qbit-network-soak/`.
- qBittorrent network restart test had been issued at `2026-05-29 3:22:57 PM`.
- qBittorrent survived the first-minute and five-minute checks with Sonarr stopped and `/downloads` still mapped to `I:\torrentfiles`.
- Windows later recorded the previous shutdown at `2026-05-29 3:28:50 PM` as unexpected.
- Reliability Monitor exposed the same EventLog `6008` unexpected-shutdown record and no more specific application-fault cause.
- Windows booted again at `2026-05-29 4:00:28 PM`.
- Latest post-recovery evidence again showed `Kernel-Power 41` plus `WHEA-Logger` Event 1, with a 3552-byte CPER record containing three fatal Firmware Error Record Reference sections.
- No minidump or `C:\Windows\MEMORY.DMP` was found.
- No checked `disk`, `storahci`, or `NTFS` warning was found in the filtered crash/recovery window.
- Current visible fixed volumes after recovery remained `C:` and `I:` only.
- `I:\torrentfiles` returned `True`.
- qBittorrent was `Exited (137)` after the user stopped it; `OOMKilled=false`.
- qBittorrent mount configuration remained `I:\torrentfiles` to `/downloads`.
- Sonarr remained stopped from the prior test path; this recurrence does not require Sonarr.
- TV drives were disconnected, the PCI SATA card was removed, and the old broken-pin-drive power branch was absent for this reproduction.
- Hardware-monitor note: no direct sensor rows cover the actual `3:22 PM` to `3:28 PM` qBittorrent networked crash window. The pre-crash logger stopped writing around `2:10 PM`, and the next logger started after reboot around `4:01 PM`.
- Interpretation: this is the clearest split so far. qBittorrent offline/startup/mount behavior passed in the clean `C:` + `I:` state, but sustained networked qBittorrent activity crashed the machine. This points away from TV drives, shared TV/Torrent drive power, Sonarr, and basic qBittorrent startup as primary causes for this reproduction.
- Current leading suspect path: qBittorrent peer/network load through Docker Desktop, WSL/Hyper-V networking, motherboard Ethernet/NIC driver, or platform firmware/power response to that network/interrupt workload.
- Active wired adapter at capture time: `Intel(R) Ethernet Controller I226-V #2`, `1 Gbps`, driver date `2024-02-15`, version `1.1.4.43`.
- Docker path at capture time: Docker Desktop `4.74.0`, engine `29.4.3`, WSL2 kernel `6.6.114.1-microsoft-standard-WSL2`.
- Storage/power is not fully cleared, but it is now lower than the qBittorrent live network path for this exact reproduction.
- Keep qBittorrent stopped until the next deliberate isolation test.
- Next recommended test should avoid full normal torrent traffic. Prefer either a controlled non-torrent network load test, or a constrained qBittorrent test with torrents paused/listening disabled/connection limits lowered after explicit approval.

## 2026-05-29 qBittorrent Config And Research Notes

- Current qBittorrent image: `lscr.io/linuxserver/qbittorrent:latest`, locally resolved to LinuxServer build `5.2.0_v2.0.12-ls458`, created `2026-05-17`.
- LinuxServer documents `latest` as stable qBittorrent releases using libtorrent v2, and separately offers a `libtorrentv1` stable tag.
- Current compose shape:
  - default Docker bridge network `plex-media-stack_default`;
  - `/config` bound to `C:\media-stack\config\qbittorrent`;
  - `/downloads` bound to `I:\torrentfiles`;
  - WebUI TCP `8080` bound to `0.0.0.0`;
  - peer TCP `6881` and UDP `6881` published to all host interfaces;
  - restart policy `unless-stopped`;
  - no explicit CPU, memory, connection, or process limits.
- Current qBittorrent config is sparse. It sets save and incomplete paths under `/downloads`, disables UPnP/NAT-PMP, and binds WebUI to `0.0.0.0`, but does not explicitly cap global connections, connections per torrent, upload slots, active torrents, DHT, PeX, LSD, uTP, disk cache, async I/O threads, or OS-cache behavior.
- qBittorrent logs show each start enables DHT, Local Peer Discovery, PeX, encryption, TCP listening, and uTP/UDP listening on `6881`.
- qBittorrent restored 39 torrents from `BT_backup` at startup; the active session is not an empty client.
- qBittorrent 5.2.0 release notes include performance changes around resume-load behavior and raised connection max limits. That does not prove a bug here, but it makes the `latest` tag less ideal while debugging a hard crash.
- Public reports exist for qBittorrent-in-Docker memory growth or host lockups, especially around qBittorrent/libtorrent version lines and large torrent sets. Those reports usually produce application/container memory failure, not WHEA hard resets, so they are supporting context rather than a direct match.
- Docker Desktop documentation says Windows container networking goes through `com.docker.backend.exe`; outbound traffic from containers is seen by host firewalls/security tooling as that backend process, and published ports are forwarded into the Linux VM.
- Active wired adapter settings at capture time:
  - `Intel(R) Ethernet Controller I226-V #2`;
  - driver date `2024-02-15`, version `1.1.4.43`;
  - Energy Efficient Ethernet already `Off`;
  - Interrupt Moderation `Enabled`;
  - IPv4/IPv6 TCP checksum offload enabled;
  - IPv4/IPv6 UDP checksum offload enabled;
  - Large Send Offload v2 enabled for IPv4 and IPv6;
  - Selective Suspend enabled.
- Intel community troubleshooting for I226-V connection issues includes checking Energy Efficient Ethernet and checksum offload behavior. This does not prove the NIC is bad, but it aligns with a safe software-side isolation pass.
- Software-first test order, before another full normal qBittorrent run:
  1. Create a backup copy of the current qBittorrent config and `BT_backup`.
  2. Pin qBittorrent away from floating `latest`, preferably to LinuxServer `5.2.0-libtorrentv1` for the first isolation pass.
  3. Add explicit qBittorrent limits before start: low global/per-torrent connections, low upload slots, low active torrents, no DHT, no PeX, no Local Peer Discovery, and consider disabling uTP/UDP by not publishing peer UDP for the test.
  4. Add a Docker memory limit so qBittorrent can fail inside the container instead of pressuring the whole host if a memory/cache path is involved.
  5. If the constrained/libtorrentv1 test passes, re-enable features one at a time: TCP peer port, then UDP/uTP, then DHT, then PeX/LSD, then higher connection limits.
  6. If it still crashes under constrained/libtorrentv1 settings, test the Windows NIC driver path next by disabling offloads/selective suspend/interrupt moderation or using a different network adapter.

## 2026-05-29 qBittorrent Conservative Profile Applied

- User approved applying the conservative qBittorrent software-isolation profile.
- qBittorrent was stopped before changes.
- Backup created outside the repo at `C:\media-stack\backups\qbittorrent-pre-conservative-20260529-162450`.
- Backup includes:
  - `qBittorrent.conf`;
  - `qBittorrent-data.conf`;
  - `BT_backup` with 80 files.
- `docker-compose.media.yml` changed qBittorrent from `lscr.io/linuxserver/qbittorrent:latest` to `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`.
- Rendered qBittorrent image after pull/create: LinuxServer build `5.2.0_v1.2.20-ls117`, created `2026-05-17`.
- qBittorrent compose now publishes:
  - WebUI TCP `8080`;
  - peer TCP `6881`;
  - no peer UDP `6881` publication for the first isolation pass.
- qBittorrent compose now includes `mem_limit: 4g`.
- qBittorrent config now explicitly sets:
  - `Session\BTProtocol=TCP`;
  - `Session\DHTEnabled=false`;
  - `Session\LSDEnabled=false`;
  - `Session\PeXEnabled=false`;
  - `Session\MaxConnections=50`;
  - `Session\MaxConnectionsPerTorrent=10`;
  - `Session\MaxUploads=20`;
  - `Session\MaxUploadsPerTorrent=4`;
  - `Session\MaxActiveDownloads=1`;
  - `Session\MaxActiveUploads=1`;
  - `Session\MaxActiveTorrents=2`;
  - `Session\QueueingSystemEnabled=true`.
- The qBittorrent container was recreated but left in `Created` state, not started.
- Post-change storage check still showed only `C:` and `I:` fixed volumes, and `I:\torrentfiles` returned `True`.
- Next test, when explicitly started: run qBittorrent alone in this conservative profile, leave Sonarr/Arr stopped, and treat any crash as evidence against the qBittorrent/libtorrent-v2/unbounded-UDP theory and back toward Docker Desktop/WSL, NIC driver, platform firmware, or remaining hardware sensitivity.

## 2026-05-29 qBittorrent Conservative Profile Start

- User approved starting qBittorrent in the conservative profile.
- Start log: `docs/crash_logs/qbit-conservative-test/qbit-conservative-start-20260529-162809.log`.
- qBittorrent start command issued at `2026-05-29 4:28:09 PM`.
- qBittorrent started as `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`.
- Sonarr remained stopped.
- qBittorrent log confirmed:
  - DHT support `OFF`;
  - Local Peer Discovery support `OFF`;
  - PeX support `OFF`;
  - TCP peer listener on `6881`.
- Docker compose is not publishing peer UDP `6881` for this test.
- qBittorrent still opened an internal UDP listener, but that UDP path is not published through Docker Desktop to the host.
- `/downloads` inside qBittorrent mapped correctly to `I:\`, about `19T` total, `15T` available, `20%` used.
- One-minute check: qBittorrent was up, memory about `548 MiB / 4 GiB`, Sonarr stopped, no new crash/storage/WHEA records found in the checked System log window.
- Three-minute check: qBittorrent was up, memory about `546 MiB / 4 GiB`, Sonarr stopped, no new crash/storage/WHEA records found.
- Seven-minute check: qBittorrent was up, memory about `547 MiB / 4 GiB`, `/downloads` still mapped to `I:\`, and no new crash/storage/WHEA records found.
- This passed the previous qBittorrent-networked failure window; the prior clean `C:` + `I:` networked qBittorrent test crashed about six minutes after restart.
- Interpretation so far: the conservative qBittorrent profile is materially different from the failing profile and has survived the first crash-prone interval. Do not declare solved yet; continue soaking before re-enabling Sonarr, UDP/uTP, DHT, PeX, LSD, higher limits, or TV drives.

## 2026-05-29 qBittorrent Container Hardening Staged

- User asked to stage additional Docker container hardening without restarting the running qBittorrent soak.
- `docker-compose.media.yml` now includes these qBittorrent settings for the next recreate:
  - `cpus: "2.0"`;
  - `pids_limit: 256`;
  - `ulimits.nofile.soft: 2048`;
  - `ulimits.nofile.hard: 4096`;
  - JSON-file log rotation with `max-size: "10m"` and `max-file: "3"`;
  - `stop_grace_period: 2m`.
- Compose rendering was validated successfully.
- The running qBittorrent container was not recreated or restarted.
- Verification showed the running container is still up on the conservative profile, but the newly staged CPU/PID/ulimit/logging/stop-grace settings are not active yet.
- These staged settings should take effect only after the next deliberate qBittorrent recreate/restart.

## 2026-05-29 qBittorrent Hardening Recreate

- User reported the conservative qBittorrent soak had reached about one hour and asked to restart qBittorrent.
- Because the staged Docker limits require container recreation, qBittorrent was recreated with `docker compose -f C:\plex-server\docker-compose.media.yml up -d --force-recreate qbittorrent`.
- Recreate log: `docs/crash_logs/qbit-conservative-test/qbit-conservative-recreate-20260529-173114.log`.
- Pre-recreate status at `2026-05-29 5:30 PM`:
  - qBittorrent had been up about one hour;
  - memory about `547 MiB / 4 GiB`;
  - network I/O about `146 GB / 7.21 GB`;
  - `/downloads` mapped to `I:\`;
  - no new crash/storage/WHEA records were found in the checked System log window since conservative start.
- Recreate requested at `2026-05-29 5:31:14 PM`.
- Post-recreate live container limits verified:
  - image `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`;
  - memory cap `4 GiB`;
  - CPU quota `2.0`;
  - `pids_limit: 256`;
  - `nofile` soft `2048`, hard `4096`;
  - JSON-file logging with `max-size=10m`, `max-file=3`;
  - stop timeout `120` seconds;
  - published ports remain TCP `8080` and TCP `6881` only.
- `/downloads` after recreate still mapped correctly to `I:\`, about `19T` total, `15T` available.
- Five-minute post-recreate check passed:
  - qBittorrent up about five to six minutes;
  - memory about `540 MiB / 4 GiB`;
  - `ulimit -n` inside the container returned `2048`;
  - no new crash/storage/WHEA records were found in the checked System log window.
- Interpretation: conservative qBittorrent profile passed a one-hour soak, then also survived the first post-recreate failure window with the Docker hardening active. Continue this exact state before adding Sonarr/Arr or re-enabling UDP/DHT/PeX/LSD.

## 2026-05-29 qBittorrent Hardened Recreate Crash

- User reported the machine crashed after the last qBittorrent container hardening settings were applied.
- Bundle: `docs/crash_logs/20260529-221657-qbit-hardened-recreate-crash/`.
- Windows recorded the previous shutdown at `2026-05-29 5:43:35 PM` as unexpected.
- Windows booted after recovery at `2026-05-29 10:16:57 PM`.
- Post-recovery System log again showed `Kernel-Power 41` and `WHEA-Logger` Event 1 with a 3552-byte CPER payload and three Firmware Error Record Reference sections.
- Reliability Monitor only exposed the same EventLog `6008` unexpected-shutdown record.
- No minidump or `C:\Windows\MEMORY.DMP` was found.
- No checked `disk`, `storahci`, or `NTFS` warning was found in the filtered crash/recovery window.
- Post-recovery visible fixed volumes were still `C:` and `I:` only.
- `I:\torrentfiles` returned `True`.
- qBittorrent was not running when checked after recovery: `Exited (0)`, `OOMKilled=false`.
- qBittorrent image and active hardened config at recovery:
  - `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`;
  - memory cap `4 GiB`;
  - CPU quota `2.0`;
  - `pids_limit: 256`;
  - `nofile` soft `2048`, hard `4096`;
  - JSON-file log rotation;
  - stop timeout `120` seconds;
  - published peer port TCP `6881` only;
  - UDP peer port not published through Docker.
- qBittorrent log around the pre-crash recreate confirmed:
  - DHT support `OFF`;
  - Local Peer Discovery support `OFF`;
  - PeX support `OFF`;
  - qBittorrent restored its torrent session at `2026-05-29 5:31:18 PM`;
  - there was no clean qBittorrent shutdown before Windows recorded the unexpected shutdown at `5:43:35 PM`.
- Thermal monitor note: no direct sensor rows cover the `5:31 PM` to `5:43 PM` hardened qBittorrent crash window. The prior logger stopped writing around `4:49 PM`, and the next logger started after recovery around `10:19 PM`.
- Interpretation: the Docker hardening settings did not solve the root issue. The conservative qBittorrent profile survived about one hour before recreate, then the machine crashed about twelve minutes after qBittorrent was recreated and restarted with Docker hardening active.
- Current strongest read: qBittorrent restart/session restore plus live peer networking can still trigger the same low-level platform failure even with libtorrent v1, DHT/PeX/LSD disabled, Docker memory/CPU/PID/file limits, and UDP not published through Docker.
- This shifts suspicion further away from qBittorrent configuration alone and toward Docker Desktop/WSL networking, the Intel I226-V driver/offload/interrupt path, or motherboard/CPU/firmware sensitivity under qBittorrent traffic.
- Keep qBittorrent stopped. Do not add Sonarr/Arr, TV drives, or relaxed torrent settings until the next isolation target is chosen.
- Next recommended isolation target: remove the onboard Intel I226-V path from the test, preferably with a USB Ethernet adapter or a Wi-Fi-only test, then run the same conservative qBittorrent profile. If that is not possible, the next software-only option is disabling Intel NIC offloads/selective suspend/interrupt moderation before another qBittorrent run.

## 2026-05-29 qBittorrent Hardening Reverted To Prior Conservative Profile

- User correctly pointed out that the prior conservative profile was safer than the later hardened-container recreate: it had survived about one hour, while the container-hardening recreate crashed about twelve minutes after restart.
- Reverted only the extra Docker hardening layer from `docker-compose.media.yml`:
  - removed `cpus: "2.0"`;
  - removed `pids_limit: 256`;
  - removed `ulimits.nofile`;
  - removed JSON-file logging rotation override;
  - removed `stop_grace_period: 2m`.
- Kept the prior conservative qBittorrent profile:
  - image remains `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`;
  - peer UDP publish remains commented out;
  - `mem_limit: 4g` remains;
  - qBittorrent app settings remain DHT/PeX/LSD off, TCP protocol, low connection/active limits.
- qBittorrent remained stopped during this revert; it was not recreated or started.
- Compose rendering was validated after the revert.
- Current interpretation: do not treat the extra Docker hardening as beneficial. It is now considered a failed branch and should stay removed unless a later test specifically calls for one setting at a time.

## 2026-05-29 qBittorrent Reverted Conservative Restart

- User asked Codex to start qBittorrent after reverting the extra Docker hardening layer.
- Start log: `docs/crash_logs/qbit-conservative-test/qbit-reverted-conservative-start-20260529-223440.log`.
- qBittorrent start command issued at `2026-05-29 10:34:40 PM`.
- Docker recreated qBittorrent because the compose definition changed back from the hardened variant to the prior conservative profile.
- Live qBittorrent container after start:
  - image `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`;
  - memory cap `4 GiB`;
  - no CPU quota;
  - no PID cap;
  - no `nofile` cap;
  - published ports remain TCP `8080` and TCP `6881` only;
  - UDP peer port remains unpublished through Docker.
- qBittorrent app log confirmed DHT `OFF`, Local Peer Discovery `OFF`, and PeX `OFF`.
- `/downloads` inside qBittorrent mapped correctly to `I:\`, about `19T` total, `15T` available.
- One-minute check: qBittorrent was up, Sonarr stopped, memory about `548 MiB / 4 GiB`, no new crash/storage/WHEA records found in the checked System log window.
- Five-minute check: qBittorrent was up, Sonarr stopped, memory about `547 MiB / 4 GiB`, `/downloads` still mapped to `I:\`, and no new crash/storage/WHEA records found.
- Continue observing this reverted conservative profile before changing another variable.

## 2026-05-30 qBittorrent Reverted Conservative Overnight Crash

- User reported there was another overnight crash.
- Bundle: `docs/crash_logs/20260530-075935-qbit-reverted-conservative-overnight-crash/`.
- qBittorrent had been started in the reverted conservative profile at `2026-05-29 10:34:40 PM`.
- Five-minute check at `2026-05-29 10:40:48 PM` had passed.
- Windows recorded the previous shutdown at `2026-05-30 12:40:08 AM` as unexpected.
- Windows booted after recovery at `2026-05-30 7:59:35 AM`.
- Post-recovery System log again showed `Kernel-Power 41` and `WHEA-Logger` Event 1.
- Latest WHEA payload was again 3552 bytes and decoded to a CPER record with three Firmware Error Record Reference sections.
- Reliability Monitor showed the same EventLog `6008` unexpected-shutdown record. It also recorded a successful Microsoft Defender security intelligence update at `2026-05-30 12:22:33 AM`, but there is no evidence that update explains the hard reset.
- No minidump or `C:\Windows\MEMORY.DMP` was found.
- No checked `disk`, `storahci`, or `NTFS` warning was found in the filtered crash/recovery window.
- Post-recovery visible fixed volumes were still `C:` and `I:` only.
- `I:\torrentfiles` returned `True`.
- qBittorrent was not running when checked after recovery: `Exited (137)`, `OOMKilled=false`.
- qBittorrent had auto-started briefly after reboot at about `2026-05-30 8:00:27 AM` and exited by `8:00:43 AM`.
- qBittorrent profile at time of test:
  - image `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1`;
  - `mem_limit: 4g`;
  - no extra CPU/PID/ulimit/logging hardening;
  - peer UDP publish disabled in Docker;
  - DHT off;
  - PeX off;
  - Local Peer Discovery off;
  - low connection and active torrent limits.
- Thermal monitor note: no direct sensor rows cover the overnight crash window. The previous logger stopped writing around `2026-05-29 10:20 PM`, and the next logger started after recovery around `2026-05-30 8:00 AM`.
- Interpretation: the reverted conservative profile is not safe either, but it delayed the crash substantially compared with the earlier immediate networked runs and the hardened recreate branch. qBittorrent live networking remains the reliable trigger family.
- Current strongest read: this is beyond qBittorrent application tuning. The next meaningful split is whether the same conservative qBittorrent workload crashes when the onboard Intel I226-V path is removed from the equation, or when Docker/WSL is removed by testing native Windows qBittorrent.
- Keep qBittorrent stopped. Do not start Sonarr/Arr or reconnect additional variables until the next isolation test is chosen.

## 2026-05-30 Native Windows qBittorrent Staging

- User approved preparing native Windows qBittorrent to remove Docker Desktop and WSL2 from the qBittorrent crash path.
- Docker qBittorrent was left stopped and its Docker restart policy was changed to `no`.
- Official qBittorrent Windows installer downloaded:
  - file: `C:\plex-server\tools\downloads\qbittorrent_5.2.1_x64_setup.exe`;
  - version: `5.2.1`;
  - SHA256: `02A177C43C08DF4DB30A8F1C2E3D71D51590403EB6BA8B8B2B7D9CF00E68E18C`.
- Native qBittorrent installed at `C:\Program Files\qBittorrent\qbittorrent.exe`.
- Conservative native qBittorrent config is now tracked in the repo at `config/qbittorrent/native-conservative/qBittorrent.ini`.
- The tracked config intentionally omits `WebUI\Password_PBKDF2`; local runtime application preserves the existing password hash outside git.
- Apply script added: `tools/apply-native-qbit-conservative-config.ps1`.
- Runtime native qBittorrent config path: `%APPDATA%\qBittorrent\qBittorrent.ini`.
- Native qBittorrent runtime config applied with:
  - save path `I:\torrentfiles`;
  - incomplete path `I:\torrentfiles\incomplete`;
  - DHT off;
  - PeX off;
  - Local Peer Discovery off;
  - TCP protocol;
  - global connections `50`;
  - per-torrent connections `10`;
  - active downloads/uploads `1`;
  - active torrents `2`;
  - WebUI enabled on port `8080`.
- Native qBittorrent was started for readiness validation.
- Validation:
  - native process running from `C:\Program Files\qBittorrent\qbittorrent.exe`;
  - WebUI returned HTTP `200` at `http://127.0.0.1:8080`;
  - native log confirmed qBittorrent `5.2.1`, DHT `OFF`, Local Peer Discovery `OFF`, and PeX `OFF`;
  - `I:\torrentfiles` and `I:\torrentfiles\incomplete` both exist.
- Next stress-test step: before starting Sonarr, update Sonarr's qBittorrent download client to use native qBittorrent at `host.docker.internal:8080` and add remote path mapping from `I:\torrentfiles` to `/downloads`.

## 2026-05-30 Native qBittorrent Controlled Download Smoke Test

- User approved a native qBittorrent download verification test before reconnecting more TV/Sonarr variables.
- Test used a small public/legal torrent and saved it to `I:\torrentfiles\native-test`.
- Native qBittorrent accepted the torrent through the Web API, downloaded about `123 MiB`, completed successfully, and wrote the payload under `I:\torrentfiles`.
- During the checked test window, Windows System log showed no new `WHEA-Logger`, `Kernel-Power`, disk, storage-controller, NIC, or TCP/IP errors.
- The test torrent was removed from qBittorrent with downloaded files deleted. The temporary `I:\torrentfiles\native-test` folder was removed afterward.
- qBittorrent remained running empty after the test.
- Interpretation: native Windows qBittorrent can perform a real download to `I:` with the conservative settings and without an immediate crash in this short smoke test. This is not equivalent to the prior long Docker qBittorrent soak failures; it mainly verifies native client install, WebUI/API, network reachability, and the `I:` write path.
- Next meaningful split remains a longer native qBittorrent soak or reconnecting TV/Sonarr variables with Sonarr pointed at native qBittorrent via `host.docker.internal:8080`.

## 2026-05-30 Native qBittorrent Repeat Download Left In Place

- User requested rerunning the native qBittorrent download test and leaving the torrent in place.
- Pre-check:
  - `I:\torrentfiles` existed;
  - `I:\torrentfiles\incomplete` existed;
  - native qBittorrent was already running;
  - qBittorrent's torrent list was empty;
  - no relevant recent System errors were found before start.
- Test used the same small public/legal torrent and saved it to `I:\torrentfiles\native-test`.
- Native qBittorrent accepted the torrent through the Web API, downloaded about `123 MiB`, completed successfully, and left the torrent in qBittorrent.
- Post-test qBittorrent state:
  - torrent name `Sintel`;
  - state `stalledUP`;
  - progress `100%`;
  - remaining `0 MiB`;
  - save path `I:\torrentfiles\native-test`;
  - connection count `10`.
- During the checked test window, Windows System log showed no new `WHEA-Logger`, `Kernel-Power`, disk, storage-controller, NIC, or TCP/IP errors.
- Interpretation: this repeats the native qBittorrent functional pass and now leaves a completed public torrent in place for continued native-client observation. It still remains a short test, not an overnight soak.

## 2026-05-30 TV Drives Reconnected With Native qBittorrent And Docker Sonarr

- User powered down, reconnected the TV drives, and requested starting native qBittorrent plus Docker Sonarr while removing qBittorrent from the Docker path.
- Windows fixed-volume check after reconnect:
  - `C:` OS SSD present;
  - `H:` volume `TV 2`, about `18.19 TiB`;
  - `I:` volume `Torrent`, about `18.19 TiB`;
  - `J:` volume `TV 1`, about `14.55 TiB`.
- `docker-compose.media.yml` no longer declares a `qbittorrent` service, so normal compose starts cannot launch qBittorrent in Docker.
- Docker compose rendering now lists Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, and Unpackerr, but not qBittorrent.
- Any old Docker `qbittorrent` container is historical only and is not part of the current deployment.
- Native qBittorrent was started from `C:\Program Files\qBittorrent\qbittorrent.exe` and returned HTTP `200` on `127.0.0.1:8080`.
- Sonarr was started with `docker compose -f C:\plex-server\docker-compose.media.yml up -d sonarr`.
- Sonarr returned HTTP `200` on `127.0.0.1:8989`.
- Sonarr container mount check:
  - `/downloads` maps to `I:\`;
  - `/tv/tv1` maps to `J:\`;
  - `/tv/tv2` maps to `H:\`.
- Sonarr download client was updated from old Docker hostname `qbittorrent:8080` to native qBittorrent at `host.docker.internal:8080`.
- Sonarr remote path mapping was added for host `host.docker.internal`: remote `I:\torrentfiles\` to local `/downloads/`.
- Sonarr's download-client test passed against native qBittorrent.
- Post-start qBittorrent state still showed the completed public test torrent left in place under `I:\torrentfiles\native-test`.
- During the checked post-start window, there were no new `WHEA-Logger`, crash, disk, storage-controller, NIC error, or TCP/IP error records. There were pre-existing/recent non-fatal entries for TPM Secure Boot CA/keys, Intel Platform License Manager service timeout, and an Intel I226-V link reconnect around boot/network recovery.
- Interpretation: the requested TV-drive plus Docker Sonarr test posture is now active with qBittorrent native on Windows and absent from compose. This isolates Sonarr's Docker workload and TV-drive scanning from qBittorrent itself.

## 2026-05-30 Full Ecosystem Start With Native qBittorrent

- User reconnected every drive and requested starting the whole media ecosystem with native qBittorrent outside Docker.
- Windows fixed-volume check showed all configured roots present:
  - `D:` Movies 1;
  - `E:` Movies 3;
  - `F:` Movies 2;
  - `G:` Spare media root, volume label `Broken Power Pin`;
  - `H:` TV 2;
  - `I:` Torrent;
  - `J:` TV 1.
- `G:` being present with the `Broken Power Pin` label is a red-risk variable for stability interpretation because that drive/cabling was an earlier suspect. Keep it explicitly noted if the machine crashes during this full-drive test.
- Native qBittorrent was started and returned HTTP `200` on `127.0.0.1:8080`.
- Docker compose was started without a qBittorrent service. Running stack: Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, and Unpackerr.
- Container mount checks:
  - Sonarr `/downloads` to `I:\`, `/tv/tv1` to `J:\`, `/tv/tv2` to `H:\`;
  - Radarr `/downloads` to `I:\`, `/movies/movies1` to `D:\`, `/movies/movies2` to `F:\`, `/movies/movies3` to `E:\`;
  - Unpackerr `/downloads` to `I:\`.
- Sonarr and Radarr are both configured to use native qBittorrent at `host.docker.internal:8080` with remote path mapping `I:\torrentfiles\` to `/downloads/`.
- Sonarr and Radarr download-client tests both passed against native qBittorrent.
- API health checks reported zero issues for Sonarr, Radarr, and Prowlarr.
- Prowlarr had two configured indexers, both enabled.
- Sonarr and Radarr queues both reported zero items.
- Native qBittorrent had 14 completed torrents loaded under the conservative settings: DHT off, PeX off, LSD off, max global connections `50`, max per-torrent connections `10`.
- Full stack health report saved at `docs/health_reports/20260530-full-ecosystem-native-qbit.md`.

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

## 2026-05-27 Docker Web UI Bind Hardening

- After another machine restart, Docker containers were up and `I:\torrentfiles` was present.
- qBittorrent `/downloads` correctly mapped to `I:\` with about `19T` total and `16T` free, so this was not the tiny/full stale mount failure.
- Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Tautulli, and Uptime Kuma again returned empty replies through Windows `127.0.0.1` published ports until the stack was restarted.
- Changed `C:\plex-server\.env` from `WEBUI_HOST_IP=127.0.0.1` to `WEBUI_HOST_IP=0.0.0.0`, then recreated the compose stack so Docker would rebuild the port bindings.
- qBittorrent also required its internal WebUI bind in `C:\media-stack\config\qbittorrent\qBittorrent\qBittorrent.conf` to remain `WebUI\Address=0.0.0.0`; setting it to `127.0.0.1`, blank, or `*` either prevented Docker host forwarding or caused qBittorrent startup churn.
- Cleared stale qBittorrent `lockfile` and `ipc-socket` while the qBittorrent container was stopped. After that, qBittorrent stayed up and WebUI returned HTTP 200.
- Final validation: localhost web checks returned Sonarr `302`, Radarr `302`, Prowlarr `302`, Bazarr `200`, qBittorrent `200`, Tautulli `303`, and Uptime Kuma `302`. Sonarr, Radarr, and Prowlarr API health checks returned zero issues after qBittorrent stabilized.
- Security note: binding the web UIs to `0.0.0.0` may expose them beyond localhost depending on Windows Firewall and Docker Desktop behavior. A firewall block for the web UI ports was attempted but could not be applied from the non-elevated session. Do not expose these ports intentionally without explicit review.

## 2026-05-28 Post-Restart Arr Recovery And Startup Helper

- After another computer restart, Plex was running natively on Windows but the Docker Arr ecosystem was not healthy.
- Docker showed the containers running, and storage was healthy: `I:\torrentfiles` existed and qBittorrent `/downloads` mapped to `I:\` with about `19T` total and `15T` free.
- Sonarr, Radarr, and Prowlarr returned empty HTTP replies because their `config.xml` files were filled with NUL bytes again.
- Moved the corrupt Sonarr, Radarr, and Prowlarr configs aside with timestamped `.corrupt-*` names and let the apps regenerate clean configs.
- Regenerated API keys required repairing dependent integrations:
  - Prowlarr Sonarr/Radarr application links.
  - Sonarr/Radarr Prowlarr-backed Torznab indexer API keys.
  - Bazarr Sonarr/Radarr API keys.
  - Unpackerr Sonarr/Radarr API keys.
- Updated `C:\plex-server\tools\restart-media-stack-after-login.ps1` so the scheduled post-login helper now:
  - waits for Docker after login,
  - checks `I:\torrentfiles`,
  - detects invalid or NUL-filled Sonarr/Radarr/Prowlarr configs,
  - moves corrupt configs aside,
  - restarts the compose stack with timeouts,
  - repairs regenerated local API keys across Prowlarr, Sonarr/Radarr indexers, Bazarr, and Unpackerr,
  - logs final service and qBittorrent mount checks.
- Verified the scheduled task `Plex Media Stack delayed restart after login` by running it through Task Scheduler. It completed with `LastTaskResult=0`.
- Final validation after the scheduled task run: Sonarr `200`, Radarr `200`, Prowlarr `200`, Bazarr `200`, qBittorrent `200`, Tautulli `303`, Uptime Kuma `302`; Sonarr/Radarr/Prowlarr API health returned zero issues; qBittorrent `/downloads` remained mounted from `I:\`.

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

## 2026-05-28 Windows Declutter And Power Hardening

- User asked to implement a Windows 10 media-server declutter and efficiency pass.
- Session was not elevated, so changes were limited to current-user app removals, current-user startup/noise settings, and power-plan settings available without admin rights.
- Removed current-user consumer AppX packages including Weather, Copilot, Get Help, Tips/Get Started, 3D Viewer, Office Hub, Solitaire, Mixed Reality Portal, OneNote, Outlook for Windows, People, Skype, Wallet, Alarms, Camera, Mail/Calendar, Feedback Hub, Maps, Sound Recorder, Phone Link, Groove/Music, Movies & TV, Dev Home, and removable Xbox packages.
- `Microsoft.XboxGameCallableUI` and `Microsoft.Windows.PeopleExperienceHost` remain because they are protected Windows system components.
- Disabled current-user OneDrive and Edge autostart entries. Remaining startup entries are Docker Desktop, Plex Media Server, and Windows Security notification icon.
- Set the active Balanced power plan for always-on server use: sleep disabled, hibernate timeout disabled, hard-disk timeout disabled, display timeout set to 15 minutes, hybrid sleep disabled, AC wake timers set to important-only, PCIe Link State Power Management disabled, and USB selective suspend disabled.
- `powercfg /a` confirmed hibernation and Fast Startup are unavailable after the pass.
- Marked currently present media/download roots as not content-indexed: `H:\TV Shows`, `I:\torrentfiles`, and `J:\TV Shows`. `D:\Movies`, `E:\Movies`, and `F:\Movies` were not visible at the time of this pass, so they were not changed.
- Set current-user background app suppression and Delivery Optimization download mode preference where writable without elevation.
- Verified Plex Web returned HTTP 200 at `http://localhost:32400/web`.
- Docker media compose stack was not running at verification time; it was not started during this cleanup to avoid implicitly resuming qBittorrent/torrent activity. `I:\torrentfiles` existed, but qBittorrent `/downloads` was not checked because the qBittorrent container was stopped.

---

# Non-Destructive Diagnostic Checklist

- [x] Record several crash times with local time.
- [x] Check Event Viewer System log around captured timestamps.
- [ ] Check Reliability Monitor for matching critical events.
- [x] Check for `C:\Windows\Minidump` files if a BSOD or bugcheck is suspected.
- [x] Record BIOS version.
- [x] Record memory profile/XMP state.
- [ ] Confirm CPU and GPU temperatures at idle and during a controlled Plex playback/transcode.
- [x] Install LibreHardwareMonitor thermal logger and reserve `C:\plex-server\docs\crash_logs\thermal` as the project sensor-log root for crash diagnosis.
- [x] Add Core Temp CPU-temperature capture and AIDA64 export parser to the project thermal logger.
- [x] Confirm AIDA64 exports motherboard/MOS/PCH temperatures, CPU fan RPM, chassis fan RPMs, and major voltage rails into the project thermal logs.
- [x] Add smartctl drive-temperature capture so duplicate-model HDDs are logged by serial number.
- [x] Capture Windows physical-disk health status for `C:` and all fixed media/data drives.
- [x] Confirm qBittorrent `/downloads` mount after at least one crash before resuming torrents.
- [x] Complete first overnight soak after removing the broken-pin HDD.
- [x] Record recurrence after the first overnight soak.
- [x] Persist 2026-05-28 crash logs and WHEA CPER bundle.
- [x] Persist 2026-05-28 11:33 post-crash logs and record missing `I:` / Torrent drive state.
- [x] Persist 2026-05-28 12:31 post-crash logs and record reduced-drive, direct-motherboard-SATA isolation state.
- [x] Persist 2026-05-28 12:53 post-crash logs and record the start of OS-only SATA storage isolation.
- [x] Record 8.5-hour OS-only soak checkpoint with no new crash.
- [x] Begin reassembly Step 1 with `I:` / Torrent drive on dedicated data and power cables.
- [x] Begin reassembly Step 2 with TV drive attempt; `H:` present, `J:` absent in first check.
- [x] Record overnight checkpoint for `C:` + `H:` + `I:` + `J:` state, about 8.6 hours uptime, no new crash records.
- [x] Start controlled software test with qBittorrent and Sonarr only; mounts verified healthy.
- [x] Run stable-state diagnostic sweep with qBittorrent and Sonarr running; no new crash records, mounts healthy.
- [x] Persist 2026-05-29 qBittorrent/Sonarr recurrence bundle.
- [x] Persist 2026-05-29 qBittorrent-only recurrence bundle, including hardware-monitor summary.
- [ ] Watch `J:` / TV 1 for repeated disk Event 153 retries.
- [x] qBittorrent/Sonarr soak failed with a hard reset; do not start additional media containers yet.
- [x] Confirm Sonarr is not required for the latest reproduction; qBittorrent alone triggered the crash.
- [ ] Verify the shared SATA power branch currently feeding Torrent/TV drives before repeating the qBittorrent/Sonarr test.
- [x] Isolate `I:` / Torrent onto its own dedicated SATA power cable and dedicated SATA data cable before another qBittorrent load test.
- [x] Reduce storage to clean `C:` + `I:` only state for next qBittorrent-only isolation test.
- [x] Run qBittorrent-only offline start test in clean `C:` + `I:` state, with Sonarr and other Arr containers stopped.
- [x] Restart qBittorrent with network available in clean `C:` + `I:` state; no immediate crash in first five minutes.
- [x] Continue qBittorrent-only networked soak in clean `C:` + `I:` state; failed with unexpected shutdown at `2026-05-29 3:28:50 PM`.
- [ ] Isolate qBittorrent peer/network path before reconnecting TV drives or starting Sonarr/Arr.
- [x] Apply conservative qBittorrent profile: libtorrent v1 image, TCP-only first pass, DHT/PeX/LSD disabled, low connection/active limits, Docker memory cap.
- [x] Start qBittorrent-only soak using the conservative profile, with Sonarr and Arr stopped; passed first seven minutes.
- [x] Stage qBittorrent Docker hardening settings in compose without restarting the running soak.
- [x] Continue conservative qBittorrent-only soak for at least one hour before changing another variable.
- [x] Recreate qBittorrent to activate staged Docker hardening after the one-hour conservative soak.
- [x] Continue qBittorrent-only soak with active Docker hardening before adding Sonarr/Arr or relaxing qBittorrent limits; failed with unexpected shutdown at `2026-05-29 5:43:35 PM`.
- [x] Revert extra Docker hardening layer back to the prior one-hour-passing conservative qBittorrent profile without starting qBittorrent.
- [x] Start qBittorrent in the reverted conservative profile and pass first five-minute check.
- [x] Keep qBittorrent on the reverted conservative profile; failed overnight with unexpected shutdown at `2026-05-30 12:40:08 AM`.
- [ ] Keep qBittorrent stopped until the next isolation test.
- [x] Install and configure native Windows qBittorrent with tracked conservative config to remove Docker/WSL from the qBittorrent path.
- [x] Configure Sonarr and Radarr to use native qBittorrent via `host.docker.internal:8080` with remote path mappings before the full ecosystem stress test.
- [ ] Test conservative qBittorrent profile through a non-Intel-I226-V network path, preferably USB Ethernet or Wi-Fi-only.
- [x] Recheck `H:` / TV 2 after recurrence; present and mapped correctly on 2026-05-27.
- [x] Review Docker Desktop/WSL logs only after Windows crash evidence is collected.
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
| Platform firmware / motherboard / CPU complex | Repeated fatal WHEA CPER firmware error record references, type 2 SOC firmware record, after hard resets |
| Power delivery / PSU cabling | Hard resets with no bugcheck or dump can occur when power delivery drops or protection trips; PSU is reused |
| Torrent drive power/data path under qBittorrent load | qBittorrent alone now reproduces the hard reset while mounted to `I:\torrentfiles`; no normal application crash or Windows storage warning was captured |
| Docker/WSL network-forwarding path under qBittorrent peer load | qBittorrent offline/startup passed in the clean `C:` + `I:` state, but networked qBittorrent soak crashed in under ten minutes, making this a current leading path |
| Memory stability | DDR5 is at safe 4800, but RAM/IMC faults can still surface as WHEA/platform resets |
| Removed broken-pin HDD or its cabling | Stability improved initially after the damaged drive was removed, but crashes recurred, so it was not the complete root cause |
| Storage or Docker/WSL timing | qBittorrent had a stale mount incident, but latest storage mounts were healthy after reboot; less likely as primary cause of hard resets |
| Sleep/power states | Random timing may correlate with idle/sleep/wake if enabled |

---

# Current Rule

The crash pattern recurred after the broken-pin HDD was removed. Preserve data first, keep the broken-pin drive out of service, verify drive mounts after every crash, and treat the current leading problem as platform-level hardware/firmware/power instability triggered most reliably by qBittorrent live peer/network activity until isolation testing proves otherwise.
