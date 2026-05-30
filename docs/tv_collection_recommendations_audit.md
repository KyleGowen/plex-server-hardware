# TV Collection Recommendations Audit

Last updated: 2026-05-29

Mode: `plex-collection-curator` audit-only. No Plex writes, no Sonarr/Radarr actions, no downloads, no library refreshes.

## Read-Only Inputs

| Check | Result |
| --- | --- |
| Plex section | `1` / `TV Shows` |
| Total TV shows in Plex | 222 |
| Plex TV roots reported | `H:\TV Shows`, `J:\TV Shows` |
| Former missing-root risk | Recommendations are based on Plex metadata only; no collection depends on changing paths or importing from a root. |

## Ranked Recommendations

| Rank | Collection | Local coverage | Grade | Likely gaps | Recommendation |
| --- | --- | ---: | --- | --- | --- |
| 1 | BBC / Attenborough Nature | 11 shows / 109 episodes | Strong themed shelf | `Frozen Planet` is the clearest companion gap; broader BBC Earth scope could add many optional titles. | Create now |
| 2 | Adventure Time | 2 shows / 282 episodes | Nearly complete if scoped tightly | `Adventure Time: Distant Lands`; `Fionna and Cake` season 2 may be incomplete in Plex metadata. | Create now, scoped as main-series universe |
| 3 | Teenage Mutant Ninja Turtles | 3 shows / 259 episodes | Good local franchise shelf | `Teenage Mutant Ninja Turtles (2003)`, `Tales of the Teenage Mutant Ninja Turtles`. | Create now if gaps are acceptable |
| 4 | DC Animated / Batman TV | 11 shows / 412 episodes | Strong local shelf, mixed scope | `Justice League Unlimited`, `Static Shock`, `The Zeta Project`, `Harley Quinn`, `My Adventures with Superman`, and other optional DC TV titles. | Create now as a local DC/Batman TV shelf |
| 5 | Star Trek TV | 8 shows / 754 episodes | High-value, not complete | `The Animated Series`, `Enterprise`, `Picard`, `Prodigy`, and possibly `Short Treks`. | Wait if completeness matters; create now if labeled as a local Trek shelf |

## Candidate Details

### BBC / Attenborough Nature

Local titles:

- `A Perfect Planet` (2021), 5 episodes
- `Blue Planet II` (2017), 7 episodes
- `David Attenborough's Natural Curiosities` (2013), 27 episodes
- `Frozen Planet II` (2022), 6 episodes
- `Our Planet (2019)` (2019), 12 episodes
- `Planet Earth` (2006), 11 episodes
- `Planet Earth II` (2016), 6 episodes
- `Planet Earth III` (2023), 8 episodes
- `Prehistoric Planet` (2022), 15 episodes
- `Seven Worlds, One Planet` (2019), 7 episodes
- `The Green Planet` (2022), 5 episodes

Why it ranks first: the local library already has a coherent prestige nature shelf with no obvious need to involve Sonarr. Keep the title broad, such as `BBC / Attenborough Nature`, because `Our Planet` and `Prehistoric Planet` are adjacent rather than strictly BBC Earth lineage.

### Adventure Time

Local titles:

- `Adventure Time` (2010), 278 episodes
- `Adventure Time: Fionna and Cake` (2023), 4 episodes

Why it ranks second: the core show is present, and `Fionna and Cake` is a direct franchise expansion. Public WBD notes identify `Fionna and Cake` as following the four `Adventure Time: Distant Lands` specials, making `Distant Lands` the clean gap to flag.

### Teenage Mutant Ninja Turtles

Local titles:

- `Rise of the Teenage Mutant Ninja Turtles` (2018), 67 episodes
- `Teenage Mutant Ninja Turtles` (1987), 111 episodes
- `Teenage Mutant Ninja Turtles (2012)` (2012), 81 episodes

Why it ranks third: this is a useful TV franchise shelf now, but it is visibly not a full TV-history shelf. Paramount/Nickelodeon sources make `Tales of the Teenage Mutant Ninja Turtles` an active franchise series, and the 2003 animated series is a major missing generation.

### DC Animated / Batman TV

Local titles:

- `Batman Beyond` (1999), 52 episodes
- `Batman: Caped Crusader` (2024), 10 episodes
- `Batman: The Animated Series` (1992), 85 episodes
- `Batman: The Brave and the Bold` (2008), 13 episodes
- `Justice League` (2001), 81 episodes
- `Peacemaker` (2022), 16 episodes
- `Suicide Squad Isekai` (2024), 4 episodes
- `Superman: The Animated Series` (1996), 54 episodes
- `The Batman` (2004), 65 episodes
- `The New Batman Adventures` (1997), 24 episodes
- `The Penguin` (2024), 8 episodes

Why it ranks fourth: the local shelf is large and watchable, especially around Batman and the classic DC animated era. Because it mixes animated continuity with live-action DC TV, use a local-scope name and avoid claiming it is a complete DCAU collection.

### Star Trek TV

Local titles:

- `Star Trek` (1966), 79 episodes
- `Star Trek: Deep Space Nine` (1993), 174 episodes
- `Star Trek: Discovery` (2017), 65 episodes
- `Star Trek: Lower Decks` (2020), 50 episodes
- `Star Trek: Starfleet Academy` (2026), 9 episodes
- `Star Trek: Strange New Worlds` (2022), 30 episodes
- `Star Trek: The Next Generation` (1987), 178 episodes
- `Star Trek: Voyager` (1995), 169 episodes

Why it ranks fifth: this would be a great collection, but StarTrek.com's own series list shows several missing TV entries. Create only if the collection title makes the local scope clear, such as `Star Trek TV (Local)`.

## Source Notes

- Star Trek official series cross-check: <https://www.startrek.com/series-and-movies>
- BBC Earth show cross-check: <https://bbcearth.ca/shows/> and <https://www.bbcearth.com/shows/frozen-planet>
- Adventure Time / WBD cross-check: <https://press.wbd.com/us/media-release/hbo-max/adventure-continues-hbo-max-orders-adventure-time-fionna-cake-wt-series> and <https://press.wbd.com/na/media-release/hbo-max/adventure-time-fionna-and-cake/max-renews-adventure-time-fionna-and-cake-second-season>
- TMNT / Paramount cross-check: <https://www.paramountpressexpress.com/paramount-plus/shows/tales-of-the-teenage-mutant-ninja-turtles/> and <https://www.paramountpressexpress.com/nickelodeon/releases/?view=104395-nickelodeon-reimagines-the-iconic-teenage-mutant-ninja-turtles-in-all-new-animated-series-rise-of-the-teenage-mutant-ninja-turtles>
- DC official cross-check: <https://www.dc.com/tv/batman-the-animated-series-1992-1995>, <https://www.dc.com/tv/superman-the-animated-series-1996-2000>, and <https://www.dc.com/tv/justice-league-2001-2004>

## TPDb Poster Leads

| Collection | Recommended TPDb lead | Coverage fit | Notes |
| --- | --- | --- | --- |
| BBC / Attenborough Nature | Planet Collection by tiederian, <https://theposterdb.com/set/273714> | Strong | Covers the core local shelf well: `Planet Earth`, `Planet Earth II`, `Planet Earth III`, `Blue Planet II`, `Frozen Planet II`, `A Perfect Planet`, `Seven Worlds, One Planet`, `The Green Planet`, `Our Planet`, and `Prehistoric Planet`. `David Attenborough's Natural Curiosities` may need a separate compatible poster. |
| Teenage Mutant Ninja Turtles | Teenage Mutant Ninja Turtles Collection by Aloha_Alona, <https://theposterdb.com/set/48889> | Strong | Includes additional TV sets for `Teenage Mutant Ninja Turtles (1987)`, `Teenage Mutant Ninja Turtles (2012)`, and `Rise of the Teenage Mutant Ninja Turtles`. This is the cleanest one-uploader match. |
| DC Animated / Batman TV | DC Animated Universe Collection by MiniZaki, <https://theposterdb.com/set/258911> | Good for animated core | Covers `Batman: The Animated Series`, `Superman: The Animated Series`, `The New Batman Adventures`, `Batman Beyond`, `Justice League`, and has an additional poster for `Batman: The Brave and the Bold`. Live-action items like `Peacemaker` and `The Penguin`, plus `Suicide Squad Isekai` and `Batman: Caped Crusader`, will need compatible supplemental posters. |
| DC Animated / Batman TV | DC Animated Universe Collection by musikmann2000, <https://theposterdb.com/poster/162413> | Good alternate | Similar DCAU coverage, likely the better choice if matching the existing movie-side Batman/DC poster family matters more than this TV-only collection being visually self-contained. |
| Star Trek TV | Star Trek TV Collection / linked TV sets by mjmattu, <https://theposterdb.com/poster/333367> | Best TV-specific lead found | Search result shows a linked `Star Trek TV Collection` plus individual TV sets for `Star Trek`, `The Next Generation`, `Deep Space Nine`, `Voyager`, `Discovery`, `Lower Decks`, `Strange New Worlds`, and related series. Avoid the many `Star Trek: Complete Collection` TPDb sets unless intentionally posterizing movie collections, because most only cover films. |

## Verification

- Re-queried Plex section `1` read-only and confirmed the five candidate counts above.
- Plex collection creation/update was later performed for all recommended collections except Adventure Time.
- TPDb poster URL uploads were later applied to the 4 created collections and 24 confidently matched TV shows.
- Did not call Sonarr, Radarr, qBittorrent, or any Arr mutation path.
- No recommendation requires changing drive letters, repairing paths, or importing from `H:\TV Shows` or `J:\TV Shows`.

---

## 2026-05-30 Additional TV Collection Candidates

Mode: `plex-collection-curator` audit-only. No Plex writes, no Sonarr/Radarr actions, no downloads, no library refreshes.

Read-only inputs:

| Check | Result |
| --- | --- |
| Plex section | `1` / `TV Shows` |
| Method | Re-queried Plex TV metadata and excluded TV collections already created in the first batch. |
| Existing collection exclusions | BBC / Attenborough Nature, Teenage Mutant Ninja Turtles, DC Animated / Batman TV, Star Trek TV. |

| Rank | Collection | Local coverage | Grade | Scope notes / likely gaps | Recommendation |
| --- | --- | ---: | --- | --- | --- |
| 1 | Marvel TV / MCU Animation | 18 shows / 336 episodes | Strong broad shelf | Mixes MCU Disney+ live action, Marvel animation, and adjacent animated Marvel TV. Missing legacy Netflix/Hulu Marvel unless intentionally filled later. | Create now if broad Marvel scope is acceptable |
| 2 | Star Wars TV | 5 shows / 71 episodes | Strong branded shelf | Missing major animated and live-action entries such as `The Clone Wars`, `Rebels`, `The Bad Batch`, `Obi-Wan Kenobi`, and `Skeleton Crew`. | Create now as local Star Wars TV shelf |
| 3 | One Chicago | 3 shows / 126 episodes | Clean franchise shelf | Local coverage has the core NBC trio: `Chicago Fire`, `Chicago Med`, and `Chicago P.D.`. `Chicago Justice` is the main optional gap. | Create now |
| 4 | Workplace / Hangout Comedy | 8 shows / 653 episodes | Strong themed shelf | Broad mood shelf rather than a franchise. Includes network sitcoms plus Apple workplace-adjacent comedies. | Create if a themed comedy shelf is desired |
| 5 | The Boys Universe | 2 shows / 44 episodes | Clean but small | Local scope has `The Boys` and `Diabolical`; `Gen V` is the obvious missing live-action spin-off. | Create now if small collections are acceptable |
| 6 | Whoniverse | 2 shows / 149 episodes | Clean but incomplete | Local scope has `Doctor Who (2005)` and `Tales of the Tardis`; classic `Doctor Who`, `Torchwood`, `The Sarah Jane Adventures`, and other spin-offs are absent. | Create now as modern/local Whoniverse |
| 7 | Spider-Man TV | 3 shows / 83 episodes | Useful character shelf | Includes `Spider-Man: The Animated Series`, `Spider-Noir`, and `Your Friendly Neighborhood Spider-Man`; the color `Spider-Noir` companion is in Sonarr but not Plex yet. | Create after Spider-Noir color/import settles, or create now as local Spider-Man TV |
| 8 | X-Men TV | 2 shows / 86 episodes | Clean but small | Tight collection around `X-Men: The Animated Series` and `X-Men '97`. | Create now if small collections are acceptable |

### Candidate Details

#### Marvel TV / MCU Animation

Local titles:

- `Agatha All Along` (2024), 9 episodes
- `Daredevil: Born Again` (2025), 17 episodes
- `Echo` (2023), 5 episodes
- `Eyes of Wakanda` (2025), 4 episodes
- `Hawkeye (2021)` (2021), 6 episodes
- `I Am Groot` (2022), 10 episodes
- `Iron Man: Armored Adventures` (2008), 52 episodes
- `Ironheart` (2025), 6 episodes
- `She-Hulk: Attorney at Law` (2022), 9 episodes
- `The Falcon and The Winter Soldier` (2021), 6 episodes
- `WandaVision` (2021), 9 episodes
- `What If...?` (2021), 26 episodes
- `Wonder Man` (2026), 8 episodes
- `X-Men '97` (2024), 10 episodes
- `X-Men: The Animated Series` (1992), 76 episodes
- `Spider-Man: The Animated Series` (1994), 65 episodes
- `Spider-Noir` (2026), 8 episodes
- `Your Friendly Neighborhood Spider-Man` (2025), 10 episodes

Why it ranks first: the local shelf is already large, recognizable, and likely useful. If created, use a broad name such as `Marvel TV` rather than claiming a strict MCU-only collection, because it includes non-MCU and animated continuity items.

#### Star Wars TV

Local titles:

- `Ahsoka` (2023), 8 episodes
- `Andor` (2022), 24 episodes
- `The Acolyte` (2024), 8 episodes
- `The Book of Boba Fett` (2021), 7 episodes
- `The Mandalorian` (2019), 24 episodes

Why it ranks second: this is a clean branded shelf with strong local coverage of Disney-era live-action Star Wars TV. Label it as local TV coverage unless filling the missing animated backbone.

#### One Chicago

Local titles:

- `Chicago Fire` (2012), 42 episodes
- `Chicago Med` (2015), 42 episodes
- `Chicago P.D.` (2014), 42 episodes

Why it ranks third: NBC treats this as a current shared franchise, and the local library has the core trio at balanced coverage.

#### Workplace / Hangout Comedy

Local titles:

- `30 Rock` (2006), 138 episodes
- `A.P. Bio` (2018), 42 episodes
- `Abbott Elementary` (2021), 93 episodes
- `Brooklyn Nine-Nine` (2013), 153 episodes
- `Community` (2009), 110 episodes
- `The Good Place` (2016), 50 episodes
- `Ted Lasso` (2020), 34 episodes
- `Shrinking` (2023), 33 episodes

Why it ranks fourth: this would be a very usable browse shelf, but it is thematic rather than canonical. Name it by mood, not franchise.

#### The Boys Universe

Local titles:

- `The Boys` (2019), 36 episodes
- `The Boys Presents: Diabolical` (2022), 8 episodes

Why it ranks fifth: tight and obvious, but small. `Gen V` is the main missing local companion.

#### Whoniverse

Local titles:

- `Doctor Who (2005)` (2005), 143 episodes
- `Tales of the Tardis` (2023), 6 episodes

Why it ranks sixth: official BBC framing supports a Whoniverse shelf, but local coverage is modern/new-series focused.

#### Spider-Man TV

Local titles:

- `Spider-Man: The Animated Series` (1994), 65 episodes
- `Spider-Noir` (2026), 8 episodes
- `Your Friendly Neighborhood Spider-Man` (2025), 10 episodes

Why it ranks seventh: useful because the library already has a Spider-Man movie collection. Wait if you want the `Spider-Noir - Color` companion imported first.

#### X-Men TV

Local titles:

- `X-Men: The Animated Series` (1992), 76 episodes
- `X-Men '97` (2024), 10 episodes

Why it ranks eighth: small but extremely clean and likely poster-friendly.

## Additional Source Notes

- Marvel TV cross-check: <https://www.marvel.com/tv-shows>
- MCU timeline / Disney+ series cross-check: <https://www.marvel.com/articles/movies/mcu-timeline-order-disney-plus>
- Star Wars official series pages cross-check: <https://www.starwars.com/series/the-mandalorian> and <https://www.starwars.com/series/the-book-of-boba-fett>
- One Chicago official cross-check: <https://www.nbc.com/one-chicago> and <https://www.nbc.com/nbc-insider/how-to-watch-one-chicago-chicago-med-chicago-fire-and-chicago-p-d-on-nbc>
- Whoniverse / Tales of the TARDIS official cross-check: <https://www.doctorwho.tv/news-and-features/welcome-to-the-whoniverse-and-tales-of-the-tardis>
