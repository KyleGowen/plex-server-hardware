# Jackett

## Purpose

Jackett is a legacy Torznab/indexer aggregation fallback. Prowlarr is the current active indexer manager. Keep Jackett disabled unless a specific old indexer requires Jackett-specific behavior.

## Deployment

| Item | Value |
|---|---|
| Deployment | Optional Docker container profile |
| Container name | `jackett` |
| Image | `lscr.io/linuxserver/jackett:latest` |
| Compose profile | `legacy-jackett` |
| Config path | `C:\media-stack\config\jackett` if enabled |
| Web UI | `http://localhost:9117` if enabled |
| Docker restart policy | `unless-stopped` when profile is active |

## Reads From

| Source | Purpose |
|---|---|
| Torrent indexers / trackers | Search/RSS data |
| Jackett config | Indexer definitions and API key |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Sonarr/Radarr, if configured | Provides Torznab feeds |
| Jackett config/logs | Stores indexer state and test results |

## Operational Rules

- Prefer Prowlarr for current Sonarr/Radarr indexer management.
- Enable Jackett only for a confirmed legacy need.
- Treat Jackett API keys, tracker credentials, cookies, passkeys, and tracker URLs with embedded secrets as local secrets.
- Do not commit Jackett config files or logs containing secrets.

## Current Gaps

- Jackett is not part of the active default stack.
- If enabled later, confirm indexers, app connections, and whether it duplicates Prowlarr behavior.
