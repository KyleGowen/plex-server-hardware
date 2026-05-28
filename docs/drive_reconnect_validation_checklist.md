# Drive Reconnect Validation Checklist

## Purpose

Use this checklist after reconnecting drives, changing SATA power/data cables, booting after storage work, recovering from a crash, restarting Docker Desktop, or running `wsl --shutdown`.

The goal is to identify which layer is failing before trusting Sonarr, Radarr, qBittorrent, Bazarr, or Unpackerr.

Do not resume torrents, trigger searches, allow imports, or write subtitles until the Windows drive letters and Docker mounts both pass.

---

## Expected Critical Paths

| Layer | Expected path | Used by |
|---|---|---|
| Windows torrent root | `I:\torrentfiles` | qBittorrent download storage |
| Docker download mount | `/downloads` | qBittorrent, Sonarr, Radarr, Unpackerr |
| Windows TV 1 root | `J:\TV Shows` | Sonarr, Bazarr, Plex |
| Docker TV 1 mount | `/tv/tv1` | Sonarr, Bazarr |
| Windows TV 2 root | `H:\TV Shows` | Sonarr, Bazarr, Plex |
| Docker TV 2 mount | `/tv/tv2` | Sonarr, Bazarr |

Known bad Docker symptom:

| Bad mount | What it means |
|---|---|
| `/downloads` or `/tv/tv2` shows a tiny filesystem such as `137M`, often `100%` used | Docker captured a placeholder/fallback mount instead of the real Windows drive |

---

## 1. Confirm Windows Drive Letters First

Run this before looking at Sonarr, Radarr, or qBittorrent health.

```powershell
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
  Select-Object DeviceID, VolumeName, FileSystem,
    @{Name='SizeTiB';Expression={[math]::Round($_.Size / 1TB, 2)}},
    @{Name='FreeTiB';Expression={[math]::Round($_.FreeSpace / 1TB, 2)}} |
  Sort-Object DeviceID
```

Checklist:

- [ ] `I:` is present and is the intended torrent/download drive.
- [ ] `H:` is present if TV 2 is expected to be online.
- [ ] `J:` is present and is the intended TV 1 drive.
- [ ] Movie drives have the expected letters before trusting Radarr imports.
- [ ] No unexpected drive-letter swap is visible.

If this fails:

| Finding | Likely failing layer | Next action |
|---|---|---|
| `I:` is missing | Hardware, cabling, power, BIOS, or Windows disk detection | Do not trust qBittorrent; inspect the torrent drive connection and Windows Disk Management |
| `H:` is missing | Hardware, cabling, power, BIOS, or Windows disk detection | Do not trust `/tv/tv2`; block Sonarr/Bazarr writes under TV 2 |
| A media drive appears under the wrong letter | Windows volume assignment | Stop and confirm the intended drive letter before repairing app paths |

---

## 2. Confirm The Torrent Root Exists

```powershell
Test-Path I:\torrentfiles
Get-Item I:\torrentfiles
```

Checklist:

- [ ] `Test-Path I:\torrentfiles` returns `True`.
- [ ] `Get-Item` identifies a real directory, not a missing path error.

If this fails:

| Finding | Likely failing layer | Next action |
|---|---|---|
| `I:` exists but `I:\torrentfiles` is missing | Wrong drive letter or missing torrent root folder | Do not change qBittorrent paths yet; confirm the drive identity |
| `I:` does not exist | Hardware/Windows drive detection | Fix Windows visibility before Docker or qBittorrent troubleshooting |

---

## 3. Confirm Docker Is Seeing The Real Download Drive

Make sure the stack is up enough to inspect mounts:

```powershell
docker compose -f C:\plex-server\docker-compose.media.yml ps
```

Check the shared download mount from qBittorrent:

```powershell
docker exec qbittorrent sh -c "df -h /downloads /downloads/incomplete; test -d /downloads/incomplete && ls -ld /downloads /downloads/incomplete"
```

Optional cross-check from the other containers that depend on `/downloads`:

```powershell
docker exec sonarr sh -c "df -h /downloads"
docker exec radarr sh -c "df -h /downloads"
docker exec unpackerr sh -c "df -h /downloads"
```

Checklist:

- [ ] `/downloads` reports `I:\` or the real torrent drive mount.
- [ ] `/downloads` has multi-terabyte size/free space, not a tiny placeholder.
- [ ] `/downloads/incomplete` exists.
- [ ] Sonarr, Radarr, qBittorrent, and Unpackerr agree on the same healthy `/downloads` mount.

If this fails:

| Finding | Likely failing layer | Next action |
|---|---|---|
| Windows sees `I:\torrentfiles`, but Docker shows `/downloads` as tiny/full | Docker Desktop or WSL bind mount is stale | Use `wsl --shutdown`, restart Docker Desktop, then bring the compose stack back up |
| qBittorrent is `Up`, but `/downloads` is tiny/full | Docker mount, not qBittorrent itself | Do not keep restarting only qBittorrent |
| Sonarr/Radarr can open but `/downloads` is wrong | Shared Docker mount | Do not trust queues, imports, or download-client health yet |

Recovery command sequence for a stale Docker mount:

```powershell
wsl --shutdown
Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
docker info --format "{{.ServerVersion}}"
docker compose -f C:\plex-server\docker-compose.media.yml up -d
docker exec qbittorrent sh -c "df -h /downloads /downloads/incomplete"
```

---

## 4. Confirm `/tv/tv2` Is Not A Tiny Placeholder

Only run TV 2 checks if `H:` / TV 2 is expected to be connected.

```powershell
Test-Path "H:\TV Shows"
docker exec sonarr sh -c "df -h /tv/tv1 /tv/tv2 /downloads"
docker exec bazarr sh -c "df -h /tv/tv1 /tv/tv2"
```

Checklist:

- [ ] `Test-Path "H:\TV Shows"` returns `True`.
- [ ] Sonarr shows `/tv/tv2` mounted from `H:\` with multi-terabyte capacity.
- [ ] Bazarr shows `/tv/tv2` mounted from `H:\` with multi-terabyte capacity.
- [ ] `/tv/tv2` is not a tiny full placeholder filesystem.

If this fails:

| Finding | Likely failing layer | Next action |
|---|---|---|
| `H:\TV Shows` is missing | Hardware/Windows drive detection or drive-letter assignment | Do not import, move, rename, or subtitle-write under `/tv/tv2` |
| Windows sees `H:\TV Shows`, but Docker shows `/tv/tv2` as tiny/full | Docker Desktop or WSL bind mount is stale | Restart Docker/WSL and recheck before trusting Sonarr/Bazarr |
| `/tv/tv1` is healthy but `/tv/tv2` is tiny/full | TV 2-specific host path or mount problem | Treat TV 1 and TV 2 separately; do not assume all TV paths are safe |

---

## 5. Only After Mounts Pass, Trust The Apps

Do these only after sections 1 through 4 pass for the paths involved.

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Health/API checks are useful only after mounts are correct:

- [ ] qBittorrent can be trusted to show meaningful torrent states.
- [ ] Sonarr can be trusted to evaluate download-client and import state.
- [ ] Radarr can be trusted to evaluate download-client and import state.
- [ ] Unpackerr can be trusted to inspect completed downloads.
- [ ] Bazarr can be trusted to write subtitles only to confirmed healthy TV/movie mounts.

Do not treat a green Web UI as proof of storage health. A service can be running while its bind mount is wrong.

---

## Quick Diagnosis Matrix

| Windows drive letter | Windows root path | Docker mount | Service UI | Most likely problem |
|---|---|---|---|---|
| Missing | Missing | Tiny/full or unavailable | May still load | Drive/cable/power/Windows detection |
| Present | Missing | Wrong or tiny/full | May still load | Wrong drive letter or missing root folder |
| Present | Present | Tiny/full | May still load | Docker/WSL stale bind mount |
| Present | Present | Healthy | Service errors remain | App-specific queue, credentials, category, import, or database issue |

---

## Stop Conditions

Stop diagnosis and fix the lower layer first if any of these are true:

- [ ] `I:\torrentfiles` is missing.
- [ ] `/downloads` is tiny, full, or not mounted from `I:\`.
- [ ] `H:\TV Shows` is expected but missing.
- [ ] `/tv/tv2` is tiny, full, or not mounted from `H:\`.
- [ ] Any media drive appears under an unexpected drive letter.

Only after the relevant stop condition is cleared should Sonarr, Radarr, qBittorrent, Bazarr, or Unpackerr be treated as the component under test.
