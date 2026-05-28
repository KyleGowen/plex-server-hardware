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

Write-Log "Starting delayed media stack restart helper."
Start-Sleep -Seconds $InitialDelaySeconds

$deadline = (Get-Date).AddSeconds($DockerWaitSeconds)
while ((Get-Date) -lt $deadline) {
    try {
        docker info *> $null
        Write-Log "Docker is available."
        break
    } catch {
        Start-Sleep -Seconds 10
    }
}

try {
    docker info *> $null
} catch {
    Write-Log "Docker did not become available before timeout; leaving stack untouched."
    exit 1
}

$torrentPathOk = Test-Path 'I:\torrentfiles'
Write-Log "I:\torrentfiles present: $torrentPathOk"

docker compose -f $composeFile restart *> $null
Write-Log "Ran docker compose restart for media stack."

Start-Sleep -Seconds 20

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

Write-Log "Delayed media stack restart helper finished."
