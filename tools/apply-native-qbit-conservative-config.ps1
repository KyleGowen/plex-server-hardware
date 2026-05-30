$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$trackedConfig = Join-Path $repoRoot 'config\qbittorrent\native-conservative\qBittorrent.ini'
$runtimeDir = Join-Path $env:APPDATA 'qBittorrent'
$runtimeConfig = Join-Path $runtimeDir 'qBittorrent.ini'
$downloadRoot = 'I:\torrentfiles'
$incompleteRoot = Join-Path $downloadRoot 'incomplete'

if (-not (Test-Path -LiteralPath $trackedConfig)) {
    throw "Tracked config not found: $trackedConfig"
}

if (-not (Test-Path -LiteralPath $downloadRoot)) {
    throw "Download root is missing: $downloadRoot"
}

New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null
New-Item -ItemType Directory -Force -Path $incompleteRoot | Out-Null

$existingPasswordLine = $null
if (Test-Path -LiteralPath $runtimeConfig) {
    $existingPasswordLine = Get-Content -LiteralPath $runtimeConfig |
        Where-Object { $_ -match '^WebUI\\Password_PBKDF2=' } |
        Select-Object -First 1

    $backupPath = Join-Path $runtimeDir ("qBittorrent.ini.bak.{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Copy-Item -LiteralPath $runtimeConfig -Destination $backupPath -Force
}

if (-not $existingPasswordLine) {
    throw 'No existing WebUI password hash was found. Start qBittorrent once and set a WebUI password, then rerun this script.'
}

$trackedLines = Get-Content -LiteralPath $trackedConfig |
    Where-Object { $_ -notmatch '^WebUI\\Password_PBKDF2=' }

$output = New-Object System.Collections.Generic.List[string]
$insertedPassword = $false

foreach ($line in $trackedLines) {
    if (-not $insertedPassword -and $line -match '^WebUI\\Port=') {
        $output.Add($existingPasswordLine)
        $insertedPassword = $true
    }
    $output.Add($line)
}

if (-not $insertedPassword) {
    $output.Add($existingPasswordLine)
}

$output | Set-Content -LiteralPath $runtimeConfig -Encoding UTF8

[pscustomobject]@{
    RuntimeConfig = $runtimeConfig
    TrackedConfig = $trackedConfig
    DownloadRoot = $downloadRoot
    IncompleteRoot = $incompleteRoot
    PasswordHashPreserved = $true
}
