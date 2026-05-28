param(
    [string]$ProjectRoot = "C:\plex-server",
    [string]$ComposeFile = "docker-compose.media.yml",
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"

$secretNamePattern = '(?i)(api[_-]?key|apikey|token|secret|password|passwd|pwd|cookie|session|sid|passkey|announce|tracker|credential|auth)'
$secretValuePattern = '(?i)(X-Plex-Token=)[^&\s]+|([?&](?:apikey|api_key|token|passkey|password|sid)=)[^&\s]+|(Bearer\s+)[A-Za-z0-9._~+\/=-]+'

$script:Results = New-Object System.Collections.Generic.List[object]
$script:DockerArgs = @()

function Redact-Text {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) { return "" }
    $text = [string]$Value
    $text = [regex]::Replace($text, $secretValuePattern, {
        param($match)
        if ($match.Groups[1].Success) { return $match.Groups[1].Value + "[REDACTED]" }
        if ($match.Groups[2].Success) { return $match.Groups[2].Value + "[REDACTED]" }
        if ($match.Groups[3].Success) { return $match.Groups[3].Value + "[REDACTED]" }
        return "[REDACTED]"
    })
    return $text
}

function Redact-Value {
    param(
        [string]$Name,
        [AllowNull()][object]$Value
    )

    if ($Name -match $secretNamePattern) { return "[REDACTED]" }
    return Redact-Text $Value
}

function Add-Check {
    param(
        [string]$Group,
        [string]$Name,
        [ValidateSet("PASS", "WARN", "FAIL", "SKIP", "INFO")]
        [string]$Status,
        [string]$Detail
    )

    $script:Results.Add([pscustomobject]@{
        Group = $Group
        Name = $Name
        Status = $Status
        Detail = Redact-Text $Detail
    })
}

function ConvertTo-WindowsPathText {
    param([string]$Path)

    if (-not $Path) { return "" }
    return ($Path -replace '/', '\')
}

function Normalize-PathForCompare {
    param([string]$Path)

    return (ConvertTo-WindowsPathText $Path).TrimEnd('\').ToLowerInvariant()
}

function Invoke-Docker {
    param([string[]]$Arguments)

    & docker @script:DockerArgs @Arguments
}

function Read-DotEnv {
    param([string]$Path)

    $values = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Check "Project files" ".env file" "FAIL" "Missing env file: $Path"
        return $values
    }

    Add-Check "Project files" ".env file" "PASS" "Found env file: $Path"
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $Path) {
        $lineNumber++
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith("#")) { continue }
        if ($trimmed -notmatch '^\s*([^=]+?)\s*=\s*(.*)\s*$') {
            Add-Check "Project files" ".env line $lineNumber" "WARN" "Could not parse line; value not displayed."
            continue
        }
        $name = $matches[1].Trim()
        $value = $matches[2].Trim().Trim('"').Trim("'")
        $values[$name] = $value
    }

    return $values
}

function Get-EnvValue {
    param(
        [hashtable]$Env,
        [string]$Name,
        [string]$Default = ""
    )

    if ($Env.ContainsKey($Name) -and $Env[$Name]) { return $Env[$Name] }
    return $Default
}

function Test-TcpPort {
    param(
        [string]$HostName,
        [int]$Port,
        [int]$TimeoutMs = 1200
    )

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $async = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) { return $false }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Resolve-ProjectPath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return Join-Path $ProjectRoot $Path
}

function Get-ContainerMap {
    $containers = @{}
    try {
        $raw = Invoke-Docker @("ps", "-a", "--format", "{{json .}}") 2>&1
        if ($LASTEXITCODE -ne 0) {
            Add-Check "Docker" "docker ps -a" "FAIL" ($raw -join "`n")
            return $containers
        }
        Add-Check "Docker" "docker ps -a" "PASS" "Docker responded with $(@($raw).Count) container rows."
        foreach ($line in $raw) {
            if (-not $line) { continue }
            $row = $line | ConvertFrom-Json
            $containers[$row.Names] = $row
        }
    } catch {
        Add-Check "Docker" "docker ps -a" "FAIL" $_.Exception.Message
    }
    return $containers
}

function Test-PathDetail {
    param(
        [string]$Group,
        [string]$Name,
        [string]$Path,
        [bool]$Required = $true
    )

    if (-not $Path) {
        $status = if ($Required) { "FAIL" } else { "SKIP" }
        Add-Check $Group $Name $status "Path is not configured."
        return
    }

    $exists = Test-Path -LiteralPath $Path
    if (-not $exists) {
        $status = if ($Required) { "FAIL" } else { "WARN" }
        Add-Check $Group $Name $status "Missing path: $Path"
        return
    }

    $item = Get-Item -LiteralPath $Path
    $root = [System.IO.Path]::GetPathRoot($item.FullName)
    $driveNote = ""
    if ($root -match '^([A-Za-z]):\\$') {
        $drive = Get-PSDrive -Name $matches[1] -ErrorAction SilentlyContinue
        if ($drive) {
            $freeGb = [math]::Round($drive.Free / 1GB, 1)
            $usedGb = [math]::Round($drive.Used / 1GB, 1)
            $driveNote = " Drive $($drive.Name): used ${usedGb}GB, free ${freeGb}GB."
        }
    }

    Add-Check $Group $Name "PASS" "Exists: $($item.FullName).$driveNote"
}

$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$composePath = Resolve-ProjectPath $ComposeFile
$envPath = Resolve-ProjectPath $EnvFile
$dockerConfigPath = Join-Path $ProjectRoot ".docker-cli"

if (Test-Path -LiteralPath $dockerConfigPath) {
    $script:DockerArgs = @("--config", $dockerConfigPath)
}

Add-Check "Run context" "Timestamp" "INFO" (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
Add-Check "Run context" "Project root" "INFO" $ProjectRoot
Add-Check "Run context" "Computer" "INFO" $env:COMPUTERNAME
if ($script:DockerArgs.Count -gt 0) {
    Add-Check "Run context" "Docker CLI config" "INFO" "Using project Docker CLI config: $dockerConfigPath"
} else {
    Add-Check "Run context" "Docker CLI config" "INFO" "Using default Docker CLI config; no project .docker-cli folder found."
}

if (Test-Path -LiteralPath $composePath) {
    Add-Check "Project files" "Compose file" "PASS" "Found compose file: $composePath"
} else {
    Add-Check "Project files" "Compose file" "FAIL" "Missing compose file: $composePath"
}

$envValues = Read-DotEnv $envPath
foreach ($requiredName in @(
    "MEDIA_STACK_CONFIG",
    "DOWNLOADS_ROOT",
    "MOVIES_1_ROOT",
    "MOVIES_2_ROOT",
    "MOVIES_3_ROOT",
    "TV_1_ROOT",
    "TV_2_ROOT",
    "SONARR_PORT",
    "RADARR_PORT",
    "PROWLARR_PORT",
    "BAZARR_PORT",
    "TAUTULLI_PORT",
    "UPTIME_KUMA_PORT",
    "QBITTORRENT_WEBUI_PORT",
    "QBITTORRENT_TORRENT_PORT"
)) {
    if ($envValues.ContainsKey($requiredName) -and $envValues[$requiredName]) {
        Add-Check "Environment" $requiredName "PASS" ("Configured as " + (Redact-Value $requiredName $envValues[$requiredName]))
    } else {
        Add-Check "Environment" $requiredName "FAIL" "Required variable is missing or empty."
    }
}

$containerMap = Get-ContainerMap
$expectedRunning = @(
    "sonarr",
    "radarr",
    "prowlarr",
    "bazarr",
    "tautulli",
    "uptime-kuma",
    "qbittorrent",
    "unpackerr"
)

foreach ($name in $expectedRunning) {
    if (-not $containerMap.ContainsKey($name)) {
        Add-Check "Expected containers" $name "FAIL" "Container was not found by docker ps -a."
        continue
    }

    $row = $containerMap[$name]
    $status = [string]$row.Status
    $state = if ($status -match '^(Up)\b') { "PASS" } else { "FAIL" }
    Add-Check "Expected containers" $name $state "Image=$($row.Image); Status=$status; Ports=$($row.Ports)"
}

if ($containerMap.ContainsKey("jackett")) {
    $jackett = $containerMap["jackett"]
    $jackettStatus = if ([string]$jackett.Status -match '^Up\b') { "WARN" } else { "INFO" }
    Add-Check "Optional containers" "jackett" $jackettStatus "Jackett exists with Status=$($jackett.Status). It should only run when the legacy-jackett profile is intentional."
} else {
    Add-Check "Optional containers" "jackett" "PASS" "Not present/running, consistent with keeping Jackett disabled unless legacy-jackett is intentionally used."
}

$hostIp = Get-EnvValue $envValues "WEBUI_HOST_IP" "127.0.0.1"
if ($hostIp -eq "0.0.0.0") { $testHost = "127.0.0.1" } else { $testHost = $hostIp }

$servicePorts = @(
    @{ Name = "Sonarr Web UI"; Env = "SONARR_PORT"; Default = "8989"; Container = "sonarr"; Required = $true },
    @{ Name = "Radarr Web UI"; Env = "RADARR_PORT"; Default = "7878"; Container = "radarr"; Required = $true },
    @{ Name = "Prowlarr Web UI"; Env = "PROWLARR_PORT"; Default = "9696"; Container = "prowlarr"; Required = $true },
    @{ Name = "Bazarr Web UI"; Env = "BAZARR_PORT"; Default = "6767"; Container = "bazarr"; Required = $true },
    @{ Name = "Tautulli Web UI"; Env = "TAUTULLI_PORT"; Default = "8181"; Container = "tautulli"; Required = $true },
    @{ Name = "Uptime Kuma Web UI"; Env = "UPTIME_KUMA_PORT"; Default = "3001"; Container = "uptime-kuma"; Required = $true },
    @{ Name = "qBittorrent Web UI"; Env = "QBITTORRENT_WEBUI_PORT"; Default = "8080"; Container = "qbittorrent"; Required = $true },
    @{ Name = "qBittorrent torrent TCP"; Env = "QBITTORRENT_TORRENT_PORT"; Default = "6881"; Container = "qbittorrent"; Required = $true },
    @{ Name = "Jackett Web UI"; Env = "JACKETT_PORT"; Default = "9117"; Container = "jackett"; Required = $false }
)

foreach ($entry in $servicePorts) {
    $portText = Get-EnvValue $envValues $entry.Env $entry.Default
    $port = 0
    if (-not [int]::TryParse($portText, [ref]$port)) {
        Add-Check "Service ports" $entry.Name "FAIL" "$($entry.Env) is not a valid integer: $portText"
        continue
    }

    $containerRunning = $containerMap.ContainsKey($entry.Container) -and ([string]$containerMap[$entry.Container].Status -match '^Up\b')
    if (-not $containerRunning -and -not $entry.Required) {
        Add-Check "Service ports" $entry.Name "SKIP" "Optional container $($entry.Container) is not running; skipped port $testHost`:$port."
        continue
    }

    $open = Test-TcpPort $testHost $port
    if ($open) {
        Add-Check "Service ports" $entry.Name "PASS" "TCP connect succeeded at $testHost`:$port."
    } else {
        $status = if ($entry.Required) { "FAIL" } else { "WARN" }
        Add-Check "Service ports" $entry.Name $status "TCP connect failed at $testHost`:$port."
    }
}

$configRoot = Get-EnvValue $envValues "MEDIA_STACK_CONFIG" "C:\media-stack\config"
Test-PathDetail "Config folders" "Config root" $configRoot $true
foreach ($service in @("sonarr", "radarr", "prowlarr", "bazarr", "tautulli", "uptime-kuma", "qbittorrent", "unpackerr")) {
    Test-PathDetail "Config folders" "$service config" (Join-Path $configRoot $service) $true
}
Test-PathDetail "Config folders" "jackett config (optional)" (Join-Path $configRoot "jackett") $false

$windowsPathChecks = @(
    @{ Name = "Downloads root"; Env = "DOWNLOADS_ROOT"; Required = $true },
    @{ Name = "Movies root 1"; Env = "MOVIES_1_ROOT"; Required = $true },
    @{ Name = "Movies root 2"; Env = "MOVIES_2_ROOT"; Required = $true },
    @{ Name = "Movies root 3"; Env = "MOVIES_3_ROOT"; Required = $true },
    @{ Name = "TV root 1"; Env = "TV_1_ROOT"; Required = $true },
    @{ Name = "TV root 2"; Env = "TV_2_ROOT"; Required = $true },
    @{ Name = "Spare media root"; Env = "SPARE_MEDIA_ROOT"; Required = $false }
)

foreach ($pathCheck in $windowsPathChecks) {
    $pathValue = Get-EnvValue $envValues $pathCheck.Env ""
    Test-PathDetail "Windows paths" "$($pathCheck.Name) ($($pathCheck.Env))" $pathValue ([bool]$pathCheck.Required)
}

$downloadsRoot = Get-EnvValue $envValues "DOWNLOADS_ROOT" ""
if ($downloadsRoot) {
    if ((Normalize-PathForCompare $downloadsRoot) -eq (Normalize-PathForCompare "I:\torrentfiles")) {
        Add-Check "Windows paths" "Expected qBittorrent host path" "PASS" "DOWNLOADS_ROOT is $(ConvertTo-WindowsPathText $downloadsRoot)."
    } else {
        Add-Check "Windows paths" "Expected qBittorrent host path" "WARN" "DOWNLOADS_ROOT is $downloadsRoot; operational notes expect I:\torrentfiles."
    }
}

if ($containerMap.ContainsKey("qbittorrent") -and ([string]$containerMap["qbittorrent"].Status -match '^Up\b')) {
    try {
        $dfRaw = Invoke-Docker @("exec", "qbittorrent", "sh", "-c", "df -P -B1 /downloads | tail -n 1") 2>&1
        if ($LASTEXITCODE -eq 0 -and $dfRaw) {
            $parts = ([string]$dfRaw).Trim() -split '\s+'
            if ($parts.Count -ge 6) {
                $sizeBytes = [int64]$parts[1]
                $usedBytes = [int64]$parts[2]
                $availableBytes = [int64]$parts[3]
                $capacityNote = "Filesystem=$($parts[0]); Size=$([math]::Round($sizeBytes / 1GB, 1))GB; Used=$([math]::Round($usedBytes / 1GB, 1))GB; Available=$([math]::Round($availableBytes / 1GB, 1))GB; Mount=$($parts[5])"
                if ($sizeBytes -lt 100GB) {
                    Add-Check "qBittorrent /downloads mount" "Container df capacity" "FAIL" "$capacityNote. This looks like the tiny/full placeholder filesystem failure mode, not the media drive."
                } else {
                    Add-Check "qBittorrent /downloads mount" "Container df capacity" "PASS" $capacityNote
                }
            } else {
                Add-Check "qBittorrent /downloads mount" "Container df capacity" "WARN" "Unexpected df output: $dfRaw"
            }
        } else {
            Add-Check "qBittorrent /downloads mount" "Container df capacity" "FAIL" ($dfRaw -join "`n")
        }
    } catch {
        Add-Check "qBittorrent /downloads mount" "Container df capacity" "FAIL" $_.Exception.Message
    }

    try {
        $writableRaw = Invoke-Docker @("exec", "qbittorrent", "sh", "-c", "test -d /downloads && test -w /downloads && echo writable || echo not_writable") 2>&1
        if ($LASTEXITCODE -eq 0 -and ([string]$writableRaw).Trim() -eq "writable") {
            Add-Check "qBittorrent /downloads mount" "Container write permission" "PASS" "/downloads exists and is writable from inside the qBittorrent container."
        } else {
            Add-Check "qBittorrent /downloads mount" "Container write permission" "FAIL" "Result: $writableRaw"
        }
    } catch {
        Add-Check "qBittorrent /downloads mount" "Container write permission" "FAIL" $_.Exception.Message
    }

    try {
        $mountRaw = Invoke-Docker @("exec", "qbittorrent", "sh", "-c", "mount | grep ' /downloads ' || true") 2>&1
        if ($mountRaw) {
            Add-Check "qBittorrent /downloads mount" "Mount detail" "INFO" ($mountRaw -join "`n")
        } else {
            Add-Check "qBittorrent /downloads mount" "Mount detail" "WARN" "No explicit mount line for /downloads was returned."
        }
    } catch {
        Add-Check "qBittorrent /downloads mount" "Mount detail" "WARN" $_.Exception.Message
    }
} else {
    Add-Check "qBittorrent /downloads mount" "Container checks" "SKIP" "qBittorrent container is not running."
}

$groups = $script:Results | Group-Object Group
$counts = $script:Results | Group-Object Status | Sort-Object Name

Write-Output "# Plex Stack Health Check"
Write-Output ""
Write-Output "Project root: $ProjectRoot"
Write-Output "Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")"
Write-Output ""
Write-Output "## Summary"
foreach ($count in $counts) {
    Write-Output "- $($count.Name): $($count.Count)"
}

foreach ($group in $groups) {
    Write-Output ""
    Write-Output "## $($group.Name)"
    foreach ($check in $group.Group) {
        Write-Output "- [$($check.Status)] $($check.Name): $($check.Detail)"
    }
}
