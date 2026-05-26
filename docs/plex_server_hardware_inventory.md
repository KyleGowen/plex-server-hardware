# Plex Server Hardware - Component And Storage Inventory

## Purpose

This file documents the current rebuilt hardware platform, storage layout, and historical failure context for the Plex server.

Use this as the stable hardware and drive inventory. Current crash work lives in [current_stability_crash_tracker.md](current_stability_crash_tracker.md). The old ASUS failure history lives in [plex_server_hardware_troubleshooting_history_log.md](plex_server_hardware_troubleshooting_history_log.md).

---

# Current System Overview

| Category | Current Known State |
|---|---|
| Primary role | Plex media server |
| Operating system | Windows 10 Home build 19045 |
| Plex deployment | Native Windows installation |
| Containerization | Docker Desktop media stack |
| Active Docker services | Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, qBittorrent, Unpackerr |
| Optional Docker service | Jackett through the `legacy-jackett` profile |
| Storage architecture | SATA drives with separate Windows drive letters |
| RAID / pooling | None known |
| Remote Plex access | Enabled historically |
| Hardware transcoding | Enabled historically |
| Current unresolved issue | Random timed crashing; still under soak after removing broken-pin HDD |

---

# Current Rebuilt Platform

| Component type | Component / model | Status | Notes |
|---|---|---|---|
| Motherboard | MSI PRO Z790-A WiFi II | Installed | LGA1700, DDR5, ATX, 6 onboard SATA ports |
| CPU | Intel Core i5-14500 SRN3T | Installed | Intel UHD Graphics 770 available |
| RAM | Lexar Thor Z DDR5 32GB Kit, 2x16GB, 6000MHz | Installed | Record current XMP/memory profile in the crash tracker |
| CPU cooler | Noctua NH-U9S chromax.black | Installed | LGA1700-compatible tower cooler |
| Case | SilverStone GD07 | Reused | HTPC/server-style chassis |
| PSU | Corsair RM750e | Reused | Use only RM750e-compatible modular PSU cables |
| GPU | GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD | Reused | Slot-powered; useful for display and NVIDIA transcoding |
| OS storage | Samsung SSD 840 EVO 250GB | Reused | Windows/application SSD on `C:` |
| Media/data storage | 6 fixed SATA HDDs currently visible | Reused | Preserve all drives; do not format or initialize; broken-pin 20 TB drive is on hand but not installed |

---

# Driver Snapshot

Recorded in [driver_install_status_2026-05-22.md](driver_install_status_2026-05-22.md):

| Area | Known installed / detected state |
|---|---|
| Intel chipset INF | MSI package `10.1.20062.8627` installed |
| Ethernet | Intel I226-V up at `1 Gbps` during verification |
| Wi-Fi | Realtek 8852CE recognized |
| Bluetooth | Realtek Bluetooth Adapter recognized |
| Audio | Realtek audio package `6.0.9977.1` installed |
| NVIDIA | RTX 3050 Studio Driver `596.36`; device driver `32.0.15.9636` |
| Intel DSA | Installed; services were running after install |
| Device Manager | No nonzero `ConfigManagerErrorCode` devices in the checked snapshot |

The current crash issue is unresolved. These driver facts are starting context, not proof that drivers are or are not the cause.

---

# Storage Inventory

Captured from read-only Windows disk and volume queries on 2026-05-23 after all then-available media drives were plugged in. A newer post-drive-swap snapshot is recorded below and should be used for current operations.

## Historical Fixed SATA Drives From 2026-05-23

| Windows Disk # | Drive Letter | Volume Label | Model | Serial | Nominal Capacity | Windows Size | Free | Used | Partition Style | Health | Role / Notes |
|---:|---|---|---|---|---:|---:|---:|---:|---|---|---|
| 0 | D: | Movies 1 | ST20000NM000H-3KV103 | ZYD022FT | 20 TB | 18.19 TiB | 18.10 TiB | 0.5% | GPT | Healthy | Media drive |
| 1 | E: | Movies 3 | ST8000DM004-2CX188 | ZCT0QF7Y | 8 TB | 7.28 TiB | 0.09 TiB | 98.7% | GPT | Healthy | Media drive; nearly full |
| 2 | F: | Movies 2 | ST8000DM004-2CX188 | ZCT1AK4D | 8 TB | 7.28 TiB | 2.37 TiB | 67.4% | GPT | Healthy | Media drive |
| 3 | C: | unlabeled | Samsung SSD 840 EVO 250GB | S1DDNWAF903275D | 250 GB | 0.23 TiB | 0.14 TiB | 39.0% | MBR | Healthy | Windows OS/application SSD; also has System Reserved partition |
| 4 | H: | TV 2 | ST20000NM000H-3KV103 | ZYD02EQ2 | 20 TB | 18.19 TiB | 8.24 TiB | 54.7% | GPT | Healthy | Media drive |
| 5 | I: | Torrent | ST20000NM000H-3KV103 | ZYE00444 | 20 TB | 18.19 TiB | 0.69 TiB | 96.2% | GPT | Healthy | Torrent/download drive; nearly full at capture time |
| 6 | G: | Broken Power Pin | ST20000NM000H-3KV103 | ZYD046SE | 20 TB | 18.19 TiB | 18.19 TiB | 0.0% | GPT | Healthy | Media/data drive; label suggests known physical connector issue to inspect |
| 7 | J: | TV 1 | ST16000NE000-3UN101 | ZVTBPM4J | 16 TB | 14.55 TiB | 3.26 TiB | 77.6% | GPT | Healthy | Media drive |

## Current Fixed Volumes After 2026-05-25 Drive Swap

Captured on 2026-05-26 after the broken-power-pin drive was removed and an 8 TB drive was installed.

| Drive Letter | Volume Label | File System | Windows Size | Free | Health / Operational Status | Current role / notes |
|---|---|---|---:|---:|---|---|
| C: | unlabeled | NTFS | 0.23 TiB | 0.15 TiB | Healthy / OK | Windows OS/application SSD |
| D: | Movies 1 | NTFS | 18.19 TiB | 10.69 TiB | Healthy / OK | Movie media drive |
| E: | Movies 3 | NTFS | 7.28 TiB | 7.14 TiB | Healthy / OK | Movie media drive |
| F: | Movies 2 | NTFS | 7.28 TiB | 2.36 TiB | Healthy / OK | Movie media drive |
| G: | Empty | NTFS | 7.28 TiB | 7.19 TiB | Healthy / OK | Replacement 8 TB drive; do not assume disposable despite label |
| I: | Torrent | NTFS | 18.19 TiB | 15.44 TiB | Healthy / OK | Torrent/download drive; `I:\torrentfiles` verified present |
| J: | TV 1 | NTFS | 14.55 TiB | 3.24 TiB | Healthy / OK | TV media drive |

Current physical disks detected on 2026-05-26:

| Model | Serial | Nominal Capacity | Bus | Media Type | Health / Operational Status |
|---|---|---:|---|---|---|
| Samsung SSD 840 EVO 250GB | S1DDNWAF903275D | 250 GB | SATA | SSD | Healthy / OK |
| ST16000NE000-3UN101 | ZVTBPM4J | 16 TB | SATA | HDD | Healthy / OK |
| ST20000NM000H-3KV103 | ZYD022FT | 20 TB | SATA | HDD | Healthy / OK |
| ST20000NM000H-3KV103 | ZYE00444 | 20 TB | SATA | HDD | Healthy / OK |
| ST8000DM004-2CX188 | ZCT0QF7Y | 8 TB | SATA | HDD | Healthy / OK |
| ST8000DM004-2CX188 | ZCT18865 | 8 TB | SATA | HDD | Healthy / OK |
| ST8000DM004-2CX188 | ZCT1AK4D | 8 TB | SATA | HDD | Healthy / OK |

The former `H:` / `TV 2` volume is absent in the 2026-05-26 snapshot. Do not repair paths, start imports, or write to `/tv/tv2` until the missing TV 2 drive and intended replacement plan are confirmed.

## On-Hand / Not Installed Drives

| Prior Drive Letter | Volume Label | Model | Serial | Nominal Capacity | Status | Notes |
|---|---|---|---|---:|---|---|
| G: | Broken Power Pin | ST20000NM000H-3KV103 | ZYD046SE | 20 TB | On hand, not installed | Removed after the 2026-05-25 10:38 PM crash and replaced by the older 8 TB `G:` drive. Physical power-pin damage; keep as parts/evidence and do not reinstall without a deliberate inspection plan. |

## Removable / Non-Server Storage

| Windows Disk # | Drive Letter | Volume Label | Model | Serial | Nominal Capacity | Windows Size | Health | Notes |
|---:|---|---|---|---|---:|---:|---|---|
| 8 | K: | ESD-USB | SanDisk Cruzer Glide 3.0 USB Device | 4C530001070519122443 | 32 GB | 0.03 TiB | Healthy | Removable USB installer/media; not part of Plex storage |

## Drive Letter Preservation Notes

- Current detected media/data drive letters are `D:`, `E:`, `F:`, `G:`, `I:`, and `J:`. The former `H:` / `TV 2` drive is not currently present.
- `I:` is the torrent/download drive and should contain `I:\torrentfiles`.
- The Docker stack maps `I:\torrentfiles` to `/downloads`.
- Do not trust qBittorrent after boot, crash, drive reconnect, or Docker restart until both Windows and Docker confirm the torrent path.
- The old `G:` volume label was `Broken Power Pin`; that physically damaged drive has been removed from service. Current `G:` is an 8 TB replacement labeled `Empty`.
- Keep the removed broken-pin drive and its associated cabling out of normal service unless there is an explicit recovery plan.
- Do not trust Sonarr/Bazarr `/tv/tv2` paths while `H:` is absent; Docker currently shows that mount as a tiny full placeholder filesystem.
- `E:` and `I:` were nearly full in the 2026-05-23 inventory, but the 2026-05-26 snapshot shows both with much more free space. Recheck live free space before imports, downloads, or library moves.

---

# Physical Mapping Still Needed

| Missing item | Why it matters |
|---|---|
| Physical bay-to-Windows disk mapping | Needed before future SATA recabling or drive replacement |
| SATA port map | Needed for predictable future servicing |
| PSU cable map | Needed to avoid modular cable mistakes |
| Fan header map | Needed for cooling/noise/stability documentation |
| BIOS memory profile state | Needed for random-crash investigation |
| Current SMART snapshot | Needed for storage health baseline |

---

# Historical Old Platform Context

The previous platform was an ASUS Sabertooth Z97 Mark II / Intel Haswell-era DDR3 system. It failed with no POST, no display, no USB keyboard initialization, partial fan activity, and a cold CPU heatsink. Motherboard failure was the strongest historical diagnosis.

Those details are preserved for repair history only. Current operational and crash diagnostics should focus on the rebuilt MSI/i5-14500 platform unless evidence points back to a reused component such as PSU, GPU, storage, cabling, or case cooling.

---

# Final Notes

The current system uses:

- Windows 10.
- Native Plex installation.
- Docker containers for Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, qBittorrent, and Unpackerr.
- Jackett only as an optional legacy profile.
- Independent SATA drives with Windows drive letters.
- No known RAID, ZFS, Unraid, or storage pool.

Keep this file factual. Put crash observations in the crash tracker and per-service operational details in `docs/services/`.
