# Plex Server Hardware

Documentation for the Korlash Windows-native Plex media server rebuild and media automation stack.

## Current Status

The hardware rebuild is complete enough for Windows, Plex, Docker Desktop, and the Docker media stack to run on the replacement Intel platform. The current unresolved issue is randomly timed system crashing. That stability problem is not solved yet, and the docs should not claim a root cause until evidence is collected.

Current deployment:

| Area | Current state |
|---|---|
| Plex | Native Windows install |
| Media automation | Docker Compose stack |
| Active Docker services | Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, Uptime Kuma, qBittorrent, Unpackerr |
| Optional legacy service | Jackett via the `legacy-jackett` compose profile |
| Storage model | Windows drive letters mounted into containers |
| Torrent root | `I:\torrentfiles`, mounted in containers as `/downloads` |

## Safety Rules

- Do not format, initialize, repartition, or wipe any existing media drive.
- Do not change drive letters casually.
- Confirm drive letters and Docker bind mounts before trusting Plex, qBittorrent, Sonarr, Radarr, Bazarr, Tautulli, Jackett, or Unpackerr after boot, crash, Docker restart, or storage work.
- Treat Plex tokens, Arr API keys, qBittorrent credentials, tracker data, cookies, passkeys, and provider credentials as local secrets.
- Plex library refreshes and other Plex write actions require explicit confirmation.

## Documentation Map

| File | Purpose |
|---|---|
| [AGENTS.md](AGENTS.md) | Assistant operating rules, safety constraints, and operational memory. |
| [docs/plex_server_rebuild_wip_tracker.md](docs/plex_server_rebuild_wip_tracker.md) | Post-rebuild status tracker, current priorities, and remaining hardening work. |
| [docs/current_stability_crash_tracker.md](docs/current_stability_crash_tracker.md) | Unresolved random-crash tracker and non-destructive diagnostic checklist. |
| [docs/plex_server_hardware_inventory.md](docs/plex_server_hardware_inventory.md) | Current hardware platform, storage inventory, and historical old-platform context. |
| [docs/plex_server_software_inventory.md](docs/plex_server_software_inventory.md) | Software inventory and ecosystem connection summary. |
| [docs/plex_storage_migration_rebuild_documentation.md](docs/plex_storage_migration_rebuild_documentation.md) | Completed migration notes and ongoing drive-letter/path safety rules. |
| [docs/qbittorrent_startup_recovery.md](docs/qbittorrent_startup_recovery.md) | Detailed qBittorrent stale Docker mount recovery runbook. |
| [docs/skills_catalog.md](docs/skills_catalog.md) | Catalog of available Codex skills and what each is for. |
| [docs/plex_server_hardware_troubleshooting_history_log.md](docs/plex_server_hardware_troubleshooting_history_log.md) | Historical diagnostics from the failed ASUS platform. |

## Service Documentation

Each ecosystem service has its own reference file with purpose, deployment, and read/write relationships:

| Service | Doc |
|---|---|
| Plex | [docs/services/plex.md](docs/services/plex.md) |
| Sonarr | [docs/services/sonarr.md](docs/services/sonarr.md) |
| Radarr | [docs/services/radarr.md](docs/services/radarr.md) |
| Prowlarr | [docs/services/prowlarr.md](docs/services/prowlarr.md) |
| Bazarr | [docs/services/bazarr.md](docs/services/bazarr.md) |
| Tautulli | [docs/services/tautulli.md](docs/services/tautulli.md) |
| Uptime Kuma | [docs/services/uptime-kuma.md](docs/services/uptime-kuma.md) |
| qBittorrent | [docs/services/qbittorrent.md](docs/services/qbittorrent.md) |
| Unpackerr | [docs/services/unpackerr.md](docs/services/unpackerr.md) |
| Jackett | [docs/services/jackett.md](docs/services/jackett.md) |

## Update Rules

- Put current crash/stability observations in the crash tracker.
- Put confirmed component, drive, app, and service facts in the inventory or per-service docs.
- Put qBittorrent stale mount details in the qBittorrent runbook.
- Put assistant workflow and reusable local automation notes in the skills catalog.
- Keep secrets out of repo docs, generated scripts, logs intended for git, commits, and GitHub.
