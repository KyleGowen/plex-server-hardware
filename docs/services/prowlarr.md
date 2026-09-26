# Prowlarr

## Purpose

Prowlarr is the active indexer manager for the Docker media stack. It stores tracker/indexer configuration and syncs usable Torznab indexers to Sonarr and Radarr.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `prowlarr` |
| Image | `lscr.io/linuxserver/prowlarr:latest` |
| Current version | `2.6.5.5623` (`2.6.5.5623-ls161`) |
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
| FlareSolverr | Tagged indexer proxy for trackers that present Cloudflare challenges |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Sonarr | Syncs TV indexers |
| Radarr | Syncs movie indexers |
| Prowlarr logs/database | Stores test results and indexer state |
| FlareSolverr | Sends tagged protected-indexer requests through a local browser-backed proxy |

## Operational Rules

- Treat tracker usernames, passwords, cookies, passkeys, invite/account details, API keys, and indexer URLs with embedded secrets as local secrets.
- Keep Prowlarr as the primary indexer layer.
- Use Jackett only when a specific legacy Jackett indexer behavior is needed.
- If Sonarr, Radarr, or Prowlarr API keys are regenerated, update both sides of the relationship: Prowlarr application links and the Prowlarr-backed Torznab indexers stored in Sonarr/Radarr.
- Do not copy tracker-specific secrets into repo docs, scripts, logs intended for git, commits, issues, or pull requests.
- Use FlareSolverr only for indexers that require it; keep direct indexers such as SpeedCD and RetroToon unproxied unless testing proves otherwise.

## Current Notes

- Current usable indexers: SpeedCD, RetroToon, and HD-Space.
- MoreThanTV is disabled in Prowlarr as of 2026-09-03 because it is expected to remain unavailable for the foreseeable future. Its saved indexer settings are preserved for possible future re-enable after validation.
- Current app sync targets: Sonarr and Radarr.
- HD-Space uses the Prowlarr tag `hd-space` and the Prowlarr indexer proxy `FlareSolverr - HD-Space`.
- MoreThanTV was configured and synced to Sonarr/Radarr on 2026-05-24.
- On 2026-05-26, Prowlarr `config.xml` was repaired after NUL-byte corruption. Sonarr/Radarr application links and their Prowlarr-backed Torznab indexers were updated to match the new local API keys.
- On 2026-05-31, SpeedCD caused a Sonarr search outage because searches succeeded but proxied torrent downloads returned an HTML account restriction page instead of valid `.torrent` content. After the SpeedCD account restriction was lifted, Prowlarr proxied download validation returned valid torrent data and SpeedCD was re-enabled for Sonarr/Radarr.
- Detailed outage notes are in `docs/indexer_outage_2026-05-31.md`.

## Update History

### 2026-09-21

- Updated `2.5.2.5491-ls159` to `2.6.5.5623-ls161`. Recreated only Prowlarr and passed service and stack health verification; the helper updated the version ledger.
- [Official release notes](https://github.com/Prowlarr/Prowlarr/releases/tag/v2.6.5.5623): hostname validation and Trusted Networks, download redirect and backup fixes, FlareSolverr error handling, and removal of the closed MoreThanTV indexer definition.

### 2026-09-14

- Updated image build `2.5.2.5491-ls158` to `2.5.2.5491-ls159`; application version unchanged. Recreated only Prowlarr and passed service and stack health verification.
- [Official image release](https://github.com/linuxserver/docker-prowlarr/releases/tag/2.5.2.5491-ls159) retains upstream version `2.5.2.5491`.

### 2026-09-03

- Updated the LinuxServer container from Prowlarr `2.4.0.5397` (`2.4.0.5397-ls149`) to `2.5.2.5491` (`2.5.2.5491-ls158`).
- Recreated the container with existing persistent configuration.
- Verified the stack health check passed after startup.
- Disabled MoreThanTV in Prowlarr and synced applications so Sonarr/Radarr use SpeedCD only until MoreThanTV recovery is proven.
- Added RetroToon as a Prowlarr Cardigann indexer, verified its Prowlarr test passed, and synced it to Sonarr/Radarr for RSS, automatic search, and interactive search.
- Added HD-Space as a Prowlarr Cardigann indexer. Initial search requests returned `403 Forbidden`, so FlareSolverr was added as a local Docker service and configured as a tagged Prowlarr indexer proxy for HD-Space only.
- Verified HD-Space searches return results through Prowlarr, all enabled Prowlarr indexers test healthy, and Sonarr/Radarr both have HD-Space synced for RSS, automatic search, and interactive search.

### 2026-06-15

- Updated the LinuxServer container from Prowlarr `2.3.5.5327` (`2.3.5.5327-ls147`) to `2.4.0.5397` (`2.4.0.5397-ls149`).
- Recreated only the Prowlarr container with the existing persistent configuration.
- Verified zero Prowlarr health issues after startup.
- Verified MoreThanTV and SpeedCD remain enabled and the Sonarr and Radarr application links remain configured for full sync.

### 2026-08-17

- Operational assumption changed: treat MoreThanTV as dead/unavailable until proven otherwise.
- Leave existing indexer configuration untouched unless explicitly asked to disable or remove it.
