# Prowlarr

## Purpose

Prowlarr is the active indexer manager for the Docker media stack. It stores tracker/indexer configuration and syncs usable Torznab indexers to Sonarr and Radarr.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `prowlarr` |
| Image | `lscr.io/linuxserver/prowlarr:latest` |
| Current version | `2.5.2.5491` (`2.5.2.5491-ls158`) |
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

- Current usable indexer assumption: SpeedCD only.
- Treat MoreThanTV as dead/unavailable as of 2026-08-17 unless fresh evidence shows it has recovered. It may still exist in config, but do not rely on it for searches or acquisition planning.
- Current app sync targets: Sonarr and Radarr.
- MoreThanTV was configured and synced to Sonarr/Radarr on 2026-05-24.
- On 2026-05-26, Prowlarr `config.xml` was repaired after NUL-byte corruption. Sonarr/Radarr application links and their Prowlarr-backed Torznab indexers were updated to match the new local API keys.
- On 2026-05-31, SpeedCD caused a Sonarr search outage because searches succeeded but proxied torrent downloads returned an HTML account restriction page instead of valid `.torrent` content. After the SpeedCD account restriction was lifted, Prowlarr proxied download validation returned valid torrent data and SpeedCD was re-enabled for Sonarr/Radarr.
- Detailed outage notes are in `docs/indexer_outage_2026-05-31.md`.

## Update History

### 2026-09-03

- Updated the LinuxServer container from Prowlarr `2.4.0.5397` (`2.4.0.5397-ls149`) to `2.5.2.5491` (`2.5.2.5491-ls158`).
- Recreated the container with existing persistent configuration.
- Verified the stack health check passed after startup.

### 2026-06-15

- Updated the LinuxServer container from Prowlarr `2.3.5.5327` (`2.3.5.5327-ls147`) to `2.4.0.5397` (`2.4.0.5397-ls149`).
- Recreated only the Prowlarr container with the existing persistent configuration.
- Verified zero Prowlarr health issues after startup.
- Verified MoreThanTV and SpeedCD remain enabled and the Sonarr and Radarr application links remain configured for full sync.

### 2026-08-17

- Operational assumption changed: treat MoreThanTV as dead/unavailable until proven otherwise.
- Leave existing indexer configuration untouched unless explicitly asked to disable or remove it.
