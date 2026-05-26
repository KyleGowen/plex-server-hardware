# Driver Install Status - 2026-05-22

## Purpose

Restart handoff note for the Windows 10 Plex server rebuild.

This file records the hardware driver work completed before restart so the rebuild can resume without guessing what was installed.

## Current Machine

| Item | Value |
|---|---|
| Timestamp | 2026-05-22 21:39:54 -07:00 |
| Windows | Windows 10 Home, build 19045, 64-bit |
| Motherboard | MSI PRO Z790-A WIFI II (MS-7E07) |
| CPU | Intel Core i5-14500 |
| GPU | NVIDIA GeForce RTX 3050 |
| iGPU | Intel UHD Graphics 770 |
| Driver staging folder | `C:\Drivers\Plex-Rebuild` |

## Installed / Updated

| Area | Result |
|---|---|
| Git for Windows | Installed and verified as `git version 2.54.0.windows.1` |
| Intel chipset INF | Installed MSI package `10.1.20062.8627`; installer returned `3010`, meaning success with reboot requested |
| Realtek 8852CE Wi-Fi | Installed from MSI package; driver version `6001.16.172.0` |
| Realtek Bluetooth | Installed from MSI package; driver version `18.4032.2510.900` |
| Realtek audio | Installed from MSI package; driver package `6.0.9977.1` |
| NVIDIA RTX 3050 Studio Driver | Installed NVIDIA driver `596.36`; device driver version `32.0.15.9636` |
| Intel Driver & Support Assistant | Installed; `DSAService` and `DSAUpdateService` were running after install |

## Verification Snapshot

| Check | Result |
|---|---|
| Ethernet | Intel I226-V up at `1 Gbps` |
| Wi-Fi | Realtek 8852CE recognized; disconnected at time of check |
| Bluetooth | Realtek Bluetooth Adapter recognized |
| Display drivers | NVIDIA RTX 3050 and Intel UHD 770 both use vendor drivers |
| Device Manager error-code check | No devices reported nonzero `ConfigManagerErrorCode` |
| Reboot pending registry checks | No pending reboot flags found in the checked registry paths |
| Repo state before this note | Clean on `main`, tracking `origin/main` |

## Important Caveats

- No reboot was performed by Codex.
- NVIDIA silent install returned exit code `1`, but the RTX 3050 driver did update to `596.36`.
- NVIDIA App, telemetry, and related NVIDIA components were installed by the current NVIDIA package despite the preference for driver-only.
- Intel DSA was installed but no DSA-driven update scan or additional Intel driver update pass was run.
- `Test-NetConnection github.com -Port 443` failed once, while DNS and prior HTTPS downloads worked. Treat as a probe/firewall/network quirk unless repeated after restart.

## Safety Rules Still Active

- Do not launch Plex, Sonarr, Radarr, qBittorrent, Jackett, or Unpackerr until drive letters and app config paths are confirmed.
- Do not initialize, format, repartition, wipe, or repair any media drive.
- Do not update BIOS or change storage controller / RAID settings during this recovery pass.
- Keep media HDDs disconnected or inactive until the OS SSD and Windows driver layer are stable.

## Recommended Next Steps After Restart

1. Restart Windows once to settle the chipset, Realtek, audio, and NVIDIA driver changes.
2. After login, verify Device Manager has no unknown or failed critical devices.
3. Run a fresh driver inventory for display, network, Bluetooth, audio, chipset, and Intel ME.
4. Confirm Ethernet, Wi-Fi visibility, Bluetooth visibility, and audio device presence.
5. Open Intel Driver & Support Assistant manually and apply only relevant Intel driver updates.
6. Do not accept BIOS or firmware updates from DSA in this pass.
7. Resume the rebuild from the documented storage-safe sequence: OS SSD first, then media drives one at a time only after Windows is stable.
