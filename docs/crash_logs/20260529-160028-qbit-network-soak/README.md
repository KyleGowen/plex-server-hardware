# 2026-05-29 qBittorrent Networked Soak Crash

Captured after recovery from the qBittorrent-only networked soak crash.

## Timeline

| Local time | Event |
|---|---|
| 2026-05-29 15:22:57 | qBittorrent restart requested with network available. |
| 2026-05-29 15:22:59 | qBittorrent restart completed. |
| About 15:24 | One-minute check passed: qBittorrent up, Sonarr stopped, `/downloads` mapped to `I:\`. |
| About 15:28 | Five-minute check passed: qBittorrent up, Sonarr stopped, `/downloads` still mapped to `I:\`. |
| 2026-05-29 15:28:50 | Windows later recorded the previous shutdown as unexpected. |
| 2026-05-29 16:00:28 | Windows booted after recovery. |
| 2026-05-29 16:00:35 | WHEA-Logger Event 1 recorded a fatal hardware error. |

## State

| Item | Result |
|---|---|
| Connected fixed volumes | `C:` and `I:` only |
| Torrent root | `I:\torrentfiles` present |
| qBittorrent `/downloads` mount before crash | Verified as mapped to `I:\torrentfiles` |
| Sonarr | Stopped before and during the test |
| TV drives | Disconnected for this test |
| PCI SATA expansion | Removed for this test |
| qBittorrent after reboot | Auto-started due `unless-stopped`, then was manually stopped |
| Minidump / MEMORY.DMP | None found |

## Evidence

- `crash-summary-redacted.json`: compact crash timeline and interpretation.
- `system-events-filtered.json`: filtered Windows System events from the crash window.
- `latest-whea.cper`: raw latest WHEA CPER payload.
- `latest-whea-decoded.json`: decoded CPER header and section descriptors.
- `qbit-docker-summary-redacted.json`: qBittorrent container state, mounts, and redacted test timing.
- `storage-mount-checks.json`: post-recovery drive and mount state.
- `thermal-monitor-summary.json`: thermal monitor coverage note.
- `reliability-records.json`: Reliability Monitor record for the unexpected shutdown.
- `network-docker-summary.json`: active NIC, Hyper-V/WSL adapter, and Docker Desktop version summary.

## Interpretation

This is the cleanest qBittorrent split so far. qBittorrent could start and run offline in the clean `C:` + `I:` state for about an hour, but sustained live networked qBittorrent activity crashed the machine in less than ten minutes after restart.

That makes the TV drives, the old Molex-to-SATA branch, the PCI SATA card, Sonarr, and basic qBittorrent startup less likely as primary causes for this reproduction. The leading path is now qBittorrent peer/network activity through Docker Desktop, WSL/Hyper-V networking, the motherboard NIC/driver, or platform firmware/power response under that workload.

No direct sensor rows cover the exact crash window. The pre-crash thermal log stopped updating at about `14:10:30`, and the next hardware-monitor logger started after reboot at `16:01:40`. This crash therefore does not prove overheating, but the monitor gap also means overheating cannot be ruled out from sensor logs for this specific event alone.
