# 2026-05-30 qBittorrent Reverted Conservative Overnight Crash

Captured after recovery from the overnight crash while qBittorrent was running in the reverted conservative profile.

## Timeline

| Local time | Event |
|---|---|
| 2026-05-29 22:34:40 | qBittorrent started after reverting the extra Docker hardening layer. |
| 2026-05-29 22:40:48 | Five-minute check passed. |
| 2026-05-30 00:40:08 | Windows later recorded the previous shutdown as unexpected. |
| 2026-05-30 07:59:35 | Windows booted after recovery. |
| 2026-05-30 07:59:42 | WHEA-Logger Event 1 recorded a fatal hardware error. |
| 2026-05-30 08:00:27 | Docker/qBittorrent briefly auto-started after reboot. |
| 2026-05-30 08:00:43 | qBittorrent exited after post-recovery startup. |

## State

| Item | Result |
|---|---|
| Connected fixed volumes | `C:` and `I:` only |
| Torrent root | `I:\torrentfiles` present |
| qBittorrent image | `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1` |
| qBittorrent app profile | DHT off, PeX off, Local Peer Discovery off, low connection limits |
| Docker published peer ports | TCP `6881`; UDP `6881` not published |
| Docker limits | `mem_limit: 4g`; extra CPU/PID/ulimit/logging hardening removed |
| Sonarr | Stopped |
| Minidump / MEMORY.DMP | None found |

## Evidence

- `system-events-filtered.json`: filtered Windows System events from the crash/recovery window.
- `latest-whea.cper`: raw latest WHEA CPER payload.
- `latest-whea-decoded.json`: decoded CPER header and section descriptors.
- `qbit-docker-summary-redacted.json`: qBittorrent container state after recovery.
- `qbit-log-window-redacted.txt`: redacted qBittorrent log lines around start and recovery.
- `storage-mount-checks.json`: post-recovery drive and mount state.
- `thermal-monitor-summary.json`: thermal monitor coverage note.
- `reliability-records.json`: Reliability Monitor records, including the unexpected shutdown.

## Interpretation

The reverted conservative qBittorrent profile also failed, but much later than the hardened recreate branch. It ran from about `22:34` to `00:40`, roughly two hours and five minutes, before Windows recorded another unexpected shutdown.

The crash signature remains the same low-level pattern: `Kernel-Power 41`, WHEA Event 1, a 3552-byte CPER payload with three Firmware Error Record Reference sections, no minidump, no `MEMORY.DMP`, and no checked storage-controller or NTFS warning.

This means the extra Docker hardening was not the sole cause. The conservative profile reduces or delays the trigger, but qBittorrent live networking still eventually reproduces the machine crash. Current leading suspects remain the Docker Desktop/WSL networking path, the Intel I226-V Ethernet driver/offload/interrupt path, or platform firmware/CPU/motherboard sensitivity under this traffic pattern.

No direct thermal sensor rows cover the exact overnight crash window. The prior logger stopped around `22:20`, and the next logger started after recovery around `08:00`.
