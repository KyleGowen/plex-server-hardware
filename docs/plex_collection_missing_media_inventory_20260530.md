# Plex Collection Missing-Media Inventory

Date: 2026-05-30

Initial audit mode: read-only audit plus proposed fill plan. During the initial audit, no Plex edits, Plex refreshes, Sonarr/Radarr adds, searches, qBittorrent actions, poster changes, path repairs, or drive-letter changes were performed.

## 2026-05-30 Fix Execution

Mode: user-authorized collection fixing and missing-media fill. Plex collection membership edits, Radarr/Sonarr adds, and Radarr/Sonarr searches were performed after confirming `I:\torrentfiles`, native qBittorrent download-client mappings, and `H:` availability.

| Area | Action | Result |
| --- | --- | --- |
| Plex Movies | Added `Iron Man` and `The Fantastic Four: First Steps` to `Marvel Cinematic Universe`. | Collection count is now 40. |
| Plex Movies | Added `Spider-Man` (2002) to `Spider-Man Collection`. | Collection count is now 14. |
| Plex TV | Added original `Beavis and Butt-Head` to `Beavis and Butt-Head Collection`. | Collection count is now 2. |
| Plex TV | Added `Hawkeye`, `Echo`, `I Am Groot`, `Eyes of Wakanda`, `Ms. Marvel`, and `Secret Invasion` to `Marvel Cinematic Universe`. | Collection count is now 24. |
| Plex TV | Added `Ms. Marvel` and `Secret Invasion` to `Marvel TV`. | Collection count is now 20. |
| Plex TV | Added `Star Trek: The Animated Series`, `Star Trek: Enterprise`, `Star Trek: Picard`, and `Star Trek: Prodigy` to `Star Trek TV`. | Collection count is now 12. |
| Radarr | Added `Evil Dead Rise` as monitored under `/movies/movies1/Movies/Evil Dead Rise (2023)`. | Radarr id `1096`; search included in batch. |
| Radarr | Searched existing missing movie ids `372`, `762`, `1081`, `1090`, `1092`, `1093`, `1094`, `1095`, and `1096`. | Immediate grabs found for `Tremors` and `Mallrats`; other searched movies had no current queue record after search. |
| Sonarr | Added `Frozen Planet` as monitored under `/tv/tv2/TV Shows/Frozen Planet`. | Sonarr id `234`; season 0 left unmonitored. |
| Sonarr | Searched `Star Trek: Short Treks`, `Teenage Mutant Ninja Turtles (2003)`, `Tales of the Teenage Mutant Ninja Turtles`, and `Frozen Planet`. | No current Sonarr queue records after search; all four remain at 0 episode files. |

Execution evidence: `logs/plex-collection-fixes-20260530.json` and `logs/collection-fill-actions-20260530.json`.

## Inputs

| Input | Result |
| --- | --- |
| Plex sections queried | `Movies` section `2`; `TV Shows` section `1` |
| Plex collections audited | 23 movie collections; 11 TV collections |
| Collection memberships counted | 320 movie memberships; 76 TV memberships |
| Plex evidence file | `logs/plex-collection-inventory-20260530.json` |
| Read-only Arr evidence | `logs/radarr-movie-inventory-20260530.json`; `logs/sonarr-series-inventory-20260530.json` |
| Missing standard | Core plus notable franchise entries; optional/loose items separated |

## Highest-Value Findings

| Collection | Finding | Status | Proposed follow-up |
| --- | --- | --- | --- |
| `Harry Potter` | `Harry Potter and the Goblet of Fire` is the only main Harry Potter film missing from Plex. | In Radarr, monitored, `hasFile=false`. | Future fill: verify download safety, then search Radarr movie id `1095`. |
| `Evil Dead Collection` | `Evil Dead Rise` is the missing core film. | Not found in Plex; not clearly present in Radarr snapshot. | Future fill: Radarr lookup/add/search after safety checks. |
| `Kevin Smith / View Askewniverse` | `Mallrats` is the missing core View Askewniverse film. | In Radarr, monitored, `hasFile=false`, id `762`. | Future fill: verify queue/download state; search or monitor existing Radarr entry if still missing. |
| `DC Cinematic Universe` | `Aquaman and the Lost Kingdom` is missing from Plex. | In Radarr, monitored, `hasFile=false`, id `1090`. | Future fill: verify queue/download state; search existing Radarr entry if still missing. |
| `Marvel Cinematic Universe` movies | `Iron Man` and `The Fantastic Four: First Steps` are in Plex but not assigned to the movie collection. | Plex search found both in `Movies`. | Future Plex collection update only; no download needed. |
| `Spider-Man Collection` | `Spider-Man` is in Plex but not assigned; `Spider-Man 2`, `Spider-Man 3`, and `Madame Web` remain absent from Plex. | `Spider-Man` has file in Radarr; the other three are monitored with `hasFile=false`. | Future Plex collection update for `Spider-Man`; future Radarr searches for the missing titles after safety checks. |
| `Studio Ghibli` | `Earwig and the Witch` is missing from Plex. | In Radarr, monitored, `hasFile=false`, id `1081`. | Future fill: search existing Radarr entry after safety checks. |
| `Shark Attack / Creature Features` | `Tremors` is the missing first Tremors film while later entries are in the collection. | In Radarr, monitored, `hasFile=false`, id `372`. | Future fill: search existing Radarr entry after safety checks. |
| `BBC / Attenborough Nature` | `Frozen Planet` is the clearest missing companion to `Frozen Planet II`. | Not found in Plex; only `Frozen Planet II` in Sonarr snapshot. | Future fill: Sonarr lookup/add/search after safety checks. |
| `Beavis and Butt-Head Collection` TV | Original `Beavis and Butt-Head` is in Plex but not assigned to the TV collection. | Plex search found the 1993 show in `TV Shows`. | Future Plex collection update only; no download needed. |
| `Star Trek TV` | `The Animated Series`, `Enterprise`, `Picard`, and `Prodigy` are in Plex but not assigned to the collection. `Short Treks` is in Sonarr but not found in Plex search. | Multiple collection-membership gaps; one possible absent/import gap. | Future Plex collection update for local shows; investigate `Short Treks` disk/Plex state before any search. |
| `Teenage Mutant Ninja Turtles` TV | `Teenage Mutant Ninja Turtles (2003)` and `Tales of the Teenage Mutant Ninja Turtles` are in Sonarr but not found in Plex search or the collection. | Likely absent from Plex or not imported. | Future fill/import investigation before searching. |

## Per-Collection Audit

| Section | Collection | Current count | Core/notable missing or not assigned | Optional or broad-scope notes |
| --- | --- | ---: | --- | --- |
| Movies | `28 Days Later Collection` | 4 | No current core gap found. | Future unnamed third `28 Years Later` sequel remains future/disputed until firm release metadata settles. |
| Movies | `Alien vs. Predator Universe` | 16 | No current core film gap found. | TV side has `Alien: Earth`. Broader comic/game/crossover material is out of scope. |
| TV Shows | `Alien vs. Predator Universe` | 1 | No current core TV gap found. | Keep TV and movie collections separate unless manually merging section-local memberships later. |
| Movies | `Avatar Collection` | 3 | No current released/core gap found. | Future `Avatar 4` and `Avatar 5` should be tracked as future, not missing media. |
| Movies | `Back to the Future Collection` | 3 | None. | Complete for main theatrical trilogy. |
| Movies | `Batman Collection` | 29 | No must-fill local core gap under the existing broad local Batman/Joker scope. | If expanding toward a complete Batman animation/live-action shelf, notable candidates include `Batman: The Movie`, `Batman Ninja`, `Batman: The Doom That Came to Gotham`, and `Batman: The Dark Knight Returns` parts. |
| Movies | `Beavis and Butt-Head Collection` | 2 | None for movies. | Movie side has both theatrical/feature entries. |
| TV Shows | `Beavis and Butt-Head Collection` | 1 | `Beavis and Butt-Head` (1993) is in Plex but not assigned. | `Daria` is a loose spin-off and should stay optional. |
| Movies | `DC Animated Movies` | 22 | No must-fill gap under the documented local-themed scope. | Full DC animated-original coverage would be a much larger separate project. |
| TV Shows | `DC Animated / Batman TV` | 11 | `Justice League Unlimited`, `Static Shock`, `The Zeta Project`, `Harley Quinn`, and `My Adventures with Superman` remain notable missing/not assigned candidates from the prior audit. | `Creature Commandos` is in Sonarr but was not found in Plex search; it belongs more naturally to DCU than the Batman/DCAU shelf. |
| Movies | `DC Cinematic Universe` | 15 | `Aquaman and the Lost Kingdom` is absent from Plex and already monitored in Radarr. | `Superman` (2025), `Supergirl`, and other new DCU titles are a successor-continuity scope, not DCEU. |
| TV Shows | `DC Cinematic Universe` | 1 | `Creature Commandos` is a notable DCU TV candidate but was not found in Plex search. | `The Penguin` belongs to the separate Batman crime-saga continuity, not the DCEU/DCU core. |
| Movies | `Descendants Collection` | 6 | None. | Complete for current Descendants feature/special scope. |
| Movies | `Disney Collection` | 65 | No actionable gap under the documented local Disney/Pixar/Disney Channel/Walt Disney Pictures scope. | A complete Disney canon audit would be too broad and should be a separate, explicitly scoped project. |
| Movies | `Evil Dead Collection` | 4 | `Evil Dead Rise` is the missing core film. | TV side has `Ash vs Evil Dead`. |
| TV Shows | `Evil Dead Collection` | 1 | None. | Complete for the major TV entry. |
| Movies | `Ghostbusters Collection` | 5 | None for core films; the old 1984/2016 gap is now resolved in Plex. | TV shows like `The Real Ghostbusters` and `Extreme Ghostbusters` are optional if a mixed Ghostbusters universe shelf is desired. |
| Movies | `Harry Potter` | 7 | `Harry Potter and the Goblet of Fire` is missing from Plex. | `Fantastic Beasts` films are Wizarding World entries but optional for the current Harry Potter-named collection. |
| Movies | `Hotel Transylvania Collection` | 4 | None. | Complete for current feature-film scope. |
| Movies | `John Wick` | 5 | None for movies. | `The Continental` is a notable TV spin-off but is not in Plex or Sonarr; add only if the collection becomes a mixed John Wick universe. |
| Movies | `Jurassic Park / Jurassic World` | 7 | None for movies. | `Camp Cretaceous` and `Chaos Theory` are optional TV spin-offs if a mixed Jurassic shelf is desired. |
| Movies | `Kevin Smith / View Askewniverse` | 7 | `Mallrats` is absent from Plex and already monitored in Radarr. | Animated/special side material is optional. |
| Movies | `Marvel Cinematic Universe` | 38 | `Iron Man` and `The Fantastic Four: First Steps` are in Plex but not assigned to the movie collection. | Future unreleased MCU films should not be treated as missing until available. |
| TV Shows | `Marvel Cinematic Universe` | 18 | `Hawkeye`, `Echo`, `I Am Groot`, and `Eyes of Wakanda` are in Plex under `Marvel TV` but not assigned here. `Ms. Marvel` and `Secret Invasion` are in Plex but not assigned to either Marvel collection. | The collection currently mixes MCU, Netflix Marvel, and animated/non-core Marvel material; decide whether to keep broad or split strict MCU from Marvel TV. |
| TV Shows | `Marvel TV` | 18 | `Ms. Marvel` and `Secret Invasion` are in Plex but not assigned here. | Legacy/adjacent candidates for a broader Marvel TV shelf include `Agents of S.H.I.E.L.D.`, `Agent Carter`, `Runaways`, `Cloak & Dagger`, `Legion`, and `The Gifted`. |
| TV Shows | `One Chicago` | 3 | No gap for the core trio. | `Chicago Justice` remains the optional broader-franchise gap. |
| Movies | `Shark Attack / Creature Features` | 27 | `Tremors` is missing while sequels are present. | Other creature-feature choices are taste/theme calls rather than canonical gaps. |
| Movies | `Spider-Man Collection` | 13 | `Spider-Man` (2002) is in Plex but not assigned; `Spider-Man 2`, `Spider-Man 3`, and `Madame Web` remain absent from Plex. | `The Fantastic Four: First Steps` is MCU-adjacent, not a Spider-Man collection item. Future `Spider-Man: Brand New Day` and `Beyond the Spider-Verse` should remain future tracking. |
| Movies | `Studio Ghibli` | 24 | `Earwig and the Witch` is the main missing Studio Ghibli feature. | `The Red Turtle` and `Nausicaa` are already included despite common co-production/pre-Ghibli boundary debates. |
| Movies | `The Matrix Collection` | 5 | None. | Complete for films plus `The Animatrix`. |
| Movies | `Transformers Collection` | 9 | None for theatrical/current feature-film scope. | TV series are optional and should not be folded in without a separate mixed Transformers scope. |
| TV Shows | `BBC / Attenborough Nature` | 11 | `Frozen Planet` is the strongest missing companion. | Broader BBC Earth/Nature additions are optional and numerous. |
| TV Shows | `Star Trek TV` | 8 | `Star Trek: The Animated Series`, `Star Trek: Enterprise`, `Star Trek: Picard`, and `Star Trek: Prodigy` are in Plex but not assigned. `Star Trek: Short Treks` is in Sonarr but not found in Plex search. | Keep movies separate unless a complete Star Trek universe collection is intentionally created. |
| TV Shows | `Teenage Mutant Ninja Turtles` | 3 | `Teenage Mutant Ninja Turtles (2003)` and `Tales of the Teenage Mutant Ninja Turtles` are in Sonarr but not found in Plex search or the collection. | Future Mutant Mayhem-era shows/specials should be reviewed as they land. |

## Proposed Fill And Repair Queue

These are recommendations only. Do not execute without a later explicit fill/update request.

| Type | Title | Current local evidence | Recommended next step |
| --- | --- | --- | --- |
| Plex collection update | `Iron Man` | Present in Plex Movies; missing from `Marvel Cinematic Universe`. | Add existing Plex item to movie collection. |
| Plex collection update | `The Fantastic Four: First Steps` | Present in Plex Movies; missing from `Marvel Cinematic Universe`. | Add existing Plex item to movie collection if MCU scope includes current 2025 releases. |
| Plex collection update | `Spider-Man` (2002) | Present in Plex Movies; missing from `Spider-Man Collection`. | Add existing Plex item to movie collection. |
| Plex collection update | `Beavis and Butt-Head` (1993) | Present in Plex TV; missing from TV collection. | Add existing Plex item to TV collection. |
| Plex collection update | `Star Trek: The Animated Series` | Present in Plex TV; missing from `Star Trek TV`. | Add existing Plex item to TV collection. |
| Plex collection update | `Star Trek: Enterprise` | Present in Plex TV; missing from `Star Trek TV`. | Add existing Plex item to TV collection. |
| Plex collection update | `Star Trek: Picard` | Present in Plex TV; missing from `Star Trek TV`. | Add existing Plex item to TV collection. |
| Plex collection update | `Star Trek: Prodigy` | Present in Plex TV; missing from `Star Trek TV`. | Add existing Plex item to TV collection. |
| Radarr fill | `Harry Potter and the Goblet of Fire` | Radarr id `1095`, monitored, `hasFile=false`. | Verify download safety, then search existing Radarr movie. |
| Radarr fill | `Aquaman and the Lost Kingdom` | Radarr id `1090`, monitored, `hasFile=false`. | Verify queue/download state and search existing Radarr movie if still missing. |
| Radarr fill | `Mallrats` | Radarr id `762`, monitored, `hasFile=false`. | Verify queue/download state and search existing Radarr movie if still missing. |
| Radarr fill | `Spider-Man 2` | Radarr id `1092`, monitored, `hasFile=false`. | Verify download safety, then search existing Radarr movie. |
| Radarr fill | `Spider-Man 3` | Radarr id `1093`, monitored, `hasFile=false`. | Verify download safety, then search existing Radarr movie. |
| Radarr fill | `Madame Web` | Radarr id `1094`, monitored, `hasFile=false`. | Verify download safety, then search existing Radarr movie. |
| Radarr fill | `Tremors` | Radarr id `372`, monitored, `hasFile=false`. | Verify download safety, then search existing Radarr movie. |
| Radarr fill | `Earwig and the Witch` | Radarr id `1081`, monitored, `hasFile=false`. | Verify download safety, then search existing Radarr movie. |
| Radarr add/fill | `Evil Dead Rise` | Added to Radarr as id `1096`, monitored, `hasFile=false`. | Search was triggered; no current queue record after search. |
| Sonarr fill/import investigation | `Frozen Planet` | Added to Sonarr as id `234`, monitored, 0 episode files. | Search was triggered; no current queue record after search. |
| Sonarr/Plex investigation | `Star Trek: Short Treks` | Present in Sonarr, not found in Plex search. | Check disk/import state before any search. |
| Sonarr/Plex investigation | `Teenage Mutant Ninja Turtles (2003)` | Present in Sonarr, not found in Plex search. | Check disk/import state before any search. |
| Sonarr/Plex investigation | `Tales of the Teenage Mutant Ninja Turtles` | Present in Sonarr, not found in Plex search. | Check disk/import state before any search. |

## Required Safety Checks Before Any Future Fill

- Confirm `I:\torrentfiles` exists on Windows.
- Confirm native qBittorrent remains the active download client target.
- Confirm Radarr still maps `I:\torrentfiles\` to `/downloads/`.
- Confirm Sonarr still maps `I:\torrentfiles\` to `/downloads/`.
- Confirm `H:` is present before allowing any Sonarr import/write target under `/tv/tv2`.
- Skip ambiguous remakes, alternate titles, future releases, and disputed-canon entries unless the exact target is confirmed.

## Spot Checks

| Check | Result |
| --- | --- |
| Strict franchises | `Back to the Future`, `The Matrix`, `John Wick`, `Hotel Transylvania`, `Transformers`, and core `Ghostbusters` have no current core film gaps. |
| Broad franchises | `Batman`, `DC Animated Movies`, `Disney`, and `Shark Attack / Creature Features` are intentionally local/theme scoped; only `Tremors` stands out as a strong internal gap. |
| Mixed movie/TV franchises | Mixed collections need section-local updates rather than one combined Plex collection. |
| Plex-only gaps | Several titles are already in Plex and need only future collection assignment, not downloads. |
| True absent-media gaps | The clearest fill candidates are `Harry Potter and the Goblet of Fire`, `Evil Dead Rise`, `Mallrats`, `Aquaman and the Lost Kingdom`, `Spider-Man 2`, `Spider-Man 3`, `Madame Web`, `Tremors`, `Earwig and the Witch`, and `Frozen Planet`. |

## Public Source Notes

Public franchise/release facts were checked against current official or high-signal sources where possible, including:

- Star Trek official series list: <https://www.startrek.com/series-and-movies>
- Marvel official movie and TV pages: <https://www.marvel.com/movies> and <https://www.marvel.com/tv-shows>
- DC official movie and TV pages: <https://www.dc.com/movies> and <https://www.dc.com/tv>
- BBC Earth show pages for `Frozen Planet`: <https://www.bbcearth.com/shows/frozen-planet>
- Paramount/Nickelodeon TMNT public release pages for `Tales of the Teenage Mutant Ninja Turtles`.
- Studio Ghibli official works lists and GKIDS/Ghibli release pages for feature-film boundary checks.
- Wizarding World and Warner Bros. public film pages for Harry Potter/Wizarding World boundaries.

## Verification

- Re-queried Plex collections and children through the Plex HTTP API.
- Queried Radarr and Sonarr read-only library endpoints.
- Confirmed no write endpoints were used.
- No secrets, tokens, API keys, private tracker URLs, torrent hashes, magnet links, or credentials are included in this report.
