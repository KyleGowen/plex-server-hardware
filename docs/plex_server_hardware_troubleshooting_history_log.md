# Plex Server Hardware — Troubleshooting History Log

## Purpose

This document records the troubleshooting steps already performed on the Plex server hardware so future diagnostics do not repeat previously tested actions.

Use this file as the historical repair log for the non-booting Plex server.

---

# System Configuration

| Component | Details |
|---|---|
| Motherboard | ASUS Sabertooth Z97 Mark II |
| PSU | Corsair RM750e |
| GPU | Gigabyte GeForce RTX |
| Platform | Intel Haswell / LGA1150 |
| RAM | DDR3 DIMMs |
| Cooling | Intel stock CPU cooler |
| Operating System | Windows 10, installed on dedicated SATA SSD |
| Plex Deployment | Native Windows install, not Docker |

---

# Original Failure Symptoms

## Initial State

- System previously worked normally.
- System suddenly stopped booting.
- No display output.
- Fans spin when powered on.
- Motherboard standby LED illuminated.
- No apparent POST process.
- No USB keyboard initialization.

---

# Diagnostic Observations

## Power Behavior

Observed:

- Motherboard standby power LED is active.
- CPU fan spins continuously.
- Some chassis fans spin.
- Lower chassis fans do **not** spin even though they are plugged into the motherboard.
- System remains powered indefinitely.
- No reboot loops observed.

## POST / BIOS Behavior

Observed:

- No motherboard Q-LED diagnostic activity observed.
- No POST indicators visible.
- No display signal.
- No USB keyboard initialization.
- USB keyboard lock keys are non-responsive.

## Thermal Observations

Observed:

- CPU heatsink area remains cold.
- No noticeable CPU warming after several minutes powered on.

---

# Troubleshooting Steps Already Attempted

## 1. GPU Removal Test

Action:

- Removed the Gigabyte RTX GPU completely.

Purpose:

- Test onboard graphics path.
- Eliminate GPU failure as a POST blocker.

Result:

- No change.
- No display.
- No POST behavior.

---

## 2. GPU Reinstallation

Actions:

- Reinstalled the Gigabyte RTX GPU.
- Verified GPU seating.

Observation:

- GPU appears slot-powered only.
- No external PCIe power connector was observed on the card.

Purpose:

- Restore graphics output path.
- Confirm whether GPU presence changes boot behavior.

Result:

- No change.
- No display output.

---

## 3. RAM Slot Verification

Initial observation:

- RAM was installed in the A1 slot, closest to the CPU.

Action:

- Moved RAM to the A2 slot, the recommended single-stick slot for many ASUS boards.

Purpose:

- Correct possible single-DIMM memory training configuration.

Result:

- No change.

---

## 4. RAM Stick Isolation Testing

Actions:

- Tested one RAM stick at a time.
- Tested alternate RAM stick.
- Reseated DIMMs multiple times.

Purpose:

- Eliminate failed DIMM.
- Eliminate memory training issue.

Result:

- No change.

---

## 5. CMOS Reset Procedure

Actions:

- Powered system off.
- Removed power cable.
- Removed CMOS battery.
- Held power button for discharge.
- Waited several minutes.
- Reinstalled battery.

Purpose:

- Clear corrupted BIOS/UEFI settings.
- Reset memory training state.

Result:

- No change.

---

## 6. CMOS Battery Replacement

Action:

- Installed replacement CR2032 CMOS battery.

Purpose:

- Eliminate dead CMOS battery as a cause.

Result:

- No change.

---

## 7. USB Keyboard Initialization Test

Action:

- Connected USB keyboard directly to motherboard.

Purpose:

- Determine whether POST reaches USB initialization stage.

Result:

- Keyboard completely unresponsive.
- No lock-key activity.
- No USB initialization observed.

---

## 8. ATX Motherboard Power Cable Reseating

Action:

- Reseated 24-pin motherboard power connector.

Purpose:

- Eliminate loose ATX power connection.

Result:

- No change.

---

## 9. CPU EPS Power Cable Reseating

Action:

- Reseated 8-pin CPU EPS connector.

Purpose:

- Eliminate loose CPU power delivery connection.

Result:

- No change.

---

## 10. SATA / Peripheral Removal

Actions:

- Removed extraneous SATA cables.
- Moved disconnected SATA cables out of the way.
- Reduced unnecessary connected hardware.

Purpose:

- Eliminate shorted peripheral.
- Eliminate failed storage device as a boot blocker.
- Simplify system to near-minimal hardware state.

Result:

- No change.

---

## 11. Dust Cleaning / Visual Inspection

Actions:

- Cleaned internal dust buildup.
- Performed visual inspection.

Observations:

- No visibly blown capacitors observed.
- No obvious scorch marks observed.
- No visible catastrophic damage observed.

Result:

- No change.

---

# Additional Findings

## Fan Header Behavior

Observed:

- CPU fan spins normally.
- Some chassis fans spin.
- Lower motherboard-controlled chassis fans do not spin.

Interpretation:

- The board has partial power behavior, but not normal initialization behavior.
- Non-responsive lower chassis fans may indicate motherboard fan-control, Super I/O, or board-level control subsystem failure.

## Storage / Cabling Context

Observed from the hardware inspection:

- SATA storage rack is present.
- OS appears to be on a dedicated 2.5-inch SATA SSD.
- Multiple 3.5-inch SATA HDDs are installed for media storage.
- Most extraneous SATA cables were disconnected during diagnostics.

Important note:

- Storage was not treated as the likely cause of the current no-POST behavior.
- Do not format, initialize, or reorder storage drives during rebuild unless absolutely necessary.

---

# Final Diagnostic Assessment

## Most Likely Failure

Motherboard failure on the ASUS Sabertooth Z97 Mark II.

## Most Likely Failed Subsystems

- CPU VRM / motherboard power delivery.
- BIOS / UEFI subsystem.
- Chipset / PCH initialization.
- Super I/O controller.
- Motherboard fan/control circuitry.

## Components Likely Still Functional

- Corsair RM750e PSU.
- Gigabyte RTX GPU.
- DDR3 RAM.
- SATA HDD media drives.
- SATA OS SSD.
- Possibly the Intel CPU.

---

# Recommended Future Actions

## Option 1 — Replace Motherboard Only

Acquire a compatible replacement:

- LGA1150 motherboard.
- Z97 or H97 chipset board.

Reuse:

- Existing CPU.
- Existing DDR3 RAM.
- Existing GPU.
- Existing PSU.
- Existing storage.
- Existing case.

Risk:

- Used LGA1150 boards are old and may have limited future reliability.

---

## Option 2 — Modern Platform Upgrade

Replace:

- Motherboard.
- CPU.
- RAM.

Reuse:

- GPU.
- PSU.
- Storage drives.
- Case.

Benefits:

- Modern BIOS/UEFI.
- NVMe support.
- Lower power consumption.
- Improved Plex transcoding options.
- Better long-term reliability.
- Modern Intel Quick Sync option if using an appropriate Intel CPU.

---

# Tests That Should Not Be Repeated

These have already been completed with no behavioral changes observed:

- CMOS reset.
- CMOS battery replacement.
- RAM reseating.
- Single-stick RAM testing.
- GPU removal.
- GPU reinstallation.
- 24-pin ATX power cable reseating.
- 8-pin CPU EPS power cable reseating.
- SATA cable/peripheral removal.
- USB keyboard initialization test.
- Dust cleaning / basic visual inspection.

---

# Current Confidence Estimate

| Suspected Cause | Confidence |
|---|---|
| Motherboard failure | Very high |
| CPU failure | Low |
| PSU failure | Very low |
| RAM failure | Very low |
| GPU failure | Very low |
| Storage failure causing current no-POST state | Very low |

---

# Rebuild Reminder

Before rebuilding or migrating the machine:

1. Label the OS SSD separately.
2. Label every HDD by physical bay position.
3. Photograph SATA cable routing.
4. Boot the replacement system with only the OS SSD first.
5. Add media drives incrementally.
6. Restore original Windows drive letters before launching Plex, Sonarr, Radarr, qBittorrent, Jackett, or Unpacker.
7. Do not format or initialize any media drive unless it is confirmed blank.
