# Plex Server Hardware

Documentation for rebuilding the Korlash Windows-native Plex media server after suspected motherboard failure.

Current software direction: keep Plex Media Server native on Windows, and move the media automation stack to Docker containers for Sonarr, Radarr, Bazarr, qBittorrent, Jackett, and Unpackerr.

## Current Status

The project is in the hardware rebuild phase. The current plan is to preserve the existing Windows 10 OS SSD and all media drives, assemble the replacement Intel platform, boot first with the OS SSD only, then reconnect media drives incrementally after Windows is stable. After drive letters are confirmed, Plex stays native Windows and the media automation tools move forward under Docker.

## Safety Rules

- Do not format, initialize, repartition, or wipe any existing media drive.
- Do not reinstall Windows over the OS SSD before searching for Plex metadata.
- Do not launch Plex, Sonarr, Radarr, Bazarr, qBittorrent, Jackett, or Unpackerr until drive letters are confirmed.
- Use only Corsair RM750e-compatible modular PSU cables.
- Restore original drive letters before normal media service operation.

## Documentation Map

| File | Purpose |
|---|---|
| [AGENTS.md](AGENTS.md) | Assistant operating rules and rebuild safety constraints. |
| [docs/plex_server_rebuild_wip_tracker.md](docs/plex_server_rebuild_wip_tracker.md) | Active rebuild checklist, current status, next action, and live observations. |
| [docs/plex_server_hardware_inventory.md](docs/plex_server_hardware_inventory.md) | Stable hardware, storage, software, and service inventory. |
| [docs/plex_server_software_inventory.md](docs/plex_server_software_inventory.md) | Software recovery inventory, official download links, app roles, and app connections. |
| [docs/qbittorrent_startup_recovery.md](docs/qbittorrent_startup_recovery.md) | qBittorrent startup checks and recovery procedure for stale Docker `/downloads` mounts. |
| [docs/bazarr_architecture.md](docs/bazarr_architecture.md) | Bazarr subtitle automation role, Docker/Arr connections, provider state, and safe verification notes. |
| [docs/plex_server_hardware_troubleshooting_history_log.md](docs/plex_server_hardware_troubleshooting_history_log.md) | Historical diagnostics already attempted on the failed platform. |
| [docs/plex_storage_migration_rebuild_documentation.md](docs/plex_storage_migration_rebuild_documentation.md) | Storage, drive-letter, Plex metadata, and application recovery guide. |

## Codex Skills

| Skill | Purpose |
|---|---|
| [tools/codex-skills/overnight-media-audit/SKILL.md](tools/codex-skills/overnight-media-audit/SKILL.md) | Reusable read-only workflow for answering what media downloaded, imported, or got stuck overnight. |

## Update Rules

- Put new physical rebuild observations in the WIP tracker.
- Put confirmed component, drive, app, and service facts in the inventory.
- Put detailed Bazarr subtitle architecture and provider-readiness findings in the Bazarr architecture doc.
- Put software download links, app relationships, and recovery/admin utilities in the software inventory.
- Put old failed-platform diagnostic evidence in the troubleshooting history.
- Put drive-letter recovery, Disk Management findings, Plex metadata, and app path notes in the storage migration guide.
