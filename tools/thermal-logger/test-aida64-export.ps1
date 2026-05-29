param(
    [int]$WaitSeconds = 10
)

$ErrorActionPreference = "Stop"

$aida64 = "C:\Program Files\FinalWire\AIDA64 Extreme\aida64.exe"
if (-not (Test-Path -LiteralPath $aida64)) {
    throw "AIDA64 executable not found at $aida64"
}

if (-not (Get-Process -Name "aida64" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $aida64 -ArgumentList "/SILENT", "/IDLE"
}

Start-Sleep -Seconds $WaitSeconds

PowerShell -NoProfile -ExecutionPolicy Bypass -File "C:\plex-server\tools\thermal-logger\start-libre-thermal-logger.ps1" -Once | Out-Null

$latest = Get-ChildItem "C:\plex-server\docs\crash_logs\thermal" -Filter "libre-sensors-*.csv" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $latest) {
    throw "No thermal logger CSV files were found."
}

$rows = Import-Csv $latest.FullName
$aidaRows = @($rows | Where-Object { $_.hardware_type -eq "AIDA64" })
$fanRows = @($aidaRows | Where-Object { $_.sensor_type -eq "Fan" })
$boardRows = @($aidaRows | Where-Object { $_.sensor_type -in @("Temperature", "Voltage") })

[pscustomobject]@{
    LogFile = $latest.FullName
    Aida64ProcessRunning = [bool](Get-Process -Name "aida64" -ErrorAction SilentlyContinue)
    Aida64Rows = $aidaRows.Count
    Aida64FanRows = $fanRows.Count
    Aida64TempVoltageRows = $boardRows.Count
    Aida64Sensors = ($aidaRows | Select-Object -First 40 sensor_type, sensor_name, value, unit)
    NextStep = if ($aidaRows.Count -eq 0) { "Enable AIDA64 External Applications shared memory or registry export, then rerun this script." } else { "AIDA64 export is visible to the project logger." }
}
