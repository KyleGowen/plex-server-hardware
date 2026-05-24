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
- Sonarr's torrent download client should use the Docker qBittorrent service at `qbittorrent:8080`, category `tv-sonarr`, with shared download paths under `/downloads`.

## Radarr Rules

- When adding a movie to Radarr, set the movie to `Monitored: true` unless the user explicitly asks for it to be unmonitored.
- Do not trigger an automatic search or download unless the user explicitly asks for a search/download action.
- Radarr's torrent download client should use the Docker qBittorrent service at `qbittorrent:8080`, category `radarr`, with shared download paths under `/downloads`.

## Plex Rules

- Use the Plex HTTP API directly for Plex checks until a trustworthy Plex MCP server is selected and approved.
- Treat the Plex token as a secret. Read or receive it at runtime, use it only for local API calls, and never write it to this repository, logs intended for git, docs, scripts, or GitHub.
- Prefer read-only Plex checks first: server identity, library sections, metadata lookup, search, active activities, and scan status.
- If Sonarr or Radarr shows media imported on disk but Plex does not show it, check the relevant Plex library section and current Plex activities before proposing a refresh.
- Plex library refreshes are allowed from the agent only after explicit user confirmation because they are write actions. For the current TV library, section `1` is `TV Shows`; for the current movie library, section `2` is `Movies`.
- After a confirmed refresh, verify the expected show or movie appears in Plex instead of assuming the scan succeeded.

## Operational Memory

- The Plex token is not shown in the XML response body. It normally appears in the browser address bar or request URL as `X-Plex-Token=...`; ask for the URL or use the browser/network request path rather than searching pasted XML content.
- PowerShell formatted object output has caused misleading nullable/table displays. For local service APIs, capture raw JSON or XML first and parse only the fields needed.
- The configured `mcp_arr` server was unavailable or not credentialed during this setup. Try it first per MCP rules, but be ready to fall back to local config files, documented APIs, or service UIs without spending time debugging the MCP path.
- The `mcp_arr` server is configured through the ignored local wrapper `.tools/mcp-arr/start-mcp-arr.ps1`, which reads Sonarr/Radarr/Prowlarr API keys from `C:\media-stack\config\...\config.xml` at startup instead of storing keys in `C:\Users\Kyle\.codex\config.toml`.
- A running Codex session may keep the old MCP server process after config changes. Restart or reload Codex MCP servers before expecting newly added `mcp_arr` credentials/tools to appear in the current tool list.
- The configured `torrent_manager` login failed during this setup. Use it read-only first if available, but fall back to the qBittorrent Web API or Web UI when credentials are not accepted.
- qBittorrent Web API login may return `HTTP 204 OK` with a session cookie rather than an `Ok.` body. Treat the status and `SID` cookie as the success signal.
- Radarr's qBittorrent download client was fixed on 2026-05-24. It should have one enabled qBittorrent client using Docker-network host `qbittorrent`, port `8080`, category `radarr`, and shared `/downloads` paths. A healthy Radarr check should report zero download-client issues.
- qBittorrent's default save path is `/downloads/` and incomplete path is `/downloads/incomplete/`, mapped from Windows `I:\torrentfiles`. Radarr and Sonarr share the `/downloads` mount, so no remote path mapping should be needed for this Docker stack.
- If Radarr's qBittorrent credential needs to be repaired again, read it locally from existing app config/runtime state and do not print or commit it. The Sonarr qBittorrent client has previously had a working stored credential; treat it as a secret.
- `C:\Program Files\Plex\Plex Media Server\Plex SQLite.exe` is available locally and can inspect Sonarr/Radarr SQLite databases when needed. Redact secrets from any output.
- Plex did not automatically show `H2O: Just Add Water` immediately after Sonarr imported all 78 episodes. A manual TV library refresh from Plex Web made it appear, so future imported-but-missing Plex cases should consider a confirmed Plex library refresh after read-only checks.
- Bazarr `episodeMissingCount` refers to missing subtitles, not missing episode files.
- Native Radarr library import previously produced at least one bad match for a remake versus original movie. For bulk Radarr imports, prefer stricter API-based matching and skip ambiguous collection/mismatch cases rather than accepting questionable UI matches.
- On 2026-05-24, the top-six Q1 2026 movie request was added/updated in Radarr as monitored Ultra-HD entries without triggering searches/downloads: `Project Hail Mary`, `Avatar: Fire and Ash`, `Hoppers`, `Scream 7`, `GOAT`, and `Zootopia 2`.

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
