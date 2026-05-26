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

## Current Gaps

- Complete or confirm the first-run Plex connection setup.
- Verify Tautulli can see the Plex server identity and libraries.
- Start one controlled Plex playback and verify it appears as an active stream.
- Stop playback and verify it lands in Tautulli history.
