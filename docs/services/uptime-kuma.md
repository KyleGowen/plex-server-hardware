# Uptime Kuma

## Purpose

Uptime Kuma is the local service health monitor for the Plex ecosystem. It checks whether Plex and the Docker media services are reachable, records uptime history, and can send notifications when services go down or recover.

It does not manage media, download torrents, import files, scan Plex libraries, repair paths, or restart services by itself unless explicit automation is added later.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `uptime-kuma` |
| Image | `louislam/uptime-kuma:1` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config/data path | `C:\media-stack\config\uptime-kuma` |
| Web UI | `http://localhost:3001` |
| Docker restart policy | `unless-stopped` |
| Added | 2026-05-25 |

Uptime Kuma is bound to localhost through `WEBUI_HOST_IP=127.0.0.1`, so the Web UI is available from the Plex server itself and is not intentionally exposed to the LAN or internet.

## Reads From

| Source | Purpose |
|---|---|
| HTTP/TCP endpoints | Checks whether monitored services respond |
| Docker network DNS | Reaches Docker services by container name, such as `sonarr`, `radarr`, and `qbittorrent` |
| `host.docker.internal` | Reaches native Windows Plex from inside Docker |
| Uptime Kuma database | Stores monitor configuration, status history, users, sessions, and notification settings |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| `C:\media-stack\config\uptime-kuma` | Persistent SQLite database, uploaded assets, screenshots, and runtime data |
| Notification providers, optional | Sends outage and recovery alerts after configured |
| Status pages, optional | Publishes selected monitor status if explicitly created |

## Depends On

| Dependency | Why |
|---|---|
| Docker Desktop | Runs the container |
| `plex-media-stack` Docker network | Lets Kuma reach other Docker services by container name |
| Native Windows Plex HTTP endpoint | Lets Kuma monitor Plex at `host.docker.internal:32400` |
| Stable Windows storage and Docker state | Helps avoid false alarms after crashes, Docker restarts, or stale WSL mounts |

## Monitors To Create

After first-run admin setup, create monitors with these targets:

| Monitor | Type | URL / Host | Expected Result |
|---|---|---|---|
| Plex | HTTP(s) | `http://host.docker.internal:32400/identity` | HTTP 200 |
| Sonarr | HTTP(s) | `http://sonarr:8989` | HTTP 200 |
| Radarr | HTTP(s) | `http://radarr:7878` | HTTP 200 or redirect |
| Prowlarr | HTTP(s) | `http://prowlarr:9696` | HTTP 200 |
| Bazarr | HTTP(s) | `http://bazarr:6767` | HTTP 200 |
| Tautulli | HTTP(s) | `http://tautulli:8181` | HTTP 200 or redirect |
| qBittorrent Web UI | HTTP(s) | `http://qbittorrent:8080` | HTTP 200 |

Do not store Plex tokens, Arr API keys, qBittorrent credentials, notification tokens, or webhook secrets in this repository. Uptime Kuma notification credentials belong only in its local config database.

## Verification Snapshot

Verified on 2026-05-25:

| Check | Result |
|---|---|
| Windows path `I:\torrentfiles` exists | Pass |
| qBittorrent `/downloads` mount | Pass: mounted as `I:\`, 19T size, 16T available |
| Container started from compose | Pass |
| Container health check | Pass: healthy |
| Local Web UI | Pass: `http://127.0.0.1:3001` returned HTTP 200 and title `Uptime Kuma` |
| Persistent data | Pass: `C:\media-stack\config\uptime-kuma\kuma.db` created |
| Docker DNS to Sonarr | Pass: `http://sonarr:8989` returned HTTP 200 |
| Docker DNS to Radarr | Pass: `http://radarr:7878` returned HTTP 302 |
| Docker DNS to Prowlarr | Pass: `http://prowlarr:9696` returned HTTP 200 |
| Docker DNS to Bazarr | Pass: `http://bazarr:6767` returned HTTP 200 |
| Docker DNS to Tautulli | Pass: `http://tautulli:8181` returned HTTP 303 |
| Docker DNS to qBittorrent | Pass: `http://qbittorrent:8080` returned HTTP 200 |
| Docker-to-native Plex | Pass: `http://host.docker.internal:32400/identity` returned HTTP 200 |

## Operational Rules

- Use Uptime Kuma for visibility and alerting, not as proof that the random crashing issue is solved.
- Treat outages after reboot, crash, Docker restart, WSL restart, or storage work as prompts to verify both `I:\torrentfiles` on Windows and `/downloads` inside qBittorrent before trusting media automation.
- Keep the Web UI on localhost unless remote access is deliberately designed and secured.
- Prefer notification-only behavior first. Do not add automatic restart/remediation hooks until the crash pattern is better understood.
- Keep monitor names plain and service-specific so status history is easy to compare with crash tracker notes.

## Current Gaps

- Complete first-run admin account setup in the Web UI.
- Add the monitors listed above after admin setup.
- Add notification provider only after choosing a destination and keeping its token secret.
- If desired, create a status page for local dashboard use only.
