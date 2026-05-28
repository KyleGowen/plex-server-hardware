# Crash Evidence Bundle - 2026-05-28 11:33

## Capture Context

| Item | Value |
|---|---|
| Capture time | 2026-05-28 11:33 local |
| Current boot | 2026-05-28 11:30:19 |
| Latest unexpected shutdown | Previous shutdown at 2026-05-28 10:23:59 AM |
| Latest Kernel-Power event | 2026-05-28 11:30:23, Event ID 41 |
| Dump files | No minidump or `MEMORY.DMP` found |

## Key Findings

- The latest crash repeated the hard-reset pattern: `Kernel-Power 41`, `BugcheckCode=0`, no power-button timestamp, not sleep/standby.
- No new WHEA Event 1 was present yet for this specific reboot during the first post-boot capture window, but earlier 2026-05-28 and 2026-05-27 crashes still show fatal WHEA firmware/platform records.
- `I:` / Torrent was absent after reboot. `Test-Path I:\` and `Test-Path I:\torrentfiles` both returned false.
- Docker started while the torrent drive was missing and mounted `/downloads` as a tiny full `137M` placeholder filesystem.
- `H:` / TV 2, `J:` / TV 1, movie drives, and the replacement `G:` drive were present.
- The missing physical disk appears to be the 20 TB Torrent drive previously identified as serial `ZYE00444`.

## Immediate Safety Note

Do not trust qBittorrent after this boot. Do not resume torrents until `I:\torrentfiles` exists in Windows and Docker shows `/downloads` mounted from `I:\` with multi-terabyte capacity.

## Photo/Hardware Follow-Up

The photos did not show obvious scorch marks or melted motherboard power connectors. The main things to verify physically are:

- CPU power: ensure `CPU_PWR1` is fully populated with the correct 4+4 EPS/CPU cable. If a second correct EPS/CPU cable is available, populate `CPU_PWR2` as well for isolation.
- Do not plug a PCIe/VGA 8-pin cable into CPU power; use only cables marked CPU/EPS.
- PSU side: ensure the motherboard 24-pin cable uses both required PSU-side plugs and that both are fully seated.
- Drive power: focus next on the SATA power branch feeding the missing `I:` / Torrent drive, since that disk disappeared after this crash.

## Recommended Next Component To Verify

Verify the SATA power cable/branch feeding the `I:` Torrent drive first. If that branch also fed the removed broken-pin drive or multiple HDDs, remove it from service and move `I:` onto a different confirmed RM750e-compatible SATA power cable.
