# Plex Server Hardware — Component Inventory

## Purpose

This file documents the known hardware inventory, storage layout, operating assumptions, and rebuild-relevant unknowns for the Plex server.

Use this as the main stable-facts reference. Rebuild procedures live in the WIP tracker, and storage/app recovery procedures live in the storage migration guide.

---

# System Overview

| Category | Current Known State |
|---|---|
| Primary Role | Plex media server |
| Operating System | Windows 10 |
| Plex Deployment | Native Windows installation |
| Containerization | None |
| Virtualization | None observed |
| Storage Architecture | SATA drives with separate Windows drive letters |
| RAID / Pooling | None known |
| Remote Plex Access | Enabled |
| Hardware Transcoding | Enabled |
| Typical Concurrent Users | 1–5 |
| Primary Failure State | Powers on partially but does not POST |

---

# Core Hardware Inventory

| Component Type | Component / Model | Status | Notes |
|---|---|---|---|
| Motherboard | ASUS Sabertooth Z97 Mark II | Suspected failed | LGA1150 / Intel Z97 chipset / DDR3 platform |
| Power Supply | Corsair RM750e | Likely functional | ATX modular PSU; standby power present |
| GPU | GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD | Likely functional | Slot-powered per official specs; no external PCIe power connector required |
| CPU | Intel Haswell-era CPU | Unknown / possibly functional | Exact CPU model not yet identified |
| CPU Cooler | Intel stock cooler | Functional mechanically | CPU fan spins continuously |
| RAM | DDR3 DIMMs | Likely functional | Two sticks tested individually |
| Case | SilverStone GD07 | Reusable | Home theater / server-style chassis |
| Case Fans | Multiple chassis fans | Mixed behavior | Some spin; lower chassis fans do not spin despite being plugged into motherboard |
| Extra Case Fan | Thermaltake TT-1225 / A1225L12S | Installed in case | DC brushless 120 mm fan; 12V, 0.30A; label photographed in empty case; source notes in `manuals/case-fan-source-notes.md` |
| Extra Case Fan | SilverStone CC12025L12S | Installed in case | 120 mm case fan; 12V, 0.07A; label photographed in empty case; source notes in `manuals/case-fan-source-notes.md` |
| OS Storage | 2.5-inch SATA SSD | Important / preserve | Windows 10 and application drive |
| Media Storage | 7x SATA HDDs detected in Windows | Preserve | Used for Plex media storage; all currently online/healthy as of 2026-05-23 inventory |
| SATA Cabling | SATA power + data cabling | Partially disconnected during diagnostics | Should be labeled before rebuild |

---

# Motherboard Details

## ASUS Sabertooth Z97 Mark II

| Attribute | Value |
|---|---|
| Socket | LGA1150 |
| Chipset | Intel Z97 |
| Memory Type | DDR3 |
| Product Line | ASUS TUF / Sabertooth |
| Current Assessment | Very likely failed |

## Observed Motherboard Behavior

- Motherboard standby LED illuminates.
- CPU fan spins continuously.
- Some chassis fans spin.
- Lower chassis fans do not spin.
- No display output.
- No USB keyboard initialization.
- No visible POST progress.
- No Q-LED diagnostic activity observed.
- System remains powered indefinitely.
- CPU heatsink area remains cool/cold after powered on.

## Likely Failed Motherboard Subsystems

- CPU VRM / motherboard power delivery.
- BIOS / UEFI subsystem.
- Chipset / PCH initialization.
- Super I/O controller.
- Fan/control circuitry.
- Board-level power regulation.

---

# Power Supply

## Corsair RM750e

| Attribute | Value |
|---|---|
| Model | Corsair RM750e |
| Type | ATX modular PSU |
| Estimated Status | Likely functional |
| Evidence | Standby LED present; fans power; system receives partial power |

## Power-Related Troubleshooting Already Done

- 24-pin ATX motherboard power connector reseated.
- 8-pin CPU EPS power connector reseated.
- System tested after reseating power cables.
- No behavior change after reseating.

---

# GPU

## GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G

| Attribute | Value |
|---|---|
| Manufacturer | GIGABYTE |
| Model | GeForce RTX 3050 WINDFORCE OC 6G |
| Model Number | GV-N3050WF2OC-6GD |
| Manufacturer Product Page | https://www.gigabyte.com/us/Graphics-Card/GV-N3050WF2OC-6GD |
| Local Manual | manuals/gigabyte-geforce-rtx-3050-windforce-oc-6g-gv-n3050wf2oc-6gd-quick-guide.pdf |
| GPU | NVIDIA GeForce RTX 3050 |
| VRAM | 6GB GDDR6 |
| Memory Bus | 96-bit |
| PCIe Interface | PCIe 4.0 |
| Core Clock | 1477 MHz |
| Display Outputs | 2x DisplayPort 1.4a, 2x HDMI 2.1 |
| Maximum Digital Resolution | 7680x4320 |
| Card Size | 191mm x 111mm x 36mm |
| Recommended PSU | 300W |
| External PCIe Power | None required; official spec lists power connectors as N/A |
| Estimated Status | Likely functional |
| Plex Role | Hardware transcoding / NVIDIA encoder path |

## GPU Notes

- Exact GPU model confirmed from purchase screenshot on 2026-05-18.
- GPU was tested removed.
- GPU was reinstalled and reseated.
- No behavior change in either state.
- The card is slot-powered only per official GIGABYTE specifications.
- GPU failure is currently considered unlikely.

---

# CPU / Cooling

| Component | Details |
|---|---|
| CPU Platform | Intel Haswell-era / LGA1150 |
| Exact CPU Model | Unknown |
| Cooler | Intel stock radial cooler |
| Fan Behavior | CPU fan spins continuously |
| Thermal Observation | Heatsink remains cool/cold |

## Interpretation

The cool CPU heatsink during power-on suggests the CPU may not be receiving normal power or the board is failing before meaningful CPU initialization. This supports the motherboard-failure theory more than a storage, GPU, or software failure.

---

# Memory

| Attribute | Value |
|---|---|
| Memory Type | DDR3 |
| Installed DIMMs | 2 sticks observed/tested |
| Exact Capacity | Unknown |
| Exact Model | Unknown |
| Estimated Status | Likely functional |

## RAM Troubleshooting Already Done

- RAM moved to recommended single-stick slot.
- Each stick tested individually.
- DIMMs reseated multiple times.
- No behavior change.

RAM failure is currently considered unlikely.

---

# Case

## SilverStone GD07

| Attribute | Value |
|---|---|
| Case | SilverStone GD07 |
| Manufacturer Page | https://www.silverstonetek.com/en/product/info/computer-chassis/GD07/ |
| Form Factor Style | HTPC / home server chassis |
| Rebuild Status | Reusable |

## Case / Fan Notes

- Multiple chassis fans are present.
- Two extra installed case fans have been identified from photos:
  - Thermaltake TT-1225 / A1225L12S, DC brushless, 12V, 0.30A.
  - SilverStone CC12025L12S, 12V, 0.07A.
- Standalone retail manuals were not found for these fans; source notes and available spec/datasheet links are tracked in `manuals/case-fan-source-notes.md`.
- Some fans spin when powered.
- Lower chassis fans do not spin despite being connected to the motherboard.
- This may indicate motherboard fan-control or Super I/O failure rather than fan failure.

---

# Storage Inventory

## High-Level Storage Architecture

| Area | Current State |
|---|---|
| OS Drive | Dedicated 2.5-inch SATA SSD |
| Media Drives | 7x SATA HDDs detected in Windows |
| Drive Organization | Independent Windows drive letters |
| RAID | None known |
| Pooling | None known |
| Filesystem Strategy | Standard Windows-mounted drives |
| Storage Interface | SATA |

## Verified Physical / Connection Status

The following facts are verified from the current Windows inventory captured on 2026-05-23:

| Item | Verified State |
|---|---|
| Fixed SATA drives detected | 8 total |
| OS/application drive | 1x Samsung SSD 840 EVO 250GB on `C:` |
| Media/data HDDs | 7x SATA HDDs on `D:`, `E:`, `F:`, `G:`, `H:`, `I:`, and `J:` |
| Removable drive present | 1x SanDisk Cruzer Glide 3.0 USB Device on `K:`; not part of Plex storage |
| Physical bay-to-disk mapping | Not yet verified |
| SATA port-to-disk mapping | Not yet verified |
| Physical labels on drives | Not yet verified in this document |

Do not infer physical bay position from Windows disk number. Before future recabling or drive replacement, correlate each physical drive label with its model, serial number, Windows disk number, and drive letter.

---

# Confirmed Drive Inventory

Captured from read-only Windows disk and volume queries on 2026-05-23 after all currently available media drives were plugged in.

## Fixed SATA Drives

| Windows Disk # | Drive Letter | Volume Label | Model | Serial | Nominal Capacity | Windows Size | Free | Used | Partition Style | Health | Role / Notes |
|---:|---|---|---|---|---:|---:|---:|---:|---|---|---|
| 0 | D: | Movies 1 | ST20000NM000H-3KV103 | ZYD022FT | 20 TB | 18.19 TiB | 18.10 TiB | 0.5% | GPT | Healthy | Media drive |
| 1 | E: | Movies 3 | ST8000DM004-2CX188 | ZCT0QF7Y | 8 TB | 7.28 TiB | 0.09 TiB | 98.7% | GPT | Healthy | Media drive; nearly full |
| 2 | F: | Movies 2 | ST8000DM004-2CX188 | ZCT1AK4D | 8 TB | 7.28 TiB | 2.37 TiB | 67.4% | GPT | Healthy | Media drive |
| 3 | C: | unlabeled | Samsung SSD 840 EVO 250GB | S1DDNWAF903275D | 250 GB | 0.23 TiB | 0.14 TiB | 39.0% | MBR | Healthy | Windows OS/application SSD; also has System Reserved partition |
| 4 | H: | TV 2 | ST20000NM000H-3KV103 | ZYD02EQ2 | 20 TB | 18.19 TiB | 8.24 TiB | 54.7% | GPT | Healthy | Media drive |
| 5 | I: | Torrent | ST20000NM000H-3KV103 | ZYE00444 | 20 TB | 18.19 TiB | 0.69 TiB | 96.2% | GPT | Healthy | Torrent/download drive; nearly full |
| 6 | G: | Broken Power Pin | ST20000NM000H-3KV103 | ZYD046SE | 20 TB | 18.19 TiB | 18.19 TiB | 0.0% | GPT | Healthy | Media/data drive; label suggests known physical connector issue to inspect |
| 7 | J: | TV 1 | ST16000NE000-3UN101 | ZVTBPM4J | 16 TB | 14.55 TiB | 3.26 TiB | 77.6% | GPT | Healthy | Media drive |

## Removable / Non-Server Storage

| Windows Disk # | Drive Letter | Volume Label | Model | Serial | Nominal Capacity | Windows Size | Health | Notes |
|---:|---|---|---|---|---:|---:|---|---|
| 8 | K: | ESD-USB | SanDisk Cruzer Glide 3.0 USB Device | 4C530001070519122443 | 32 GB | 0.03 TiB | Healthy | Removable USB installer/media; not part of Plex storage |

## Drive Letter Preservation Notes

- Current media drive letters are `D:`, `E:`, `F:`, `G:`, `H:`, `I:`, and `J:`.
- Do not launch Plex, Sonarr, Radarr, qBittorrent, Jackett, or Unpacker after any future recabling until these drive letters are confirmed.
- The `G:` volume label is `Broken Power Pin`; inspect and document the physical drive/cable before relying on it for writes.
- `E:` and `I:` are nearly full and should be treated carefully during imports, downloads, or library moves.

---

# Software / Service Inventory

## Operating System

| Attribute | Value |
|---|---|
| Operating System | Windows 10 |
| Installation Type | Native install on SATA SSD |
| Boot Device | Dedicated 2.5-inch SATA SSD |
| Containerization | None |
| Virtualization | None observed |

## Plex

| Attribute | Value |
|---|---|
| Plex Installation | Native Windows installation |
| Remote Access | Enabled |
| Local Streaming | Enabled |
| Remote Streaming | Enabled |
| 4K Transcoding | Enabled |
| Hardware Transcoding | Enabled |
| Typical Concurrent Users | 1–5 |
| User Limit | No configured limit |
| Reverse Proxy | None |
| Static IP | None |
| Custom Hostname | None |

## Media Management Stack

| Application | Purpose |
|---|---|
| Plex Media Server | Media streaming and transcoding |
| Sonarr | TV series management |
| Radarr | Movie management |
| qBittorrent | Torrent client |
| Jackett | Indexer aggregation |
| Unpacker | Post-download extraction / processing |

---

# Current Failure Summary

## Symptoms

- System powers on partially.
- Motherboard standby LED is active.
- CPU fan spins.
- Some chassis fans spin.
- No display output.
- No POST.
- USB keyboard does not initialize.
- CPU heatsink remains cold.
- Lower chassis fans do not spin.

## Most Likely Failure

**Motherboard failure on the ASUS Sabertooth Z97 Mark II.**

## Current Confidence Estimate

| Suspected Cause | Confidence |
|---|---|
| Motherboard failure | Very high |
| CPU failure | Low |
| PSU failure | Very low |
| RAM failure | Very low |
| GPU failure | Very low |
| Storage failure causing current no-POST state | Very low |

---

# Components Most Likely Reusable

| Component | Reuse Confidence | Notes |
|---|---|---|
| Corsair RM750e PSU | High | Partial power behavior suggests PSU is likely okay |
| GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G GPU | High | Tested in/out with no behavior change |
| SATA OS SSD | Unknown but important | Preserve and test first in rebuild |
| SATA HDD media drives | High | 7 media/data HDDs detected online and healthy in Windows on 2026-05-23 |
| SilverStone GD07 case | High | Reusable chassis |
| DDR3 RAM | Moderate to high | Tested individually; likely okay |
| Intel CPU | Moderate | Less likely than motherboard, but exact status unconfirmed |

---

# Physical Labeling Status

No verified physical drive labels are recorded in this inventory yet. Use the confirmed drive table above as the current source of truth until each physical bay and SATA cable is matched to a serial number.

---

# Plex Metadata Fact To Verify

The exact previous Plex metadata location is unknown.

Most likely default Windows location:

```text
C:\Users\<WindowsUser>\AppData\Local\Plex Media Server
```

Detailed Plex recovery procedure is maintained in [plex_storage_migration_rebuild_documentation.md](plex_storage_migration_rebuild_documentation.md).

---

# Unknowns To Capture

| Missing Item | Why It Matters |
|---|---|
| Exact CPU model | Needed for specs, performance, reuse planning |
| RAM capacity / model | Needed for inventory and compatibility |
| Physical bay-to-Windows disk mapping | Needed before future SATA recabling or drive replacement |
| SATA port map | Needed to preserve predictable rebuild documentation |
| Plex metadata location | Needed for full Plex restore |
| Windows username used for Plex | Helps locate AppData folder |
| qBittorrent save paths | Needed to prevent broken torrents |
| Sonarr root folders | Needed for TV library repair |
| Radarr root folders | Needed for movie library repair |
| Jackett config location | Needed for indexer recovery |
| Unpacker config paths | Needed for post-download automation |
| SATA expansion card model, if present | Needed for driver/manual lookup |
| BIOS SATA mode | AHCI/RAID mode can affect boot behavior |

---

# Final Notes

The failure pattern is most consistent with motherboard failure rather than PSU, RAM, GPU, storage, or software failure.

The rebuild should be manageable because the system used:

- Windows 10.
- Native Plex installation.
- Independent SATA drives.
- Separate Windows drive letters.
- No Docker.
- No RAID.
- No storage pool.
- No reverse proxy.
- No static IP or custom hostname dependency.

Operational checklists and current next actions are maintained in [plex_server_rebuild_wip_tracker.md](plex_server_rebuild_wip_tracker.md).
