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

Enabled providers recorded during setup and later validation:

| Provider | Credential state | Notes |
|---|---|---|
| `subdl` | API key configured locally | Verified working on 2026-05-31 with controlled downloads. Treat key as secret. |
| `opensubtitlescom` | Username/password configured locally | UI/API can temporarily show `Good`, but real searches have returned `AuthenticationError` / `ConfigurationError`. Do not rely on it until a successful download is verified. |
| `podnapisi` | No account configured or required in current notes | UI/API can temporarily show `Good`, but real searches have returned `ConnectionError` from inside Bazarr/Docker. Treat as unproven fallback. |

## Current Verified State

Last controlled validation: 2026-05-31.

| Check | Result |
|---|---|
| Bazarr Web UI | Reachable at `http://localhost:6767` |
| Sonarr/Radarr integration | Connected to `sonarr:8989` and `radarr:7878` |
| TV mounts | `/tv/tv1` from `J:\`, `/tv/tv2` from `H:\`, `/tv/tv3` from `G:\` verified healthy after reconnecting `J:` |
| Movie mounts | `/movies/movies1` from `D:\`, `/movies/movies2` from `F:\`, `/movies/movies3` from `E:\` verified healthy |
| Automatic sync/search settings | Sonarr/Radarr sync enabled; series/movie sync every 60 minutes; wanted subtitle searches every 6 hours; subtitle upgrades enabled |
| Controlled subtitle write | Passed via `subdl`; subtitles were written beside movie files and Bazarr missing counts dropped to `0` for tested items |
| Plex visibility | Not separately verified; Plex should detect sidecar subtitle files, but no Plex refresh was triggered |

Verified controlled downloads:

| Media | Provider | Written file |
|---|---|---|
| `Deathgasm` | `subdl` | `F:\Movies\Deathgasm (2015)\Deathgasm.2015.1080p.BluRay.x265.en.srt` |
| `Descendants` | `subdl` | `F:\Movies\Descendants (2015)\Descendants (2015) 1080p WEB-DL DD+ 5.1 x264-TrollHD.en.hi.srt` |
| `Descendants 3` | `subdl` | `F:\Movies\Descendants 3 (2019)\Descendants.3.2019.1080p.WEB-DL.X264.AC3-EVO.en.srt` |

## Operational Rules

- Do not run broad manual/bulk subtitle searches after boot, crash, Docker restart, WSL restart, or storage work until path mappings and provider state are confirmed.
- If provider state changes, test one manual subtitle search/download for a single known item before trusting broad automatic behavior.
- Confirm the subtitle file is written next to the correct media file.
- Do not write subtitles to any TV root until the matching Windows drive letter and Docker mount are verified after boot, crash, Docker restart, WSL restart, or storage work.
- TV roots are mounted as `/tv/tv1` from `J:\`, `/tv/tv2` from `H:\`, and `/tv/tv3` from `G:\`.
- Do not refresh Plex for subtitle visibility without explicit confirmation.
- Keep Bazarr, Sonarr, Radarr, and provider credentials out of repo docs and logs.

## Current Gaps

- Fix or replace OpenSubtitles.com provider auth before relying on it as a primary provider.
- Diagnose Podnapisi container/network connection failures if it should be used as a fallback provider.
- Continue verifying all TV root mounts before any `/tv/tv1`, `/tv/tv2`, or `/tv/tv3` subtitle write test.
- Confirm Plex subtitle visibility only after file existence is verified.
