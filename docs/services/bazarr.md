# Bazarr

## Purpose

Bazarr is the subtitle automation layer. It syncs TV/movie metadata from Sonarr and Radarr, applies subtitle language profiles, searches configured subtitle providers, and writes external subtitle files beside media files.

Bazarr missing counts are about subtitles, not missing media files.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `bazarr` |
| Image | `lscr.io/linuxserver/bazarr:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\bazarr` |
| Database | `C:\media-stack\config\bazarr\db\bazarr.db` |
| Web UI | `http://localhost:6767` |
| Docker restart policy | `unless-stopped` |

## Reads From

| Source | Purpose |
|---|---|
| Sonarr at `sonarr:8989` | TV metadata, monitored state, paths, episode data |
| Radarr at `radarr:7878` | Movie metadata, monitored state, paths |
| TV/movie media folders | Inspects media and existing subtitle files |
| Subtitle providers | Searches subtitle candidates |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Media folders | Writes external subtitle files beside video files |
| Bazarr database/config | Stores language profiles, provider state, history |
| Plex, indirectly | Plex can later detect written subtitle files |

## Provider State

Enabled providers recorded during setup:

| Provider | Credential state | Notes |
|---|---|---|
| `opensubtitlescom` | Needs user credentials before relying on it as primary | Free accounts are rate-limited |
| `podnapisi` | No account configured or required in current notes | Fallback provider |
| `subdl` | API key configured locally | Treat key as secret |

## Operational Rules

- Do not run bulk subtitle searches until provider credentials, rate limits, path mappings, and write behavior are confirmed.
- Test one manual subtitle search/download for a single known item first.
- Confirm the subtitle file is written next to the correct media file.
- Do not write subtitles under `/tv/tv2` while `H:` / TV 2 is absent. On 2026-05-26 Docker showed `/tv/tv2` as a tiny full placeholder filesystem, not the intended TV drive.
- Do not refresh Plex for subtitle visibility without explicit confirmation.
- Keep Bazarr, Sonarr, Radarr, and provider credentials out of repo docs and logs.

## Current Gaps

- Add OpenSubtitles.com credentials if that provider should be primary.
- Complete one controlled subtitle download/write test.
- Decide the replacement/missing-drive plan for `H:` / TV 2 before any `/tv/tv2` subtitle write test.
- Confirm Plex subtitle visibility only after file existence is verified.
