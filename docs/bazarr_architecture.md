# Bazarr Architecture

## Purpose

Bazarr is the subtitle automation layer for the Plex media stack.

It does not choose or download media releases. Sonarr and Radarr manage TV/movie monitoring, release decisions, qBittorrent handoff, and imports. Bazarr syncs the resulting Sonarr/Radarr library metadata, applies subtitle language profiles, searches configured subtitle providers, and writes external subtitle files beside the media files.

## Current Role In The Stack

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `bazarr` |
| Image | `lscr.io/linuxserver/bazarr:latest` |
| Compose file | `docker-compose.media.yml` |
| Web UI | `http://localhost:6767` |
| Published port | `127.0.0.1:6767 -> 6767/tcp` |
| Config path | `C:\media-stack\config\bazarr` |
| Database | `C:\media-stack\config\bazarr\db\bazarr.db` |
| Startup mode | Docker Compose, `restart: unless-stopped` |

## Upstream Connections

Bazarr is configured to sync from both Arr applications over the Docker network.

| Source | Docker target | Purpose |
|---|---|---|
| Sonarr | `sonarr:8989` | Sync TV series, seasons, episodes, monitored state, file paths, and metadata for subtitle matching. |
| Radarr | `radarr:7878` | Sync movies, monitored state, file paths, and metadata for subtitle matching. |

Bazarr stores API keys for Sonarr/Radarr in its local config. Treat those as secrets. Do not copy them into repo docs, logs, commits, issues, or pull requests.

## Media Mounts

Bazarr sees the same organized media folders used by Sonarr/Radarr so it can inspect media and write subtitle files beside the video files.

| Media type | Container paths |
|---|---|
| TV | `/tv/tv1`, `/tv/tv2` |
| Movies | `/movies/movies1`, `/movies/movies2`, `/movies/movies3` |

Do not change these mappings or repair paths until Windows drive letters and root folders are confirmed.

## Subtitle Behavior

| Setting / Behavior | Current architecture |
|---|---|
| Default series subtitle handling | Enabled for newly synced series. |
| Default movie subtitle handling | Enabled for newly synced movies. |
| Language profile | `English` profile exists. |
| Embedded subtitles | Bazarr is allowed to consider embedded subtitles when deciding what is missing. |
| Subtitle upgrades | Enabled, subject to Bazarr scoring and provider availability. |
| Automatic missing-subtitle searches | Scheduled by Bazarr, but depends on enabled, healthy providers. |

Important: Bazarr can mark items as missing subtitles even when the video files are present. A missing count in Bazarr is about subtitle availability, not missing media files.

## Provider State

As of 2026-05-24, Bazarr is connected to Sonarr/Radarr and its health endpoint reports no app-level health issues.

Enabled providers:

| Provider | Why it is enabled | Credential state | Notes |
|---|---|---|---|
| `opensubtitlescom` | Broad, commonly used subtitle source and first provider to try for general TV/movie coverage. | Needs the user's OpenSubtitles.com credentials before relying on it. | Free accounts are rate-limited; avoid bulk searches until credentials and limits are understood. |
| `podnapisi` | Easy no-credential fallback provider supported by Bazarr. | No account configured or required in current Bazarr config. | Useful as a low-friction second source. |
| `subdl` | Common Bazarr provider with broad subtitle coverage and a simple API-key model. | API key configured locally in Bazarr on 2026-05-24. | Treat the key as a secret; do not copy it into repo files, logs, commits, issues, or pull requests. |

Recent history:

- Before providers were enabled, Bazarr logs repeatedly reported `All providers are throttled`.
- Provider throttles were reset after enabling `opensubtitlescom`, `podnapisi`, and `subdl`.
- TV and movie subtitle download history tables had no successful download history at the time of the initial inspection.

Conclusion: Bazarr is architecturally installed and has three enabled providers. It should not be considered fully proven until one controlled subtitle download test succeeds. OpenSubtitles credentials can still be added later if that provider should be used as a primary source.

## Safe Verification Procedure

Use read-only checks first:

- Confirm container status with `docker ps`.
- Open Bazarr at `http://localhost:6767`.
- Check Bazarr system status and health.
- Confirm Sonarr/Radarr versions appear in Bazarr status.
- Confirm the `English` language profile exists.
- Confirm provider list and provider credentials in the Bazarr UI.
- Review logs for provider throttling or authentication failures.

After provider setup:

- Add OpenSubtitles.com credentials in Bazarr if using `opensubtitlescom` as the primary provider.
- Test one manual subtitle search/download for a single known item.
- Confirm Bazarr writes the subtitle file next to the correct media file.
- Confirm Plex can see/use the subtitle if needed.
- Only then rely on scheduled automatic missing-subtitle searches.

Do not run bulk subtitle searches until provider credentials, rate limits, path mappings, and subtitle write behavior are confirmed.

## Troubleshooting Notes

| Symptom | Likely meaning | Next check |
|---|---|---|
| Bazarr is running but downloads nothing | Providers are missing, disabled, throttled, or failing authentication. | Check providers in Bazarr UI and logs. |
| Bazarr shows missing subtitles | Subtitle files are missing, not media files. | Inspect the item in Bazarr and verify profile/language settings. |
| Bazarr can sync items but cannot write subtitles | Media mounts or filesystem permissions may be wrong. | Verify container paths and perform one controlled write test. |
| Sonarr/Radarr versions do not appear in Bazarr status | Arr API link or Docker network target may be broken. | Check Bazarr Sonarr/Radarr settings and container network. |
| Plex does not show a new subtitle | Plex may need to refresh metadata for that item/library. | Confirm the subtitle file exists first; only refresh Plex after explicit confirmation. |

## Safety Rules

- Treat Bazarr, Sonarr, Radarr, and subtitle provider credentials as local secrets.
- Do not commit Bazarr config files, API keys, cookies, provider credentials, or logs containing secrets.
- Do not trigger bulk subtitle searches/downloads until provider setup and write behavior are confirmed.
- Do not repair media paths until drive letters and root folders are confirmed.
- Keep Bazarr path mappings aligned with Sonarr/Radarr Docker paths.
