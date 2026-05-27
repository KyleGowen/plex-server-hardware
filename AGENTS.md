# AGENTS.md - Plex Server Hardware Project

## Project Goal

Help operate, stabilize, and document a rebuilt Windows-native Plex media server.

The rebuild from the failed ASUS platform to the modern Intel platform has been accomplished. The random crashing improved after the broken-power-pin HDD was removed, but do not claim the stability issue is fully solved until a longer normal-operation soak supports that conclusion.

The project now involves:

- Preserving the existing Windows 10 OS SSD and all media HDDs.
- Keeping Plex Media Server native on Windows.
- Running Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, qBittorrent, and Unpackerr in Docker.
- Keeping Jackett disabled unless its optional `legacy-jackett` profile is intentionally needed.
- Maintaining clear operational documentation and crash/stability notes.

## Critical Safety Rules

- Do not recommend formatting, initializing, repartitioning, or wiping any existing media drive unless the user explicitly confirms it is blank.
- Do not assume a drive is disposable.
- Do not randomly reorder SATA drives.
- Do not casually change drive letters.
- Confirm drive letters and root folders before repairing Plex, Sonarr, Radarr, Bazarr, Tautulli, qBittorrent, Jackett, or Unpackerr paths.
- Confirm `I:\torrentfiles` on Windows and `/downloads` inside qBittorrent before trusting downloads after boot, crash, Docker restart, WSL restart, or storage work.
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
- Do not ask for permission before running harmless Python discovery commands for this project, including `Get-Command py`, `Get-Command python`, `py --version`, and `python --version`; always allow these checks.
- Do not ask for permission before running harmless local path checks for this project, including `Test-Path I:\torrentfiles`; always allow these checks.
- Do not ask for permission before running read-only Sonarr MCP calls through the configured `mcp_arr` server, including `sonarr_get_download_clients`; always allow these checks.
- Do not ask for permission before running harmless local wait commands such as `Start-Sleep -Seconds 60`.

## Media Internet Search Routing

- For any public internet lookup about movies, films, TV shows, series, seasons, episodes, collections, franchises, release years, cast/crew, chronology, production facts, title identity, or media type, use the `media-internet-search` skill/subagent first.
- Treat `media-internet-search` as read-only research. It must not mutate Plex, Sonarr, Radarr, qBittorrent, Prowlarr, Bazarr, Jackett, Unpackerr, local files, or service settings.
- Use its sourced result to resolve ambiguity before calling local Plex/Arr workflows. Only move to `add-media-to-plex` when the user explicitly asks to add, search, download, monitor, or request media.

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

- The current stability lead is the removed broken-power-pin HDD, its power connection, or related cabling. Track observations in `docs/current_stability_crash_tracker.md`; treat this as probable under soak, not a fully confirmed root cause yet.
- As of 2026-05-26, the system survived the first overnight soak after the broken-pin drive was removed and an 8 TB `G:` drive was installed.
- As of 2026-05-26, the former `H:` / TV 2 volume is absent. Do not allow Sonarr/Bazarr imports or subtitle writes to `/tv/tv2`; Docker showed `/tv/tv2` as a tiny full placeholder filesystem while `H:` was missing.
- The Plex token is not shown in the XML response body. It normally appears in the browser address bar or request URL as `X-Plex-Token=...`; ask for the URL or use the browser/network request path rather than searching pasted XML content.
- PowerShell formatted object output has caused misleading nullable/table displays. For local service APIs, capture raw JSON or XML first and parse only the fields needed.
- The configured `mcp_arr` server was unavailable or not credentialed during this setup. Try it first per MCP rules, but be ready to fall back to local config files, documented APIs, or service UIs without spending time debugging the MCP path.
- The `mcp_arr` server is configured through the ignored local wrapper `.tools/mcp-arr/start-mcp-arr.ps1`, which reads Sonarr/Radarr/Prowlarr API keys from `C:\media-stack\config\...\config.xml` at startup instead of storing keys in `C:\Users\Kyle\.codex\config.toml`.
- A running Codex session may keep the old MCP server process after config changes. Restart or reload Codex MCP servers before expecting newly added `mcp_arr` credentials/tools to appear in the current tool list.
- The configured `torrent_manager` login failed during this setup. Use it read-only first if available, but fall back to the qBittorrent Web API or Web UI when credentials are not accepted.
- qBittorrent Web API login may return `HTTP 204 OK` with a session cookie rather than an `Ok.` body. Treat the status and `SID` cookie as the success signal.
- Radarr's qBittorrent download client was fixed on 2026-05-24. It should have one enabled qBittorrent client using Docker-network host `qbittorrent`, port `8080`, category `radarr`, and shared `/downloads` paths. A healthy Radarr check should report zero download-client issues.
- qBittorrent's default save path is `/downloads/` and incomplete path is `/downloads/incomplete/`, mapped from Windows `I:\torrentfiles`. Radarr and Sonarr share the `/downloads` mount, so no remote path mapping should be needed for this Docker stack.
- On 2026-05-25, qBittorrent started while `I:\torrentfiles` was absent or not visible to Docker. The container showed `/downloads` as a tiny full `137M` filesystem and torrents errored with `No space left on device`, even though Windows reported free space on `I:`. A qBittorrent container restart and container recreate did not fix the mount. The working fix was `wsl --shutdown`, restart Docker Desktop, `docker compose -f C:\plex-server\docker-compose.media.yml up -d`, verify `docker exec qbittorrent sh -c "df -h /downloads"` shows `I:\` with multi-terabyte capacity, then recheck/start torrents.
- Before trusting qBittorrent after boot, drive reconnect, Docker restart, or storage work, verify both `Test-Path I:\torrentfiles` on Windows and `df -h /downloads` inside the qBittorrent container. If `/downloads` is tiny/full, do not keep restarting qBittorrent; restart Docker/WSL first.
- If Radarr's qBittorrent credential needs to be repaired again, read it locally from existing app config/runtime state and do not print or commit it. The Sonarr qBittorrent client has previously had a working stored credential; treat it as a secret.
- `C:\Program Files\Plex\Plex Media Server\Plex SQLite.exe` is available locally and can inspect Sonarr/Radarr SQLite databases when needed. Redact secrets from any output.
- Plex did not automatically show `H2O: Just Add Water` immediately after Sonarr imported all 78 episodes. A manual TV library refresh from Plex Web made it appear, so future imported-but-missing Plex cases should consider a confirmed Plex library refresh after read-only checks.
- Tautulli was added as a Docker container on 2026-05-25 using `lscr.io/linuxserver/tautulli:latest`, config path `C:\media-stack\config\tautulli`, and local Web UI `http://127.0.0.1:8181`. Initial validation showed container `tautulli` running, persistent config created, logs reporting `Tautulli is ready!`, and HTTP 200 from the welcome page. It still needs first-run Plex setup with a Plex token handled as a secret.
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

## Current Rebuilt Hardware

Purchased and installed:

- Motherboard: MSI PRO Z790-A WiFi II
- CPU: Intel Core i5-14500 SRN3T
- RAM: Lexar Thor Z DDR5 32GB Kit, 2x16GB, 6000MHz
- CPU Cooler: Noctua NH-U9S chromax.black

Reused:

- Case: SilverStone GD07
- PSU: Corsair RM750e
- GPU: GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G, GV-N3050WF2OC-6GD, slot-powered
- OS drive: Samsung SSD 840 EVO 250GB
- Media/data drives: 6 fixed SATA HDD volumes currently detected after the 2026-05-25 drive swap; former broken-pin 20 TB drive is on hand but not installed

## Documentation Style

Use markdown.
Prefer tables and checklists.
Keep advice practical and hardware-safe.
When adding new findings, update the relevant docs instead of scattering notes.
