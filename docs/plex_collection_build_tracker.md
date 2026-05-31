# Plex Collection Build Tracker

Last updated: 2026-05-30

Overall status: Complete for built collections; see the 2026-05-30 missing-media inventory for current collection gaps, pending imports, and proposed fill actions.

## 2026-05-30 Missing-Media Inventory

Read-only audit report: `docs/plex_collection_missing_media_inventory_20260530.md`

- Audited 23 movie collections and 11 TV collections through the Plex HTTP API.
- No Plex edits, Plex refreshes, Sonarr/Radarr adds, searches, qBittorrent actions, poster changes, path repairs, or drive-letter changes were performed.
- Highest-value follow-ups are split between collection-membership fixes for media already in Plex and future Radarr/Sonarr fill candidates.
- Notable already-in-Plex collection gaps: `Iron Man`, `The Fantastic Four: First Steps`, `Spider-Man` (2002), original `Beavis and Butt-Head`, and several `Star Trek TV` shows.
- Notable absent/pending fill candidates: `Harry Potter and the Goblet of Fire`, `Evil Dead Rise`, `Mallrats`, `Aquaman and the Lost Kingdom`, `Spider-Man 2`, `Spider-Man 3`, `Madame Web`, `Tremors`, `Earwig and the Witch`, and `Frozen Planet`.
- Fix execution completed after the audit: Plex collection-membership gaps above were updated; `Evil Dead Rise` and `Frozen Planet` were added to Arr; Radarr/Sonarr searches were triggered for the identified fill queue.
- Immediate grab results: `Tremors` is downloading and `Mallrats` is queued in Radarr. Sonarr searches for `Frozen Planet`, `Star Trek: Short Treks`, `Teenage Mutant Ninja Turtles (2003)`, and `Tales of the Teenage Mutant Ninja Turtles` produced no current queue records.

## Ordered Checklist

| Order | Collection | Status | Notes |
| --- | --- | --- | --- |
| 1 | John Wick Universe | Complete | 5 movies assigned; TPDb posters verified. |
| 2 | The Matrix Collection | Complete | 5 movies assigned; TPDb posters verified. |
| 3 | Back to the Future Collection | Complete | Trilogy assigned; TPDb posters verified. |
| 4 | Hotel Transylvania Collection | Complete | 4 movies assigned; TPDb posters verified. |
| 5 | Descendants Collection | Complete | 6 movies/specials assigned; available TPDb posters verified. |
| 6 | Jurassic Park / Jurassic World | Complete | 7 movies assigned; TPDb posters verified. |
| 7 | Kevin Smith / View Askewniverse | Complete | 7 Plex items assigned; Mallrats downloading via Radarr. |
| 8 | DC Animated Movies | Complete | 22 local DC animated films assigned; poster overrides verified. |
| 9 | Shark Attack / Creature Features | Complete | 27 local creature-feature movies assigned; no coherent TPDb set applied. |
| 10 | Batman Collection | Complete | 29 local Batman/Joker movies and specials assigned. |

## 1. John Wick Universe

Status: Complete

- Plex collection rating key: 22557
- Item count: 5 movies
- Missing items: None
- Poster set/source: TPDb John Wick Collection by willtong93, https://theposterdb.com/set/290279
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for collection plus all 5 items.

## 2. The Matrix Collection

Status: Complete

- Plex collection rating key: 22558
- Item count: 5 movies
- Missing items: None
- Poster set/source: TPDb The Matrix Collection by Aloha_Alona, https://theposterdb.com/set/55510
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for collection plus all 5 items.

## 3. Back to the Future Collection

Status: Complete

- Plex collection rating key: 22559
- Item count: 3 movies
- Missing items: None
- Poster set/source: TPDb Back to the Future Collection by XDM, https://theposterdb.com/set/86419
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for collection plus all 3 items.

## 4. Hotel Transylvania Collection

Status: Complete

- Plex collection rating key: 22560
- Item count: 4 movies
- Missing items: None
- Poster set/source: TPDb Sony Pictures Animation Collection / Hotel Transylvania subset by DIIIVOY, https://theposterdb.com/set/65010
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for collection plus all 4 items.

## 5. Descendants Collection

Status: Complete

- Plex collection rating key: 22561
- Item count: 6 movies/specials
- Missing items: None
- Poster set/source: TPDb Descendants Collection by CmdrRiker, plus Rise of Red poster by JoshTPDb49, https://theposterdb.com/poster/507579
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified for collection and 5 matching items. No dedicated TPDb poster found for Wicked Woods: A Descendants Halloween Story.

## 6. Jurassic Park / Jurassic World

Status: Complete

- Plex collection rating key: 22562
- Item count: 7 movies
- Missing items: None
- Poster set/source: TPDb Jurassic Park Collection by thebrowncoatali, https://theposterdb.com/set/342841
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for collection plus all 7 items.

## 7. Kevin Smith / View Askewniverse

Status: Complete

- Plex collection rating key: 22563
- Item count: 7 movies
- Missing items: Mallrats (1995), already monitored in Radarr and not yet imported into Plex
- Poster set/source: TPDb View Askewniverse by musikmann2000, https://theposterdb.com/poster/187841
- Radarr/Sonarr actions: Triggered Radarr MoviesSearch for Mallrats, Radarr movie id 762. It grabbed Mallrats.1995.Repack.2160p.UHD.Blu-ray.Remux.DV.HDR.HEVC.DTS-HD.MA.5.1-CiNEPHiLES.mkv and is downloading. An earlier accidental Radarr search command for movie id 1 completed with 0 reports downloaded.
- Verification notes: Collection children verified through Plex API. Poster overrides verified for the collection and 3 confidently mapped item posters. Remaining item poster mapping was left unchanged rather than applying uncertain TPDb matches.

## 8. DC Animated Movies

Status: Complete

- Plex collection rating key: 22564
- Item count: 22 movies
- Missing items: None for the local-themed scope. This was intentionally scoped to local DC animated films rather than the full DC animated originals catalog.
- Poster set/source: TPDb DC Universe Animated Original Movies by CmdrRiker, https://theposterdb.com/set/97366
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for collection plus all 22 items.

## 9. Shark Attack / Creature Features

Status: Complete

- Plex collection rating key: 22565
- Item count: 27 movies
- Missing items: None for the local-themed scope
- Poster set/source: No coherent TPDb set applied; broad theme spans multiple unrelated franchises.
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API.

## 10. Batman Collection

Status: Complete

- Plex collection rating key: 22566
- Item count: 29 movies/specials
- Missing items: None for the broad local Batman/Joker scope
- Poster set/source: Replaced the disjointed Batman artwork with a mostly cohesive musikmann2000 TPDb family: Batman Collection / In Association With DC, DC Universe Animated Original Movies, LEGO Movie Collection, Joker, and The Batman poster pages.
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for the collection plus 25 item posters. The only items intentionally left unchanged were The Batman vs. Dracula, Batman & Bill, Joker: Folie à Deux, and Batman Ninja vs. Yakuza League because no confident matching musikmann2000 poster was found during cleanup.

## Final Verification

- Plex movie collections now include all 10 requested new collections:
  - John Wick Universe: 5 items
  - The Matrix Collection: 5 items
  - Back to the Future Collection: 3 items
  - Hotel Transylvania Collection: 4 items
  - Descendants Collection: 6 items
  - Jurassic Park / Jurassic World: 7 items
  - Kevin Smith / View Askewniverse: 7 items
  - DC Animated Movies: 22 items
  - Shark Attack / Creature Features: 27 items
  - Batman Collection: 29 items
- Radarr queue follow-up:
  - Mallrats.1995.Repack.2160p.UHD.Blu-ray.Remux.DV.HDR.HEVC.DTS-HD.MA.5.1-CiNEPHiLES.mkv is downloading and tracked OK for the View Askewniverse gap.
  - Aquaman and the Lost Kingdom is still downloading and tracked OK from the earlier DC Cinematic Universe fill.
- No Plex library refreshes, drive-letter changes, path repairs, or download-client setting changes were performed.

## 11. Spider-Man Collection

Status: Complete; pending imports noted

- Plex collection rating key: 22567
- Item count: 13 current Plex movies/shorts
- Missing items: Spider-Man (2002), Spider-Man 2 (2004), Spider-Man 3 (2007), and Madame Web (2024) were missing from Plex at collection time.
- Poster set/source: TPDb Spider-Man Universe / related Spider-Man sets by musikmann2000, https://theposterdb.com/set/99235
- Radarr/Sonarr actions: Added Spider-Man, Spider-Man 2, Spider-Man 3, and Madame Web to Radarr as monitored Ultra-HD entries under /movies/movies3/Movies with searches triggered. Current queue shows Spider-Man downloading and Spider-Man 2, Spider-Man 3, and Madame Web queued/tracked OK.
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for the collection plus 9 confidently matched item posters. Spider-Verse, Spider-Ham, and Kraven item posters were left unchanged to avoid mismatched art. Plex has Spider-Man: No Way Home, but Radarr currently reports its tracked entry as hasFile false; no path repair was performed.

## 12. Disney Collection

Status: Complete

- Plex collection rating key: 22568
- Item count: 65 current Plex movies/shorts
- Missing items: None for the local Disney/Pixar/Disney Channel/Walt Disney Pictures scope. Marvel, Star Wars/Lucasfilm, and 20th Century titles were intentionally excluded because they are separate ecosystems.
- Poster set/source: TPDb Walt Disney Animation Studios collection poster by DarkMatte, https://theposterdb.com/set/314337
- Radarr/Sonarr actions: None
- Verification notes: Collection children verified through Plex API. Collection poster override verified in Plex DB. Item poster overrides were intentionally left unchanged because this broad collection spans WDAS, Pixar, Disney live action, Disney Channel, and shorts; no single coherent all-item poster family was applied.

## 13. TV Collection Batch

Status: Complete

- Scope: Plex TV Shows section only; Adventure Time was intentionally skipped at user request.
- Plex collection rating keys:
  - BBC / Attenborough Nature: 22577, 11 shows
  - Teenage Mutant Ninja Turtles: 22578, 3 shows
  - DC Animated / Batman TV: 22579, 11 shows
  - Star Trek TV: 22580, 8 shows
- Missing items: See `docs/tv_collection_recommendations_audit.md` for known gaps and scope notes.
- Poster set/source:
  - BBC / Attenborough Nature: TPDb Planet Collection by tiederian applied to collection plus 10 matching shows.
  - Teenage Mutant Ninja Turtles: TPDb Teenage Mutant Ninja Turtles Collection by Aloha_Alona applied to collection plus 2 matching shows.
  - DC Animated / Batman TV: TPDb DC Animated Universe Collection by MiniZaki applied to collection plus 8 matching shows.
  - Star Trek TV: TPDb Star Trek family by mjmattu applied to collection plus 4 matching shows.
- Radarr/Sonarr actions: None.
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for 4 collections and 24 matching shows. No Plex library refreshes, drive-letter changes, path repairs, download-client actions, Sonarr/Radarr actions, or downloads were performed.

## 14. Additional TV Collections

Status: Complete; no posters applied

- Scope: Plex TV Shows section only.
- Plex collection rating keys:
  - Marvel TV: 22778, 18 shows
  - One Chicago: 22779, 3 shows
- Missing items:
  - Marvel TV: None for the broad local Marvel TV scope from `docs/tv_collection_recommendations_audit.md`.
  - One Chicago: None for the local core trio scope; `Chicago Justice` remains an optional broader-franchise gap.
- Poster set/source: None applied.
- Radarr/Sonarr actions: None.
- Verification notes: Collection children verified through Plex API. No Plex library refreshes, drive-letter changes, path repairs, download-client actions, Sonarr/Radarr actions, or downloads were performed.

## 15. Transformers Collection

Status: Complete

- Scope: Plex Movies section only; broad local Transformers film scope, including the 1986 animated movie, the Michael Bay-directed live-action run, and later non-Bay theatrical entries present in Plex.
- Plex collection rating key: 22892
- Item count: 9 movies
- Missing items: None for the local broad film scope.
- Poster set/source: TPDb Transformers Collection by AMC, https://theposterdb.com/set/108971, applied to the collection plus 8 matching movies; Transformers One used the matching rebelworks TPDb poster, https://theposterdb.com/poster/531576.
- Radarr/Sonarr actions: None.
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for the collection plus all 9 movies. No Plex library refreshes, drive-letter changes, path repairs, download-client actions, Sonarr/Radarr actions, or downloads were performed.

## 16. Ghostbusters Collection

Status: Complete; missing local entries noted

- Scope: Plex Movies section only; theatrical Ghostbusters film scope.
- Plex collection rating key: 22893
- Item count: 3 current Plex movies
- Missing items: Ghostbusters (1984) and Ghostbusters (2016) were not present in Plex at collection time.
- Poster set/source: TPDb Ghostbusters Collection by Jezzfreeman, https://theposterdb.com/set/261112, applied to the collection plus all 3 matching local movies.
- Radarr/Sonarr actions: None.
- Verification notes: Collection children verified through Plex API. Poster overrides verified in Plex DB for the collection plus all 3 movies. No Plex library refreshes, drive-letter changes, path repairs, download-client actions, Sonarr/Radarr actions, or downloads were performed.
