# Homarr

## Purpose

Homarr is the local dashboard for the Plex ecosystem. It provides one browser landing page for the services that operate, monitor, and support the media server.

Homarr does not acquire media, download torrents, import files, write subtitles, scan Plex libraries, or repair paths. It is an access and visibility layer over the existing stack.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `homarr` |
| Image | `ghcr.io/homarr-labs/homarr:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config/data path | `C:\media-stack\config\homarr` |
| Web UI | `http://localhost:7575` |
| Container port | `7575` |
| Host port variable | `HOMARR_PORT=7575` |
| Docker restart policy | `unless-stopped` |
| Added | 2026-06-01 |

Homarr follows the stack's `WEBUI_HOST_IP` binding. The current local `.env` uses `WEBUI_HOST_IP=0.0.0.0`, so Homarr may be reachable from the LAN if Windows Firewall and network routing allow it. Do not expose Homarr directly to the public internet.

## Current Configuration

| Item | Current decision |
|---|---|
| Docker socket mount | Not mounted |
| Media folders | Not mounted |
| Download folder | Not mounted |
| Service discovery | Manual dashboard apps and optional API integrations |
| Persistent app data | `C:\media-stack\config\homarr` |
| Encryption key | `HOMARR_SECRET_ENCRYPTION_KEY` in the ignored local `.env` |
| Temperature panels | Local iframe widgets from `http://127.0.0.1:8765` |

The Docker socket is intentionally not mounted in the recommended configuration. Homarr remains useful as a dashboard without being able to start, stop, restart, or remove containers.

## Reads From

| Source | Purpose |
|---|---|
| Homarr app database | Stores users, boards, app tiles, widgets, integrations, uploaded assets, and sessions |
| Docker network DNS | Reaches Docker services by container name when configured with internal URLs |
| `host.docker.internal` | Reaches native Windows Plex and native Windows qBittorrent from inside Docker |
| Optional service APIs | Adds richer widgets for supported apps after credentials are entered through Homarr |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| `C:\media-stack\config\homarr` | Persistent Homarr data |
| Browser clients | Serves the local dashboard UI |
| Optional service APIs | Reads status or metadata for widgets after explicit integration setup |

Homarr should not write to media folders, download folders, Plex libraries, Arr root folders, or qBittorrent save paths.

## Depends On

| Dependency | Why |
|---|---|
| Docker Desktop | Runs the container |
| `plex-media-stack` Docker network | Lets Homarr reach other Docker services by container name |
| Native Windows Plex endpoint | Dashboard link and optional status/API checks |
| Native Windows qBittorrent endpoint | Dashboard link and optional status/API checks |
| Local `.env` secret | Required for stable encrypted data storage across restarts |

## Dashboard App Plan

The `Plex` board is the configured home board for the current Homarr user. It was seeded on 2026-06-01 with these app tiles. Use the external URL for click-through behavior from a browser. Use the internal ping URL when Homarr supports a separate status or integration URL.

| App | External URL | Internal / ping URL | Notes |
|---|---|---|---|
| Plex | `http://localhost:32400/web` | `http://host.docker.internal:32400/identity` | Native Windows service |
| Sonarr | `http://localhost:8989` | `http://sonarr:8989` | Docker service |
| Radarr | `http://localhost:7878` | `http://radarr:7878` | Docker service |
| Prowlarr | `http://localhost:9696` | `http://prowlarr:9696` | Docker service |
| Bazarr | `http://localhost:6767` | `http://bazarr:6767` | Docker service |
| Tautulli | `http://localhost:8181` | `http://tautulli:8181` | Docker service |
| Uptime Kuma | `http://localhost:3001` | `http://uptime-kuma:3001` | Docker service |
| qBittorrent | `http://localhost:8080` | `http://host.docker.internal:8080` | Native Windows service |
| Jackett | `http://localhost:9117` | `http://jackett:9117` | Optional; only useful when `legacy-jackett` profile is intentionally running |

Unpackerr is not listed as a primary app tile because this deployment does not expose a normal Web UI for it. Track it through Docker status, logs, or a future controlled monitoring path.

## Optional Integrations

| Integration | Recommendation |
|---|---|
| Sonarr | Useful after Homarr first-run setup; store the API key only inside Homarr |
| Radarr | Useful after Homarr first-run setup; store the API key only inside Homarr |
| Prowlarr | Useful if Homarr widgets provide enough value; store the API key only inside Homarr |
| qBittorrent | Optional; avoid unless the widget value is worth storing Web UI credentials in Homarr |
| Plex | Optional; avoid storing the Plex token unless a Homarr widget requires it and the value is clear |
| Docker | Defer; do not mount the raw Docker socket in the default deployment |

Do not write API keys, Plex tokens, qBittorrent credentials, cookies, tracker URLs, passkeys, or invite/account details into this repository.

## Temperature Panels

The Plex board includes local iframe temperature widgets for CPU, GPU, and drive temperatures.

| Item | Value |
|---|---|
| Panel script | `C:\plex-server\tools\homarr-temperature-panel\start-temperature-panel.ps1` |
| Local URL | `http://127.0.0.1:8765` |
| Data source | `C:\plex-server\docs\crash_logs\thermal\latest-sensors.json` |
| Startup path | User Startup shortcut: `Plex Homarr Temperature Panel.lnk` |
| Homarr widgets | CPU temperature, GPU temperature, Drive temperatures |

The panel does not collect sensors itself. It reads the existing thermal logger snapshot and marks the display stale if the snapshot is older than five minutes. The existing thermal logger remains the source of truth for CPU, GPU, and SMART drive temperatures.

## Verification Snapshot

Verified on 2026-06-01:

| Check | Result |
|---|---|
| Compose render | Pass: `homarr` appears in `docker compose config --services` |
| Local config path | Pass: `C:\media-stack\config\homarr` exists with `db`, `redis`, and `trusted-certificates` folders |
| Container status | Pass: `homarr` is `Up` in `docker ps` |
| Web UI | Pass: `http://127.0.0.1:7575` returned HTTP 200 and title `Homarr` |
| First-run state | Homarr redirects to `/init` and asks to start setup |
| Docker socket | Pass: only `/appdata` is mounted; no `/var/run/docker.sock` mount is present |
| Stack health check | Pass: project health check reported no FAIL or WARN checks after Homarr was added |
| Dashboard board | Pass: `/boards/Plex` renders Plex, Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, qBittorrent, and Jackett tiles |
| Safe widget | Pass: `/boards/Plex` includes a no-secret Date and time widget |
| Temperature widgets | Pass: `/boards/Plex` includes CPU, GPU, and drive temperature iframe widgets |

Before seeding the board, the Homarr SQLite database was backed up under `C:\media-stack\config\homarr\db\backups`.

## Operational Rules

- Keep Homarr as a dashboard and visibility layer, not a remediation tool.
- Do not mount the raw Docker socket unless container management from Homarr is deliberately chosen later.
- If Docker visibility is desired later, prefer a socket proxy with tightly limited permissions.
- Keep the dashboard local/LAN only; do not port-forward it to the public internet.
- Store Homarr credentials, app integration secrets, and uploaded assets only in `C:\media-stack\config\homarr`.
- After boot, crash, Docker restart, WSL restart, or storage work, do not treat Homarr green tiles as proof that download/import paths are safe; still verify `I:\torrentfiles`, native qBittorrent paths, and `/downloads` inside Sonarr/Radarr/Unpackerr when media operations matter.

## Current Gaps

- Keep Docker socket integration disabled unless explicitly approved.
