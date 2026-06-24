# Plex Collection Ledger

## Purpose

Route agents to the record for each Plex collection without loading the complete collection ledger into context. Collection-specific membership, missing or blacklisted titles, download status, poster provenance, and dates live in `collections/`.

## Agent Routing

- Find the exact Plex collection name in the index below.
- Load only that linked collection record for normal single-collection work.
- For cross-collection audits, load only the records needed for the requested comparison.
- Update the targeted record whenever tracked collection information changes; do not copy mutable details into this index.
- For a new collection, create `collections/<stable-lowercase-ascii-slug>.md` and add its exact Plex name and link to this index.

## Audit Basis

- First populated: 2026-06-05.
- Collection names, membership, Plex creation dates, and Plex update dates were read from the live local Plex HTTP API.
- Missing and waiting items were included only when supported by project documentation and a current read-only Radarr/Sonarr check.
- Poster provenance was copied only from documented, verified collection work. `Unknown` means Plex has collection artwork but the applied set/source is not documented.
- No explicit movie or TV blacklist records were found in the available project docs or current thread history. Intentionally excluded or optional titles were not relabeled as blacklisted.

## Conventions

- Keep the exact Plex collection name as the record heading and index label.
- Use one record file per collection and `YYYY-MM-DD` dates.
- `Created at` is the earliest live Plex creation date for same-name section-local collections.
- `Updated at` is the date that collection record was last reconciled.
- `Plex records` preserves section-specific rating keys and Plex timestamps.
- Use `Unknown` when a category has not been conclusively audited.
- Preserve each record file and index link when renaming or reorganizing; do not silently merge same-name section-local Plex records.

## Collection Index

| Exact Plex collection name | Record |
|---|---|
| 28 Days Later Collection | [`collections/28-days-later-collection.md`](collections/28-days-later-collection.md) |
| Alien vs. Predator Universe | [`collections/alien-vs-predator-universe.md`](collections/alien-vs-predator-universe.md) |
| Avatar Collection | [`collections/avatar-collection.md`](collections/avatar-collection.md) |
| Back to the Future Collection | [`collections/back-to-the-future-collection.md`](collections/back-to-the-future-collection.md) |
| Batman Collection | [`collections/batman-collection.md`](collections/batman-collection.md) |
| BBC / Attenborough Nature | [`collections/bbc-attenborough-nature.md`](collections/bbc-attenborough-nature.md) |
| Beavis and Butt-Head Collection | [`collections/beavis-and-butt-head-collection.md`](collections/beavis-and-butt-head-collection.md) |
| DC Animated / Batman TV | [`collections/dc-animated-batman-tv.md`](collections/dc-animated-batman-tv.md) |
| DC Animated Movies | [`collections/dc-animated-movies.md`](collections/dc-animated-movies.md) |
| DC Cinematic Universe | [`collections/dc-cinematic-universe.md`](collections/dc-cinematic-universe.md) |
| Descendants Collection | [`collections/descendants-collection.md`](collections/descendants-collection.md) |
| Disney Collection | [`collections/disney-collection.md`](collections/disney-collection.md) |
| Evil Dead Collection | [`collections/evil-dead-collection.md`](collections/evil-dead-collection.md) |
| Futurama Collection | [`collections/futurama-collection.md`](collections/futurama-collection.md) |
| Ghostbusters Collection | [`collections/ghostbusters-collection.md`](collections/ghostbusters-collection.md) |
| Harry Potter | [`collections/harry-potter.md`](collections/harry-potter.md) |
| Highlander Collection | [`collections/highlander-collection.md`](collections/highlander-collection.md) |
| Hotel Transylvania Collection | [`collections/hotel-transylvania-collection.md`](collections/hotel-transylvania-collection.md) |
| Jackass Collection | [`collections/jackass-collection.md`](collections/jackass-collection.md) |
| James Bond Collection | [`collections/james-bond-collection.md`](collections/james-bond-collection.md) |
| John Wick | [`collections/john-wick.md`](collections/john-wick.md) |
| Jurassic Park / Jurassic World | [`collections/jurassic-park-jurassic-world.md`](collections/jurassic-park-jurassic-world.md) |
| Kevin Smith / View Askewniverse | [`collections/kevin-smith-view-askewniverse.md`](collections/kevin-smith-view-askewniverse.md) |
| Mad Max | [`collections/mad-max.md`](collections/mad-max.md) |
| Marvel Cinematic Universe | [`collections/marvel-cinematic-universe.md`](collections/marvel-cinematic-universe.md) |
| Marvel TV | [`collections/marvel-tv.md`](collections/marvel-tv.md) |
| Middle-earth | [`collections/middle-earth.md`](collections/middle-earth.md) |
| One Chicago | [`collections/one-chicago.md`](collections/one-chicago.md) |
| Pitch Perfect Collection | [`collections/pitch-perfect-collection.md`](collections/pitch-perfect-collection.md) |
| Shark Attack / Creature Features | [`collections/shark-attack-creature-features.md`](collections/shark-attack-creature-features.md) |
| Spider-Man Collection | [`collections/spider-man-collection.md`](collections/spider-man-collection.md) |
| Star Trek TV | [`collections/star-trek-tv.md`](collections/star-trek-tv.md) |
| Star Trek: Complete Collection | [`collections/star-trek-complete-collection.md`](collections/star-trek-complete-collection.md) |
| Star Wars Movies and Shows | [`collections/star-wars-movies-and-shows.md`](collections/star-wars-movies-and-shows.md) |
| Studio Ghibli | [`collections/studio-ghibli.md`](collections/studio-ghibli.md) |
| Teenage Mutant Ninja Turtles | [`collections/teenage-mutant-ninja-turtles.md`](collections/teenage-mutant-ninja-turtles.md) |
| The Matrix Collection | [`collections/the-matrix-collection.md`](collections/the-matrix-collection.md) |
| The Terminator Collection | [`collections/the-terminator-collection.md`](collections/the-terminator-collection.md) |
| Transformers Collection | [`collections/transformers-collection.md`](collections/transformers-collection.md) |
| Tremors Collection | [`collections/tremors-collection.md`](collections/tremors-collection.md) |
| Underworld | [`collections/underworld.md`](collections/underworld.md) |
