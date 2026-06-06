---
name: plex-collection-curator
description: Build and maintain curated Plex collections for Kyle's media server. Use when the user asks to audit, create, update, fill, or posterize a Plex collection such as a franchise, studio, actor, universe, chronology, or themed set. Choose the smallest mode implied by the request; use complete mode only when the user explicitly asks for end-to-end collection, fill, and poster work.
---

# Plex Collection Curator

## Goal

Create or maintain Plex collections for Kyle's Windows-native Plex server. Choose the smallest mode implied by the user's wording. Use `complete` only when the user clearly asks for end-to-end collection creation/update plus missing-media fill and poster work.

Modes:

- `audit-only`: research and reconcile what exists/missing; no Plex or Arr mutations.
- `collection-only`: create/update Plex collection membership for already available library items; no missing-media fill and no poster work.
- `fill-missing`: add missing movies/series to Radarr/Sonarr and start searches after download-path checks.
- `posterize`: find/apply TPDb posters for the collection and matched items.
- `complete`: research, reconcile, update collection, fill missing media, and posterize. Use only when explicitly requested.

Read only the selected mode file under `references/modes/` when possible. Read `references/workflow.md` only for a full end-to-end task or when a mode file is insufficient.

The mode files include fast-path notes from prior local runs. Follow those before improvising manual API loops, especially for Radarr add/search verification and TPDb poster URL extraction.

## Credit-Saving Fast Paths

- For broad studio/franchise audits, fetch each relevant Plex section and Arr library once, then match locally by normalized title plus year. Avoid per-title Plex searches or MCP calls unless a title is ambiguous.
- For mixed movie/show collections, first list existing collection titles in both sections. Reuse the user's existing title exactly and create same-title section-local collections; Plex clients may not show TV children inside a movie-library collection view.
- Treat `Plex has file` plus `Radarr/Sonarr has no file` as a mismatch, not a missing item. Do not trigger duplicate downloads until the Arr path/import association is reconciled.
- For bulk Radarr fills, use one API inventory, add exact title/year matches in a loop, and trigger a single `MoviesSearch` command with all no-file movie ids. Use MCP one-title add/search tools only for small or ambiguous batches.
- For TPDb, prefer one known set page and extract all optimized image URLs from that HTML; avoid repeated web searches for each title.

## Non-Negotiables

- Treat Plex tokens, Arr API keys, cookies, and TPDb/login details as secrets. Never print, write, commit, or document them.
- Use `C:\plex-server\COLLECTIONS.md` as the collection index. Resolve the exact Plex collection name there, then load only the linked record under `C:\plex-server\collections\` for normal single-collection work.
- Record the exact collection name; movie and TV content; known missing and blacklisted titles; content waiting for download or ready to add; poster-set details; and created/updated dates when those fields are known or changed.
- Whenever collection membership changes, reconcile the movie/TV content and any affected missing, blacklisted, or waiting rows in the targeted collection record.
- Whenever a collection poster or poster set is applied or changed, record the set/style, creator/uploader, source URL when public, and notes in the targeted collection record.
- For a new collection, create `C:\plex-server\collections\<stable-lowercase-ascii-slug>.md` and add the exact Plex collection name and record link to `C:\plex-server\COLLECTIONS.md`.
- Preserve the entry's original `Created at` date and set `Updated at` to the current date whenever tracked information changes. Never store credentials, tokens, or private URLs there.
- Use Plex HTTP API directly. Do not use an unapproved Plex MCP server.
- Prefer read-only Plex checks before write actions.
- Plex collection creation/update, poster changes, and library scans are allowed when the user has asked for that work. For unrelated refreshes or broad repairs, confirm first.
- Missing-media fill requests imply starting Radarr `MoviesSearch` and Sonarr `SeriesSearch` after the required download-path safety check, unless the user explicitly asks for add-only behavior.
- Audit-only requests must not add media, trigger searches, or apply posters.
- Collection creation/update requests do not include TPDb poster work unless the user asks to posterize, apply posters, make it pretty, or run complete mode.
- Collection creation/update requests do not fill missing media unless the user asks to fill, add, search, download, complete, or acquire missing items.
- When adding to Sonarr, set `monitored: true`, monitor normal seasons, and leave specials/season 0 unmonitored unless requested.
- When adding to Radarr, set `monitored: true`.
- Confirm library root folders, drive letters, and path mappings before any path repair or import-path mutation.
- If qBittorrent/download state matters, verify native `I:\torrentfiles` and `/downloads` in Sonarr/Radarr before trusting downloads.

## Source Strategy

Use internet research for the master list only when the collection membership is not already locally defined or obvious. Use ThePosterDB research only for `posterize` or `complete`.

For public movie, TV, franchise, collection, release, chronology, title/year, or media identity research, use `media-internet-search` first and carry its sourced findings into this workflow.

Prefer:

- Official franchise/studio pages.
- Wikis or databases dedicated to the franchise, such as Xenopedia for Alien/Predator.
- Wikipedia or TMDb/IMDb only as cross-checks, not as the sole source when better sources exist.
- ThePosterDB/TPDb set pages with visible set membership, uploader, and poster counts/likes.

Summarize sources used in the final answer, but keep the list compact.

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
- For user-scoped fills, add only the explicitly approved titles. Keep audited-but-unapproved gaps in the report, not in Radarr/Sonarr.
- If the local add-media helper is used and PowerShell blocks script execution, rerun the same helper through `powershell -NoProfile -ExecutionPolicy Bypass -File ...`; this is process-scoped and avoids manual API fallback.
- Report what was added and what could not be confidently matched.

## TPDb Poster Strategy

Use this only for `posterize` or `complete`. Search TPDb for a coherent set by one uploader that covers as much of the collection as possible.

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

When a TPDb set/uploader has already been chosen, extract the set link and optimized image URLs from one TPDb poster page HTML and map them by nearby title/year text instead of running multiple searches.

## Final Response

Keep the final concise:

- Name the collection.
- Count items assigned.
- List major missing/unavailable items.
- State which TPDb set/uploader was applied.
- Confirm that the targeted collection record was updated, and mention an index update when a record was created or renamed; otherwise state why no tracked information changed.
- Mention if Radarr/Sonarr adds were made, whether Radarr/Sonarr searches were started, and any titles that did not grab an acceptable release.
- Mention any verification limitations.
