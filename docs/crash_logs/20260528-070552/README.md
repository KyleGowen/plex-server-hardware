# Crash Evidence Bundle - 2026-05-28 07:05

## Capture Context

| Item | Value |
|---|---|
| Capture time | 2026-05-28 07:05 local |
| Current boot | 2026-05-28 07:03:42 |
| Latest unexpected shutdown | Previous shutdown at 2026-05-27 11:34:23 PM |
| Latest Kernel-Power event | 2026-05-28 07:03:46, Event ID 41 |
| Latest WHEA event | 2026-05-28 07:04:00, Event ID 1 |
| Dump files | No minidump or `MEMORY.DMP` found |

## Preserved Files

| File | Purpose |
|---|---|
| `System-last18h.evtx` | Native Windows System event export for the last 18 hours |
| `Application-last18h.evtx` | Native Windows Application event export for the last 18 hours |
| `system-events-last18h.clixml` | PowerShell XML export of System events |
| `application-events-last18h.clixml` | PowerShell XML export of Application events |
| `crash-summary.json` | Compact parsed summary of boot time, Kernel-Power, WHEA, storage, memory, and dump checks |
| `latest-whea.cper` | Raw WHEA CPER blob from the latest WHEA Event 1 |
| `latest-whea-decoded.json` | Parsed CPER section metadata |
| `mount-checks.json` | Post-boot Docker and drive mount checks |
| `device-manager-errors.json` | Device Manager nonzero error-code scan |

## Key Findings

- The latest crash is another hard reset pattern, not a normal bugcheck.
- `Kernel-Power 41` reported `BugcheckCode=0`, `PowerButtonTimestamp=0`, `SleepInProgress=0`, and `ConnectedStandbyInProgress=false`.
- No Windows crash dump was created.
- The latest WHEA CPER record contains three fatal `Firmware Error Record Reference` sections.
- `I:\torrentfiles`, `H:\TV Shows`, qBittorrent `/downloads`, and Sonarr `/tv/tv2` were mounted correctly after reboot.
- `device-manager-errors.json` is empty, meaning no nonzero Device Manager error-code devices were detected during capture.

## Recommended Next Component To Verify

Verify the PSU/power delivery path first: the reused Corsair RM750e, every modular cable attached to it, and every SATA power branch feeding the drives.

Reason: the repeated symptom is abrupt hard reset with no bugcheck and no dump, while WHEA records a fatal firmware/platform condition after reboot. Power delivery is the most practical first hardware isolation step before replacing motherboard/CPU/RAM.
