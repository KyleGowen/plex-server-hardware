# FlareSolverr

## Purpose

FlareSolverr is a local Docker helper used by Prowlarr for tracker/indexer requests that require browser-backed Cloudflare challenge handling.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `flaresolverr` |
| Image | `ghcr.io/flaresolverr/flaresolverr:latest` |
| Current version | `3.5.0` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Web/API URL | `http://localhost:8191` |
| Docker restart policy | `unless-stopped` |

## Reads From

| Source | Purpose |
|---|---|
| Prowlarr | Receives tagged indexer proxy requests |
| Protected tracker/indexer sites | Fetches challenge-protected pages for Prowlarr |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Prowlarr | Returns solved page responses for indexed searches |
| Docker logs | Stores local operational status |

## Operational Rules

- Keep FlareSolverr local to the media stack; do not expose it publicly.
- Use it only for indexers that require it because browser-backed requests are heavier than normal Prowlarr requests.
- Do not store tracker credentials, cookies, passkeys, private URLs, or proxy-derived request details in repository docs.

## Current Notes

- Added on 2026-09-03 to support HD-Space, which returned `403 Forbidden` on direct Prowlarr search requests.
- Prowlarr proxy name: `FlareSolverr - HD-Space`.
- Prowlarr tag: `hd-space`.
- Verified FlareSolverr API status `ok`, version `3.5.0`.

## Update History

### 2026-09-03

- Added `flaresolverr` to `docker-compose.media.yml` using `ghcr.io/flaresolverr/flaresolverr:latest`.
- Started only the FlareSolverr container.
- Configured Prowlarr to use FlareSolverr for HD-Space via a dedicated tag.
- Verified HD-Space Prowlarr searches return results and Prowlarr health is clear.
