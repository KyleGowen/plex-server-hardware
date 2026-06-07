# Plex Collection Fill-Missing Mode

Use when the user asks to fill, add, search, download, acquire, or complete missing collection items.

1. Identify missing items from a compact master list and read-only Plex checks.
2. Check Radarr/Sonarr for existing monitored or unmonitored entries before adding.
3. Verify native `I:\torrentfiles` and Sonarr/Radarr `/downloads` point to the real download storage before triggering searches.
4. Add missing movies to Radarr and missing series to Sonarr as monitored.
5. Trigger searches only for newly added or already-present no-file items that the user explicitly approved.

Do not update Plex collection membership or posters unless the user asks for those actions.

## Fast Path Notes

- Prefer the local add-media helper for exact title/year adds. If normal script execution is blocked, run it with a process-scoped bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File 'tools\codex-skills\add-media-to-plex\scripts\Add-ArrMedia.ps1' -Type movie -Title 'Example Title' -Year 2007 -Compact
```

- Before triggering searches, keep the required download-path checks compact: `Test-Path I:\torrentfiles`, confirm Radarr/Sonarr `/downloads` inside Docker, and confirm remote path mapping from `I:\torrentfiles\` to `/downloads/`.
- For bulk Radarr fills, prefer one `/api/v3/movie` inventory, exact normalized title/year matching, API adds for unmatched titles, then one `MoviesSearch` command with all approved no-file movie ids.
- Do not POST a Radarr `/movie/lookup` result back to `/movie` unchanged. Lookup metadata can contain fields that the create endpoint rejects after PowerShell JSON serialization. Build a minimal create payload with `title`, `tmdbId`, `titleSlug`, `year`, `qualityProfileId`, `monitored`, `minimumAvailability`, `rootFolderPath`, `path`, `images`, and `addOptions`.
- If Radarr returns HTTP 400 while adding a movie, inspect recent `docker logs radarr` validation lines before changing matching or path logic. An error such as `The JSON value could not be converted to System.String. Path: $.alternateTitles[n].title` confirms lookup-payload replay/serialization failure; use the schema-safe minimal payload rather than removing alternate titles one at a time.
- If Plex has a file but Radarr says `hasFile: false`, stop treating that item as a gap. Report it as a Radarr path/import association mismatch unless the user explicitly asks to redownload.
- For Radarr verification, do not rely on `/movie?tmdbId=...` returning one record. If needed, call `/movie` and filter client-side by `tmdbId`, or use the helper's returned `tmdbId`/title and a compact queue check.
- After a Radarr `MoviesSearch`, `queueMatches: 0` with a completed command means Radarr accepted the search but did not grab a currently acceptable release.
