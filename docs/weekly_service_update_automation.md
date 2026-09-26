# Weekly Service Update Automation

## Purpose

`Weekly Plex Ecosystem Updates` is the scheduled Codex maintenance task for the Plex server ecosystem. It checks all twelve managed services, installs safe stable updates, verifies the affected services, updates project documentation and the version ledger, and returns one consolidated report.

This runbook is the repository record for AgentOS and future operators. The active Codex automation is machine-local and is not committed to Git.

## Schedule And Runtime

| Setting | Value |
|---|---|
| Automation ID | `weekly-plex-ecosystem-updates` |
| Status | Active |
| Schedule | Every Monday at 2:00 AM |
| Time basis | Local host time, `America/Los_Angeles` |
| Project | `C:\plex-server` |
| Execution environment | Local saved project, not an isolated worktree |
| Coordinator model | GPT-5.6 Sol, high reasoning |
| Machine-local definition | `C:\Users\Kyle\.codex\automations\weekly-plex-ecosystem-updates\automation.toml` |

The local execution environment is intentional. The update helpers must reach native Windows services, Docker Desktop, the Docker engine, local service endpoints, and `I:\torrentfiles`.

## Managed Services

| Service | Skill | Deployment | Launch model | Update boundary |
|---|---|---|---|---|
| Plex Media Server | `update-plex-media-server` | Native Windows | GPT-5.6 Sol, high | Official public stable Windows x64 release; do not interrupt active streams |
| qBittorrent | `update-qbittorrent` | Native Windows | GPT-5.6 Sol, high | Stable WinGet release; do not mutate torrents |
| Docker Desktop | `update-docker-desktop` | Native Windows runtime | GPT-5.6 Sol, high | Stable WinGet release; wait for engine recovery and validate the stack |
| Sonarr | `update-sonarr` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Sonarr only |
| Radarr | `update-radarr` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Radarr only |
| Prowlarr | `update-prowlarr` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Prowlarr only |
| Bazarr | `update-bazarr` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Bazarr only |
| Tautulli | `update-tautulli` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Tautulli only |
| Uptime Kuma | `update-uptime-kuma` | Docker | GPT-5.6 Sol, high | Remain on the approved v1 image line; v2 needs separate approval and migration planning |
| Homarr | `update-homarr` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Homarr only |
| Unpackerr | `update-unpackerr` | Docker | GPT-5.6 Sol, medium | Configured `latest` image; recreate Unpackerr only and verify download storage |
| Jackett | `update-jackett` | Optional Docker profile | GPT-5.6 Sol, medium | Pull the legacy image when changed while preserving its disabled state |

Repo skill sources live under `skills/update-*`. Installed runtime copies live under `C:\Users\Kyle\.codex\skills\update-*`. Use the sync checklist in `docs/skills_catalog.md` after changing a skill.

## Execution Contract

1. Read `AGENTS.md` and follow its storage, service, and secret-handling rules.
2. Invoke every listed skill. Run independent check phases concurrently when supported. If delegation is unavailable, run the same checks concurrently in the coordinator; model guidance must not block the sweep.
3. Do not race Docker Desktop against container operations. When Docker Desktop needs an update, install it first, wait for the engine to recover, and validate the stack before updating containers.
4. Do not write `docs/service_versions.json` concurrently. Serialize update applications. A failed apply must leave a sanitized failure record with the installed pre-attempt state, authoritative attempted target, and recurrence count.
5. Apply every safe stable update authorized by the applicable skill. A failure in one service must not prevent checks for the remaining services.
6. Let each skill verify the affected service. Collect all successful update results, then read and patch only the affected `docs/services/<service>.md` records in one batch. Append one dated history entry per changed image or application.
7. Keep Jackett disabled, keep Uptime Kuma on v1, do not refresh Plex libraries, and do not mutate torrents, media, service paths, credentials, indexers, providers, or application settings.
8. Never commit downloaded installers, temporary update artifacts, credentials, tokens, cookies, hashes, magnets, private URLs, or raw secret-bearing output.

Parallel checks keep normal no-update runs quick. The mutation barriers are required because Docker Desktop can temporarily remove the Docker engine and every updater shares one JSON ledger.

After all apply runs finish, fetch official release notes concurrently through the upstream release API when available. Query only services whose application version changed. Prefer the installed target reported by the apply helper over a target seen during the earlier check because mutable package feeds can advance between phases.

## Version And Documentation State

`docs/service_versions.json` is the machine-readable version ledger. Each skill records the fields relevant to its deployment, including:

- installed application or container version
- release channel
- image, digest, image version label, source revision, and separately observed application version for Docker services
- Docker engine version where applicable
- last check time, last update time, and result
- attempted target, sanitized failure signature, and consecutive failure count for failed applies

The corresponding `docs/services/*.md` file is the human-readable service record. No-op checks update the ledger's check state but must not add noisy service-document history entries. Mutable labels such as Homarr's `main` are not sufficient evidence for a release number; report the digest/revision and say the application version is unknown when upstream identity cannot be resolved confidently.

## Report Contract

Every scheduled run ends with one Markdown table containing exactly one row per managed service:

| Service | Current version | Upgraded? | Official update notes |
|---|---|---|---|
| Example unchanged service | `1.2.3` | No | Not applicable |
| Example updated service | `2.0.0` | `1.9.0 -> 2.0.0` | Concise summary with an official source link |

Release notes are looked up only when the application version actually changed during that run. An image-only refresh with an unchanged application version is reported as `No` in `Upgraded?` with a brief image-refresh note. Use the official upstream source, summarize material changes, and write `Not published/found` when official notes are unavailable. Never invent release notes.

Add a short `Problems` section only when a check, update, verification, documentation write, or release-note lookup fails. Identify recurring failures using the ledger recurrence count, and include actionable details without exposing secrets.

## Maintenance

- When adding or removing a managed update skill, update this runbook, `docs/skills_catalog.md`, and the active automation together.
- When changing the schedule, model, safety boundary, report schema, or execution ordering, update both this runbook and the active Codex automation.
- Inspect the active automation in the Codex app or its machine-local definition when diagnosing scheduling behavior. Do not copy the machine-local file into the repository.
- After a failed run, use its `Problems` section and `docs/service_versions.json` to rerun only the affected skill unless a complete sweep is specifically needed.
