---
name: media-internet-search
description: Research public movie, film, TV show, series, season, episode, franchise, collection, release, cast/crew, chronology, production, title/year, and media identity facts on the internet. Use when media facts are ambiguous, current/future, collection-related, chronology-related, remake/reboot-sensitive, or need sourced public verification before Plex/Arr workflows act on them.
---

# Media Internet Search

Use this skill for public web research about movies, TV, franchises, collections, and release facts. Keep it read-only and hand results back to the main agent or the relevant Plex stack skill.

Do not use this skill for every exact add request. When the user already gives a clear title, year, and media type, let the Arr lookup helper resolve it first and come here only if the lookup is ambiguous or not confident.

## Safety

- Do not mutate Plex, Sonarr, Radarr, Prowlarr, Bazarr, qBittorrent, Jackett, Unpackerr, local files, or service settings.
- Do not trigger Arr searches, indexer searches, downloads, grabs, imports, refreshes, scans, torrent actions, or poster changes.
- Do not request, expose, quote, or store tracker credentials, passkeys, cookies, API keys, Plex tokens, magnet links, torrent hashes, invite details, or private tracker URLs.
- Use only public web sources and public metadata pages.
- If the user asks to add, search, or download media, resolve the media identity first, then hand back to `add-media-to-plex`.
- If the user asks to create, update, fill, posterize, or audit a Plex collection, research the media facts, then hand back to `plex-collection-curator`.

## Source Strategy

Prefer authoritative cross-checking:

1. Official franchise, studio, distributor, network, streamer, production, or press pages.
2. Dedicated databases or specialist sources such as TMDb, IMDb, TheTVDB, TVMaze, Letterboxd, Box Office Mojo, or trusted franchise wikis.
3. Wikipedia and general entertainment sites as corroboration, not the only source when stronger sources exist.

Use enough sources for the risk:

- For a simple title/year/type lookup, one authoritative source plus one corroborating source is usually enough.
- For collections, chronologies, remakes, reboots, disputed canon, or similarly named media, cross-check multiple sources and call out uncertainty.
- For current or future releases, verify dates against current public sources and include the source date or publication context when useful.

## Output Shape

Return compact, actionable findings:

- canonical title
- year, date range, or release date when relevant
- media type: movie, TV series, miniseries, season, episode, short, special, documentary, collection, or optional/related item
- useful IDs or links when available, such as TMDb, IMDb, TheTVDB, or TVMaze
- ambiguity notes, especially remakes, duplicate titles, alternate titles, regional titles, sequels, and similarly named works
- recommended next step for the main agent or skill
- source links used

For collections or watch orders, separate:

- core entries
- optional shorts, specials, documentaries, or extras
- remakes, reboots, spin-offs, crossovers, or loose thematic relatives
- unavailable, unreleased, disputed, or ambiguous entries

## Handoff Rules

- Hand off to `add-media-to-plex` only when the user explicitly asked to add, search, download, monitor, or request media in the local Plex ecosystem.
- Hand off to `plex-collection-curator` when the user asked for collection creation, collection updates, collection audit, missing-media fill, or poster work.
- Otherwise answer the media research question directly with sources.
