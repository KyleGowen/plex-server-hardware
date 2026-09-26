param(
    [string]$ProjectRoot = "C:\plex-server",
    [switch]$Apply,
    [switch]$SkipDocumentation,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$PackageId = "qBittorrent.qBittorrent"
$Executable = "C:\Program Files\qBittorrent\qbittorrent.exe"
$WebUri = "http://127.0.0.1:8080"
$LedgerPath = Join-Path $ProjectRoot "docs\service_versions.json"
$HealthScript = Join-Path $ProjectRoot "skills\plex-stack-health-check\scripts\Test-PlexStackHealth.ps1"

function Invoke-Winget {
    param([string[]]$Arguments)
    $output = & winget @Arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        $details = @()
        $packageMatch = [regex]::Match($output, '(?m)^Found .+ Version\s+(\S+)\s*$')
        $installerMatch = [regex]::Match($output, '(?m)Installer failed with exit code:\s*(\d+)')
        if ($packageMatch.Success) { $details += "package version $($packageMatch.Groups[1].Value)" }
        if ($installerMatch.Success) { $details += "installer exit $($installerMatch.Groups[1].Value)" }
        $suffix = if ($details.Count) { " (" + ($details -join ", ") + ")" } else { "" }
        throw "winget failed with exit code $LASTEXITCODE$suffix."
    }
    return $output
}

function Get-InstalledVersion {
    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $item = Get-ItemProperty $paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq "qBittorrent" } | Select-Object -First 1
    if (-not $item.DisplayVersion) { throw "The installed qBittorrent version was not found." }
    return [string]$item.DisplayVersion
}

function Get-LatestVersion {
    $output = Invoke-Winget -Arguments @("show", "--id", $PackageId, "--exact", "--accept-source-agreements", "--disable-interactivity")
    $match = [regex]::Match($output, '(?m)^Version:\s*(\S+)\s*$')
    if (-not $match.Success) { throw "The latest qBittorrent version could not be parsed from winget." }
    return $match.Groups[1].Value
}

function Wait-ForWebUi {
    $deadline = [DateTime]::UtcNow.AddMinutes(2)
    do {
        try {
            $response = Invoke-WebRequest -Uri $WebUri -UseBasicParsing -TimeoutSec 10
            if ($response.StatusCode -eq 200) { return }
        } catch {
            # qBittorrent may still be starting.
        }
        Start-Sleep -Seconds 4
    } while ([DateTime]::UtcNow -lt $deadline)
    throw "qBittorrent did not restore its Web UI after the update."
}

function Assert-StackHealthy {
    if (-not (Test-Path -LiteralPath $HealthScript)) { throw "Stack health helper not found: $HealthScript" }
    $healthText = & powershell -NoProfile -ExecutionPolicy Bypass -File $HealthScript -JsonSummary | Out-String
    if ($LASTEXITCODE -ne 0) { throw "The stack health helper failed after the qBittorrent update." }
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
    $signature = $Failure.ToLowerInvariant()
    $signature = [regex]::Replace($signature, 'package version\s+[^\s,)]+', 'package version <target>')
    return $signature
}

function Update-Ledger {
    param([string]$Version, [bool]$Updated, [string]$Result, [string]$AttemptedVersion, [string]$Failure)
    if ($SkipDocumentation) { return }
    $ledger = if (Test-Path -LiteralPath $LedgerPath) { Get-Content -Raw -LiteralPath $LedgerPath | ConvertFrom-Json } else { [pscustomobject]@{ schema_version = 2; updated_at = $null; services = [pscustomobject]@{} } }
    $now = [DateTimeOffset]::Now.ToString("o")
    $previous = $ledger.services.PSObject.Properties["qbittorrent"]
    $previousValue = if ($previous) { $previous.Value } else { $null }
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
        release_channel = "stable"
        installed_version = $Version
        image = $null
        image_digest = $null
        attempted_version = if ($Result -eq "failed") { $AttemptedVersion } else { $null }
        last_checked_at = $now
        last_successful_check_at = $lastSuccessfulCheck
        last_updated_at = if ($Updated) { $now } elseif ($previousValue) { $previousValue.last_updated_at } else { $null }
        last_result = $Result
        last_error = $Failure
        failure_signature = $failureSignature
        consecutive_failures = $consecutiveFailures
    }
    if ($previous) { $previous.Value = $entry } else { $ledger.services | Add-Member -NotePropertyName "qbittorrent" -NotePropertyValue $entry }
    $ledger.updated_at = $now
    $ledger | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $LedgerPath -Encoding utf8
}

$installed = "unknown"
$latest = $null
$updateAvailable = $false
$updated = $false
$resultName = "unknown"
$wasRunning = $false

try {
    if (-not (Test-Path -LiteralPath "I:\torrentfiles")) { throw "Required download root I:\torrentfiles is unavailable." }
    $installed = Get-InstalledVersion
    $latest = Get-LatestVersion
    $updateAvailable = ([version]$installed -lt [version]$latest)
    $resultName = if ($updateAvailable) { "update_available" } else { "current" }
    $wasRunning = [bool](Get-Process -Name "qbittorrent" -ErrorAction SilentlyContinue)

    if ($Apply -and $updateAvailable) {
        Invoke-Winget -Arguments @("upgrade", "--id", $PackageId, "--exact", "--accept-source-agreements", "--accept-package-agreements", "--silent", "--disable-interactivity") | Out-Null
        $installed = Get-InstalledVersion
        if ([version]$installed -lt [version]$latest) { throw "qBittorrent remains at $installed after attempting to install $latest." }
        if ($wasRunning -and -not (Get-Process -Name "qbittorrent" -ErrorAction SilentlyContinue)) {
            Start-Process -FilePath $Executable
        }
        if ($wasRunning) { Wait-ForWebUi }
        Assert-StackHealthy
        $updated = $true
        $resultName = "updated"
    }
    if ($Apply) { Update-Ledger -Version $installed -Updated $updated -Result $resultName }
} catch {
    $originalError = $_
    $failure = Get-SafeFailureSummary -ErrorRecord $originalError
    $attemptedMatch = [regex]::Match($failure, 'package version\s+([^\s,)]+)')
    if ($attemptedMatch.Success) { $latest = $attemptedMatch.Groups[1].Value }
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
    service = "qbittorrent"
    mode = if ($Apply) { "apply" } else { "check-only" }
    release_channel = "stable"
    installed_version = $installed
    latest_version = $latest
    update_available = $updateAvailable
    updated = $updated
    result = $resultName
    documentation_required = ($updated -and -not $SkipDocumentation)
}
if ($Json) { $summary | ConvertTo-Json -Compress } else { $summary | Format-List }
