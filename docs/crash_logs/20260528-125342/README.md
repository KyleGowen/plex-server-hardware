# Crash Evidence Bundle - 2026-05-28 12:53

## Capture Context

| Item | Value |
|---|---|
| Capture time | 2026-05-28 12:53 local |
| Current boot | 2026-05-28 12:50:06 |
| Latest unexpected shutdown | Previous shutdown at 2026-05-28 12:23:38 PM |
| Latest Kernel-Power event | 2026-05-28 12:50:08, Event ID 41 |
| Latest WHEA event | 2026-05-28 12:50:15, Event ID 1 |
| Dump files | No minidump or `MEMORY.DMP` found |

## Isolation State

- User clarified that the true OS-only drive state began after recovery from this crash.
- User removed all SATA drives and cables except the OS SSD after the `2026-05-28 12:23:38 PM` unexpected shutdown.
- User removed unused power cables after that recovery.
- Windows detected only `C:` / the Samsung SSD 840 EVO OS drive.
- Physical disk inventory detected only serial `S1DDNWAF903275D`.
- RAM still reported two Lexar 16 GB DIMMs in A2/B2 at 4800.
- GPU detected as NVIDIA GeForce RTX 3050 with driver `32.0.15.9636`.

## Key Finding

This bundle records the transition into the OS-only storage soak, not a failure of that soak. The crash happened before the true OS-only state began.

## Current Test

Soak with only the OS SSD connected. If the system crashes in this state, then storage drives, the PCI SATA expansion card, the loose Torrent-drive SATA data cable, and the removed Molex-to-SATA adapter branch become much less likely to be the complete root cause.

Do not move to RAM isolation until this OS-only storage soak either fails or runs long enough to change the diagnosis.
