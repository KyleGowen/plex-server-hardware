# Futurama Collection

**Created at:** 2026-06-22  
**Updated at:** 2026-06-22

**Plex records:**
- TV Shows: rating key 24129; 1 item; Plex updated 2026-06-22.
- Movies: no section-local Plex collection yet because no Futurama movies are currently present in Plex.

### Movie Content

| Movie | Year | Notes |
|---|---:|---|
| None |  | No Futurama movie members are currently present in the live Plex Movies library. |

### Missing Movies

| Movie | Year | Status / Notes |
|---|---:|---|
| Futurama: Bender's Big Score | 2007 | Added to Radarr ID `1186`, TMDb `7249`; monitored; no file yet. Radarr search command `68816` completed with 0 reports downloaded. |
| Futurama: The Beast with a Billion Backs | 2008 | Added to Radarr ID `1184`, TMDb `12889`; monitored; no file yet. Radarr search command `68811` completed with 0 reports downloaded. |
| Futurama: Bender's Game | 2008 | Added to Radarr ID `1183`, TMDb `13253`; monitored; no file yet. Radarr search command `68810` completed with 0 reports downloaded. |
| Futurama: Into the Wild Green Yonder | 2009 | Added to Radarr ID `1185`, TMDb `15060`; monitored; no file yet. Radarr search command `68815` completed with 0 reports downloaded. |

### Blacklisted Movies

| Movie | Year | Reason |
|---|---:|---|
| None known |  | No explicit movie blacklist evidence found. |

### TV Show Content

| TV Show | Year | Notes |
|---|---:|---|
| Futurama | 1999 | Current Plex TV collection member; Plex show rating key `6536`; Sonarr ID `43`; TVDB `73871`. |

### Missing TV Shows / Episodes

| TV Show | Year | Status / Notes |
|---|---:|---|
| Futurama | 1999 | Sonarr is monitored and has one missing aired/listed episode: S10E06 `Wicked Human` from 2025-09-29. Sonarr `SeriesSearch` command `69902` was started on 2026-06-22 and was still processing at the final check. |

### Blacklisted TV Shows

| TV Show | Year | Reason |
|---|---:|---|
| None known |  | No explicit TV blacklist evidence found. |

### Waiting For Download / Ready To Add

| Type | Title | Year | Status | Notes |
|---|---|---:|---|---|
| Movie | Futurama: Bender's Big Score | 2007 | Waiting for acceptable grab | Added and searched in Radarr; no active queue match found immediately after search. |
| Movie | Futurama: The Beast with a Billion Backs | 2008 | Waiting for acceptable grab | Added and searched in Radarr; no active queue match found immediately after search. |
| Movie | Futurama: Bender's Game | 2008 | Waiting for acceptable grab | Added and searched in Radarr; no active queue match found immediately after search. |
| Movie | Futurama: Into the Wild Green Yonder | 2009 | Waiting for acceptable grab | Added and searched in Radarr; no active queue match found immediately after search. |
| TV Episode | Futurama S10E06 `Wicked Human` | 2025 | Search in progress at documentation time | Existing monitored Sonarr series; search command `69902` was still processing release 55/68 at final check. |

### Poster Set

| Applied | Set / Style | Creator / Uploader | Source | Notes |
|---|---|---|---|---|
| No poster changes in this run | Existing user-selected Futurama show and season posters | Unknown / local Plex-selected metadata posters | See [`tv-shows/futurama.md`](../tv-shows/futurama.md) | The user explicitly requested the selected show and season posters be preserved and catalogued. No collection, show, season, or movie posters were changed. |

## Research Notes

- Core scope for this collection is the main `Futurama` TV series plus the four direct-to-video Futurama movies: `Bender's Big Score`, `The Beast with a Billion Backs`, `Bender's Game`, and `Into the Wild Green Yonder`.
- The four movies are also represented in some TV metadata as segmented episodes/specials, but this collection tracks them as standalone Radarr movie targets because the user requested shows and movies.
- Required download-path checks passed before searches: `I:\torrentfiles` exists, and `/downloads` exists inside the Sonarr, Radarr, and Unpackerr containers.
