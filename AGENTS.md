# AGENTS.md — Plex Server Hardware Project

## Project Goal

Help rebuild and document a Windows-native Plex media server after suspected motherboard failure.

The project involves:
- Replacing the failed old platform with a modern Intel platform
- Preserving the existing Windows 10 OS SSD
- Preserving all media HDDs
- Avoiding destructive storage actions
- Restoring drive letters before launching Plex/Sonarr/Radarr/Bazarr/qBittorrent/Jackett/Unpacker
- Maintaining clear rebuild documentation

## Critical Safety Rules

- Do not recommend formatting, initializing, repartitioning, or wiping any existing media drive unless the user explicitly confirms it is blank.
- Do not assume a drive is disposable.
- Do not launch or repair Plex/Sonarr/Radarr/Bazarr/qBittorrent paths before confirming drive letters.
- Do not randomly reorder SATA drives.
- Preserve the OS SSD and search for Plex metadata before reinstalling Windows or Plex.
- Use only Corsair RM750e-compatible modular PSU cables.
- Favor step-by-step checklists over broad advice.

## Secret Handling

- Treat tracker credentials, service usernames/passwords, cookies, passkeys, API keys, tokens, and invite/account details as local secrets.
- Never commit secrets to this repository, generated scripts, documentation, `.env` examples, logs intended for git, or GitHub.
- Before staging, committing, pushing, or opening a PR, scan changed files for secrets and remove or redact anything sensitive.
- Prefer reading service API keys from local config files or environment variables at runtime instead of hard-coding them in scripts.
- When reporting command output, redact secrets unless the user explicitly asks to view a credential for immediate local use.

## Agent Permissions

- Do not ask for permission before running local `git` commands for this project.
- Do not ask for permission before running local `docker` or `docker compose` commands for this project.
- Do not ask for permission before reading local files on this computer.
- Do not ask for permission before searching public websites.
- Do not ask for permission before running local PowerShell commands for this project.

## PowerShell Output Handling

- When querying local HTTP APIs or service endpoints from PowerShell, prefer raw JSON responses and explicit parsing over PowerShell-formatted object tables.
- Avoid relying on `Format-Table`, truncated table output, or nullable object display when deciding service health, IDs, paths, counts, or status fields.
- For diagnostics, capture the raw response first, convert from JSON only when needed, and print the specific fields required for the next step.

## Sonarr Rules

- When adding a series to Sonarr, set the series to `Monitored: true` unless the user explicitly asks for it to be unmonitored.
- When adding a series, monitor normal seasons by default and leave specials/season 0 unmonitored unless the user asks otherwise.
- Do not trigger an automatic search or download unless the user explicitly asks for a search/download action.

## Radarr Rules

- When adding a movie to Radarr, set the movie to `Monitored: true` unless the user explicitly asks for it to be unmonitored.
- Do not trigger an automatic search or download unless the user explicitly asks for a search/download action.

## MCP Usage

- Until a trustworthy, well-maintained Plex MCP server is selected, interact with Plex through the Plex HTTP API directly from the agent.
- Treat community Plex MCP servers as experimental. Do not give one a Plex token unless the user explicitly approves after review.
- Prefer read-only Plex HTTP API actions first: server status, libraries, active sessions, metadata lookup, and scan status.
- Require explicit confirmation before write actions such as library refreshes, metadata edits, deletes, or server setting changes.
- When interacting with Sonarr, Radarr, Lidarr, or Prowlarr, try the configured `mcp_arr` MCP server first.
- If `mcp_arr` is unavailable or lacks the needed API credentials, fall back to local files, documented API calls, or the service UI as appropriate.
- Do not use `mcp_arr` to launch, repair, add, move, search, or mutate media paths until drive letters and root folders have been confirmed.
- When interacting with qBittorrent or torrent download state, try the configured `torrent_manager` MCP server first.
- Use `torrent_manager` read-only tools first for status, torrent lists, session stats, and disk-space checks.
- Do not use `torrent_manager` to add, start, stop, remove, delete, move, or recheck torrents until qBittorrent categories, save paths, incomplete paths, and root-folder mappings have been confirmed.
- If `torrent_manager` is unavailable or lacks needed credentials, fall back to local qBittorrent config/log files, documented Web API calls, or the qBittorrent Web UI as appropriate.

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
