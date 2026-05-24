# AGENTS.md — Plex Server Hardware Project

## Project Goal

Help rebuild and document a Windows-native Plex media server after suspected motherboard failure.

The project involves:
- Replacing the failed old platform with a modern Intel platform
- Preserving the existing Windows 10 OS SSD
- Preserving all media HDDs
- Avoiding destructive storage actions
- Restoring drive letters before launching Plex/Sonarr/Radarr/qBittorrent/Jackett/Unpacker
- Maintaining clear rebuild documentation

## Critical Safety Rules

- Do not recommend formatting, initializing, repartitioning, or wiping any existing media drive unless the user explicitly confirms it is blank.
- Do not assume a drive is disposable.
- Do not launch or repair Plex/Sonarr/Radarr/qBittorrent paths before confirming drive letters.
- Do not randomly reorder SATA drives.
- Preserve the OS SSD and search for Plex metadata before reinstalling Windows or Plex.
- Use only Corsair RM750e-compatible modular PSU cables.
- Favor step-by-step checklists over broad advice.

## Agent Permissions

- Do not ask for permission before running local `git` commands for this project.
- Do not ask for permission before running local `docker` or `docker compose` commands for this project.
- Do not ask for permission before reading local files on this computer.
- Do not ask for permission before searching public websites.
- Do not ask for permission before running local PowerShell commands for this project.

## MCP Usage

- When interacting with Sonarr, Radarr, Lidarr, or Prowlarr, try the configured `mcp_arr` MCP server first.
- If `mcp_arr` is unavailable or lacks the needed API credentials, fall back to local files, documented API calls, or the service UI as appropriate.
- Do not use `mcp_arr` to launch, repair, add, move, search, or mutate media paths until drive letters and root folders have been confirmed.

## Current Rebuild Hardware

Purchased:
- Motherboard: MSI PRO Z790-A WiFi II
- CPU: Intel Core i5-14500 SRN3T
- RAM: Lexar Thor Z DDR5 32GB Kit, 2x16GB, 6000MHz
- CPU Cooler: Noctua NH-U9S chromax.black

Reused:
- Case: SilverStone GD07
- PSU: Corsair RM750e
- GPU: GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD, slot-powered
- OS drive: existing 2.5-inch SATA SSD
- Media drives: existing 5x 3.5-inch SATA HDDs

## Rebuild Strategy

1. Assemble minimal system first.
2. Boot with OS SSD only.
3. Confirm BIOS sees CPU, RAM, and OS SSD.
4. Boot Windows 10 if possible.
5. Install drivers.
6. Search for Plex metadata.
7. Reconnect media drives one at a time.
8. Record and restore drive letters.
9. Only then launch Plex and media automation tools.

## Documentation Style

Use markdown.
Prefer tables and checklists.
Keep advice practical and hardware-safe.
When adding new findings, update the relevant docs instead of scattering notes.
