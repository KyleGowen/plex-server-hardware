# 2026-05-29 qBittorrent / Sonarr Crash Bundle

| Item | Value |
|---|---|
| Capture time | 2026-05-29 after recovery from the 10:07 AM unexpected shutdown |
| Current boot | 2026-05-29 10:19:03 |
| Previous unexpected shutdown | 2026-05-29 10:07:35 |
| Latest Kernel-Power | 2026-05-29 10:19:06, Event ID 41, `BugcheckCode=0` |
| Latest WHEA | 2026-05-29 10:19:14, Event ID 1 |
| Latest WHEA shape | 3552-byte CPER record with three fatal Firmware Error Record Reference sections |
| qBittorrent/Sonarr state after capture | Both stopped; Docker reported `Exited (137)` after the user's manual stop/post-reboot interruption |

## Files

| File | Contents |
|---|---|
| `crash-summary-redacted.json` | Redacted machine, storage, WHEA, container, and service-log summary |
| `system-events-filtered.json` / `.clixml` | Filtered System events around the crash window |
| `application-events-filtered.json` / `.clixml` | Filtered Application events around the crash window |
| `latest-whea.cper` | Raw latest WHEA CPER payload |
| `latest-whea-decoded.json` | Parsed CPER header and section metadata |

## Findings

- The system stayed up for roughly 12 hours before qBittorrent and Sonarr were started.
- qBittorrent started at about 09:27:39 and restored its torrents normally from the configured `I:\torrentfiles` bind mount.
- Sonarr started at about 09:27:42, authenticated to qBittorrent, and performed a broad TV library scan across `/tv/tv1` and `/tv/tv2`.
- Sonarr's broad scan appears to have finished around 09:34:43. Later Sonarr activity was mostly RSS/indexer polling, which failed because Prowlarr was intentionally not running.
- qBittorrent remained active after startup and logged at least one completed torrent event before the crash.
- Windows did not log a pre-crash `disk`, `storahci`, or `NTFS` warning in the checked 09:20-10:07 window.
- Docker Desktop logs did not show an application panic or mount failure before the crash; they showed normal API polling and qBittorrent-related network forwarding activity.
- The crash record again matches the existing hard-reset pattern: `Kernel-Power 41`, `BugcheckCode=0`, no minidump, and fatal WHEA firmware/platform CPER after reboot.

## Interpretation

This evidence does not prove that the qBittorrent `I:\` mount is logically corrupt or misconfigured. The stronger read is that qBittorrent plus Sonarr created storage, network, Docker/WSL, and SATA power activity that reproduced the existing platform-level crash.

Given the current physical wiring note that TV drives were sharing the same power cable as the Torrent drive, the next suspect to verify is the shared SATA power branch feeding `I:`, `H:`, and/or `J:`, followed by the `I:` drive's SATA data/power path.
