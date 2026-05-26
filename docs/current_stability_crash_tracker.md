# Current Stability And Crash Tracker

## Purpose

Track the unresolved randomly timed crashing on the rebuilt Plex server.

This file is for evidence and non-destructive diagnostics only. Do not claim a root cause until the pattern is supported by logs, observations, or repeatable tests.

---

# Current Problem Statement

| Item | Current state |
|---|---|
| Issue | Randomly timed crashing |
| Status | Unresolved |
| Affected system | Rebuilt MSI PRO Z790-A WiFi II / Intel Core i5-14500 Windows 10 Plex server |
| Known service state | Plex and Docker media stack can run |
| Current evidence level | User report; crash timestamps and event details still needed |

---

# Known Rebuild / Driver Context

| Area | Known state |
|---|---|
| Windows | Windows 10 Home build 19045, 64-bit |
| Motherboard | MSI PRO Z790-A WIFI II |
| CPU | Intel Core i5-14500 |
| GPU | NVIDIA GeForce RTX 3050 |
| iGPU | Intel UHD Graphics 770 |
| Intel chipset INF | MSI package `10.1.20062.8627` installed |
| Wi-Fi | Realtek 8852CE driver `6001.16.172.0` installed |
| Bluetooth | Realtek Bluetooth driver `18.4032.2510.900` installed |
| Audio | Realtek package `6.0.9977.1` installed |
| NVIDIA | Studio Driver `596.36`; device driver `32.0.15.9636` |
| Intel DSA | Installed |
| Device Manager snapshot | No nonzero `ConfigManagerErrorCode` devices in the checked snapshot |

Source: [driver_install_status_2026-05-22.md](driver_install_status_2026-05-22.md).

---

# Evidence To Capture

| Evidence | Why it matters | Status |
|---|---|---|
| Exact crash timestamps | Required to correlate Event Viewer and service logs | Needed |
| Crash behavior | Distinguishes reboot, power loss, freeze, BSOD, display-driver reset, sleep/wake issue | Needed |
| Event Viewer System log | Finds Kernel-Power, bugcheck, WHEA, driver, storage, or service events | Needed |
| Reliability Monitor | Summarizes Windows hardware/application failures | Needed |
| Minidump presence | Supports BSOD/debug path if bugchecks occur | Needed |
| BIOS memory/XMP state | RAM profile instability is a common post-rebuild variable | Needed |
| Temperatures | Checks CPU/GPU/storage thermal correlation | Needed |
| SMART status | Checks OS SSD and HDD health | Needed |
| Workload correlation | Separates idle, Plex playback/transcode, Docker download/import, and mixed-load crashes | Needed |
| Power/sleep settings | Checks sleep, wake, USB, PCIe, and power-state behavior | Needed |

---

# Non-Destructive Diagnostic Checklist

- [ ] Record the next three crash times with local time and what the server was doing.
- [ ] Check Event Viewer System log around each timestamp.
- [ ] Check Reliability Monitor for matching critical events.
- [ ] Check for `C:\Windows\Minidump` files if a BSOD or bugcheck is suspected.
- [ ] Record BIOS version and memory profile/XMP state.
- [ ] Confirm CPU and GPU temperatures at idle and during a controlled Plex playback/transcode.
- [ ] Capture SMART status for `C:` and all fixed media/data drives.
- [ ] Confirm qBittorrent `/downloads` mount after any crash before resuming torrents.
- [ ] Review Docker Desktop/WSL logs only after Windows crash evidence is collected.
- [ ] Avoid firmware, BIOS, storage-controller, or drive-letter changes until a diagnostic plan calls for them.

---

# Possible Areas To Investigate

These are hypotheses, not conclusions:

| Area | Why it is plausible |
|---|---|
| Memory stability / XMP | New DDR5 platform; memory profile state still needs recording |
| Driver/platform transition | Windows install was preserved across a major motherboard platform change |
| GPU/display driver | NVIDIA driver was updated; Plex may use GPU transcoding |
| Power delivery / PSU cabling | PSU is reused; modular cable safety remains important |
| Thermals/fan control | Reused case and fans; fan map still needs documentation |
| Storage or Docker/WSL timing | qBittorrent already had a stale mount incident after `I:` was unavailable |
| Sleep/power states | Random timing may correlate with idle/sleep/wake if enabled |

---

# Current Rule

Until the crash pattern is understood, treat service changes as secondary. Preserve data first, collect evidence second, and only then change drivers, BIOS settings, hardware configuration, or service behavior.
