# Plex Server Rebuild — Work In Progress Tracker

## Purpose

Track the current rebuild status, purchased parts, pending work, risks, and post-rebuild documentation tasks for the Plex media server hardware replacement.

This file is intended to be added to the **Plex Server Hardware** project knowledge files and updated throughout the rebuild.

---

# Current Status

| Area | Status |
|---|---|
| Failure diagnosis | Motherboard failure strongly suspected |
| Rebuild direction | Modern Intel platform upgrade |
| Parts ordered | Yes |
| Existing case reuse | Yes |
| Existing PSU reuse | Yes |
| Existing GPU reuse | Likely |
| Existing OS SSD reuse | Yes, preserve and test first |
| Existing media HDD reuse | Yes, preserve all drives |
| Storage architecture | Windows-native separate SATA drive letters |
| RAID / pooling | None known |
| Plex deployment | Native Windows install |
| Current priority | Receive parts, inspect, assemble minimal boot system |

---

# Purchased Rebuild Parts

| Component | Purchased Part | Status | Notes |
|---|---|---|---|
| Motherboard | MSI PRO Z790-A WiFi II | Purchased | LGA1700, DDR5, ATX, 6 SATA ports |
| CPU | Intel Core i5-14500 SRN3T | Purchased | eBay open-box / pulled CPU; inspect and test within return window |
| RAM | Lexar Thor Z Series DDR5 32GB Kit, 2x16GB, 6000MHz | Purchased | DDR5 kit for MSI Z790 board |
| CPU Cooler | Noctua NH-U9S chromax.black | Purchased | LGA1700-compatible, 125mm tall, should fit GD07 |

---

# Existing Parts To Reuse

| Component | Existing Part | Reuse Status | Notes |
|---|---|---|---|
| Case | SilverStone GD07 | Reuse | ATX-compatible HTPC/server-style case |
| PSU | Corsair RM750e | Reuse | Should have enough wattage for the new build |
| GPU | GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD | Likely reuse | Slot-powered; useful for display and possible NVIDIA transcoding |
| OS Drive | 2.5-inch SATA SSD | Preserve | Contains Windows 10 and application install; boot this first by itself |
| Media Drives | 5x 3.5-inch SATA HDDs | Preserve | Do not format, initialize, or randomly reorder |
| SATA cabling | Existing SATA data/power cables | Reuse if good | Confirm enough cables for 6 SATA drives |
| Case fans | Existing case fans | Reuse initially | Reassess noise and airflow after rebuild |

---

# Known Compatibility Notes

## Motherboard / CPU / RAM

- MSI PRO Z790-A WiFi II is an LGA1700 DDR5 motherboard.
- Intel Core i5-14500 is an LGA1700 CPU.
- Lexar DDR5 RAM is compatible with the DDR5 board.
- Do not use the previously considered Corsair DDR4 kit with this board.

## Case Fit

- SilverStone GD07 supports ATX motherboards.
- Noctua NH-U9S is approximately 125mm tall.
- GD07 CPU cooler clearance is approximately 138mm.
- Cooler should fit with reasonable clearance.

## Storage Port Count

- The MSI PRO Z790-A WiFi II has 6 SATA ports.
- Current server requires exactly 6 SATA connections:
  - 1x SATA OS SSD
  - 5x SATA media HDDs
- There will be no spare SATA ports after reconnecting all existing drives.
- Future SATA expansion will require a PCIe SATA card or HBA.

## Power Supply

- Corsair RM750e should support the build.
- Confirm availability of:
  - 24-pin ATX motherboard cable
  - 8-pin CPU EPS cable
  - Enough SATA power connectors for 6 drives
- No PCIe GPU power cable needed for the confirmed GV-N3050WF2OC-6GD card
- Do not mix modular PSU cables from other power supplies.

---

# Immediate Work Items

## Before Parts Arrive

- [ ] Clear a safe workspace.
- [ ] Gather screwdrivers and small containers for screws.
- [ ] Find all Corsair RM750e modular cables.
- [ ] Confirm enough SATA power connectors for 6 drives.
- [ ] Confirm enough SATA data cables for 6 drives.
- [ ] Prepare labels for each storage drive.
- [ ] Prepare USB Windows installer or recovery media.
- [ ] Prepare another computer for downloading drivers if needed.
- [ ] Download motherboard manual and drivers.
- [ ] Download NVIDIA GPU driver installer.
- [ ] Download Intel chipset / LAN / Wi-Fi drivers if needed.

## When Parts Arrive

- [ ] Inspect motherboard box for shipping damage.
- [ ] Inspect CPU contact pads for damage or contamination.
- [ ] Confirm CPU is i5-14500 and not 14500F, 14500T, ES, or QS.
- [ ] Inspect RAM kit and confirm it is 2x16GB DDR5.
- [ ] Confirm Noctua cooler includes LGA1700 mounting hardware.
- [ ] Confirm Noctua cooler includes thermal paste.
- [ ] Keep all packaging until system is confirmed stable.
- [ ] Photograph part labels / serials for inventory.

---

# Pre-Disassembly Checklist

Before removing old hardware or moving drives:

- [ ] Photograph full interior of the existing server.
- [ ] Photograph motherboard connections.
- [ ] Photograph SATA data cable routing.
- [ ] Photograph SATA power cable routing.
- [ ] Photograph drive rack from multiple angles.
- [ ] Label OS SSD clearly as `OS-SSD`.
- [ ] Label each media HDD by physical bay position.
- [ ] Label SATA data cables if possible.
- [ ] Record which drive was connected to which SATA cable if still known.
- [ ] Do not remove or reorder drives until labeled.

Suggested labels:

| Label | Meaning |
|---|---|
| OS-SSD | Windows 10 boot/application SSD |
| HDD-L1 | Lower-left HDD |
| HDD-C1 | Center-right HDD |
| HDD-R1 | Right bay 1 |
| HDD-R2 | Right bay 2 |
| HDD-R3 | Right bay 3 |
| HDD-R4 | Right bay 4 |

---

# Assembly Plan

## Phase 1 — Bench / Minimal Assembly

Install only:

- Motherboard
- CPU
- CPU cooler
- RAM
- PSU connections
- GPU only if needed for display
- OS SSD only

Do **not** connect media HDDs yet.

Checklist:

- [ ] Install CPU carefully in LGA1700 socket.
- [ ] Install RAM in recommended two-stick slots from motherboard manual.
- [ ] Install Noctua LGA1700 mounting hardware.
- [ ] Apply thermal paste if cooler does not have pre-applied paste.
- [ ] Install cooler and connect CPU fan to CPU_FAN header.
- [ ] Connect 24-pin ATX motherboard power.
- [ ] Connect 8-pin CPU EPS power.
- [ ] Connect GPU if needed.
- [ ] Connect OS SSD only.
- [ ] Connect keyboard, mouse, monitor, and Ethernet.

## Phase 2 — First Power-On / BIOS

- [ ] Confirm system powers on.
- [ ] Confirm CPU fan spins.
- [ ] Enter BIOS/UEFI.
- [ ] Confirm CPU detected as Intel Core i5-14500.
- [ ] Confirm 32GB RAM detected.
- [ ] Confirm OS SSD detected.
- [ ] Confirm CPU temperature is reasonable in BIOS.
- [ ] Set boot order to Windows Boot Manager / OS SSD.
- [ ] Leave XMP disabled initially for first stability test.
- [ ] Save BIOS settings.

## Phase 3 — First Windows Boot With OS SSD Only

- [ ] Attempt to boot existing Windows 10 install.
- [ ] Allow Windows to detect new hardware.
- [ ] Do not launch Plex yet.
- [ ] Install chipset drivers.
- [ ] Install LAN / Wi-Fi drivers if needed.
- [ ] Install NVIDIA driver if GPU is installed.
- [ ] Check Device Manager for missing drivers.
- [ ] Confirm Ethernet / internet works.
- [ ] Confirm Windows activation status.
- [ ] Search OS SSD for Plex data folder.
- [ ] Back up Plex metadata if found before making major changes.

---

# Media Drive Reconnection Plan

Reconnect media HDDs only after Windows is stable with the OS SSD.

For each drive:

- [ ] Shut down fully.
- [ ] Connect one media HDD.
- [ ] Boot Windows.
- [ ] Open Disk Management.
- [ ] Confirm drive appears.
- [ ] Do not initialize or format any drive.
- [ ] Record assigned drive letter.
- [ ] Open drive and confirm folders are intact.
- [ ] Compare contents against expected Plex/Sonarr/Radarr paths.
- [ ] Correct drive letter if needed.
- [ ] Shut down and repeat for next drive.

Drive tracking table:

| Label | Physical Location | Model | Capacity | Old Drive Letter | New Drive Letter | Notes |
|---|---|---|---:|---|---|---|
| OS-SSD |  |  |  |  |  |  |
| HDD-L1 |  |  |  |  |  |  |
| HDD-C1 |  |  |  |  |  |  |
| HDD-R1 |  |  |  |  |  |  |
| HDD-R2 |  |  |  |  |  |  |
| HDD-R3 |  |  |  |  |  |  |
| HDD-R4 |  |  |  |  |  |  |

---

# Application Recovery Checklist

Do not allow applications to mass-reorganize, rescan destructively, or move files until drive letters are confirmed.

## Plex

- [ ] Confirm Plex Media Server data directory exists.
- [ ] Preserve `Preferences.xml` if found.
- [ ] Confirm Plex opens.
- [ ] Confirm libraries point to valid paths.
- [ ] Confirm movie library paths.
- [ ] Confirm TV library paths.
- [ ] Confirm any 4K-specific paths.
- [ ] Confirm hardware transcoding setting.
- [ ] Test local playback.
- [ ] Test remote access.
- [ ] Test one transcode.

## Sonarr

- [ ] Confirm Sonarr opens.
- [ ] Confirm root folders.
- [ ] Confirm download client settings.
- [ ] Confirm completed download handling.
- [ ] Do not mass-edit paths unless drive-letter restoration fails.

## Radarr

- [ ] Confirm Radarr opens.
- [ ] Confirm root folders.
- [ ] Confirm download client settings.
- [ ] Confirm completed download handling.
- [ ] Do not mass-edit paths unless drive-letter restoration fails.

## qBittorrent

- [ ] Confirm default save path.
- [ ] Confirm incomplete downloads path.
- [ ] Confirm completed downloads path.
- [ ] Confirm category paths.
- [ ] Do not resume all torrents until paths are confirmed.

## Jackett

- [ ] Confirm service/app opens.
- [ ] Confirm indexers remain configured.
- [ ] Test one indexer.

## Unpacker

- [ ] Confirm watched folders.
- [ ] Confirm extraction destination.
- [ ] Test on a small/non-critical file if needed.

---

# Noise / Cooling Checklist

Because the server sits in the room where TV is watched, quiet operation matters.

- [ ] Confirm CPU cooler fan is connected to CPU_FAN.
- [ ] Confirm case fans are connected.
- [ ] Confirm BIOS fan curves are not overly aggressive.
- [ ] Set CPU fan profile to quiet/standard initially.
- [ ] Set case fan profiles to quiet/standard initially.
- [ ] Monitor CPU temperature at idle.
- [ ] Monitor CPU temperature during Plex transcode test.
- [ ] Listen for bearing noise or fan whine.
- [ ] Replace noisy case fans later if needed.

---

# Known Risks

| Risk | Mitigation |
|---|---|
| Existing Windows install may not boot on new motherboard | Try repair boot first; preserve OS SSD before reinstalling |
| BIOS/driver issues after platform change | Install chipset, LAN, Wi-Fi, and GPU drivers after first boot |
| Drive letters may change | Reconnect drives incrementally and restore letters in Disk Management |
| Only 6 SATA ports available | Current drives fit exactly; add PCIe SATA/HBA card for future expansion |
| eBay CPU is open-box/OEM | Inspect and test quickly within return window |
| Plex metadata location unknown | Search OS SSD before reinstalling Plex |
| Modular PSU cable mismatch | Use only Corsair-compatible RM750e cables |
| Noise in TV room | Tune fan curves and consider replacing old case fans if needed |

---

# Do Not Do

- [ ] Do not format any media drive.
- [ ] Do not initialize any existing media drive in Disk Management.
- [ ] Do not reinstall Windows over the OS SSD before checking Plex metadata.
- [ ] Do not randomly reorder drives.
- [ ] Do not launch Plex/Sonarr/Radarr/qBittorrent before verifying drive letters.
- [ ] Do not mix modular PSU cables from another power supply.
- [ ] Do not assume the eBay CPU includes a cooler.
- [ ] Do not enable aggressive overclocking or unstable RAM settings during first boot.

---

# Post-Rebuild Documentation To Create

After rebuild succeeds, create/update these project files:

- [ ] Final component inventory.
- [ ] Drive inventory with model, serial, capacity, and drive letter.
- [ ] SATA port map.
- [ ] PSU cable map.
- [ ] Fan header map.
- [ ] Plex library path map.
- [ ] Sonarr root folder map.
- [ ] Radarr root folder map.
- [ ] qBittorrent category/path map.
- [ ] Jackett config notes.
- [ ] Unpacker config notes.
- [ ] BIOS settings notes.
- [ ] Driver versions installed.
- [ ] Plex hardware transcoding test result.
- [ ] Backup plan for Plex metadata.
- [ ] Backup plan for app configs.

---

# Final Purchased Build Summary

| Category | Part |
|---|---|
| Motherboard | MSI PRO Z790-A WiFi II |
| CPU | Intel Core i5-14500 SRN3T |
| RAM | Lexar Thor Z DDR5 32GB, 2x16GB, 6000MHz |
| CPU Cooler | Noctua NH-U9S chromax.black |
| Case | SilverStone GD07, reused |
| PSU | Corsair RM750e, reused |
| GPU | GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD, reused if needed |
| OS Storage | Existing 2.5-inch SATA SSD |
| Media Storage | Existing 5x 3.5-inch SATA HDDs |

---

# Next Action

Wait for parts to arrive, then perform a minimal first boot using only:

1. New motherboard
2. New CPU
3. New RAM
4. New CPU cooler
5. Existing PSU
6. Existing OS SSD
7. GPU only if needed for display

Do not reconnect media HDDs until the OS SSD boot path and Windows stability are confirmed.
