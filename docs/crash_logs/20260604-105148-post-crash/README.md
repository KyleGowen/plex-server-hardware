# 2026-06-04 10:51:48 AM Post-Crash Evidence

Captured after user reported another machine crash.

- Previous shutdown recorded by Windows: 2026-06-04 10:51:48 AM local.
- Current boot at capture: 06/04/2026 10:59:46.
- Pattern: hard reset / unexpected shutdown with Kernel-Power 41, EventLog 6008, and WHEA-Logger Event 1.
- Dump status: no minidump, no MEMORY.DMP, no LiveKernelReports dump found.
- WHEA: latest record persisted as latest-whea.cper and decoded in latest-whea-decoded.json.
- qBittorrent: only redacted native summary persisted; raw qBittorrent log intentionally omitted because it can contain torrent names or tracker-adjacent details.
- Thermal: see thermal-coverage-summary.json. Current logger output appears to begin after reboot, so this bundle does not prove pre-crash temperatures.
