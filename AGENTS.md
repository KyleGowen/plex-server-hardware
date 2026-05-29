# AGENTS.md - Plex Server Hardware Project

## Project Goal

Operate, stabilize, and document Kyle's rebuilt Windows-native Plex media server.

Current shape:

- Windows 10 OS SSD and existing media HDDs are preserved.
- Plex Media Server runs native on Windows.
- Sonarr, Radarr, Prowlarr, Bazarr, Tautulli, qBittorrent, and Unpackerr run in Docker.
- Jackett stays disabled unless the optional `legacy-jackett` profile is intentionally needed.
- The broken-power-pin HDD removal is the current probable stability lead, but do not call the crash issue fully solved until longer normal-operation soak data supports it.

For deeper context, read only the directly relevant file:

- Stability and crash notes: `docs/current_stability_crash_tracker.md`
- Thermal monitoring and crash sensor logs: `docs/thermal_monitoring.md`
- Service details: `docs/services/*.md`
- Skills and workflows: `docs/skills_catalog.md`
- Storage recovery: `docs/qbittorrent_startup_recovery.md`
- Hardware inventory: `docs/plex_server_hardware_inventory.md`

## Critical Safety Rules

- Do not recommend formatting, initializing, repartitioning, or wiping any existing media drive unless the user explicitly confirms it is blank.
- Do not assume a drive is disposable.
- Do not randomly reorder SATA drives or casually change drive letters.
- Confirm drive letters and root folders before repairing Plex, Sonarr, Radarr, Bazarr, Tautulli, qBittorrent, Jackett, or Unpackerr paths.
- Before trusting downloads after boot, crash, Docker restart, WSL restart, or storage work, confirm both `I:\torrentfiles` on Windows and `/downloads` inside qBittorrent.
- If `/downloads` inside qBittorrent appears as a tiny/full filesystem, restart Docker/WSL using the documented recovery flow instead of repeatedly restarting qBittorrent.
- The former `H:` / TV 2 volume is absent as of 2026-05-26. Do not allow Sonarr/Bazarr imports or subtitle writes to `/tv/tv2` while that root is missing.
- Use only Corsair RM750e-compatible modular PSU cables.
- Favor step-by-step checklists over broad advice.

## Token Discipline

- Prefer existing helper scripts and skills over manual multi-step API exploration.
- Read only the directly relevant docs, configs, or logs for the user's request.
- Summarize command output; do not paste full raw output unless the user asks or the raw evidence is necessary.
- For service APIs, request raw JSON/XML and parse only the fields needed for the decision.
- Use compact reports by default; expand to detailed evidence only when troubleshooting requires it.

## Secret Handling

- Treat tracker credentials, service usernames/passwords, cookies, passkeys, API keys, tokens, invite/account details, magnet links, torrent hashes, and private tracker URLs as local secrets.
- Never commit secrets to this repository, generated scripts, documentation, `.env` examples, logs intended for git, or GitHub.
- Before staging, committing, pushing, or opening a PR, scan changed files for secrets and remove or redact anything sensitive.
- Prefer reading service API keys from local config files or environment variables at runtime instead of hard-coding them.
- When reporting command output, redact secrets unless the user explicitly asks to view a credential for immediate local use.

## Permissions

Do not ask before running local read/discovery commands for this project, including:

- `git`
- `docker` or `docker compose`
- PowerShell
- harmless Python availability checks
- harmless path checks such as `Test-Path I:\torrentfiles`
- read-only Sonarr/Radarr/Prowlarr MCP calls if `mcp_arr` is available
- harmless waits such as `Start-Sleep -Seconds 60`
- public website searches

Still require explicit user confirmation for destructive storage actions, Plex library refreshes, deletes, metadata edits, path repairs, service setting changes, and torrent start/stop/remove/recheck/move actions unless a skill's documented purpose and the user's request explicitly authorize that mutation.

## Media And Skills Routing

- Use `docs/skills_catalog.md` to pick the leanest applicable workflow.
- For "what is downloading now", use `arr-current-downloads`.
- For overnight/new-media reports, use `overnight-media-audit`.
- For stack health, use `plex-stack-health-check`; default to summary output unless full evidence is requested.
- For public media facts, use `media-internet-search` when the request is ambiguous, current/future, collection/chronology-related, remake/reboot-sensitive, or otherwise needs sourced public research.
- For exact add requests where title, year, and media type are already clear, try the Arr lookup helper first and escalate to `media-internet-search` only if matching is ambiguous or not confident.
- Use `add-media-to-plex` only when the user explicitly asks to add, search, download, monitor, or request local media acquisition.
- Use `plex-collection-curator` for collection audit/create/fill/poster work, choosing the smallest mode implied by the request.

## Sonarr And Radarr Rules

- When adding a series to Sonarr, set `Monitored: true` unless the user explicitly asks otherwise.
- For series, monitor normal seasons by default and leave specials/season 0 unmonitored unless requested.
- When adding a movie to Radarr, set `Monitored: true` unless the user explicitly asks otherwise.
- Do not trigger automatic Arr searches/downloads unless the user explicitly asks for search/download/add-acquire behavior or the invoked skill specifically authorizes it.
- Sonarr's qBittorrent client should use Docker host `qbittorrent:8080`, category `tv-sonarr`, and shared `/downloads` paths.
- Radarr's qBittorrent client should use Docker host `qbittorrent:8080`, category `radarr`, and shared `/downloads` paths.

## Plex Rules

- Use the Plex HTTP API directly until a trustworthy Plex MCP server is selected and approved.
- Treat the Plex token as a secret. Read or receive it at runtime only; never write or print it.
- Prefer read-only Plex checks first: server identity, sections, metadata lookup, search, active activities, and scan status.
- If Arr shows media imported on disk but Plex does not show it, check the relevant Plex library and active activities before proposing a refresh.
- Plex library refreshes require explicit user confirmation. Current library sections: `1` is `TV Shows`; `2` is `Movies`.
- After a confirmed refresh, verify the expected show or movie appears in Plex.

## MCP And Fallbacks

- For Sonarr, Radarr, Lidarr, or Prowlarr, try `mcp_arr` first when it is available and credentialed.
- If `mcp_arr` is unavailable or stale, fall back to local config files, documented APIs, or service UIs without spending time debugging MCP.
- The `mcp_arr` wrapper is `.tools/mcp-arr/start-mcp-arr.ps1`; it reads local Arr API keys at startup.
- For qBittorrent state, use read-only `torrent_manager` if available; otherwise use local qBittorrent Web API/config/logs or the Web UI.
- qBittorrent Web API login may succeed with HTTP 204 and an `SID` cookie rather than an `Ok.` body.

## Documentation Style

Use markdown. Prefer tables and checklists. Keep advice practical and hardware-safe. Add new findings to the relevant doc instead of scattering notes.
