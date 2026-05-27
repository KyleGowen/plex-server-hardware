# qBittorrent Startup And Recovery Notes

## Purpose

Use this note when qBittorrent starts while the torrent drive is disconnected, late-mounted, or mounted incorrectly through Docker Desktop.

The goal is to make sure qBittorrent always sees the real Windows torrent drive before torrents are allowed to resume.

---

# Current Known-Good Paths

| Item | Value |
|---|---|
| Windows torrent root | `I:\torrentfiles` |
| qBittorrent container path | `/downloads` |
| Incomplete path | `/downloads/incomplete` |
| qBittorrent config path | `C:\media-stack\config\qbittorrent` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Web UI | `http://localhost:8080` |
| Torrent port | `6881/tcp` and `6881/udp` |

Expected Docker view from inside the qBittorrent container:

```powershell
docker exec qbittorrent sh -c "df -h /downloads /downloads/incomplete"
```

Healthy output should show `I:\` with the real multi-terabyte capacity and free space. On 2026-05-25, the healthy view was approximately `19T` size, `2.7T` used, and `16T` available.

---

# 2026-05-25 Failure Mode

qBittorrent was started while `I:\torrentfiles` was not connected or not visible to Docker Desktop.

Symptoms:

- qBittorrent Web UI showed all torrents as errored.
- Torrent states included `error` and `missingFiles`.
- qBittorrent logs showed write failures such as `No space left on device`.
- Windows reported `I:\` had plenty of free space.
- Inside the container, Docker reported `/downloads` as a tiny full filesystem:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/sde        137M  126M     0 100% /downloads
```

Root cause:

- Docker Desktop had a stale or incorrect bind mount for `I:\torrentfiles`.
- Restarting only the qBittorrent container did not repair the bind mount.
- Recreating only the qBittorrent container also did not repair the bind mount.
- Restarting the Docker/WSL backend was required so Docker could remount the now-connected `I:` drive.

---

# Safe Startup Checklist

Run this before trusting qBittorrent after boot, drive reconnection, Docker restart, or hardware/storage work.

- [ ] Confirm Windows sees the torrent root:

```powershell
Test-Path I:\torrentfiles
Get-PSDrive I
```

- [ ] Confirm Docker is reachable:

```powershell
docker info --format "{{.ServerVersion}}"
```

- [ ] Confirm qBittorrent is running:

```powershell
docker ps --filter name=qbittorrent --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

- [ ] Confirm qBittorrent sees the real torrent drive, not a tiny full mount:

```powershell
docker exec qbittorrent sh -c "df -h /downloads /downloads/incomplete"
```

- [ ] Confirm `/downloads` maps to `I:\` and has multi-terabyte capacity/free space.
- [ ] Confirm `/downloads/incomplete` exists:

```powershell
docker exec qbittorrent sh -c "test -d /downloads/incomplete && ls -ld /downloads /downloads/incomplete"
```

- [ ] Only after the mount looks correct, inspect or start/recheck torrents.

---

# Recovery Procedure

Use this when qBittorrent shows torrent errors after the torrent drive was missing or late-mounted.

## 1. Confirm The Host Drive

```powershell
Test-Path I:\torrentfiles
Get-PSDrive I
```

Do not proceed if `I:\torrentfiles` is missing. Restore the drive letter first.

## 2. Check Docker's View

```powershell
docker exec qbittorrent sh -c "df -h /downloads /downloads/incomplete"
```

If `/downloads` shows a tiny filesystem such as `137M` at `100%`, the Docker bind mount is stale. Do not keep restarting qBittorrent; restart Docker/WSL.

## 3. Restart Docker/WSL Backend

```powershell
wsl --shutdown
Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
```

Wait for Docker:

```powershell
docker info --format "{{.ServerVersion}}"
```

Bring the media stack back up:

```powershell
docker compose -f C:\plex-server\docker-compose.media.yml up -d
```

## 4. Verify The Correct Mount

```powershell
docker exec qbittorrent sh -c "df -h /downloads /downloads/incomplete"
```

Expected: `/downloads` reports `I:\` with the real multi-terabyte capacity.

## 5. Repair Torrent States

After the mount is correct, use qBittorrent's API or Web UI to recheck and start torrents.

API example from inside the container, assuming local Web UI API access is available:

```powershell
docker exec qbittorrent python3 -c "import urllib.parse,urllib.request; base='http://127.0.0.1:8080/api/v2/torrents'; data=urllib.parse.urlencode({'hashes':'all'}).encode(); [print(ep, urllib.request.urlopen(urllib.request.Request(base+'/'+ep,data=data,method='POST'),timeout=20).status) for ep in ['recheck','start']]"
```

Then poll states:

```powershell
docker exec qbittorrent python3 -c "import json,urllib.request; data=json.load(urllib.request.urlopen('http://127.0.0.1:8080/api/v2/torrents/info',timeout=10)); summary={}; [summary.__setitem__(t['state'], summary.get(t['state'],0)+1) for t in data]; print(summary)"
```

Healthy recovery states include:

- `checkingDL`: qBittorrent is verifying files after the bad mount.
- `downloading`: torrent is actively downloading.
- `stalledDL`: torrent is waiting for peers but is no longer in a filesystem error state.
- `stalledUP` or `uploading`: torrent is complete/seeding.

Bad states that require more investigation:

- `error`
- `missingFiles`

## 6. Watch Logs For Real Blockers

```powershell
docker exec qbittorrent sh -c "tail -80 /config/qBittorrent/logs/qbittorrent.log"
```

Important log patterns:

| Log text | Meaning | Action |
|---|---|---|
| `No space left on device` while Windows has free space | Docker sees the wrong `/downloads` mount | Restart Docker/WSL backend and verify `df -h /downloads` |
| `fast resume rejected` / `mismatching file size` | qBittorrent must recheck after stale mount or partial files | Recheck torrents after mount is correct |
| `missingFiles` | qBittorrent cannot find expected files | Verify save path and recheck; inspect whether files were imported/moved |

---

# Startup Hardening Notes

- qBittorrent should not be trusted just because the container is `Up`.
- Always verify Docker's view of `/downloads` after a boot or drive reconnect.
- A plain `docker restart qbittorrent` is not enough if Docker Desktop already captured a bad bind mount.
- If Docker sees `/downloads` as a tiny full filesystem, use `wsl --shutdown`, start Docker Desktop, then bring the compose stack back up.
- Keep qBittorrent's save path as `/downloads/` and incomplete path as `/downloads/incomplete/`.
- Keep qBittorrent's internal WebUI bind as `WebUI\Address=0.0.0.0` in `C:\media-stack\config\qbittorrent\qBittorrent\qBittorrent.conf`. Docker host port forwarding to `8080` will not work if qBittorrent only listens on `127.0.0.1` inside the container.
- If qBittorrent starts and exits repeatedly with only `qBittorrent termination initiated` in the log, stop the container and remove stale `lockfile` and `ipc-socket` from `C:\media-stack\config\qbittorrent\qBittorrent`, then start qBittorrent again.
- Sonarr and Radarr should continue using Docker-network host `qbittorrent:8080` and shared `/downloads` paths. No remote path mapping should be needed when the Docker mount is healthy.
- Arr health and qBittorrent mount health are separate checks. Sonarr, Radarr, Prowlarr, Bazarr, and Unpackerr can all be running while `/downloads` is still the tiny full fallback filesystem.
- If Sonarr/Radarr/Prowlarr config files are rebuilt and API keys change, update dependent integrations before declaring the stack recovered: Prowlarr app links, Sonarr/Radarr Torznab indexers, Bazarr, and Unpackerr.
- The compose environment now uses `WEBUI_HOST_IP=0.0.0.0` to avoid repeated Docker Desktop localhost port-proxy failures after restart. Review Windows Firewall before treating these web UIs as safely local-only.
- Treat Web UI credentials, API sessions, tracker URLs, passkeys, and temporary passwords as secrets. Do not copy them into docs, commits, logs intended for git, or GitHub.
