# Crash Evidence Bundle - 2026-05-28 12:31

## Capture Context

| Item | Value |
|---|---|
| Capture time | 2026-05-28 12:31 local |
| Current boot | 2026-05-28 12:23:28 |
| Latest unexpected shutdown | Previous shutdown at 2026-05-28 11:44:14 AM |
| Latest Kernel-Power event | 2026-05-28 12:23:31, Event ID 41 |
| Latest WHEA event | 2026-05-28 12:23:39, Event ID 1 |
| Dump files | No minidump or `MEMORY.DMP` found |

## Hardware Isolation State

- User removed every drive except OS, Torrent, TV 1, and TV 2.
- Remaining drives are plugged directly into motherboard SATA ports.
- PCI SATA expansion card was removed from the active storage path.
- The power cable/adapter branch that powered the broken-pin drive was removed entirely.
- User reported that branch used a legacy 4-pin peripheral/Molex-style power connector with SATA power adapter(s) to feed other drives because there were not enough native SATA power cables available.

## Current Detected Storage

| Drive | Label | Role |
|---|---|---|
| C: | unlabeled | OS SSD |
| H: | TV 2 | TV media |
| I: | Torrent | qBittorrent download root |
| J: | TV 1 | TV media |

Physical disks present: OS SSD `S1DDNWAF903275D`, TV 1 `ZVTBPM4J`, TV 2 `ZYD02EQ2`, Torrent `ZYE00444`.

## Key Findings

- Crash pattern remains a hard reset: `Kernel-Power 41`, `BugcheckCode=0`, no power-button timestamp, not sleep/standby.
- Fatal WHEA Event 1 returned after this reboot.
- `I:\torrentfiles` was present after the isolation change.
- Docker showed qBittorrent `/downloads` mounted from `I:\`.
- Sonarr showed `/tv/tv1`, `/tv/tv2`, and `/downloads` correctly mounted.

## Current Hardware Suspect

The removed legacy 4-pin-to-SATA adapter power branch is now a major suspect. Do not reuse it. Run the next soak with only native, RM750e-compatible modular SATA power cables and direct motherboard SATA data connections.
