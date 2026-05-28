param(
    [int]$InitialDelaySeconds = 120,
    [int]$DockerWaitSeconds = 180
)

$ErrorActionPreference = 'Stop'
$composeFile = 'C:\plex-server\docker-compose.media.yml'
$logDir = 'C:\plex-server\logs'
$logFile = Join-Path $logDir 'media-stack-after-login-restart.log'

New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Write-Log {
    param([string]$Message)
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $logFile -Value "[$stamp] $Message"
}

function Invoke-Docker {
    param(
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 180,
        [switch]$Quiet
    )

    $psi = [Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = 'docker.exe'
    $psi.Arguments = ($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        } else {
            $_
        }
    }) -join ' '
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $psi
    $null = $process.Start()

    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        try { $process.Kill() } catch {}
        Write-Log "docker $($Arguments -join ' ') timed out after ${TimeoutSeconds}s."
        return $false
    }

    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    if (-not $Quiet) {
        foreach ($line in (($stdout -split "`r?`n") + ($stderr -split "`r?`n"))) {
            if ($line -and $line.Trim()) {
                Write-Log "docker: $line"
            }
        }
    }

    if ($process.ExitCode -ne 0) {
        Write-Log "docker $($Arguments -join ' ') exited with code $($process.ExitCode)."
        return $false
    }

    return $true
}

function Test-XmlConfig {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    try {
        $bytes = [IO.File]::ReadAllBytes($Path)
        if ($bytes -contains 0) { return $false }
        [xml](Get-Content -Raw -LiteralPath $Path) | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Move-CorruptConfig {
    param(
        [string]$ServiceName,
        [string]$ConfigPath,
        [string]$Stamp
    )

    if (Test-XmlConfig -Path $ConfigPath) { return $false }
    if (Test-Path -LiteralPath $ConfigPath) {
        $destination = "$ConfigPath.corrupt-$Stamp"
        Move-Item -LiteralPath $ConfigPath -Destination $destination -Force
        Write-Log "$ServiceName config was corrupt; moved to $destination."
    } else {
        Write-Log "$ServiceName config missing; service will regenerate it."
    }
    return $true
}

function Get-ApiKey {
    param([string]$ConfigPath)
    [xml]$xml = Get-Content -Raw -LiteralPath $ConfigPath
    return [string]$xml.Config.ApiKey
}

function Set-KeyValueInSection {
    param(
        [string]$Path,
        [string]$SectionPattern,
        [string]$KeyPattern,
        [string]$Value
    )

    if (-not (Test-Path -LiteralPath $Path)) { return }

    $lines = Get-Content -LiteralPath $Path
    $inSection = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $SectionPattern) {
            $inSection = $true
            continue
        }
        if ($inSection -and $lines[$i] -match '^\S') {
            $inSection = $false
        }
        if ($inSection -and $lines[$i] -match $KeyPattern) {
            $prefix = $matches[1]
            $quote = if ($lines[$i] -match '"') { '"' } else { '' }
            $lines[$i] = "$prefix$quote$Value$quote"
            break
        }
    }
    Set-Content -LiteralPath $Path -Value $lines
}

function Repair-GeneratedApiKeys {
    $sonarrConfig = 'C:\media-stack\config\sonarr\config.xml'
    $radarrConfig = 'C:\media-stack\config\radarr\config.xml'
    $prowlarrConfig = 'C:\media-stack\config\prowlarr\config.xml'

    if (-not ((Test-XmlConfig $sonarrConfig) -and (Test-XmlConfig $radarrConfig) -and (Test-XmlConfig $prowlarrConfig))) {
        Write-Log 'Skipping API-key repair because one or more regenerated configs are not readable yet.'
        return
    }

    $sonarrKey = Get-ApiKey $sonarrConfig
    $radarrKey = Get-ApiKey $radarrConfig
    $prowlarrKey = Get-ApiKey $prowlarrConfig

    Set-KeyValueInSection -Path 'C:\media-stack\config\bazarr\config\config.yaml' -SectionPattern '^sonarr:\s*$' -KeyPattern '^(\s*apikey:\s*).*' -Value $sonarrKey
    Set-KeyValueInSection -Path 'C:\media-stack\config\bazarr\config\config.yaml' -SectionPattern '^radarr:\s*$' -KeyPattern '^(\s*apikey:\s*).*' -Value $radarrKey
    Set-KeyValueInSection -Path 'C:\media-stack\config\unpackerr\unpackerr.conf' -SectionPattern '^\[\[sonarr\]\]\s*$' -KeyPattern '^(\s*api_key\s*=\s*).*' -Value $sonarrKey
    Set-KeyValueInSection -Path 'C:\media-stack\config\unpackerr\unpackerr.conf' -SectionPattern '^\[\[radarr\]\]\s*$' -KeyPattern '^(\s*api_key\s*=\s*).*' -Value $radarrKey
    Write-Log 'Updated Bazarr and Unpackerr local API keys.'

    $prowlarrHeaders = @{ 'X-Api-Key' = $prowlarrKey }
    try {
        $apps = Invoke-RestMethod -Uri 'http://127.0.0.1:9696/api/v1/applications' -Headers $prowlarrHeaders -TimeoutSec 20
        foreach ($app in $apps) {
            if ($app.implementation -eq 'Sonarr') {
                (($app.fields | Where-Object { $_.name -eq 'apiKey' })[0]).value = $sonarrKey
                (($app.fields | Where-Object { $_.name -eq 'baseUrl' })[0]).value = 'http://sonarr:8989'
            } elseif ($app.implementation -eq 'Radarr') {
                (($app.fields | Where-Object { $_.name -eq 'apiKey' })[0]).value = $radarrKey
                (($app.fields | Where-Object { $_.name -eq 'baseUrl' })[0]).value = 'http://radarr:7878'
            } else {
                continue
            }
            (($app.fields | Where-Object { $_.name -eq 'prowlarrUrl' })[0]).value = 'http://prowlarr:9696'
            Invoke-RestMethod -Uri "http://127.0.0.1:9696/api/v1/applications/$($app.id)" -Method Put -Headers $prowlarrHeaders -ContentType 'application/json' -Body ($app | ConvertTo-Json -Depth 30) -TimeoutSec 20 | Out-Null
            Write-Log "Updated Prowlarr application $($app.name)."
        }
    } catch {
        Write-Log "Prowlarr application key repair failed: $($_.Exception.Message)"
    }

    foreach ($target in @(
        @{ Name = 'Sonarr'; Url = 'http://127.0.0.1:8989'; Key = $sonarrKey },
        @{ Name = 'Radarr'; Url = 'http://127.0.0.1:7878'; Key = $radarrKey }
    )) {
        try {
            $headers = @{ 'X-Api-Key' = $target.Key }
            $indexers = Invoke-RestMethod -Uri "$($target.Url)/api/v3/indexer" -Headers $headers -TimeoutSec 20
            foreach ($indexer in $indexers) {
                $baseUrl = (($indexer.fields | Where-Object { $_.name -eq 'baseUrl' -or $_.name -eq 'url' }) | Select-Object -First 1).value
                if ($baseUrl -notmatch 'prowlarr:9696') { continue }
                (($indexer.fields | Where-Object { $_.name -eq 'apiKey' })[0]).value = $prowlarrKey
                Invoke-RestMethod -Uri "$($target.Url)/api/v3/indexer/$($indexer.id)" -Method Put -Headers $headers -ContentType 'application/json' -Body ($indexer | ConvertTo-Json -Depth 30) -TimeoutSec 20 | Out-Null
                Write-Log "Updated $($target.Name) Prowlarr indexer $($indexer.name)."
            }
        } catch {
            Write-Log "$($target.Name) indexer key repair failed: $($_.Exception.Message)"
        }
    }

    Invoke-Docker -Arguments @('compose', '-f', $composeFile, 'restart', 'bazarr', 'unpackerr') -TimeoutSeconds 120 | Out-Null
}

Write-Log 'Starting delayed media stack restart helper.'
Start-Sleep -Seconds $InitialDelaySeconds

$deadline = (Get-Date).AddSeconds($DockerWaitSeconds)
while ((Get-Date) -lt $deadline) {
    if (Invoke-Docker -Arguments @('info') -TimeoutSeconds 30 -Quiet) {
        Write-Log 'Docker is available.'
        break
    }
    Start-Sleep -Seconds 10
}

if (-not (Invoke-Docker -Arguments @('info') -TimeoutSeconds 30 -Quiet)) {
    Write-Log 'Docker did not become available before timeout; leaving stack untouched.'
    exit 1
}

$torrentPathOk = Test-Path 'I:\torrentfiles'
Write-Log "I:\torrentfiles present: $torrentPathOk"

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$corruptConfigs = @()
$corruptConfigs += Move-CorruptConfig -ServiceName 'Sonarr' -ConfigPath 'C:\media-stack\config\sonarr\config.xml' -Stamp $stamp
$corruptConfigs += Move-CorruptConfig -ServiceName 'Radarr' -ConfigPath 'C:\media-stack\config\radarr\config.xml' -Stamp $stamp
$corruptConfigs += Move-CorruptConfig -ServiceName 'Prowlarr' -ConfigPath 'C:\media-stack\config\prowlarr\config.xml' -Stamp $stamp

Invoke-Docker -Arguments @('compose', '-f', $composeFile, 'restart') -TimeoutSeconds 240 | Out-Null
Write-Log 'Ran docker compose restart for media stack.'

Start-Sleep -Seconds 30

if ($corruptConfigs -contains $true) {
    Repair-GeneratedApiKeys
}

$checks = @(
    @{ Name = 'Sonarr'; Url = 'http://127.0.0.1:8989/' },
    @{ Name = 'Radarr'; Url = 'http://127.0.0.1:7878/' },
    @{ Name = 'Prowlarr'; Url = 'http://127.0.0.1:9696/' },
    @{ Name = 'Bazarr'; Url = 'http://127.0.0.1:6767/' },
    @{ Name = 'qBittorrent'; Url = 'http://127.0.0.1:8080/' },
    @{ Name = 'Tautulli'; Url = 'http://127.0.0.1:8181/' }
)

foreach ($check in $checks) {
    try {
        $response = Invoke-WebRequest -Uri $check.Url -UseBasicParsing -TimeoutSec 10 -MaximumRedirection 0 -ErrorAction Stop
        Write-Log "$($check.Name) HTTP $([int]$response.StatusCode)"
    } catch {
        if ($_.Exception.Response) {
            Write-Log "$($check.Name) HTTP $([int]$_.Exception.Response.StatusCode)"
        } else {
            Write-Log "$($check.Name) check failed: $($_.Exception.Message)"
        }
    }
}

try {
    $downloads = docker exec qbittorrent sh -c "df -h /downloads | tail -1"
    Write-Log "qBittorrent /downloads: $downloads"
} catch {
    Write-Log "qBittorrent /downloads check failed: $($_.Exception.Message)"
}

Write-Log 'Delayed media stack restart helper finished.'
