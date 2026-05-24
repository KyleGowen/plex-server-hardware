# Plex Server Hardware — Storage Migration & Rebuild Documentation

## Purpose

This document converts the storage migration notes from the troubleshooting chat into a standalone rebuild file.

Use this during the Plex server rebuild so the OS SSD, media drives, drive-letter mappings, and Plex-related services can be migrated without repeating prior discovery work.

---

# Current Storage Architecture

## High-Level Summary

The existing Plex server used a simple Windows-native storage layout. The rebuild keeps Windows-native storage and Plex, but moves the media automation stack forward under Docker.

| Area | Current State |
|---|---|
| Operating System | Windows 10 |
| OS Drive | Dedicated 2.5-inch SATA SSD |
| Plex Install | Native Windows installation |
| Media Drives | Multiple SATA HDDs |
| Drive Organization | Separate Windows drive letters |
| RAID | None known |
| Drive Pooling | None known |
| Docker | Chosen for Sonarr, Radarr, Bazarr, qBittorrent, Jackett, and Unpackerr going forward |
| Virtualization | Not used |

## Important Rebuild Implication

Because the system uses independent Windows drive letters rather than RAID, ZFS, Unraid, or a storage pool, the rebuild should be simpler than a typical NAS migration.

The goal is to preserve or restore the original Windows drive-letter layout so native Plex and the Docker containers for Sonarr, Radarr, Bazarr, qBittorrent, Jackett, and Unpackerr can be mapped to the correct media and download folders.

---

# Physical Storage Rack Layout

## Rack Overview

Earlier visual inspection of the storage rack appeared to contain:

- 6 total installed drives
- 5x 3.5-inch SATA HDDs
- 1x 2.5-inch SATA SSD used as the Windows OS/application drive
- SATA-only storage architecture
- Mixed drive models and generations
- One visible empty bay in the center section

Current Windows inventory after all currently available media drives were plugged in shows:

- 8 fixed SATA drives total
- 1x Samsung 2.5-inch SATA SSD used as the Windows OS/application drive
- 7x SATA HDD media/data drives
- 1x SanDisk USB removable drive also connected; not part of server storage

The detailed drive table with models, serials, sizes, volume labels, drive letters, and health status is maintained in [plex_server_hardware_inventory.md](plex_server_hardware_inventory.md).

# Confirmed Drive Inventory

As of the 2026-05-23 Windows inventory, the OS drive and all currently connected media drives are identified. Keep the canonical table in [plex_server_hardware_inventory.md](plex_server_hardware_inventory.md) so there is one stable inventory source.

Current fixed SATA storage summary:

| Role | Count | Models / Labels |
|---|---:|---|
| Windows OS/application SSD | 1 | Samsung SSD 840 EVO 250GB, `C:` |
| 20 TB media/data HDDs | 4 | ST20000NM000H-3KV103 on `D:`, `G:`, `H:`, `I:` |
| 16 TB media HDD | 1 | ST16000NE000-3UN101 on `J:` |
| 8 TB media HDDs | 2 | ST8000DM004-2CX188 on `E:`, `F:` |

---

# Pre-Migration Rules

## Do Not Randomly Reorder Drives

The highest-priority rule is:

**Do not randomly reorder SATA drives during migration.**

Even without RAID, Windows drive-letter assignments and application paths may depend on disk identity and prior mounting order. Reordering may not destroy data, but it can cause Plex and related tools to lose track of libraries or download paths.

## Before Removing Drives

Perform the following before disassembly:

1. Photograph the storage rack from multiple angles.
2. Photograph the SATA data cable routing.
3. Photograph the SATA power routing.
4. Label each physical drive.
5. Label each SATA cable if possible.
6. Record which motherboard or expansion-card port each cable connects to.
7. Record visible model numbers and capacities from each drive label.
8. Keep the OS SSD clearly marked and separate from media drives.

## Physical Labeling Status

No verified physical drive labels are recorded in this document yet. Before future recabling or drive replacement, correlate each physical drive label with its model, serial number, Windows disk number, drive letter, and SATA port.

---

# Recommended Migration Sequence

## Phase 1 — Build Minimal Replacement System

Install only:

- Replacement motherboard
- CPU
- RAM
- PSU
- GPU if needed for display
- OS SSD only

Do **not** connect the media HDDs yet.

### Verify

- System powers on
- BIOS/UEFI sees the OS SSD
- Windows Boot Manager appears if present
- Windows 10 starts or attempts startup repair
- Keyboard and display work
- No unexpected boot loops

## Phase 2 — Boot Windows From Existing OS SSD

The preferred first attempt is to boot the existing Windows 10 installation from the original OS SSD.

### Expected Outcomes

Possible results:

| Outcome | Meaning |
|---|---|
| Windows boots normally | Best case. Continue with driver cleanup and storage reintegration. |
| Windows starts repair | Still potentially recoverable. Avoid wiping the drive. |
| Windows fails due to driver/platform change | May need repair install or fresh Windows install. |
| SSD not detected | Check SATA power/data, BIOS mode, port, or SSD health. |

## Phase 3 — Stabilize Windows

Once Windows boots:

1. Install motherboard chipset drivers.
2. Install LAN/network drivers if needed.
3. Install NVIDIA drivers for the GPU.
4. Confirm Windows activation status.
5. Confirm system date/time.
6. Confirm device manager has no major missing devices.
7. Avoid launching Plex until media drive letters are checked.

## Phase 4 — Reconnect Media Drives Incrementally

Reconnect media HDDs one at a time or in the smallest practical groups.

For each drive:

1. Shut down.
2. Connect one media HDD.
3. Boot Windows.
4. Open Disk Management.
5. Confirm the drive appears.
6. Confirm the filesystem is intact.
7. Record the assigned drive letter.
8. Compare with expected Plex/Sonarr/Radarr/qBittorrent paths.
9. Correct the drive letter if needed.
10. Repeat for the next drive.

## Phase 5 — Restore Drive Letters

The previous system used separate Windows drive letters. The most important rebuild task is to restore those same letters.

### Where to Check

Use:

- Windows Disk Management
- File Explorer
- Plex library folder paths
- Docker host volume mappings
- Sonarr container root folders
- Radarr container root folders
- qBittorrent container download paths
- Jackett container configuration paths if applicable
- Unpackerr watched/completed folder paths

### Drive Letter Recovery Strategy

If a media path is broken, do not move files first. Instead:

1. Identify which physical drive contains the expected folders.
2. Change that drive's letter in Disk Management.
3. Update the Docker host volume mapping only if the restored drive letter still does not match the intended path.
4. Reopen the relevant application or container.
5. Confirm the original path resolves again.

---

# Plex Recovery Notes

## Known Prior Plex Configuration

| Setting | Value |
|---|---|
| Plex Deployment | Native Windows installation |
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

## Plex Metadata Location

The exact previous Plex metadata location is unknown.

Most likely default Windows location:

```text
C:\Users\<WindowsUser>\AppData\Local\Plex Media Server
```

Possible service/system locations may vary depending on how Plex was originally installed and run.

## Plex Recovery Priority

Before reinstalling Plex or wiping anything:

1. Check whether the OS SSD is readable.
2. Search the OS SSD for `Plex Media Server`.
3. Preserve the Plex data directory if found.
4. Preserve `Preferences.xml` if found.
5. Preserve library metadata, plug-in support files, and database files.
6. Only reinstall Plex after copying or confirming the existing metadata location.

## Plex Paths To Verify

After reconnecting media drives, verify:

- Movie library paths
- TV library paths
- Any 4K-specific library paths
- Download/import folders
- Transcode temporary directory, if customized
- Hardware transcoding setting
- Remote access setting

---

# Media Management Stack Recovery

The previous stack was Windows-native. The chosen forward plan is native Windows Plex plus Docker containers for the media automation stack.

| Application | Purpose | Migration Concern |
|---|---|---|
| Plex Media Server | Media streaming and transcoding | Library paths and metadata location |
| Docker Desktop / Compose | Container runtime and orchestration | Daemon availability, compose file, `.env`, restart behavior |
| Sonarr container | TV series management | Persistent config volume, root folders, download client paths |
| Radarr container | Movie management | Persistent config volume, root folders, download client paths |
| Bazarr container | Subtitle management | Persistent config volume, Sonarr/Radarr API links, media folder write access, subtitle provider credentials |
| qBittorrent container | Torrent client | Persistent config volume, Web UI credentials, incomplete/completed paths |
| Jackett container | Indexer aggregation | Persistent config volume, API key, indexer settings |
| Unpackerr container | Post-download extraction | Persistent config volume, watched folders, extraction output paths |

## Recovery Order

Recommended application recovery order:

1. Windows boot and driver stability
2. Drive letters
3. Folder visibility
4. Docker Desktop and Compose availability
5. Docker compose file and volume mappings
6. qBittorrent paths
7. Sonarr/Radarr root folders
8. Bazarr ARR links and subtitle provider settings
9. Jackett indexers
10. Unpackerr paths
11. Plex libraries
12. Plex remote access
13. Plex hardware transcoding

## Docker Path Mapping Notes

Before starting the media containers:

- Confirm Windows drive letters `D:` through `J:` are stable.
- Confirm `I:` remains the torrent/download drive before mapping qBittorrent paths.
- Prefer stable, documented container paths such as `/media/movies1`, `/media/tv1`, and `/downloads` instead of changing Windows drive letters or moving files.
- Keep each application's config in a persistent host folder, not only inside an ephemeral container layer.
- Review the compose file before first start so no container writes to the wrong media drive.

---

# qBittorrent Migration Notes

qBittorrent paths may break if drive letters or Docker volume mappings are wrong.

Check:

- Default save path
- Incomplete downloads path
- Completed downloads path
- Watched folders
- Category-specific paths
- Sonarr/Radarr download client integration through the Docker network or published host port

Do not resume all torrents until paths are verified.

---

# Sonarr / Radarr Migration Notes

Sonarr and Radarr are sensitive to path changes. In Docker, both the host drive-letter mapping and the in-container path must be correct.

Check:

- Root folders
- Existing series/movie paths
- Download client settings
- Completed download handling
- Import paths
- Permissions/access to media drives
- Container volume mappings
- Remote path mappings if Sonarr/Radarr and qBittorrent see different paths

If paths are broken, prefer restoring original drive letters rather than mass-editing paths.

## Confirmed Sonarr TV Root Folders

Confirmed in Sonarr on 2026-05-24.

| Host Path | Container Path | Sonarr Status |
|---|---|---|
| `J:\TV Shows` | `/tv/tv1/TV Shows` | Root folder configured and accessible |
| `H:\TV Shows` | `/tv/tv2/TV Shows` | Root folder configured and accessible |

Existing show folders are visible to Sonarr as unmapped folders. Do not bulk-import or mass-edit series paths until download client settings, indexers, and import behavior are reviewed.

## Confirmed Radarr Movie Root Folders

Confirmed in Radarr on 2026-05-24.

| Host Path | Container Path | Radarr Status |
|---|---|---|
| `D:\Movies` | `/movies/movies1/Movies` | Root folder configured and accessible |
| `F:\Movies` | `/movies/movies2/Movies` | Root folder configured and accessible |
| `E:\Movies` | `/movies/movies3/Movies` | Root folder configured and accessible |

Do not bulk-import or mass-edit movie paths until download client settings, indexers, and import behavior are reviewed.

## Confirmed Bazarr Subtitle Configuration

Confirmed in Bazarr on 2026-05-24.

| Item | Value |
|---|---|
| Web UI | `http://localhost:6767` |
| Config path | `C:\media-stack\config\bazarr` |
| Sonarr link | Enabled; Docker-network target `sonarr:8989` |
| Radarr link | Enabled; Docker-network target `radarr:7878` |
| TV media mounts | `/tv/tv1`, `/tv/tv2` |
| Movie media mounts | `/movies/movies1`, `/movies/movies2`, `/movies/movies3` |
| Language profile | `English` |
| Default profile | Enabled for newly synced series and movies |
| Subtitle providers | Not configured yet |

Bazarr can talk to Sonarr and Radarr and has a clean health check. Add subtitle provider credentials before relying on automatic subtitle downloads. Do not run bulk subtitle searches until Sonarr/Radarr imports, provider settings, and subtitle write behavior are confirmed.

---

# Network Recovery Notes

## Known Prior Network Setup

| Attribute | Value |
|---|---|
| Static IP | No |
| Custom Hostname | No |
| Reverse Proxy | No |
| Remote Plex Access | Enabled through standard Plex remote access |
| Primary Use | Local and remote Plex streaming |

## Rebuild Implication

Because there was no static IP, hostname, or reverse proxy, network recovery should be relatively simple.

Check:

1. Windows network connectivity
2. Plex sign-in
3. Plex remote access status
4. Router port forwarding / UPnP behavior
5. Local client visibility
6. Remote client visibility

---

# Hardware Transcoding Notes

The system used hardware transcoding.

## Known Details

- GPU-assisted transcoding was enabled.
- The installed GPU is a GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, model GV-N3050WF2OC-6GD.
- Official GIGABYTE specs list power connectors as N/A, so the card is slot-powered.
- No external PCIe power connector is required for this GPU.
- Typical usage was 1–5 concurrent users.
- 4K transcoding was used.

## Rebuild Considerations

A replacement platform should preserve:

- PCIe slot compatibility for the NVIDIA GPU
- NVIDIA driver support on Windows
- Stable cooling and airflow
- Sufficient power from the PSU
- Plex Pass hardware transcoding support, if applicable

A modern Intel platform may also provide Quick Sync as a future fallback or replacement option.

---

# Data Safety Checklist

Before making destructive changes:

- Do not format any media drive.
- Do not initialize a disk in Disk Management unless you are certain it is blank.
- Do not convert disks unless necessary.
- Do not create a new partition table on existing media drives.
- Do not reinstall Windows over the OS SSD until Plex metadata has been checked.
- Do not delete unknown folders from media drives.
- Do not allow applications to mass-reorganize libraries until paths are confirmed.

---

# Unknowns To Capture During Rebuild

The following information is still missing and should be documented during the rebuild:

| Missing Item | Why It Matters |
|---|---|
| Physical bay-to-Windows disk mapping | Needed before future SATA recabling or drive replacement |
| SATA port map | Needed for driver/manual lookup and predictable future servicing |
| Plex metadata location | Needed for full Plex restore |
| Windows username used for Plex | Helps locate AppData folder |
| qBittorrent save paths | Needed to prevent broken torrents |
| Sonarr root folders | Needed for TV library repair |
| Radarr root folders | Needed for movie library repair |
| Jackett config location | Needed for indexer recovery |
| Unpackerr config paths | Needed for post-download automation |
| Docker compose file and `.env` | Needed to reproduce the container stack |
| Docker volume mapping plan | Needed to prevent containers writing to the wrong drive |
| SATA expansion card model | Needed for driver/manual lookup |
| BIOS SATA mode | AHCI/RAID mode can affect boot behavior |

---

# First-Boot Checklist

Use this checklist when the replacement system is assembled.

## With OS SSD Only

- [ ] BIOS sees OS SSD
- [ ] BIOS boot order points to Windows Boot Manager or OS SSD
- [ ] Windows starts
- [ ] Keyboard works
- [ ] Mouse works
- [ ] Network works
- [ ] Device Manager checked
- [ ] Motherboard drivers installed
- [ ] GPU driver installed
- [ ] Windows activation checked
- [ ] Plex data folder searched
- [ ] No media drives connected yet

## With Media Drives Added

- [ ] First media drive connected
- [ ] Disk Management checked
- [ ] Drive letter recorded
- [ ] Drive contents verified
- [ ] Drive letter corrected if needed
- [ ] Repeat for each media drive
- [ ] All media folders visible
- [ ] No drives initialized or formatted

## Application Recovery

- [ ] Docker Desktop starts
- [ ] Docker Compose works
- [ ] Docker media stack compose file reviewed
- [ ] Docker media stack volume mappings verified
- [ ] qBittorrent container paths verified
- [ ] Sonarr container root folders verified
- [ ] Radarr container root folders verified
- [ ] Jackett container opens and indexers remain configured
- [ ] Unpackerr container paths verified
- [ ] Plex libraries open
- [ ] Plex metadata appears intact
- [ ] Hardware transcoding enabled
- [ ] Local streaming tested
- [ ] Remote access tested

---

# Recommended Final Documentation After Rebuild

Once the rebuild succeeds, create or update the following:

1. Final component inventory
2. Drive inventory with model, serial, capacity, and drive letter
3. SATA port map
4. Plex library path map
5. Docker compose and `.env` documentation
6. Docker volume mapping table
7. Sonarr/Radarr root folder map
8. qBittorrent category/path map
9. Backup plan for Plex metadata
10. Backup plan for app configs
11. Remote access / router configuration notes

---

# Summary

The storage migration risk is manageable because the old server used simple Windows-native, non-RAID storage with independent drive letters. The new Docker plan adds container path mapping risk, so drive letters and Docker volumes must be verified before starting automation containers.

The critical success factors are:

1. Preserve the OS SSD.
2. Do not wipe or reinstall before checking Plex metadata.
3. Label every drive before migration.
4. Reconnect the OS SSD first, by itself.
5. Add media drives incrementally.
6. Restore original drive letters before launching automation tools.
7. Verify Plex paths, Docker volume mappings, and Sonarr/Radarr/qBittorrent/Jackett/Unpackerr paths before normal use.
