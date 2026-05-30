# 2026-05-29 qBittorrent Hardened Recreate Crash

Captured after recovery from the crash that occurred after the qBittorrent container was recreated with the staged Docker hardening settings.

## Timeline

| Local time | Event |
|---|---|
| 2026-05-29 16:28:09 | qBittorrent conservative profile started. |
| 2026-05-29 17:30 | Conservative qBittorrent profile had survived about one hour. |
| 2026-05-29 17:31:14 | qBittorrent recreated to activate Docker hardening. |
| 2026-05-29 17:37:22 | Five-minute post-recreate check passed. |
| 2026-05-29 17:43:35 | Windows later recorded the previous shutdown as unexpected. |
| 2026-05-29 22:16:57 | Windows booted after recovery. |
| 2026-05-29 22:17:07 | WHEA-Logger Event 1 recorded a fatal hardware error. |

## State

| Item | Result |
|---|---|
| Connected fixed volumes | `C:` and `I:` only |
| Torrent root | `I:\torrentfiles` present |
| qBittorrent image | `lscr.io/linuxserver/qbittorrent:5.2.0-libtorrentv1` |
| qBittorrent limits active | `4 GiB` memory, `2` CPU quota, PID limit `256`, `nofile` soft `2048`, hard `4096` |
| qBittorrent peer features | DHT off, PeX off, Local Peer Discovery off |
| Docker published peer ports | TCP `6881`; UDP `6881` not published |
| Sonarr | Stopped |
| Minidump / MEMORY.DMP | None found |

## Evidence

- `system-events-filtered.json`: filtered Windows System events from the crash/recovery window.
- `latest-whea.cper`: raw latest WHEA CPER payload.
- `latest-whea-decoded.json`: decoded CPER header and section descriptors.
- `qbit-docker-summary-redacted.json`: qBittorrent container state and active limits after recovery.
- `qbit-log-window-redacted.txt`: redacted qBittorrent log lines around the hardened recreate and post-recovery start.
- `storage-mount-checks.json`: post-recovery drive and mount state.
- `thermal-monitor-summary.json`: thermal monitor coverage note.
- `reliability-records.json`: Reliability Monitor record for the unexpected shutdown.

## Interpretation

This crash means the Docker hardening settings did not solve the root issue. The conservative qBittorrent profile survived about an hour before the recreate, then the machine crashed about twelve minutes after the hardened container was recreated.

The evidence still points to a qBittorrent-triggered platform failure rather than a normal qBittorrent application crash: Windows recorded another unexpected shutdown, `Kernel-Power 41`, and WHEA Event 1 with the same CPER section pattern. There was no useful application-level fault, no minidump, and no storage warning in the checked window.

The stronger current theory is now: qBittorrent restart/session restore plus live peer networking is enough to trigger a low-level platform failure even with libtorrent v1, DHT/PeX/LSD disabled, Docker memory/CPU/PID/file limits, and UDP not published through Docker. That shifts suspicion further away from qBittorrent configuration alone and toward Docker Desktop/WSL networking, the Intel I226-V driver/offload/interrupt path, or motherboard/CPU/firmware sensitivity under this traffic pattern.

No direct thermal sensor rows cover the exact crash window. The prior logger stopped around `16:49`, and the next thermal logger started after recovery around `22:19`.
