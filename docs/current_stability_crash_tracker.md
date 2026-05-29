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
- [ ] Soak current `C:` + `I:` + `H:` state with qBittorrent/Arr off, or remove TV drives if instability returns.
- [x] Recheck `H:` / TV 2 after recurrence; present and mapped correctly on 2026-05-27.
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
| Platform firmware / motherboard / CPU complex | Repeated fatal WHEA CPER firmware error record references, type 2 SOC firmware record, after hard resets |
| Power delivery / PSU cabling | Hard resets with no bugcheck or dump can occur when power delivery drops or protection trips; PSU is reused |
| Memory stability | DDR5 is at safe 4800, but RAM/IMC faults can still surface as WHEA/platform resets |
| Removed broken-pin HDD or its cabling | Stability improved initially after the damaged drive was removed, but crashes recurred, so it was not the complete root cause |
| Storage or Docker/WSL timing | qBittorrent had a stale mount incident, but latest storage mounts were healthy after reboot; less likely as primary cause of hard resets |
| Sleep/power states | Random timing may correlate with idle/sleep/wake if enabled |

---

# Current Rule

The crash pattern recurred after the broken-pin HDD was removed. Preserve data first, keep the broken-pin drive out of service, verify drive mounts after every crash, and treat the current leading problem as platform-level hardware/firmware/power instability until isolation testing proves otherwise.
