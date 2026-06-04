# Plex Collection Curator Workflow

## 0. Select Mode

- `audit-only`: research and reconcile; no Plex or Arr writes.
- `collection-only`: create/update collection membership for available Plex items only.
- `fill-missing`: add missing media to Radarr/Sonarr and search after safety checks.
- `posterize`: apply TPDb posters to an existing or newly updated collection.
- `complete`: run all phases. Use only when the user explicitly requests end-to-end collection, fill, and poster work.

Choose the smallest mode implied by the user's wording. Prefer the short selected mode file under `references/modes/`; use this full workflow only for complete mode or when the short mode file lacks necessary detail. Skip phases that are outside the selected mode.

## 1. Research the Master List

1. Search the internet for the requested collection/franchise/studio/theme only when local data is not enough to identify the requested collection.
2. Build a table with:
   - canonical title
   - year
   - type: movie, show, special, short, optional/related
   - source URL
   - notes for ambiguous or disputed entries
3. Include movies and TV shows when applicable.
4. Separate core entries from optional shorts, documentaries, specials, or loose thematic relatives.

## 2. Discover Plex Libraries

1. Read Plex token at runtime and keep it secret.
2. Query `/library/sections`.
3. Identify movie and TV sections by type, not by assumed names.
4. For large collections, query each relevant section once and match locally by normalized title plus year. Use `/search` only for ambiguous, duplicate, or stubborn titles.
5. If API matching misses likely entries, query Plex SQLite read-only:

```sql
SELECT mi.id, mi.title, mi.original_title, mi.year, mi.metadata_type,
       mi.library_section_id, mp.file
FROM metadata_items mi
LEFT JOIN media_items m ON m.metadata_item_id = mi.id
LEFT JOIN media_parts mp ON mp.media_item_id = m.id
WHERE mi.library_section_id IN (...)
  AND (lower(mi.title) LIKE ... OR lower(mp.file) LIKE ...);
```

## 3. Check Disk Reality

When the user believes missing items exist, inspect library roots:

- Movie roots currently known from prior work: `D:\Movies`, `F:\Movies`
- TV roots currently known from prior work: `G:\TV Shows`, `H:\TV Shows`, `J:\TV Shows`

Use root discovery from Plex, not hard-coded assumptions, before acting.

If a file/folder exists but Plex lacks metadata:

1. Confirm it is under a Plex library root.
2. Check `.plexignore`.
3. Check active `/activities`.
4. Run a targeted scan for that exact folder when the user has asked to complete the collection.
5. Re-query Plex metadata after scan.

## 4. Create or Update Collection

Skip this section in `audit-only` and `fill-missing` modes unless the user also asked to update Plex collection membership.

For a normal manual collection:

1. Find existing collection by title under the relevant section.
2. If absent, create it with `POST /library/collections`.
3. Build a Plex URI:

`server://{machineIdentifier}/com.plexapp.plugins.library/library/metadata/{ratingKey1},{ratingKey2}`

4. Set membership:

`PUT /library/collections/{collectionKey}/items?uri={encodedUri}`

For mixed movie/show collections, maintain separate Plex collections per library section when Plex requires section-local collections. Before creating anything, list existing relevant collection titles in each section and reuse the title the user is already seeing. Same-title movie and TV collections are the most reliable Plex client behavior; some clients will not display TV children inside the movie collection view.

## 5. Missing Media Adds

Run this section only in `fill-missing` or `complete` mode.

For master-list entries not in Plex and not found on disk:

1. Check Radarr/Sonarr for existing monitored/unmonitored entries before adding.
2. If Plex has a file but Arr says `hasFile: false`, treat it as a path/import association mismatch and do not search it unless the user explicitly accepts duplicate-download risk.
3. Add missing movies to Radarr as monitored.
4. Add missing shows to Sonarr as monitored.
5. For Sonarr, monitor normal seasons and leave specials unmonitored unless requested.
6. Verify `I:\torrentfiles` exists for native qBittorrent and Sonarr/Radarr `/downloads` map to the real `I:\` multi-terabyte filesystem before triggering downloads.
7. For bulk Radarr fills, collect all exact title/year no-file ids and trigger one `MoviesSearch` command. For newly added Sonarr series, trigger `SeriesSearch` for each new series id.
8. If matching is ambiguous, skip and report rather than adding the wrong item.

## 6. TPDb Poster Application

Run this section only for `posterize` or `complete` mode.

1. Search ThePosterDB/TPDb for the collection name and key titles.
2. Prefer one uploader/set family with collection and item posters.
3. Extract JPEG URLs from TPDb HTML. The useful image URLs usually look like:

`https://images.theposterdb.com/prod/public/images/posters/optimized/...jpg`

4. Map poster titles to Plex rating keys, including the Plex collection rating key for the collection cover.
5. Apply:

`POST /library/metadata/{ratingKey}/posters?url={encodedPosterUrl}`

6. Verify with Plex SQLite:

```sql
SELECT id, title, year, user_thumb_url, updated_at
FROM metadata_items
WHERE id IN (...);
```

Every updated item should have a non-empty `user_thumb_url`, often starting with `upload://posters/`.

## 7. Report

Include:

- sources used for master list
- Plex collection count(s)
- targeted scans performed
- Radarr/Sonarr adds made
- TPDb uploader/set links
- any missing/ambiguous items skipped
