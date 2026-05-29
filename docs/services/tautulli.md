# Tautulli

## Purpose

Tautulli is the Plex monitoring and history companion. It records active streams, play history, users, clients, bandwidth, and notification events. It does not manage media files, trigger downloads, search indexers, or import content.

## Deployment

| Item | Value |
|---|---|
| Deployment | Docker container |
| Container name | `tautulli` |
| Image | `lscr.io/linuxserver/tautulli:latest` |
| Compose file | `C:\plex-server\docker-compose.media.yml` |
| Config path | `C:\media-stack\config\tautulli` |
| Web UI | `http://localhost:8181` |
| Docker restart policy | `unless-stopped` |
| Added | 2026-05-25 |

Tautulli has no media-drive mounts in the compose file. Its normal integration path is the Plex HTTP API, using the native Windows Plex server and a Plex token handled as a local secret.

## First-Run Plex Setup Notes

Use the local Web UI at `http://localhost:8181` and connect Tautulli to the native Windows Plex server.

| Field / choice | Value / guidance |
|---|---|
| Plex server | Native Windows Plex Media Server |
| Plex URL | Prefer `http://host.docker.internal:32400` from inside Docker if Tautulli cannot auto-discover Plex |
| Plex token | Retrieve only at setup time; treat as a local secret |
| Authentication method | Use the Tautulli wizard's Plex sign-in or manually paste the Plex token |
| Remote access | Keep Tautulli bound to localhost unless a separate secure remote-access design is chosen |
| Notifications | Leave unconfigured until a destination and secret-handling plan are chosen |

Safe first-run order:

1. Open `http://localhost:8181`.
2. Complete the Tautulli welcome wizard.
3. Connect to the existing native Windows Plex server.
4. If auto-discovery fails, use `http://host.docker.internal:32400` as the Plex server URL.
5. Provide the Plex token only in the Tautulli UI or at runtime for an immediate local API check.
6. Confirm Tautulli lists the expected Plex server identity and libraries.
7. Start one short controlled Plex playback.
8. Verify the stream appears under Tautulli activity.
9. Stop playback and verify the play event lands in Tautulli history.

## Plex Token Handling

- Do not write the Plex token into this repository, markdown notes, scripts, command transcripts, Git commits, or GitHub.
- Do not paste the token into final reports or shared logs.
- If a token is needed for a one-off local API check, read it at runtime and redact it from output.
- The token normally appears in a Plex Web request URL or browser address bar as `X-Plex-Token=...`; it is not normally visible in the XML response body.
- If copying a Plex Web URL for setup help, redact the token before saving or reporting it.
- Tautulli may store the token in its local config database under `C:\media-stack\config\tautulli`; treat that whole config folder as secret-bearing operational data, not repo content.

## Reads From

| Source | Purpose |
|---|---|
| Plex HTTP API | Server identity, libraries, sessions, history, users |
| Plex token | Authenticates to Plex; must remain secret |

## Writes To / Sends To

| Target | Purpose |
|---|---|
| Tautulli config/database | Stores history, settings, notifier config |
| Notification services, optional | Sends activity/outage/newsletter notifications if configured |

## Operational Rules

- Treat Tautulli as read-only monitoring unless the user explicitly asks for notifications, newsletters, or scripts.
- Do not expose the Tautulli Web UI beyond localhost unless remote access is intentionally designed and secured.
- Do not commit Tautulli API keys, Plex tokens, notification credentials, or generated config files.
- Do not reset or delete Tautulli config while investigating setup unless its current state has been backed up.

## Current Gaps

- [ ] Complete or confirm the first-run Plex connection setup.
- [ ] Verify Tautulli can see the Plex server identity and libraries.
- [ ] Start one controlled Plex playback and verify it appears as an active stream.
- [ ] Stop playback and verify it lands in Tautulli history.
- [ ] Decide whether any notifications are desired; if yes, document the destination without committing notification tokens.
