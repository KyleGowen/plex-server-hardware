---
name: add-media-to-plex
description: Add requested media to Kyle's Plex ecosystem by using Radarr for movies and Sonarr for TV shows/series, then trigger the appropriate Arr search so qBittorrent attempts to download it. Use when the user asks to add a movie, film, show, series, season, or TV media to Plex, the Plex library, Radarr, Sonarr, or qBittorrent, including requests like "add the Minecraft movie from last year to Plex" or "add this series and search for it".
---

# Add Media to Plex

Use this skill to add wanted media to the local Plex ecosystem. Plex itself should not be mutated for acquisition; Radarr/Sonarr manage acquisition, qBittorrent downloads, and the ecosystem imports to Plex afterward.

## Safety

- Treat Arr API keys and qBittorrent credentials as secrets. Read them from local config/runtime state and do not print them.
- Use Radarr for movies and Sonarr for TV shows or series.
- Add media as monitored unless the user explicitly asks otherwise.
- For TV, monitor normal seasons by default and leave specials/season 0 unmonitored unless requested.
- Trigger an Arr search only when the user asks to add/search/download media, which this skill is designed to do.
- Do not refresh Plex libraries from this skill. Plex refreshes require separate explicit confirmation.
- If a download client fails, diagnose Radarr/Sonarr health and qBittorrent auth/connectivity before retrying search.
- If title, year, and media type are already clear, try the helper's Arr lookup first. Use `media-internet-search` before adding only when identity is ambiguous, current/future, remake/reboot-sensitive, collection/chronology-related, or the Arr lookup cannot select one confident match.

## Preferred Workflow

1. Classify the request:
   - Movie words: movie, film, documentary, TMDB, release year.
   - TV words: show, series, season, episode, TV, Sonarr.
   - If title, year, and type are explicit, proceed directly to the helper/Arr lookup.
   - If ambiguous, infer from title/year context when obvious; otherwise use `media-internet-search` or ask one concise question.
   - For current/future releases, collections, chronology, remakes/reboots, or ambiguous public identity checks, route through `media-internet-search` first.
2. Resolve the title through the correct Arr lookup endpoint.
   - Prefer exact year matches for movie requests such as "from last year".
   - Skip ambiguous matches instead of adding the wrong remake or unrelated title.
3. Add or update the media:
   - Movies: Radarr, monitored true, quality profile `Ultra-HD` by default, root folder with the most free accessible space, `minimumAvailability: released` unless the user requests otherwise.
   - TV: Sonarr, monitored true, normal seasons monitored, season 0 unmonitored, use an existing sensible quality profile and root folder from Sonarr.
4. Trigger the Arr search command after the media exists:
   - Radarr: `MoviesSearch` with `movieIds`.
   - Sonarr: use the appropriate series search command for the added series.
5. Verify handoff:
   - Check the relevant Arr queue for the media title/id.
   - Report title, quality, state, client, size/progress when available.
   - If queued as `downloadClientUnavailable`, inspect health and qBittorrent connectivity before retrying.

## Helper Script

Prefer the bundled helper for the common case:

```powershell
tools\codex-skills\add-media-to-plex\scripts\Add-ArrMedia.ps1 -Type movie -Title "A Minecraft Movie" -Year 2025
tools\codex-skills\add-media-to-plex\scripts\Add-ArrMedia.ps1 -Type series -Title "Example Show" -Year 2024
```

The helper reads API keys from:

- `C:\media-stack\config\radarr\config.xml`
- `C:\media-stack\config\sonarr\config.xml`

It returns JSON with the selected match, add/update status, search command status, and queue matches. It does not print API keys or qBittorrent credentials.

If the helper fails because the Arr API schema differs, use the same workflow manually with raw JSON responses and explicit parsing. Avoid PowerShell formatted tables for health, queue, or status decisions.
