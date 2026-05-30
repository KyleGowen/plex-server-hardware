# Native qBittorrent Conservative Config

This directory tracks the conservative native Windows qBittorrent profile used to test qBittorrent without Docker Desktop or WSL networking.

`qBittorrent.ini` intentionally omits `WebUI\Password_PBKDF2`. The apply script preserves the local password hash from the installed Windows qBittorrent profile and inserts it into the runtime config outside the repository.

Runtime config path:

`%APPDATA%\qBittorrent\qBittorrent.ini`

Apply command from the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\apply-native-qbit-conservative-config.ps1
```

Safety notes:

- Keep Docker qBittorrent stopped while using native qBittorrent.
- Do not commit qBittorrent WebUI password hashes, tracker URLs, passkeys, torrent hashes, cookies, or magnet links.
- The native profile uses `I:\torrentfiles` and `I:\torrentfiles\incomplete`.
