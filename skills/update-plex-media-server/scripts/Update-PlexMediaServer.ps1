param(
    [string]$ProjectRoot = "C:\plex-server",
    [switch]$Apply,
    [switch]$AllowActiveStreams,
    [switch]$SkipDocumentation,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$DownloadsApi = "https://plex.tv/api/downloads/5.json"
$IdentityUri = "http://127.0.0.1:32400/identity"
$SessionsUri = "http://127.0.0.1:32400/status/sessions"
$PlexRegistryPath = "HKCU:\Software\Plex, Inc.\Plex Media Server"
$Executable = "C:\Program Files\Plex\Plex Media Server\Plex Media Server.exe"
$LedgerPath = Join-Path $ProjectRoot "docs\service_versions.json"
$HealthScript = Join-Path $ProjectRoot "skills\plex-stack-health-check\scripts\Test-PlexStackHealth.ps1"

function Get-InstalledVersion {
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $item = Get-ItemProperty $paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "Plex Media Server*" } | Select-Object -First 1
    if (-not $item.DisplayVersion) { throw "Plex DisplayVersion is missing from the uninstall registry entry." }
    return [string]$item.DisplayVersion
}

function Get-LatestRelease {
    $catalog = Invoke-RestMethod -Uri $DownloadsApi -Headers @{ Accept = "application/json" } -TimeoutSec 30
    $release = @($catalog.computer.Windows.releases | Where-Object { $_.build -eq "windows-x86_64" }) | Select-Object -First 1
    if (-not $release -or -not $release.version -or -not $release.url -or -not $release.checksum) {
        throw "The official Plex download catalog did not contain a Windows x64 release."
    }
    return $release
}

function Get-CoreVersion {
    param([string]$Version)
    return ($Version -split "-", 2)[0]
}

function Assert-NoActiveStreams {
    if ($AllowActiveStreams) { return }
    $token = (Get-ItemProperty -LiteralPath $PlexRegistryPath -Name PlexOnlineToken -ErrorAction SilentlyContinue).PlexOnlineToken
    if (-not $token) { return }
    $response = Invoke-WebRequest -Uri $SessionsUri -Headers @{ "X-Plex-Token" = $token } -UseBasicParsing -TimeoutSec 15
    [xml]$sessions = $response.Content
    $count = [int]$sessions.MediaContainer.size
    if ($count -gt 0) { throw "Plex has $count active stream(s). Retry later or explicitly use -AllowActiveStreams." }
}

function Wait-ForPlex {
    param([string]$ExpectedVersion)
    $deadline = [DateTime]::UtcNow.AddMinutes(3)
    do {
        try {
            [xml]$identity = (Invoke-WebRequest -Uri $IdentityUri -UseBasicParsing -TimeoutSec 10).Content
            $actual = [string]$identity.MediaContainer.version
            if ((Get-CoreVersion $actual) -eq (Get-CoreVersion $ExpectedVersion)) { return $actual }
        } catch {
            # Plex may still be starting.
        }
        Start-Sleep -Seconds 5
    } while ([DateTime]::UtcNow -lt $deadline)
    throw "Plex did not report version $ExpectedVersion after the update."
}

function Assert-StackHealthy {
    if (-not (Test-Path -LiteralPath $HealthScript)) { throw "Stack health helper not found: $HealthScript" }
    $healthText = & powershell -NoProfile -ExecutionPolicy Bypass -File $HealthScript -JsonSummary | Out-String
    if ($LASTEXITCODE -ne 0) { throw "The stack health helper failed after the Plex update." }
    $health = $healthText | ConvertFrom-Json
    if (-not $health.ok) { throw "The media stack did not pass its post-update health check." }
}

function Get-SafeFailureSummary {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)
    $message = [string]$ErrorRecord.Exception.Message
    $firstLine = (($message -split "`r?`n", 2)[0]).Trim()
    $firstLine = [regex]::Replace($firstLine, 'https?://\S+', '<url>')
    if ($firstLine.Length -gt 300) { $firstLine = $firstLine.Substring(0, 300) }
    return $firstLine
}

function Get-FailureSignature {
    param([string]$Failure)
    return $Failure.ToLowerInvariant()
}

function Update-Ledger {
    param([string]$Version, [bool]$Updated, [string]$Result, [string]$AttemptedVersion, [string]$Failure)
    if ($SkipDocumentation) { return }
    if (Test-Path -LiteralPath $LedgerPath) {
        $ledger = Get-Content -Raw -LiteralPath $LedgerPath | ConvertFrom-Json
    } else {
        $ledger = [pscustomobject]@{ schema_version = 2; updated_at = $null; services = [pscustomobject]@{} }
    }
    $now = [DateTimeOffset]::Now.ToString("o")
    $previous = $ledger.services.PSObject.Properties["plex"]
    $previousValue = if ($previous) { $previous.Value } else { $null }
    $lastUpdated = if ($Updated) { $now } elseif ($previousValue) { $previousValue.last_updated_at } else { $null }
    $failureSignature = if ($Failure) { Get-FailureSignature -Failure $Failure } else { $null }
    $previousSignature = if ($previousValue -and $previousValue.PSObject.Properties["failure_signature"]) { [string]$previousValue.failure_signature } else { $null }
    $previousFailureCount = if ($previousValue -and $previousValue.PSObject.Properties["consecutive_failures"]) { [int]$previousValue.consecutive_failures } else { 0 }
    $consecutiveFailures = if ($Result -eq "failed") { if ($previousSignature -eq $failureSignature) { $previousFailureCount + 1 } else { 1 } } else { 0 }
    $lastSuccessfulCheck = if ($Result -eq "failed") {
        if ($previousValue -and $previousValue.PSObject.Properties["last_successful_check_at"]) { $previousValue.last_successful_check_at }
        elseif ($previousValue -and $previousValue.last_result -ne "failed") { $previousValue.last_checked_at }
        else { $null }
    } else { $now }
    $ledger.schema_version = 2
    $entry = [pscustomobject][ordered]@{
        deployment = "native-windows"
        release_channel = "public-stable"
        installed_version = $Version
        image = $null
        image_digest = $null
        attempted_version = if ($Result -eq "failed") { $AttemptedVersion } else { $null }
        last_checked_at = $now
        last_successful_check_at = $lastSuccessfulCheck
        last_updated_at = $lastUpdated
        last_result = $Result
        last_error = $Failure
        failure_signature = $failureSignature
        consecutive_failures = $consecutiveFailures
    }
    if ($previous) { $previous.Value = $entry } else { $ledger.services | Add-Member -NotePropertyName "plex" -NotePropertyValue $entry }
    $ledger.updated_at = $now
    $ledger | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $LedgerPath -Encoding utf8
}

$installed = "unknown"
$release = $null
$latest = $null
$updateAvailable = $false
$updated = $false
$resultName = "unknown"
$wasRunning = $false

try {
    $installed = Get-InstalledVersion
    $release = Get-LatestRelease
    $latest = [string]$release.version
    $updateAvailable = (Get-CoreVersion $installed) -ne (Get-CoreVersion $latest)
    $resultName = if ($updateAvailable) { "update_available" } else { "current" }
    $wasRunning = [bool](Get-Process -Name "Plex Media Server" -ErrorAction SilentlyContinue)

    if ($Apply -and $updateAvailable) {
        Assert-NoActiveStreams
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "plex-media-server-updater"
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
        $installerPath = Join-Path $tempRoot ([System.IO.Path]::GetFileName([string]$release.url))
        try {
            Invoke-WebRequest -Uri ([string]$release.url) -OutFile $installerPath -UseBasicParsing -TimeoutSec 300
            $actualHash = (Get-FileHash -LiteralPath $installerPath -Algorithm SHA1).Hash.ToLowerInvariant()
            if ($actualHash -ne ([string]$release.checksum).ToLowerInvariant()) { throw "The Plex installer checksum did not match the official catalog." }

            $process = Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT", "/NORESTART" -PassThru
            if (-not $process.WaitForExit(600000)) { throw "The Plex installer did not finish within 10 minutes." }
            if ($process.ExitCode -ne 0) { throw "The Plex installer exited with code $($process.ExitCode)." }
        } finally {
            if (Test-Path -LiteralPath $installerPath) { Remove-Item -LiteralPath $installerPath -Force }
        }

        $installed = Get-InstalledVersion
        if ((Get-CoreVersion $installed) -ne (Get-CoreVersion $latest)) { throw "Plex registry version is $installed after installing $latest." }
        if ($wasRunning -and -not (Get-Process -Name "Plex Media Server" -ErrorAction SilentlyContinue)) {
            Start-Process -FilePath $Executable -WindowStyle Hidden
        }
        if ($wasRunning) { Wait-ForPlex -ExpectedVersion $latest | Out-Null }
        Assert-StackHealthy
        $updated = $true
        $resultName = "updated"
    }
    if ($Apply) { Update-Ledger -Version $installed -Updated $updated -Result $resultName }
} catch {
    $originalError = $_
    $failure = Get-SafeFailureSummary -ErrorRecord $originalError
    if ($Apply -and -not $SkipDocumentation) {
        try {
            try { $installed = Get-InstalledVersion } catch { }
            Update-Ledger -Version $installed -Updated $false -Result "failed" -AttemptedVersion $latest -Failure $failure
        } catch {
            throw "$failure Ledger failure recording also failed: $(Get-SafeFailureSummary -ErrorRecord $_)"
        }
    }
    throw $originalError
}

$summary = [pscustomobject][ordered]@{
    service = "plex"
    mode = if ($Apply) { "apply" } else { "check-only" }
    release_channel = "public-stable"
    installed_version = $installed
    latest_version = $latest
    update_available = $updateAvailable
    updated = $updated
    result = $resultName
    documentation_required = ($updated -and -not $SkipDocumentation)
}
if ($Json) { $summary | ConvertTo-Json -Compress } else { $summary | Format-List }
