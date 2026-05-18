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
| GPU | Gigabyte GeForce RTX | Likely functional | Appears slot-powered; no external PCIe power connector observed |
| CPU | Intel Haswell-era CPU | Unknown / possibly functional | Exact CPU model not yet identified |
| CPU Cooler | Intel stock cooler | Functional mechanically | CPU fan spins continuously |
| RAM | DDR3 DIMMs | Likely functional | Two sticks tested individually |
| Case | SilverStone GD07 | Reusable | Home theater / server-style chassis |
| Case Fans | Multiple chassis fans | Mixed behavior | Some spin; lower chassis fans do not spin despite being plugged into motherboard |
| OS Storage | 2.5-inch SATA SSD | Important / preserve | Windows 10 and application drive |
| Media Storage | Multiple 3.5-inch SATA HDDs | Preserve | Used for Plex media storage |
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

## Gigabyte GeForce RTX

| Attribute | Value |
|---|---|
| Manufacturer | Gigabyte |
| Family | NVIDIA GeForce RTX |
| External PCIe Power | None observed |
| Estimated Status | Likely functional |
| Plex Role | Hardware transcoding / NVIDIA encoder path |

## GPU Notes

- GPU was tested removed.
- GPU was reinstalled and reseated.
- No behavior change in either state.
- The card appears to be slot-powered only.
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
- Some fans spin when powered.
- Lower chassis fans do not spin despite being connected to the motherboard.
- This may indicate motherboard fan-control or Super I/O failure rather than fan failure.

---

# Storage Inventory

## High-Level Storage Architecture

| Area | Current State |
|---|---|
| OS Drive | Dedicated 2.5-inch SATA SSD |
| Media Drives | Multiple 3.5-inch SATA HDDs |
| Drive Organization | Independent Windows drive letters |
| RAID | None known |
| Pooling | None known |
| Filesystem Strategy | Standard Windows-mounted drives |
| Storage Interface | SATA |

## Physical Drive Rack Summary

The storage rack appears to contain:

- 6 total installed drives.
- 5x 3.5-inch SATA HDDs.
- 1x 2.5-inch SATA SSD used as the Windows OS/application drive.
- Mixed drive models and generations.
- One visible empty bay in the center section.

## Physical Drive Layout — Front View

### Left Section

| Position | Drive Type | Notes |
|---|---|---|
| Upper Left / Dangling Mounted Drive | 2.5-inch SATA SSD | Windows 10 OS and application drive; mounted above lower HDD stack |
| Lower Left Stack | 3.5-inch HDD | Older HDD; likely legacy archive/media drive |

### Center Section

| Position | Drive Type | Notes |
|---|---|---|
| Center Left Bay | Empty | Available expansion slot |
| Center Right Bay | 3.5-inch HDD | Drive with visible green PCB edge |

### Right Section

| Position | Drive Type | Notes |
|---|---|---|
| Right Bay 1 | 3.5-inch HDD | Silver enclosure |
| Right Bay 2 | 3.5-inch HDD | Visible green PCB edge |
| Right Bay 3 | 3.5-inch HDD | Silver enclosure |
| Right Bay 4 | 3.5-inch HDD | Silver enclosure |

---

# Confirmed / Partially Identified Drives

| Drive | Model | Capacity | Role | Notes |
|---|---|---:|---|---|
| Seagate Exos X24 | ST20000NM000H | 20TB | Media/archive storage | Enterprise recertified drive |
| OS SSD | Unknown | Unknown | Windows 10 boot/app drive | Dedicated 2.5-inch SATA SSD mounted at top-left of rack |
| Additional HDDs | Unknown | Unknown | Media storage | Need label/model capture before disassembly |

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
| Gigabyte RTX GPU | High | Tested in/out with no behavior change |
| SATA OS SSD | Unknown but important | Preserve and test first in rebuild |
| SATA HDD media drives | High | No evidence of storage-related failure |
| SilverStone GD07 case | High | Reusable chassis |
| DDR3 RAM | Moderate to high | Tested individually; likely okay |
| Intel CPU | Moderate | Less likely than motherboard, but exact status unconfirmed |

---

# Drive Labels

| Label | Meaning |
|---|---|
| OS-SSD | Windows 10 boot/application SSD |
| HDD-L1 | Lower-left HDD |
| HDD-C1 | Center-right HDD |
| HDD-R1 | Right bay 1 |
| HDD-R2 | Right bay 2 |
| HDD-R3 | Right bay 3 |
| HDD-R4 | Right bay 4 |

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
| OS SSD brand/model/capacity | Helps assess reliability and replacement need |
| Exact Windows drive letters | Needed to restore Plex and automation paths |
| Full HDD model/capacity list | Needed for future inventory and replacement planning |
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
