# Prowlarr

## Purpose

Prowlarr is the active indexer manager for the Docker media stack. It stores tracker/indexer configuration and syncs usable Torznab indexers to Sonarr and Radarr.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `prowlarr` |
| Image | `lscr.io/linuxserver/prowlarr:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\prowlarr` |
| Web UI | `http://localhost:9696` |
| Docker restart policy | `unless-stopped` |

## Reads From

| Source | Purpose |
|---|---|
| Torrent indexers / trackers | Search and RSS indexer data |
| Prowlarr config/database | Indexer definitions, app sync settings |
| Sonarr/Radarr APIs | Tests and syncs app connectivity |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Sonarr | Syncs TV indexers |
| Radarr | Syncs movie indexers |
| Prowlarr logs/database | Stores test results and indexer state |

## Operational Rules

- Treat tracker usernames, passwords, cookies, passkeys, invite/account details, API keys, and indexer URLs with embedded secrets as local secrets.
- Keep Prowlarr as the primary indexer layer.
- Use Jackett only when a specific legacy Jackett indexer behavior is needed.
- If Sonarr, Radarr, or Prowlarr API keys are regenerated, update both sides of the relationship: Prowlarr application links and the Prowlarr-backed Torznab indexers stored in Sonarr/Radarr.
- Do not copy tracker-specific secrets into repo docs, scripts, logs intended for git, commits, issues, or pull requests.

## Current Notes

- MoreThanTV was configured and synced to Sonarr/Radarr on 2026-05-24.
- Prowlarr indexer testing passed during the setup notes.
- On 2026-05-26, Prowlarr `config.xml` was repaired after NUL-byte corruption. Sonarr/Radarr application links and their Prowlarr-backed Torznab indexers were updated to match the new local API keys.
