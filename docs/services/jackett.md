# Jackett

## Purpose

Jackett is a legacy Torznab/indexer aggregation fallback. Prowlarr is the current active indexer manager. Keep Jackett disabled unless a specific old indexer requires Jackett-specific behavior.

## Deployment

| Item | Value |
|---|---|
| Deployment | Optional Docker container profile |
| Container name | `jackett` |
| Image | `lscr.io/linuxserver/jackett:latest` |
| Current pulled image | `v0.24.2527-ls18` |
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
- The `legacy-jackett` profile was started on 2026-05-31 to test SpeedCD as a fallback while Prowlarr SpeedCD grabs were failing.
- SpeedCD was configured in Jackett and Jackett search/test passed, but downloads were blocked by the same SpeedCD account restriction.
- After SpeedCD account download access was restored, SpeedCD worked directly through Prowlarr again. Jackett was stopped and remains unnecessary for active Sonarr/Radarr routing.
- Jackett config may exist locally because of the fallback test. Treat it as secret-bearing local state and do not commit Jackett config files.

## Update History

### 2026-09-03

- Pulled the latest LinuxServer Jackett image, `v0.24.2527-ls18`, for the optional `legacy-jackett` profile.
- Did not start or enable Jackett; Prowlarr remains the active indexer manager.
- Refreshed the local image to the newer upstream digest; the reported LinuxServer version remained `v0.24.2527-ls18`.
- Confirmed the existing Jackett container remained stopped after the refresh.
