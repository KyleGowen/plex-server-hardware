param(
    [string]$LogPath = "C:\plex-server\docs\admin_system_repair_log.txt"
)

$ErrorActionPreference = "Continue"

function Write-Log {
    param([string]$Message)
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$stamp  $Message" | Tee-Object -FilePath $LogPath -Append
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $LogPath) | Out-Null
Write-Log "Starting admin system repair pass."

Write-Log "Running DISM /Online /Cleanup-Image /RestoreHealth."
DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Running sfc /scannow."
sfc /scannow 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Admin system repair pass complete."
