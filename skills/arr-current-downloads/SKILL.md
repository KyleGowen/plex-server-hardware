---
name: arr-current-downloads
description: Report media currently downloading in Kyle's Plex Docker Arr stack. Use when the user asks what media is currently downloading, what is downloading now, current downloads, active downloads, or similar status checks. Only list downloads managed by the Arr media ecosystem such as Sonarr, Radarr, Lidarr, or Readarr; exclude unrelated qBittorrent items, uncategorized torrents, manual tracker downloads, and anything outside those media libraries.
---

# Arr Current Downloads

## Goal

Return a concise read-only report of Arr-managed media that is actively downloading right now.

## Hard Filter

Only list items that satisfy both conditions:

1. The item is actively downloading or queued/stalled for download.
2. The item is tracked by the Arr ecosystem, shown by an Arr queue entry or an Arr qBittorrent category.

Treat these qBittorrent categories as Arr-managed unless local config proves otherwise:

- `tv-sonarr`
- `sonarr`
- `radarr`
- `lidarr`
- `readarr`

Do not list:

- Uncategorized torrents.
- Non-Arr categories.
- Manual downloads that only happen to be media files.
- Tracker names, passkeys, announce URLs, magnet URLs, hashes, credentials, cookies, or API keys.
- Completed uploads/seeding items unless they are still in an active download state.

## Workflow

1. Prefer read-only MCP tools first:
   - Use `torrent_manager` only for listing/status if its login works.
   - Use `mcp_arr` queue tools when available to cross-check Sonarr/Radarr queues.
2. If MCP login fails, use the local qBittorrent Web API read-only.
   - Host-side API requests may be forbidden. In that case query from inside the `qbittorrent` container:

```powershell
docker exec qbittorrent sh -c "wget -qO- http://127.0.0.1:8080/api/v2/torrents/info"
```

3. Filter results to active download states:
   - `downloading`
   - `stalledDL`
   - `metaDL`
   - `forcedDL`
   - `queuedDL`
   - `checkingDL`
   - `allocating`
4. Filter the active results to Arr-managed categories only.
5. Present a small table with media name, Arr category, progress, speed, ETA, and status.
6. If no Arr-managed media is downloading, say so clearly and mention that unrelated or completed torrents were intentionally excluded.

## Helper Script

Use `scripts/Get-ArrCurrentDownloads.ps1` when a deterministic qBittorrent report is enough. It queries qBittorrent from inside the container, filters to active Arr-managed downloads, and emits safe JSON with no tracker URLs, hashes, magnets, or secrets.

Example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\Kyle\.codex\skills\arr-current-downloads\scripts\Get-ArrCurrentDownloads.ps1
```

## Output Style

Keep the answer short. Example:

```markdown
Currently downloading in the Arr stack:

| Media | Arr app | Progress | Speed | ETA | Status |
|---|---:|---:|---:|---:|---|
| Example.Movie.2026.2160p.WEB-DL | Radarr | 42.1% | 12.4 MB/s | 8 min | downloading |
```

If using raw qBittorrent categories, map `tv-sonarr` and `sonarr` to `Sonarr`, `radarr` to `Radarr`, `lidarr` to `Lidarr`, and `readarr` to `Readarr`.
