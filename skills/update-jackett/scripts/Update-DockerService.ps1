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

function Get-ImageVersion {
    param([string]$ImageRef)
    $result = Invoke-Captured -FilePath "docker" -Arguments @("image", "inspect", $ImageRef)
    $image = @($result.Output | ConvertFrom-Json)[0]
    $labels = $image.Config.Labels
    $version = $null

    if ($labels -and $labels.build_version -match 'version:-\s*([^\s]+)') {
        $version = $Matches[1]
    } elseif ($labels -and $labels.'org.opencontainers.image.version') {
        $version = [string]$labels.'org.opencontainers.image.version'
    }

    if ($ServiceName -eq "uptime-kuma" -and (Get-ContainerState).Running) {
        $versionResult = Invoke-Captured -FilePath "docker" -Arguments @("exec", "uptime-kuma", "node", "-p", "require('/app/package.json').version") -AllowFailure
        if ($versionResult.ExitCode -eq 0 -and $versionResult.Output) { $version = $versionResult.Output.Trim() }
    }

    if (-not $version) { $version = "unknown" }
    return $version
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
        [string]$Version,
        [string]$ImageRef,
        [string]$Digest,
        [bool]$Updated,
        [string]$Result
    )

    if ($SkipDocumentation) { return }
    if (Test-Path -LiteralPath $LedgerPath) {
        $ledger = Get-Content -Raw -LiteralPath $LedgerPath | ConvertFrom-Json
    } else {
        $ledger = [pscustomobject]@{ schema_version = 1; updated_at = $null; services = [pscustomobject]@{} }
    }

    $now = [DateTimeOffset]::Now.ToString("o")
    $previous = $ledger.services.PSObject.Properties[$ServiceName]
    $lastUpdated = if ($Updated) { $now } elseif ($previous) { $previous.Value.last_updated_at } else { $null }
    $entry = [pscustomobject][ordered]@{
        deployment = if ($serviceSettings[$ServiceName].Optional) { "docker-optional" } else { "docker" }
        release_channel = $serviceSettings[$ServiceName].Channel
        installed_version = $Version
        image = $ImageRef
        image_digest = $Digest
        last_checked_at = $now
        last_updated_at = $lastUpdated
        last_result = $Result
    }
    if ($previous) {
        $previous.Value = $entry
    } else {
        $ledger.services | Add-Member -NotePropertyName $ServiceName -NotePropertyValue $entry
    }
    $ledger.updated_at = $now
    $ledger | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $LedgerPath -Encoding utf8
}

Assert-DockerAvailable
$settings = $serviceSettings[$ServiceName]
$imageRef = Get-ComposeImage
if ($ServiceName -eq "uptime-kuma" -and $imageRef -notmatch ':1$') {
    throw "Uptime Kuma is no longer configured on the approved v1 image line. Handle this as a separately approved migration."
}
$before = Get-ContainerState
$deployedDigest = if ($settings.Optional -and -not $before.Running) { Get-LocalDigest -ImageRef $imageRef } else { $before.ImageDigest }
$remoteDigest = Get-RemoteDigest -ImageRef $imageRef
$updateAvailable = ($deployedDigest -ne $remoteDigest)
$updated = $false
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
$version = if ($finalDigest) { Get-ImageVersion -ImageRef $imageRef } else { "not-pulled" }
if ($Apply) {
    Update-Ledger -Version $version -ImageRef $imageRef -Digest $finalDigest -Updated $updated -Result $resultName
}

$summary = [pscustomobject][ordered]@{
    service = $ServiceName
    mode = if ($Apply) { "apply" } else { "check-only" }
    image = $imageRef
    release_channel = $settings.Channel
    installed_version = $version
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
