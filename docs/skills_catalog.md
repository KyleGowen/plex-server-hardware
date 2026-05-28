# Codex Skills Catalog

## Purpose

Catalog the skills available for this project and what they can do. Use this file to pick the right workflow without rediscovering it each time.

---

# Project Media Skills

| Skill | Location | Mutability | Use when | What it can do |
|---|---|---|---|---|
| `arr-current-downloads` | `skills/arr-current-downloads` | Read-only | User asks what is downloading now | Lists active Arr-managed qBittorrent downloads only, filtering to Sonarr/Radarr/Lidarr/Readarr categories and omitting unrelated/manual torrents |
| `plex-stack-health-check` | `skills/plex-stack-health-check` | Read-only | User asks to validate stack health, Docker containers, service ports, config folders, Windows media paths, or the qBittorrent `/downloads` mount | Runs a detailed redacted PowerShell validation report covering `docker ps -a`, expected containers, optional Jackett status, service TCP ports, config folders, Windows paths, and qBittorrent container mount capacity/writability |
| `media-internet-search` | `tools/codex-skills/media-internet-search` and installed at `C:\Users\Kyle\.codex\skills\media-internet-search` | Read-only | Any public internet lookup for movie, film, TV, series, episode, franchise, collection, release, cast/crew, chronology, production, title/year, or media identity facts | Researches public media facts with authoritative cross-checking, resolves ambiguity, returns sources, and hands back to the main agent or relevant Plex skill without mutating local services |
| `overnight-media-audit` | `tools/codex-skills/overnight-media-audit` | Read-only | User asks what downloaded, completed, imported, or got stuck overnight | Reports Sonarr/Radarr imports, qBittorrent completions, stuck queue items, and health blockers for a time window |
| `add-media-to-plex` | `tools/codex-skills/add-media-to-plex` | Mutates Arr state and can trigger searches | User asks to add/search/download a movie or show for Plex | Uses Radarr for movies and Sonarr for TV, adds monitored media, triggers Arr search, and verifies queue handoff |

## Project Skill Rules

- Read-only skills must not trigger searches, downloads, imports, refreshes, deletes, moves, torrent actions, or path repairs.
- `media-internet-search` is mandatory before direct public-web media fact lookups by the main agent or any project skill.
- Use `media-internet-search` before `add-media-to-plex` when title identity, year, media type, collection membership, chronology, remake/reboot status, or similarly named media could affect the requested action.
- `add-media-to-plex` can mutate Sonarr/Radarr and trigger searches because that is its purpose.
- Plex library refreshes are never part of these skills unless the user separately confirms a Plex refresh.
- All skills must keep API keys, qBittorrent credentials, tracker credentials, passkeys, cookies, tokens, hashes, magnets, and secret URLs out of repo docs and final reports.

---

# General Codex Skills

| Skill | Use when | What it can do |
|---|---|---|
| `imagegen` | A task needs AI-created or edited bitmap visuals | Generate or edit raster images, illustrations, mockups, sprites, textures, or transparent cutouts |
| `openai-docs` | User asks how to build with OpenAI products or APIs | Use up-to-date official OpenAI documentation with citations and model guidance |
| `plugin-creator` | User wants a new personal Codex plugin scaffold | Create plugin directories, manifests, optional plugin folders, and marketplace entries |
| `skill-creator` | User wants to create or update a Codex skill | Guide effective skill design, structure, and instructions |
| `skill-installer` | User wants to list or install Codex skills | Install curated skills or skills from GitHub into the Codex skills directory |

---

# Browser And GitHub Plugin Skills

| Skill / plugin capability | Use when | What it can do |
|---|---|---|
| Browser automation | User asks to open, inspect, navigate, click, type, screenshot, or verify local web targets | Drive the Codex in-app browser for localhost, file URLs, and relevant web UIs |
| GitHub triage | User asks for repo, issue, or PR context | Inspect repositories, summarize PRs/issues, and orient GitHub work |
| Address PR comments | User asks to resolve PR review feedback | Inspect unresolved review threads and implement selected fixes |
| Fix CI | User asks to debug failing PR checks | Inspect GitHub Actions checks/logs, identify failures, and implement fixes |
| Publish draft PR workflow | User asks to publish local changes | Confirm scope, commit intentionally, push branch, and open a draft PR |

---

# Plex Stack Operational Notes

| Action | Skill / workflow | Confirmation rule |
|---|---|---|
| Report current downloads | `arr-current-downloads` | Read-only; no confirmation needed |
| Validate local stack health | `plex-stack-health-check` | Read-only; no confirmation needed |
| Report overnight activity | `overnight-media-audit` | Read-only; no confirmation needed |
| Add/search/download media | `add-media-to-plex` | User request to add/search/download is enough for Arr mutation; still protect secrets |
| Refresh Plex library | Plex HTTP API/manual Plex workflow | Requires explicit confirmation because it is a Plex write action |
| Start/stop/remove torrents | qBittorrent API/Web UI | Confirm paths/categories/mounts first; destructive actions need explicit instruction |
| Repair paths or drive letters | Manual storage/service workflow | Requires careful evidence and explicit user confirmation |
| Inspect crashes | Crash tracker workflow | Start read-only with Event Viewer/Reliability Monitor/log evidence |
