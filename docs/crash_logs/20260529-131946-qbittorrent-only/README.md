# 2026-05-29 qBittorrent-Only Crash Bundle

## Summary

User reported another recovery after starting qBittorrent alone. This removes Sonarr as a required trigger for the latest reproduction.

## Captured Evidence

| File | Purpose |
|---|---|
| `crash-summary-redacted.json` | Compact redacted diagnosis summary |
| `system-events-filtered.json` / `.clixml` | Filtered System log after 12:45 PM |
| `application-events-filtered.json` / `.clixml` | Filtered Application log after 12:45 PM |
| `latest-whea.cper` | Raw latest WHEA CPER payload |
| `latest-whea-decoded.json` | Compact CPER descriptor decode |
| `qbit-docker-summary-redacted.json` | qBittorrent/Docker state without torrent names, hashes, peer IPs, or tracker details |
| `storage-mount-checks.json` | Windows fixed disks, physical disks, and key root checks |
| `hardware-monitor-summary.json` | Crash-window and post-reboot sensor-log summary |

## Key Findings

- qBittorrent startup and the unexpected shutdown line up at roughly `2026-05-29 1:11 PM`.
- Windows again recorded `Kernel-Power 41` with no bugcheck dump and `WHEA-Logger` Event 1 after reboot.
- The latest WHEA CPER remains a fatal 3552-byte `CPER` record with three fatal `Firmware Error Record Reference` sections.
- qBittorrent was mounted to `I:\torrentfiles` as `/downloads` and restored 39 torrent/session files at startup.
- No checked pre-crash `disk`, `storahci`, or `NTFS` warning was found.
- Hardware monitor logging was initialized for the crash window, but the reset happened before any complete sensor row flushed. Post-reboot sensors were visible and showed no obvious thermal emergency.

## Current Interpretation

qBittorrent is now a confirmed trigger. The available evidence still looks like a platform/power/storage-path hard reset rather than a normal qBittorrent application crash. The leading next component path to verify is the Torrent drive path under qBittorrent load: `I:` drive, SATA data cable/port, and especially the SATA power branch shared with other drives.
