# Plex Server Storage Migration And Operational Path Notes

## Purpose

This document preserves the rebuild storage lessons and current operational safety rules.

The storage migration/rebuild phase is complete enough for Windows, Plex, and the Docker media stack to run. The remaining value of this file is preventing future drive-letter, Docker bind-mount, and application-path mistakes.

---

# Current Storage Architecture

| Area | Current state |
|---|---|
| Operating system | Windows 10 on dedicated SATA SSD |
| Plex install | Native Windows installation |
| Media/data drives | 6 detected media/data HDD volumes plus the OS SSD after the 2026-05-25 drive swap |
| Drive organization | Separate Windows drive letters |
| RAID / pooling | None known |
| Docker stack | Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, Unpackerr |
| Native download client | qBittorrent |
| Optional legacy service | Jackett profile |
| Download root | `I:\torrentfiles` on Windows, `/downloads` in Arr/Unpackerr containers |

The canonical drive table is maintained in [plex_server_hardware_inventory.md](plex_server_hardware_inventory.md).

---

# Current Fixed Drive Summary

| Role | Count | Current letters / labels |
|---|---:|---|
| Windows OS/application SSD | 1 | `C:` Samsung SSD 840 EVO 250GB |
| Movie media drives | 3 | `D:` Movies 1, `F:` Movies 2, `E:` Movies 3 |
| TV media drives | 3 currently detected | `J:` TV 1, `H:` TV 2, `G:` TV 3 |
| Torrent/download drive | 1 | `I:` Torrent |
| Extra media/data drive | 0 currently distinct from TV roots | The earlier `G:` Empty replacement context is historical; current `G:` is TV 3 |

Older visual inspection suggested fewer HDDs in the rack. Treat that as historical/photo-based context only. The 2026-05-26 post-swap inventory in [plex_server_hardware_inventory.md](plex_server_hardware_inventory.md) is the current operational storage snapshot.

---

# Operational Safety Rules

- Do not format, initialize, repartition, or wipe existing media drives.
- Do not change drive letters casually.
- Do not move media folders to satisfy a broken app path until drive identity and current drive letter are verified.
- Do not repair Plex, Sonarr, Radarr, Bazarr, Tautulli, qBittorrent, Jackett, or Unpackerr paths until drive letters and Docker mounts are confirmed.
- Keep `I:\torrentfiles` as the host download root unless a separate migration plan explicitly changes it.
- Keep the removed broken-pin drive and any suspect cabling out of service unless there is an explicit recovery plan.
- Verify `G:`, `H:`, and `J:` after any boot, crash, Docker restart, WSL restart, or storage work before importing, repairing, or mass-editing TV paths.

---

# Docker Path Mapping

The Docker stack uses stable container paths mapped from Windows drive letters.

| Host path | Container path | Used by |
|---|---|---|
| `I:\torrentfiles` | `/downloads` | Sonarr, Radarr, Unpackerr |
| `J:\TV Shows` | `/tv/tv1/TV Shows` | Sonarr |
| `H:\TV Shows` | `/tv/tv2/TV Shows` | Sonarr |
| `J:\` | `/tv/tv1` | Bazarr |
| `H:\` | `/tv/tv2` | Bazarr |
| `D:\Movies` | `/movies/movies1/Movies` | Radarr |
| `F:\Movies` | `/movies/movies2/Movies` | Radarr |
| `E:\Movies` | `/movies/movies3/Movies` | Radarr |
| `D:\` | `/movies/movies1` | Bazarr |
| `F:\` | `/movies/movies2` | Bazarr |
| `E:\` | `/movies/movies3` | Bazarr |
| `C:\media-stack\config\<service>` | `/config` | Docker service configs |

Before normal operation after boot, crash, drive reconnect, Docker restart, or WSL restart:

```powershell
Test-Path I:\torrentfiles
Invoke-WebRequest http://127.0.0.1:8080 -UseBasicParsing
docker exec sonarr sh -c "df -h /downloads"
docker exec radarr sh -c "df -h /downloads"
docker exec unpackerr sh -c "df -h /downloads"
```

Healthy Docker output should show `/downloads` mounted from `I:\` with multi-terabyte capacity. If Docker shows a tiny full filesystem, restart Docker/WSL before trusting Arr imports or Unpackerr extraction.

On 2026-05-26, `/downloads` was healthy, but `/tv/tv2` showed as a tiny full placeholder filesystem because `H:` was absent. A later 2026-05-30 snapshot restored TV roots on `G:`, `H:`, and `J:`. Treat this as a reminder to verify mounts after reboots or storage work, not as the current TV 2 state.

For a step-by-step reconnect diagnosis that checks Windows drive letters, `I:\torrentfiles`, Docker `/downloads`, and Docker `/tv/tv2` before trusting Sonarr/Radarr/qBittorrent, use [drive_reconnect_validation_checklist.md](drive_reconnect_validation_checklist.md).

---

# Plex Path Rules

Plex runs natively on Windows and reads media through Windows paths, not Docker container paths.

| Item | Current rule |
|---|---|
| Plex data path | Preserve `C:\Users\Kyle\AppData\Local\Plex Media Server` unless later verified otherwise |
| Plex token | Secret; use only at runtime for local API calls |
| Library refreshes | Require explicit user confirmation |
| Missing imported media | Check Plex library, activity, and Arr import state before proposing a refresh |

Detailed Plex service context lives in [services/plex.md](services/plex.md).

---

# qBittorrent Notes

Confirmed current architecture:

| Item | Value |
|---|---|
| Host download root | `I:\torrentfiles` |
| Shared container download root | `/downloads` for Sonarr/Radarr/Unpackerr |
| qBittorrent default save path | `I:\torrentfiles\` |
| qBittorrent incomplete path | `I:\torrentfiles\incomplete\` |
| Sonarr download client | `host.docker.internal:8080`, category `tv-sonarr`, remote path `I:\torrentfiles\` -> `/downloads/` |
| Radarr download client | `host.docker.internal:8080`, category `radarr`, remote path `I:\torrentfiles\` -> `/downloads/` |

Native qBittorrent writes directly to `I:\torrentfiles`. Radarr, Sonarr, and Unpackerr mount the same host download root as `/downloads`, so Sonarr/Radarr need remote path mappings from qBittorrent's Windows path to their container path.

Do not resume all torrents or trigger broad automatic searches until category behavior and completed import handling are confirmed with controlled tests.

---

# Confirmed Root Folders

## Sonarr TV Root Folders

Confirmed in Sonarr on 2026-05-24.

| Host path | Container path | Status |
|---|---|---|
| `J:\TV Shows` | `/tv/tv1/TV Shows` | Root folder configured and accessible |
| `H:\TV Shows` | `/tv/tv2/TV Shows` | Root folder configured and accessible when `H:` is present |
| `G:\TV Shows` | `/tv/tv3/TV Shows` | Root folder configured and accessible when `G:` is present |

## Radarr Movie Root Folders

Confirmed in Radarr on 2026-05-24.

| Host path | Container path | Status |
|---|---|---|
| `D:\Movies` | `/movies/movies1/Movies` | Root folder configured and accessible |
| `F:\Movies` | `/movies/movies2/Movies` | Root folder configured and accessible |
| `E:\Movies` | `/movies/movies3/Movies` | Root folder configured and accessible |

---

# Remaining Storage Documentation Tasks

- [ ] Confirm physical bay-to-drive mapping.
- [ ] Confirm SATA port-to-drive mapping.
- [ ] Confirm PSU cable map.
- [ ] Confirm fan header map.
- [x] Capture current Windows physical-disk health status for all detected fixed drives.
- [ ] Capture detailed SMART attributes for all fixed drives.
- [ ] Create a backup procedure for Plex metadata and Docker app configs.

---

# Summary

The rebuild retained simple Windows-native storage with independent drive letters. That is good for recovery, but it means service health depends on stable drive letters and correct Docker bind mounts.

The critical ongoing rules are:

1. Preserve existing media drives.
2. Confirm drive letters before repairing paths.
3. Confirm native qBittorrent sees `I:\torrentfiles`, and Docker services see `/downloads`, before trusting downloads/imports.
4. Keep Plex native Windows paths and Docker container paths distinct.
