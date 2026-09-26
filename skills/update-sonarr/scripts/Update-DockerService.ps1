param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("sonarr", "radarr", "prowlarr", "bazarr", "tautulli", "uptime-kuma", "homarr", "unpackerr", "jackett")]
    [string]$ServiceName,

    [string]$ProjectRoot = "C:\plex-server",
    [switch]$Apply,
    [switch]$SkipDocumentation,
    [switch]$Json
)

$ErrorActionPreference = "Stop"
$ComposeFile = Join-Path $ProjectRoot "docker-compose.media.yml"
$LedgerPath = Join-Path $ProjectRoot "docs\service_versions.json"
$HealthScript = Join-Path $ProjectRoot "skills\plex-stack-health-check\scripts\Test-PlexStackHealth.ps1"

$serviceSettings = @{
    "sonarr" = @{ Uri = "http://127.0.0.1:8989"; Optional = $false; Channel = "latest" }
    "radarr" = @{ Uri = "http://127.0.0.1:7878"; Optional = $false; Channel = "latest" }
    "prowlarr" = @{ Uri = "http://127.0.0.1:9696"; Optional = $false; Channel = "latest" }
    "bazarr" = @{ Uri = "http://127.0.0.1:6767"; Optional = $false; Channel = "latest" }
    "tautulli" = @{ Uri = "http://127.0.0.1:8181"; Optional = $false; Channel = "latest" }
    "uptime-kuma" = @{ Uri = "http://127.0.0.1:3001"; Optional = $false; Channel = "major-v1" }
    "homarr" = @{ Uri = "http://127.0.0.1:7575"; Optional = $false; Channel = "latest" }
    "unpackerr" = @{ Uri = $null; Optional = $false; Channel = "latest" }
    "jackett" = @{ Uri = "http://127.0.0.1:9117"; Optional = $true; Channel = "latest" }
}

function Invoke-Captured {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $previousPreference = $ErrorActionPreference
    try {
        # Windows PowerShell surfaces native stderr as ErrorRecord objects. Docker
        # writes normal pull progress there, so use the process exit code instead.
        $ErrorActionPreference = "Continue"
        $output = & $FilePath @Arguments 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "$FilePath failed with exit code $exitCode`: $($output.Trim())"
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = $output.Trim() }
}

function Get-ComposeImage {
    $arguments = @("compose", "-f", $ComposeFile)
    if ($serviceSettings[$ServiceName].Optional) { $arguments += @("--profile", "legacy-jackett") }
    $arguments += @("config", "--format", "json")
    $result = Invoke-Captured -FilePath "docker" -Arguments $arguments
    $config = $result.Output | ConvertFrom-Json
    $property = $config.services.PSObject.Properties[$ServiceName]
    if (-not $property) { throw "Service '$ServiceName' is not defined in $ComposeFile." }
    return [string]$property.Value.image
}

function Get-ContainerState {
    $result = Invoke-Captured -FilePath "docker" -Arguments @("inspect", $ServiceName, "--format", "{{json .State}}") -AllowFailure
    if ($result.ExitCode -ne 0) {
        return [pscustomobject]@{ Exists = $false; Running = $false; ImageDigest = $null }
    }
    $state = $result.Output | ConvertFrom-Json
    $digest = (Invoke-Captured -FilePath "docker" -Arguments @("inspect", $ServiceName, "--format", "{{.Image}}" )).Output
    return [pscustomobject]@{ Exists = $true; Running = [bool]$state.Running; ImageDigest = $digest }
}

function Get-RemoteDigest {
    param([string]$ImageRef)
    $result = Invoke-Captured -FilePath "docker" -Arguments @("buildx", "imagetools", "inspect", $ImageRef, "--format", "{{json .Manifest}}")
    $manifest = $result.Output | ConvertFrom-Json
    if (-not $manifest.digest) { throw "The registry did not return a digest for $ImageRef." }
    return [string]$manifest.digest
}

function Get-LocalDigest {
    param([string]$ImageRef)
    $result = Invoke-Captured -FilePath "docker" -Arguments @("image", "inspect", $ImageRef, "--format", "{{json .RepoDigests}}") -AllowFailure
    if ($result.ExitCode -ne 0 -or -not $result.Output) { return $null }
    $repoDigests = $result.Output | ConvertFrom-Json
    if (-not $repoDigests -or $repoDigests.Count -eq 0) { return $null }
    return ([string]$repoDigests[0] -split "@", 2)[1]
}

function Get-ImageMetadata {
    param([string]$ImageRef)
    $result = Invoke-Captured -FilePath "docker" -Arguments @("image", "inspect", $ImageRef)
    $image = @($result.Output | ConvertFrom-Json)[0]
    $labels = $image.Config.Labels
    $versionLabel = $null
    $applicationVersion = $null
    $sourceRevision = $null

    if ($labels -and $labels.build_version -match 'version:-\s*([^\s]+)') {
        $versionLabel = $Matches[1]
    } elseif ($labels -and $labels.'org.opencontainers.image.version') {
        $versionLabel = [string]$labels.'org.opencontainers.image.version'
    }
    if ($labels -and $labels.'org.opencontainers.image.revision') {
        $sourceRevision = [string]$labels.'org.opencontainers.image.revision'
    }

    if ($ServiceName -eq "uptime-kuma" -and (Get-ContainerState).Running) {
        $versionResult = Invoke-Captured -FilePath "docker" -Arguments @("exec", "uptime-kuma", "node", "-p", "require('/app/package.json').version") -AllowFailure
        if ($versionResult.ExitCode -eq 0 -and $versionResult.Output) { $applicationVersion = $versionResult.Output.Trim() }
    } elseif ($versionLabel -match '^(v?\d+(?:\.\d+)+)(?:-ls\d+)?$') {
        $applicationVersion = $Matches[1]
    }

    $installedVersion = if ($versionLabel) { $versionLabel } elseif ($applicationVersion) { $applicationVersion } else { "unknown" }
    return [pscustomobject][ordered]@{
        InstalledVersion = $installedVersion
        ApplicationVersion = if ($applicationVersion) { $applicationVersion } else { "unknown" }
        ImageVersionLabel = if ($versionLabel) { $versionLabel } else { "unknown" }
        ImageSourceRevision = $sourceRevision
    }
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
    $signature = [regex]::Replace($signature, 'sha256:[0-9a-f]+', 'sha256:<digest>')
    return $signature
}

function Assert-DockerAvailable {
    if (-not (Test-Path -LiteralPath $ComposeFile)) { throw "Compose file not found: $ComposeFile" }
    Invoke-Captured -FilePath "docker" -Arguments @("info", "--format", "{{.ServerVersion}}") | Out-Null
}

function Assert-StackHealthy {
    if (-not (Test-Path -LiteralPath $HealthScript)) { throw "Stack health helper not found: $HealthScript" }
    $healthText = & powershell -NoProfile -ExecutionPolicy Bypass -File $HealthScript -JsonSummary | Out-String
    if ($LASTEXITCODE -ne 0) { throw "The stack health helper failed." }
    $health = $healthText | ConvertFrom-Json
    if (-not $health.ok) { throw "The stack health helper found a failure or warning." }
}

function Assert-ServiceHealthy {
    param([bool]$ExpectedRunning)
    $deadline = [DateTime]::UtcNow.AddMinutes(3)
    do {
        $state = Get-ContainerState
        if (-not $ExpectedRunning) {
            if (-not $state.Running) { return }
        } elseif ($state.Running) {
            $uri = $serviceSettings[$ServiceName].Uri
            if (-not $uri) { return }
            try {
                $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 10
                if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) { return }
            } catch {
                # The service may still be starting.
            }
        }
        Start-Sleep -Seconds 5
    } while ([DateTime]::UtcNow -lt $deadline)

    if ($ExpectedRunning) { throw "$ServiceName did not become healthy after the update." }
    throw "$ServiceName started even though its prior state was disabled or stopped."
}

function Update-Ledger {
    param(
        [pscustomobject]$Metadata,
        [string]$ImageRef,
        [string]$Digest,
        [bool]$Updated,
        [string]$Result,
        [string]$AttemptedDigest,
        [string]$Failure
    )

    if ($SkipDocumentation) { return }
    if (Test-Path -LiteralPath $LedgerPath) {
        $ledger = Get-Content -Raw -LiteralPath $LedgerPath | ConvertFrom-Json
    } else {
        $ledger = [pscustomobject]@{ schema_version = 2; updated_at = $null; services = [pscustomobject]@{} }
    }

    $now = [DateTimeOffset]::Now.ToString("o")
    $previous = $ledger.services.PSObject.Properties[$ServiceName]
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
        deployment = if ($serviceSettings[$ServiceName].Optional) { "docker-optional" } else { "docker" }
        release_channel = $serviceSettings[$ServiceName].Channel
        installed_version = $Metadata.InstalledVersion
        application_version = $Metadata.ApplicationVersion
        image = $ImageRef
        image_digest = $Digest
        image_version_label = $Metadata.ImageVersionLabel
        image_source_revision = $Metadata.ImageSourceRevision
        attempted_image_digest = if ($Result -eq "failed") { $AttemptedDigest } else { $null }
        last_checked_at = $now
        last_successful_check_at = $lastSuccessfulCheck
        last_updated_at = $lastUpdated
        last_result = $Result
        last_error = $Failure
        failure_signature = $failureSignature
        consecutive_failures = $consecutiveFailures
    }
    if ($previous) {
        $previous.Value = $entry
    } else {
        $ledger.services | Add-Member -NotePropertyName $ServiceName -NotePropertyValue $entry
    }
    $ledger.updated_at = $now
    $ledger | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $LedgerPath -Encoding utf8
}

$settings = $serviceSettings[$ServiceName]
$imageRef = $null
$before = [pscustomobject]@{ Exists = $false; Running = $false; ImageDigest = $null }
$deployedDigest = $null
$remoteDigest = $null
$finalDigest = $null
$metadata = [pscustomobject]@{ InstalledVersion = "unknown"; ApplicationVersion = "unknown"; ImageVersionLabel = "unknown"; ImageSourceRevision = $null }
$updateAvailable = $false
$updated = $false
$resultName = "unknown"

try {
    Assert-DockerAvailable
    $imageRef = Get-ComposeImage
    if ($ServiceName -eq "uptime-kuma" -and $imageRef -notmatch ':1$') {
        throw "Uptime Kuma is no longer configured on the approved v1 image line. Handle this as a separately approved migration."
    }
    $before = Get-ContainerState
    $deployedDigest = if ($settings.Optional -and -not $before.Running) { Get-LocalDigest -ImageRef $imageRef } else { $before.ImageDigest }
    $remoteDigest = Get-RemoteDigest -ImageRef $imageRef
    $updateAvailable = ($deployedDigest -ne $remoteDigest)
    $resultName = if ($updateAvailable) { "update_available" } else { "current" }

    if ($Apply) {
        if ($updateAvailable) {
            $willRecreate = (-not $settings.Optional -or $before.Running)
            if ($willRecreate) { Assert-StackHealthy }
            $pullArgs = @("compose", "-f", $ComposeFile)
            if ($settings.Optional) { $pullArgs += @("--profile", "legacy-jackett") }
            $pullArgs += @("pull", $ServiceName)
            Invoke-Captured -FilePath "docker" -Arguments $pullArgs | Out-Null

            if ($willRecreate) {
                $upArgs = @("compose", "-f", $ComposeFile)
                if ($settings.Optional) { $upArgs += @("--profile", "legacy-jackett") }
                $upArgs += @("up", "-d", "--no-deps", $ServiceName)
                Invoke-Captured -FilePath "docker" -Arguments $upArgs | Out-Null
            }
            Assert-ServiceHealthy -ExpectedRunning $before.Running
            if ($willRecreate) { Assert-StackHealthy }
            $updated = $true
            $resultName = if ($settings.Optional -and -not $before.Running) { "image_updated_service_left_disabled" } else { "updated" }
        } else {
            Assert-ServiceHealthy -ExpectedRunning $before.Running
        }
    }

    $finalDigest = if ($Apply) { Get-LocalDigest -ImageRef $imageRef } else { $deployedDigest }
    if ($finalDigest) { $metadata = Get-ImageMetadata -ImageRef $imageRef }
    if ($Apply) {
        Update-Ledger -Metadata $metadata -ImageRef $imageRef -Digest $finalDigest -Updated $updated -Result $resultName
    }
} catch {
    $originalError = $_
    $failure = Get-SafeFailureSummary -ErrorRecord $originalError
    if ($Apply -and -not $SkipDocumentation) {
        try {
            if (-not $finalDigest -and $imageRef) { $finalDigest = Get-LocalDigest -ImageRef $imageRef }
            if ($finalDigest) { $metadata = Get-ImageMetadata -ImageRef $imageRef }
            Update-Ledger -Metadata $metadata -ImageRef $imageRef -Digest $finalDigest -Updated $false -Result "failed" -AttemptedDigest $remoteDigest -Failure $failure
        } catch {
            throw "$failure Ledger failure recording also failed: $(Get-SafeFailureSummary -ErrorRecord $_)"
        }
    }
    throw $originalError
}

$summary = [pscustomobject][ordered]@{
    service = $ServiceName
    mode = if ($Apply) { "apply" } else { "check-only" }
    image = $imageRef
    release_channel = $settings.Channel
    installed_version = $metadata.InstalledVersion
    application_version = $metadata.ApplicationVersion
    image_version_label = $metadata.ImageVersionLabel
    image_source_revision = $metadata.ImageSourceRevision
    deployed_digest = $deployedDigest
    remote_digest = $remoteDigest
    final_digest = $finalDigest
    update_available = $updateAvailable
    updated = $updated
    prior_running_state = $before.Running
    result = $resultName
    documentation_required = ($updated -and -not $SkipDocumentation)
}

if ($Json) {
    $summary | ConvertTo-Json -Compress
} else {
    $summary | Format-List
}
