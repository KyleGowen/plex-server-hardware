param(
    [string]$LogPath = "C:\plex-server\docs\admin_stability_hardening_log.txt"
)

$ErrorActionPreference = "Continue"

function Write-Log {
    param([string]$Message)
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$stamp  $Message" | Tee-Object -FilePath $LogPath -Append
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $LogPath) | Out-Null
Write-Log "Starting admin stability hardening."

Write-Log "Creating C:\Windows\Minidump."
New-Item -ItemType Directory -Force -Path "C:\Windows\Minidump" | Out-Null

Write-Log "Configuring crash capture: small memory dumps, no automatic reboot."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name CrashDumpEnabled -Type DWord -Value 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name AutoReboot -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name LogEvent -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name MinidumpDir -Type ExpandString -Value "%SystemRoot%\Minidump"
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" |
    Select-Object CrashDumpEnabled,AutoReboot,MinidumpDir,DumpFile,LogEvent |
    Format-List | Out-String | ForEach-Object { Write-Log $_.TrimEnd() }

Write-Log "Disabling hibernation and Fast Startup with powercfg -h off."
powercfg -h off 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Ensuring PCIe Link State Power Management is disabled."
powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 2>&1 | Tee-Object -FilePath $LogPath -Append
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Ensuring USB selective suspend is disabled."
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>&1 | Tee-Object -FilePath $LogPath -Append
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>&1 | Tee-Object -FilePath $LogPath -Append
powercfg /setactive SCHEME_CURRENT 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Running DISM health check."
DISM /Online /Cleanup-Image /CheckHealth 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Running SFC verification only."
sfc /verifyonly 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Running online C: file-system scan."
chkdsk C: /scan 2>&1 | Tee-Object -FilePath $LogPath -Append

Write-Log "Admin stability hardening complete."
