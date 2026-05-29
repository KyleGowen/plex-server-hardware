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
| AIDA64 Extreme MSI Edition | Motherboard, MOS/VRM-adjacent, PCH, fan RPM, and voltage sensors | Provides board and fan sensors that the open-source stack did not expose |
| smartmontools / smartctl | Serial-specific drive temperatures | Reports SMART drive temperatures directly by model and serial, avoiding duplicate-model ambiguity and AIDA64 trial masking |

Scheduled Tasks are the authoritative startup path. They start the GUI sensor sources first, then start the project logger after a short delay so AIDA64 and Core Temp have time to publish their shared-memory exports.

| Item | Current state |
|---|---|
| AIDA64 source task | `Plex Thermal AIDA64 Sensor Source` |
| Core Temp source task | `Plex Thermal Core Temp Source` |
| Logger task | `Plex Thermal Sensor Logger` |
| Run level | Highest for all three tasks |
| Trigger | At user logon |
| Logger delay | `30 seconds` |
| Logger script | `C:\plex-server\tools\thermal-logger\start-libre-thermal-logger.ps1` |
| Autostart installer | `C:\plex-server\tools\thermal-logger\install-thermal-logger-task.ps1` |
| AIDA64 export validator | `C:\plex-server\tools\thermal-logger\test-aida64-export.ps1` |
| Project log root | `C:\plex-server\docs\crash_logs\thermal` |
| Poll interval | `2 seconds` |
| SMART poll interval | `30 seconds` |
| Rotation | New files every `24 hours` |

The logger script name still includes `libre` because the scheduled task already uses that path, but the current script merges LibreHardwareMonitor, Core Temp, and AIDA64 readings.

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
| Motherboard/platform | Motherboard temperature, MOS temperature, PCH temperature, PCH diode temperature |
| Fans | CPU fan RPM and chassis fan RPMs |
| Storage | OS SSD and connected HDD temperatures via smartctl, labeled by serial number |
| Voltage rails | Numeric AIDA64 readings for major rails including `+12 V` and `+3.3 V` |

AIDA64 MSI/OEM output masks some duplicate values as `TRIAL`, but the primary overheating-diagnosis signals above are numeric in the checked sample.

Drive temperatures from smartctl use `hardware_type=Smartctl` and labels like `model [serial]`, for example the two `ST20000NM000H-3KV103` drives are distinguished as `ZYD02EQ2` and `ZYE00444`.

## Normal Operations

Check whether the thermal monitoring tasks are registered:

```powershell
Get-ScheduledTask -TaskName "Plex Thermal AIDA64 Sensor Source","Plex Thermal Core Temp Source","Plex Thermal Sensor Logger"
```

Install or repair the elevated autostart tasks from an administrator PowerShell:

```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\plex-server\tools\thermal-logger\install-thermal-logger-task.ps1
```

This command is safe to rerun after logger updates. It replaces the three thermal Scheduled Tasks and starts them in the correct order:

1. AIDA64 sensor source.
2. Core Temp sensor source.
3. Project thermal logger after a short delay.

Run a one-shot logger sample:

```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\plex-server\tools\thermal-logger\start-libre-thermal-logger.ps1 -Once
```

Validate AIDA64 export:

```powershell
PowerShell -NoProfile -ExecutionPolicy Bypass -File C:\plex-server\tools\thermal-logger\test-aida64-export.ps1
```

## AIDA64 Requirements

AIDA64 must be running and exporting sensor values for motherboard, fan, voltage, MOS, and PCH readings to appear.

Required AIDA64 setting:

1. Open AIDA64.
2. Go to `File` > `Preferences` > `Hardware Monitoring` > `External Applications`.
3. Enable `Shared Memory`, or enable writing sensor values to `Registry`.
4. Select the motherboard, voltage, and fan sensor entries that matter.
5. Keep AIDA64 running in the background.

The project logger reads:

| Export path | Name |
|---|---|
| Shared memory | `AIDA64_SensorValues` |
| Registry | `HKCU:\Software\FinalWire\AIDA64\SensorValues` |

## Post-Crash Agent Checklist

- Check `C:\plex-server\docs\crash_logs\thermal` for the newest `libre-sensors-*.csv` or `libre-sensors-*.jsonl`.
- Compare the final sensor timestamp to Event Viewer `Kernel-Power 41`, `EventLog 6008`, and `WHEA-Logger` timestamps.
- Look for CPU/GPU/storage temperature ramps, fan RPM drops, power spikes, voltage anomalies, or sudden sensor loss before the crash.
- Confirm `AIDA64Rows` remains greater than `0` with `test-aida64-export.ps1` if board/fan sensors are missing.
- If no thermal log exists, record that thermal logging was not active for that crash.
