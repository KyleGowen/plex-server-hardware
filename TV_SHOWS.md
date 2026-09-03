# Plex TV Show Ledger

## Purpose

Route agents to concise, show-specific records without loading the full TV library inventory. Each record tracks Plex and Sonarr identity, season completeness, missing media, poster provenance, useful research links, and operational matching notes.

## Agent Routing

- Find the exact Plex show title and year in the index below.
- Load only the linked record for normal single-show work.
- Update the record after poster changes, imports, missing-media changes, or completeness audits.
- Preserve `Created at`; it is the date the show was originally added to Plex.
- Set `Updated at` to the date the tracked information was last reconciled.
- Use live Plex and Sonarr data before changing availability or completeness claims.
- Do not store API keys, Plex tokens, credentials, private tracker URLs, magnets, torrent hashes, or other secrets.
- For a new show, create `tv-shows/<stable-lowercase-ascii-slug>.md` and add its exact Plex title, year, and record link here.

## Audit Basis

- First populated: 2026-06-08.
- Plex titles, years, rating keys, added dates, and external GUIDs were read from the live local Plex HTTP API.
- Sonarr identifiers, monitoring state, series status, and season completeness were read from the live local Sonarr API.
- Specials are tracked separately. Unmonitored specials do not count as ordinary missing media.
- Poster provenance is recorded only when the applied TPDb set and uploader were verified.

## Conventions

- Use one record per Plex show, distinguished by title and year.
- Use `YYYY-MM-DD` dates.
- Season totals reflect Sonarr's current episode and episode-file statistics.
- `Missing` means an expected monitored episode has no associated file in Sonarr.
- Record direct identifiers and research links, but never local credentials or private service URLs.

## TV Show Index

| Exact Plex title | Year | Record |
|---|---:|---|
| A.P. Bio | 2018 | [`tv-shows/ap-bio.md`](tv-shows/ap-bio.md) |
| A Science Odyssey | 1998 | [`tv-shows/a-science-odyssey.md`](tv-shows/a-science-odyssey.md) |
| Abbott Elementary | 2021 | [`tv-shows/abbott-elementary.md`](tv-shows/abbott-elementary.md) |
| Bob's Burgers | 2011 | [`tv-shows/bobs-burgers.md`](tv-shows/bobs-burgers.md) |
| Daredevil: Born Again | 2025 | [`tv-shows/daredevil-born-again.md`](tv-shows/daredevil-born-again.md) |
| Futurama | 1999 | [`tv-shows/futurama.md`](tv-shows/futurama.md) |
| High Potential | 2024 | [`tv-shows/high-potential.md`](tv-shows/high-potential.md) |
| INVINCIBLE (2021) | 2021 | [`tv-shows/invincible-2021.md`](tv-shows/invincible-2021.md) |
| It's Always Sunny in Philadelphia | 2005 | [`tv-shows/its-always-sunny-in-philadelphia.md`](tv-shows/its-always-sunny-in-philadelphia.md) |
| King of the Hill | 1997 | [`tv-shows/king-of-the-hill.md`](tv-shows/king-of-the-hill.md) |
| Life, Larry and the Pursuit of Unhappiness | 2026 | [`tv-shows/life-larry-and-the-pursuit-of-unhappiness.md`](tv-shows/life-larry-and-the-pursuit-of-unhappiness.md) |
| Rick and Morty | 2013 | [`tv-shows/rick-and-morty.md`](tv-shows/rick-and-morty.md) |
| Rise of the Teenage Mutant Ninja Turtles | 2018 | [`tv-shows/rise-of-the-teenage-mutant-ninja-turtles.md`](tv-shows/rise-of-the-teenage-mutant-ninja-turtles.md) |
| Tales of the Teenage Mutant Ninja Turtles | 2024 | [`tv-shows/tales-of-the-teenage-mutant-ninja-turtles.md`](tv-shows/tales-of-the-teenage-mutant-ninja-turtles.md) |
| Teenage Mutant Ninja Turtles | 1987 | [`tv-shows/teenage-mutant-ninja-turtles-1987.md`](tv-shows/teenage-mutant-ninja-turtles-1987.md) |
| Teenage Mutant Ninja Turtles (2012) | 2012 | [`tv-shows/teenage-mutant-ninja-turtles-2012.md`](tv-shows/teenage-mutant-ninja-turtles-2012.md) |
| The Bear | 2022 | [`tv-shows/the-bear.md`](tv-shows/the-bear.md) |
| The Boys | 2019 | [`tv-shows/the-boys.md`](tv-shows/the-boys.md) |
| VisionQuest | 2026 | [`tv-shows/visionquest.md`](tv-shows/visionquest.md) |
