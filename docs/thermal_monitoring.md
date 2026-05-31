# Thermal Monitoring

## Purpose

Capture searchable hardware sensor logs for crash diagnosis on the Plex server.

Use these logs after hard resets, freezes, WHEA recurrences, Docker/WSL restarts, Plex transcode tests, qBittorrent/Sonarr load tests, or storage disappearance events.

## Current Architecture

The logger writes one combined evidence stream from three sensor sources:

| Source | Role | Why it stays |
|---|---|---|
| LibreHardwareMonitor | GPU, storage, memory, network, and general hardware sensors | Provides good open-source coverage for GPU and drive temperatures |
| Core Temp | Intel CPU core temperatures, CPU speed, CPU load, and CPU package power | Provides complete per-core CPU temperatures that LibreHardwareMonitor did not expose on this MSI Z790 system |
| smartmontools / smartctl | Serial-specific drive temperatures | Reports SMART drive temperatures directly by model and serial, avoiding duplicate-model ambiguity |

Scheduled Tasks are the authoritative startup path. They start Core Temp first, then start the project logger after a short delay so Core Temp has time to publish its shared-memory export.

| Item | Current state |
|---|---|
| Core Temp source task | `Plex Thermal Core Temp Source` |
| Logger task | `Plex Thermal Sensor Logger` |
| Run level | Highest for both tasks |
| Trigger | At user logon |
| Logger delay | `30 seconds` |
| Logger script | `C:\plex-server\tools\thermal-logger\start-libre-thermal-logger.ps1` |
| Autostart installer | `C:\plex-server\tools\thermal-logger\install-thermal-logger-task.ps1` |
| Project log root | `C:\plex-server\docs\crash_logs\thermal` |
| Poll interval | `2 seconds` |
| SMART poll interval | `30 seconds` |
| Rotation | New files every `24 hours` |

The logger script name still includes `libre` because the scheduled task already uses that path, but the current script merges LibreHardwareMonitor, Core Temp, and smartctl readings.

## Log Format

The logger writes long-form sensor records:

| File | Format | Purpose |
|---|---|---|
| `libre-sensors-*.csv` | One sensor reading per row | Spreadsheet and PowerShell searches |
| `libre-sensors-*.jsonl` | One sensor object per line | Fast text searches and agent parsing |
| `latest-sensors.json` | Last sample snapshot | Quick live-state inspection |
| `libre-thermal-logger-*.metadata.json` | Session metadata | Confirms logger settings and source paths |

Thermal log files are local runtime evidence and are ignored by git via `.gitignore`.

Each CSV row has:

```text
timestamp,hardware_type,hardware_name,sensor_type,sensor_name,value,unit
```

## Confirmed Coverage

Validated on 2026-05-29:

| Group | Confirmed readings |
|---|---|
| CPU | Per-core temperatures, CPU package temperature, CPU speed, CPU load, CPU package power |
| GPU | RTX 3050 temperature, hotspot temperature, fan RPM, power, load, clocks |
| Motherboard/platform | LibreHardwareMonitor board/platform readings when exposed by the system |
| Fans | Fan readings when exposed by LibreHardwareMonitor |
| Storage | OS SSD and connected HDD temperatures via smartctl, labeled by serial number |
| Voltage rails | Not currently captured by the active thermal logger |

Drive temperatures from smartctl use `hardware_type=Smartctl` and labels like `model [serial]`, for example the two `ST20000NM000H-3KV103` drives are distinguished as `ZYD02EQ2` and `ZYE00444`.

## Normal Operations

Check whether the thermal monitoring tasks are registered:

```powershell
Get-ScheduledTask -TaskName "Plex Thermal Core Temp Source","Plex Thermal Sensor Logger"
```

Install or repair the elevated autostart tasks from an administrator PowerShell:

```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\plex-server\tools\thermal-logger\install-thermal-logger-task.ps1
```

This command is safe to rerun after logger updates. It replaces the active thermal Scheduled Tasks and starts them in the correct order:

1. Core Temp sensor source.
2. Project thermal logger after a short delay.

Run a one-shot logger sample:

```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\plex-server\tools\thermal-logger\start-libre-thermal-logger.ps1 -Once
```

## Post-Crash Agent Checklist

- Check `C:\plex-server\docs\crash_logs\thermal` for the newest `libre-sensors-*.csv` or `libre-sensors-*.jsonl`.
- Compare the final sensor timestamp to Event Viewer `Kernel-Power 41`, `EventLog 6008`, and `WHEA-Logger` timestamps.
- Look for CPU/GPU/storage temperature ramps, fan RPM drops, power spikes, voltage anomalies, or sudden sensor loss before the crash.
- If no thermal log exists, record that thermal logging was not active for that crash.
