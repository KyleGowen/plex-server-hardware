# 2026-05-31 Indexer Outage And Recovery

## Summary

On 2026-05-31, Sonarr searches appeared to work briefly and then return empty results. The outage was not a Sonarr-to-Prowlarr connection failure. Sonarr, Radarr, and Prowlarr were reachable, and Prowlarr could search trackers. The failure was caused by SpeedCD search results being usable for lookup but blocked at torrent-download time.

## Current Resolved State

| Component | Current state |
|---|---|
| Prowlarr | Active indexer manager |
| Prowlarr indexers | MoreThanTV enabled; SpeedCD enabled |
| Sonarr indexers | MoreThanTV (Prowlarr) enabled; SpeedCD (Prowlarr) enabled |
| Radarr indexers | MoreThanTV (Prowlarr) enabled; SpeedCD (Prowlarr) enabled |
| Jackett | Stopped; optional `legacy-jackett` fallback only |
| Validation | SpeedCD proxied download through Prowlarr returned valid torrent data |

## Cause Chain

1. Prowlarr could search SpeedCD and return releases.
2. Prowlarr failed when proxying SpeedCD torrent downloads because SpeedCD returned an HTML account restriction page instead of `.torrent` bytes.
3. Sonarr treated repeated SpeedCD grab failures as an indexer failure and temporarily suppressed SpeedCD.
4. With SpeedCD suppressed, Sonarr searched only the remaining available tracker for some requests.
5. For affected media, the remaining tracker had no matching releases, so Sonarr interactive search looked empty.

## Mitigation Applied

| Time | Action | Result |
|---|---|---|
| Initial mitigation | Disabled SpeedCD in Prowlarr and disabled the synced SpeedCD indexer in Sonarr | Sonarr/Prowlarr health returned clean, but only MoreThanTV remained available |
| Jackett test | Started optional Jackett `legacy-jackett` profile and configured SpeedCD | Jackett search/test passed, but downloads were blocked by the same SpeedCD account restriction |
| Final recovery | SpeedCD account restriction was lifted; SpeedCD was re-enabled in Prowlarr and Sonarr/Radarr | Prowlarr proxied download validation passed and Sonarr searches returned SpeedCD releases |

## Lessons

- A tracker can pass search/login tests while still being unusable for grabs.
- For private tracker outages, validate both search results and one proxied torrent download before re-enabling an indexer.
- Do not add Jackett as a workaround unless Prowlarr cannot perform the same validated search and grab path.
- Keep Jackett stopped unless a specific tracker requires Jackett-only behavior.

## Safe Validation Checklist

Use this before re-enabling a failing torrent indexer:

1. Confirm Prowlarr can search the tracker.
2. Download one proxied result through Prowlarr to a temporary local file.
3. Confirm the file begins like torrent bencoded data, not HTML or XML error content.
4. Re-enable the Prowlarr indexer.
5. Confirm Sonarr/Radarr synced indexers are enabled.
6. Confirm Sonarr/Radarr health is clean.
