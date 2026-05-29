---
name: plex-stack-health-check
description: Run a read-only validation of Kyle's Windows-native Plex plus Docker Arr stack. Use when the user asks to check stack health, validate Docker containers, service ports, config folders, Windows media paths, qBittorrent downloads mount, or wants a redacted operational validation report.
---

# Plex Stack Health Check

## Goal

Produce a compact redacted validation report for the local Plex media server stack. Use detailed evidence only when the user asks for full details or the summary shows a failure that needs diagnosis.

The check is read-only. It validates:

- `docker ps -a` access and expected container state.
- Expected media stack containers.
- Optional Jackett status, preserving the rule that Jackett should stay disabled unless `legacy-jackett` is intentional.
- Service TCP ports.
- Config folders under the configured media stack config root.
- Windows media/download paths from `.env`.
- qBittorrent `/downloads` capacity and write visibility inside the container.

## Fast Path

Run summary mode from `C:\plex-server` by default:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\plex-stack-health-check\scripts\Test-PlexStackHealth.ps1 -SummaryOnly
```

Use the full report only when the user asks for evidence or troubleshooting detail:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File skills\plex-stack-health-check\scripts\Test-PlexStackHealth.ps1
```

## Reporting

Return the script output as the basis of the answer. Keep the normal response brief: summary counts plus any `FAIL` or `WARN` checks. Do not include per-check `Evidence` blocks unless the user asked for a full report or the evidence is necessary for the next decision.

Call out especially:

- Missing or stopped expected containers.
- Closed required service ports.
- Missing config folders.
- Missing Windows media/download paths.
- Any mismatch from the expected `I:\torrentfiles` qBittorrent host path.
- Any `/downloads` filesystem under 100 GB inside qBittorrent, because that likely indicates the tiny placeholder mount failure mode.

## Secret Handling

The script redacts sensitive-looking names and URL/query values before printing. Do not add raw credentials, API keys, tracker URLs, passkeys, cookies, tokens, hashes, magnets, or passwords to the final report.

If additional manual checks are needed, redact secrets before showing command output.
