# qBittorrent Startup And Path Validation

## Purpose

Use this note when validating native Windows qBittorrent after boot, crash recovery, drive reconnects, Docker restarts, WSL restarts, or storage work.

qBittorrent now runs natively on Windows. It is not a Docker Compose service.

For the broader drive-reconnect flow that also checks Windows drive letters and Docker media mounts, start with [drive_reconnect_validation_checklist.md](drive_reconnect_validation_checklist.md).

---

# Current Known-Good Paths

| Item | Value |
|---|---|
| Windows torrent root | `I:\torrentfiles` |
| Native incomplete path | `I:\torrentfiles\incomplete` |
| Native qBittorrent config | `%APPDATA%\qBittorrent\qBittorrent.ini` |
| Tracked conservative config | `C:\plex-server\config\qbittorrent\native-conservative\qBittorrent.ini` |
| Apply script | `C:\plex-server\tools\apply-native-qbit-conservative-config.ps1` |
| Web UI | `http://localhost:8080` |
| Torrent port | `6881/tcp` |
| Sonarr/Radarr Docker path | `/downloads`, mapped from `I:\torrentfiles` |

---

# Safe Startup Checklist

Run this before trusting downloads after boot, crash recovery, drive reconnects, Docker restarts, WSL restarts, or storage work.

- [ ] Confirm Windows sees the torrent root:

```powershell
Test-Path I:\torrentfiles
Get-PSDrive I
```

- [ ] Confirm the native incomplete folder exists:

```powershell
Test-Path I:\torrentfiles\incomplete
```

- [ ] Confirm native qBittorrent responds:

```powershell
Invoke-WebRequest http://127.0.0.1:8080 -UseBasicParsing
```

- [ ] Confirm the native qBittorrent save paths before trusting torrents:

```powershell
Get-Content $env:APPDATA\qBittorrent\qBittorrent.ini |
  Select-String 'DefaultSavePath|TempPath|SavePath'
```

- [ ] Confirm Docker-hosted import/extraction services see the real download root:

```powershell
docker exec sonarr sh -c "df -h /downloads"
docker exec radarr sh -c "df -h /downloads"
docker exec unpackerr sh -c "df -h /downloads"
```

Healthy Docker output should show `/downloads` mapped from `I:\` with multi-terabyte capacity. If it shows a tiny/full filesystem, fix Docker/WSL bind mounts before trusting Sonarr/Radarr imports or Unpackerr extraction.

---

# Recovery Procedure

## 1. Confirm The Host Drive

```powershell
Test-Path I:\torrentfiles
Get-PSDrive I
```

Do not proceed if `I:\torrentfiles` is missing. Restore the drive letter or drive visibility first.

## 2. Confirm Native qBittorrent

```powershell
Invoke-WebRequest http://127.0.0.1:8080 -UseBasicParsing
```

If the Web UI is not reachable, check whether `qbittorrent.exe` is running and start the native app from:

```powershell
C:\Program Files\qBittorrent\qbittorrent.exe
```

## 3. Confirm Arr/Unpackerr Container Paths

```powershell
docker exec sonarr sh -c "df -h /downloads"
docker exec radarr sh -c "df -h /downloads"
docker exec unpackerr sh -c "df -h /downloads"
```

If `/downloads` is wrong in these containers, restart Docker/WSL and recheck before trusting imports or extraction:

```powershell
wsl --shutdown
Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
docker info --format "{{.ServerVersion}}"
docker compose -f C:\plex-server\docker-compose.media.yml up -d
```

## 4. Repair Torrent States Only After Paths Are Correct

After `I:\torrentfiles` and the relevant `/downloads` mounts are correct, use qBittorrent's Web UI or API to recheck/start torrents if needed.

API example from the Windows host:

```powershell
$base = 'http://127.0.0.1:8080/api/v2/torrents'
Invoke-WebRequest "$base/recheck" -Method Post -Body @{ hashes = 'all' } -UseBasicParsing
Invoke-WebRequest "$base/start" -Method Post -Body @{ hashes = 'all' } -UseBasicParsing
```

Poll states:

```powershell
Invoke-RestMethod http://127.0.0.1:8080/api/v2/torrents/info |
  Group-Object state |
  Select-Object Name, Count
```

---

# Operational Rules

- qBittorrent is native Windows; do not add it back to Docker Compose unless the deployment model is explicitly changed.
- Sonarr and Radarr should use `host.docker.internal:8080` with remote path mapping `I:\torrentfiles\` to `/downloads/`.
- Do not start, stop, remove, delete, move, or recheck torrents until categories, save paths, incomplete paths, and root-folder mappings are confirmed.
- Treat Web UI credentials, API sessions, tracker URLs, passkeys, and temporary passwords as secrets.
