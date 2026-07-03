# qBittorrent

## Purpose

qBittorrent is the native Windows torrent download client for the media stack. Docker-hosted Sonarr and Radarr send approved releases to it through `host.docker.internal:8080`, and completed downloads are imported back into TV/movie folders through their `/downloads` bind mount.

## Current Deployment

As of `2026-05-30`, qBittorrent runs as a native Windows install. It is not part of Docker Compose.

| Item | Value |
|---|---|
| Deployment | Native Windows qBittorrent |
| Version | `5.2.2` |
| Executable | `C:\Program Files\qBittorrent\qbittorrent.exe` |
| Runtime config | `%APPDATA%\qBittorrent\qBittorrent.ini` |
| Tracked conservative config | `C:\plex-server\config\qbittorrent\native-conservative\qBittorrent.ini` |
| Apply script | `C:\plex-server\tools\apply-native-qbit-conservative-config.ps1` |
| Web UI | `http://localhost:8080` |
| Save path | `I:\torrentfiles` |
| Incomplete path | `I:\torrentfiles\incomplete` |
| Compose service | Removed; qBittorrent is native Windows only for current operations |

The tracked config intentionally omits `WebUI\Password_PBKDF2`. The apply script preserves the local WebUI password hash outside the repo.

## Maintenance Log

| Date | Note |
|---|---|
| `2026-07-03` | qBittorrent was reinstalled/updated to `5.2.2`. Reapplied the tracked conservative native profile with `C:\plex-server\tools\apply-native-qbit-conservative-config.ps1`; the local Web UI password hash was preserved. Confirmed native Web UI on `127.0.0.1:8080`, torrent TCP port `6881`, save path `I:\torrentfiles`, incomplete path `I:\torrentfiles\incomplete`, and Docker container access to native qBittorrent through `host.docker.internal:8080`. |

## Native Smoke Test

On `2026-05-30`, native qBittorrent completed a small public/legal download to `I:\torrentfiles\native-test`, writing about `123 MiB` with no checked WHEA, crash, disk, storage-controller, NIC, or TCP/IP errors during the test window. The first test torrent and temporary folder were removed afterward, and native qBittorrent remained running empty.

The same test was then repeated at user request and left in place. Native qBittorrent completed it again, and the completed public torrent remains in qBittorrent with payload under `I:\torrentfiles\native-test`.

Treat this as a functional smoke test, not as proof that long-running qBittorrent peer traffic is safe.

## Reads From

| Source | Purpose |
|---|---|
| Sonarr | TV download requests |
| Radarr | Movie download requests |
| Torrent swarms/trackers | Downloads content |
| qBittorrent config | Credentials, paths, categories, resume data |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| `I:\torrentfiles` | Default completed download path |
| `I:\torrentfiles\incomplete` | Incomplete download path |
| Sonarr/Radarr APIs | Queue/download status is read by Arr apps |
| Sonarr/Radarr/Unpackerr `/downloads` bind mount | Docker containers read the same Windows download root through `/downloads` |

## Categories

| Category | Used by |
|---|---|
| `tv-sonarr` | Sonarr |
| `radarr` | Radarr |

## Startup Path Rule

Verify native qBittorrent and the Windows torrent root directly:

```powershell
Test-Path I:\torrentfiles
Test-Path I:\torrentfiles\incomplete
Invoke-WebRequest http://127.0.0.1:8080 -UseBasicParsing
```

For Docker-hosted Sonarr/Radarr/Unpackerr, also verify the container-side `/downloads` bind mount when imports or extraction matter:

```powershell
Test-Path I:\torrentfiles
docker exec sonarr sh -c "df -h /downloads"
docker exec radarr sh -c "df -h /downloads"
docker exec unpackerr sh -c "df -h /downloads"
```

Healthy Docker output should show `/downloads` mounted from `I:\` with multi-terabyte capacity. If Docker reports a tiny full filesystem, restart Docker/WSL before trusting imports, but do not treat qBittorrent itself as a Docker container.

## Operational Rules

- Treat Web UI credentials, session cookies, tracker URLs, passkeys, hashes, and magnet links as secrets unless the user explicitly asks to inspect one locally.
- Do not start, stop, remove, delete, move, or recheck torrents until categories, save paths, incomplete paths, and root-folder mappings are confirmed.
- qBittorrent is native Windows. Do not run `docker exec qbittorrent`, configure Arr clients to `qbittorrent:8080`, or re-add qBittorrent to compose unless the deployment model is explicitly changed again.
- Sonarr and Radarr are configured to use native qBittorrent via `host.docker.internal:8080` with remote path mappings from `I:\torrentfiles\` to `/downloads/`.
- If `/downloads` is stale inside Sonarr/Radarr/Unpackerr, restart Docker/WSL and recheck those containers. Native qBittorrent can still be running correctly against `I:\torrentfiles`.
- Keep native qBittorrent Web UI exposure reviewed through Windows Firewall and qBittorrent settings.

## Current Gaps

- Confirm Web UI credentials are changed from defaults.
- Confirm category behavior with one controlled Sonarr/Radarr grab.
- Add a startup guard if desired so torrents do not resume before `I:\torrentfiles` is verified.
- Add or confirm a Windows Firewall rule limiting web UI exposure after `WEBUI_HOST_IP=0.0.0.0`.
