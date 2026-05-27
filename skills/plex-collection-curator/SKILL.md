---
name: plex-collection-curator
description: Build and maintain curated Plex collections for Kyle's media server. Use when the user asks to create, update, fill, posterize, or audit a Plex collection such as a franchise, studio, actor, universe, chronology, or themed set. The workflow researches a current source-backed master list, reconciles movies and TV shows against Plex, creates or updates Plex collections, finds missing library items, adds missing movies to Radarr and starts downloads by default, adds missing series to Sonarr and starts downloads by default, and applies matching The Poster Database posters to the collection and contained media.
---

# Plex Collection Curator

## Goal

Create complete, polished Plex collections for Kyle's Windows-native Plex server:

- Research the requested collection from reliable current sources.
- Include movies and TV shows when the franchise/universe/studio/theme calls for both.
- Reconcile the master list against Plex metadata and actual library folders.
- Create or update Plex collections and assign all matched Plex items.
- Add missing movies to Radarr and missing series to Sonarr, monitored by default. Start downloads for newly added missing media by default unless the user explicitly asks for add-only behavior.
- Find a popular, coherent The Poster Database (TPDb) poster set and apply posters to the collection and each item.

Read `references/workflow.md` when executing this skill.

## Non-Negotiables

- Treat Plex tokens, Arr API keys, cookies, and TPDb/login details as secrets. Never print, write, commit, or document them.
- Use Plex HTTP API directly. Do not use an unapproved Plex MCP server.
- Prefer read-only Plex checks before write actions.
- Plex collection creation/update, poster changes, and library scans are allowed when the user has asked for that work. For unrelated refreshes or broad repairs, confirm first.
- Missing-media fill requests imply starting Radarr `MoviesSearch` and Sonarr `SeriesSearch` after the required download-path safety check, unless the user explicitly asks for add-only behavior.
- When adding to Sonarr, set `monitored: true`, monitor normal seasons, and leave specials/season 0 unmonitored unless requested.
- When adding to Radarr, set `monitored: true`.
- Confirm library root folders, drive letters, and path mappings before any path repair or import-path mutation.
- If qBittorrent/download state matters, verify `I:\torrentfiles` and `/downloads` before trusting downloads.

## Source Strategy

Use internet research for the master list and TPDb poster selection because both change over time.

For public movie, TV, franchise, collection, release, chronology, title/year, or media identity research, use `media-internet-search` first and carry its sourced findings into this workflow.

Prefer:

- Official franchise/studio pages.
- Wikis or databases dedicated to the franchise, such as Xenopedia for Alien/Predator.
- Wikipedia or TMDb/IMDb only as cross-checks, not as the sole source when better sources exist.
- TPDb set pages with visible set membership, uploader, and poster counts/likes.

Always summarize which sources were used in the final answer.

## Plex Strategy

Use the local Plex token at runtime if available, such as:

- `C:\Users\Kyle\AppData\Local\Plex Media Server\.LocalAdminToken`

Never display the token.

Useful Plex endpoints:

- `GET /library/sections`
- `GET /library/sections/{section}/all?type=1` for movies
- `GET /library/sections/{section}/all?type=2` for shows
- `GET /search?query=...`
- `GET /library/metadata/{ratingKey}`
- `GET /library/metadata/{collectionKey}/children`
- `POST /library/collections?...` to create a collection
- `PUT /library/collections/{collectionKey}/items?uri=...` to set collection membership
- `POST /library/metadata/{ratingKey}/posters?url=...` to apply a poster
- `GET /library/sections/{section}/refresh?path=...` for targeted scans when already authorized by the task

For stubborn mismatches, inspect Plex's SQLite database read-only with:

`C:\Program Files\Plex\Plex Media Server\Plex SQLite.exe`

Check both metadata rows and `media_parts.file`. If files exist under Plex library roots but no metadata rows exist, run a targeted Plex scan for the exact folder when the user has requested collection completion.

## Arr Strategy

Try the configured `mcp_arr` server first for Sonarr/Radarr when available. If unavailable, fall back to local config files and documented Sonarr/Radarr HTTP APIs.

When adding missing media:

- Movies go to Radarr.
- Series go to Sonarr.
- Add monitored by default.
- Choose the existing root folder and quality profile that best matches local conventions; inspect existing items first.
- Trigger Radarr `MoviesSearch` for newly added missing movies and Sonarr `SeriesSearch` for newly added missing series by default after verifying qBittorrent storage is healthy.
- Report what was added and what could not be confidently matched.

## TPDb Poster Strategy

Search TPDb for a coherent set by one uploader that covers as much of the collection as possible.

Prefer poster sets that:

- Include collection poster plus item posters.
- Cover recent entries.
- Have high visible counts/likes or appear near top/search results.
- Link related sets, such as Alien and Predator sets by the same uploader.

If no single set covers everything:

- Use the best matching family of linked sets from one uploader.
- Fill gaps from visually compatible sets.
- Report gaps or substitutions.

Apply posters via Plex URL upload endpoints and verify `metadata_items.user_thumb_url` is populated for the collection and each item.

## Final Response

Keep the final concise:

- Name the collection.
- Count items assigned.
- List major missing/unavailable items.
- State which TPDb set/uploader was applied.
- Mention if Radarr/Sonarr adds were made, whether Radarr/Sonarr searches were started, and any titles that did not grab an acceptable release.
- Mention any verification limitations.
