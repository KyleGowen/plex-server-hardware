# Unpackerr

## Purpose

Unpackerr extracts archived completed downloads so Sonarr and Radarr can import them. It does not choose releases, search indexers, or manage Plex libraries.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `unpackerr` |
| Image | `golift/unpackerr:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\unpackerr` |
| Web UI | None expected |
| Docker restart policy | `unless-stopped` |

## Reads From

| Source | Purpose |
|---|---|
| `/downloads` | Finds completed archived downloads |
| Sonarr API, when configured | Tracks TV imports and extraction decisions |
| Radarr API, when configured | Tracks movie imports and extraction decisions |
| Unpackerr config | App URLs, keys, extraction behavior |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| `/downloads` | Writes extracted files beside or within completed download paths |
| Sonarr/Radarr | Extracted files become available for import |
| Unpackerr logs | Extraction status and errors |

## Operational Rules

- Configure Sonarr/Radarr API URLs and keys before relying on extraction automation.
- Treat Arr API keys as secrets.
- Do not test on critical downloads first; use a small/non-critical archived item if a test is needed.
- Keep `/downloads` shared with qBittorrent, Sonarr, and Radarr to avoid remote path mapping issues.
- After Sonarr or Radarr API-key repair, update Unpackerr and confirm logs show one Sonarr server and one Radarr server. A running container is not enough.
- Keep commented example blocks fully commented; TOML duplicate keys can put Unpackerr into a restart loop.

## Current Gaps

- Confirm watched folders and extraction destination behavior with a small non-critical archived download once `/downloads` is healthy.
- As of the 2026-05-26 repair, Unpackerr logs showed one configured Sonarr server, one configured Radarr server, and an idle queue with zero failures.
