# Current Stability And Crash Tracker

## Purpose

Track the unresolved randomly timed crashing on the rebuilt Plex server.

This file is for evidence and non-destructive diagnostics only. Do not claim a root cause until the pattern is supported by logs, observations, or repeatable tests.

---

# Current Problem Statement

| Item | Current state |
|---|---|
| Issue | Randomly timed crashing |
| Status | Unresolved |
| Affected system | Rebuilt MSI PRO Z790-A WiFi II / Intel Core i5-14500 Windows 10 Plex server |
| Known service state | Plex and Docker media stack can run |
| Current evidence level | Multiple crash timestamps captured; Kernel-Power hard resets; post-BIOS WHEA/IOMMU clue seen before Wi-Fi BIOS disable |

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

## 2026-05-25 WHEA / IOMMU Finding

- After BIOS update to `M.A0`, Windows logged `WHEA-Logger` Event ID `1`: `A fatal hardware error has occurred`.
- Matching `Microsoft-Windows-HAL` Event ID `15` said: `The iommu has detected an error`.
- HAL data included `SourceId=768`, which is PCI requester ID `0x300`.
- PCI requester `0x300` maps to PCI bus `3`, device `0`, function `0`.
- Windows mapped PCI bus `3`, device `0`, function `0` to `Realtek 8852CE WiFi 6E PCI-E NIC #2`.
- User disabled the Realtek Wi-Fi device in Device Manager, then later disabled Wi-Fi in BIOS.
- The next captured crash after Windows-level Wi-Fi disable did not log a new WHEA/HAL IOMMU event, but still hard-reset with `BugcheckCode=0`.
- Do not call the Realtek Wi-Fi the confirmed root cause yet; treat it as a strong lead that changed the event signature.

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
| Storage or Docker/WSL timing | qBittorrent already had a stale mount incident after `I:` was unavailable |
| Sleep/power states | Random timing may correlate with idle/sleep/wake if enabled |

---

# Current Rule

Until the crash pattern is understood, treat service changes as secondary. Preserve data first, collect evidence second, and only then change drivers, BIOS settings, hardware configuration, or service behavior.
