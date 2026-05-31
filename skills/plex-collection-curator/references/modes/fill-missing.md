# Plex Collection Fill-Missing Mode

Use when the user asks to fill, add, search, download, acquire, or complete missing collection items.

1. Identify missing items from a compact master list and read-only Plex checks.
2. Check Radarr/Sonarr for existing monitored or unmonitored entries before adding.
3. Verify native `I:\torrentfiles` and Sonarr/Radarr `/downloads` point to the real download storage before triggering searches.
4. Add missing movies to Radarr and missing series to Sonarr as monitored.
5. Trigger searches only for newly added missing items unless the user requests broader searching.

Do not update Plex collection membership or posters unless the user asks for those actions.
