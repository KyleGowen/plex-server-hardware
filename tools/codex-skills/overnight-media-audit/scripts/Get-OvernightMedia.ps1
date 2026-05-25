param(
    [string]$ProjectRoot = "C:\plex-server",
    [string]$SinceLocal
)

$ErrorActionPreference = "Stop"

function Convert-FromUnixLocal {
    param([object]$Value)
    if ($null -eq $Value -or [int64]$Value -le 0) { return "" }
    $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
    return [System.TimeZoneInfo]::ConvertTime([DateTimeOffset]::FromUnixTimeSeconds([int64]$Value), $tz).ToString("yyyy-MM-dd HH:mm:ss zzz")
}

function Invoke-Arr {
    param([string]$Uri, [hashtable]$Headers)
    Invoke-RestMethod -Uri $Uri -Headers $Headers -TimeoutSec 20
}

function Expand-Items {
    param([object]$Value)
    if ($null -eq $Value) { return @() }
    if ($Value -is [array]) { return @($Value) }
    if ($null -ne $Value.value -and $Value.value -is [array]) { return @($Value.value) }
    return @($Value)
}

if ($SinceLocal) {
    $sinceDto = [DateTimeOffset]::new([DateTime]::Parse($SinceLocal), [TimeSpan]::FromHours(-7))
} else {
    $now = [DateTimeOffset]::Now
    $yesterday = $now.AddDays(-1)
    $sinceDto = [DateTimeOffset]::new($yesterday.Year, $yesterday.Month, $yesterday.Day, 18, 0, 0, [TimeSpan]::FromHours(-7))
}

$sinceUnix = $sinceDto.ToUnixTimeSeconds()
$sinceUtc = $sinceDto.UtcDateTime.ToString("yyyy-MM-ddTHH:mm:ssZ")

$result = [ordered]@{
    since_local = $sinceDto.ToString("yyyy-MM-dd HH:mm:ss zzz")
    qbit = [ordered]@{ login = "not_checked"; count = 0; items = @() }
    sonarr = [ordered]@{ history_count = 0; imports = @(); health = @(); queue = @() }
    radarr = [ordered]@{ history_count = 0; imports = @(); health = @(); queue = @() }
}

$sonarrConfigPath = "C:\media-stack\config\sonarr\config.xml"
$radarrConfigPath = "C:\media-stack\config\radarr\config.xml"

if (Test-Path $sonarrConfigPath) {
    $sonarrConfig = [xml](Get-Content $sonarrConfigPath)
    $sonarrHeaders = @{ "X-Api-Key" = $sonarrConfig.Config.ApiKey }
    $sHistory = Invoke-Arr "http://127.0.0.1:8989/api/v3/history/since?date=$sinceUtc" $sonarrHeaders
    $result.sonarr.history_count = @($sHistory).Count
    $result.sonarr.imports = @($sHistory | Where-Object { $_.eventType -eq "downloadFolderImported" -or $_.eventType -eq "episodeFileImported" } | Select-Object date,eventType,sourceTitle,@{n="series";e={$_.series.title}},@{n="episode";e={($_.episodes | ForEach-Object { "S{0:00}E{1:00} {2}" -f $_.seasonNumber,$_.episodeNumber,$_.title }) -join "; "}})
    $sHealth = Expand-Items (Invoke-Arr "http://127.0.0.1:8989/api/v3/health" $sonarrHeaders)
    if ($sHealth.Count -gt 0) {
        $result.sonarr.health = @($sHealth | Where-Object { $null -ne $_ } | Select-Object source,type,message)
    }
    $sQueue = Invoke-Arr "http://127.0.0.1:8989/api/v3/queue?includeUnknownSeriesItems=true&includeSeries=true&includeEpisode=true&page=1&pageSize=50" $sonarrHeaders
    $result.sonarr.queue = @($sQueue.records | Select-Object title,status,trackedDownloadStatus,trackedDownloadState)
}

if (Test-Path $radarrConfigPath) {
    $radarrConfig = [xml](Get-Content $radarrConfigPath)
    $radarrHeaders = @{ "X-Api-Key" = $radarrConfig.Config.ApiKey }
    $rHistory = Invoke-Arr "http://127.0.0.1:7878/api/v3/history/since?date=$sinceUtc" $radarrHeaders
    $result.radarr.history_count = @($rHistory).Count
    $result.radarr.imports = @($rHistory | Where-Object { $_.eventType -eq "downloadFolderImported" -or $_.eventType -eq "movieFileImported" } | Select-Object date,eventType,sourceTitle,@{n="movie";e={$_.movie.title}},@{n="year";e={$_.movie.year}})
    $rHealth = Expand-Items (Invoke-Arr "http://127.0.0.1:7878/api/v3/health" $radarrHeaders)
    if ($rHealth.Count -gt 0) {
        $result.radarr.health = @($rHealth | Where-Object { $null -ne $_ } | Select-Object source,type,message)
    }
    $rQueue = Invoke-Arr "http://127.0.0.1:7878/api/v3/queue?includeUnknownMovieItems=true&includeMovie=true&page=1&pageSize=50" $radarrHeaders
    $result.radarr.queue = @($rQueue.records | Select-Object title,status,trackedDownloadStatus,trackedDownloadState)
}

try {
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $qbitPassword = $null
    $logPath = "C:\media-stack\config\qbittorrent\qBittorrent\logs\qbittorrent.log"
    if (Test-Path $logPath) {
        $pwLine = Get-Content $logPath -Tail 250 | Select-String "temporary password is provided for this session:" | Select-Object -Last 1
        if ($pwLine) { $qbitPassword = ($pwLine.Line -replace ".*session:\s*", "").Trim() }
    }
    if (-not $qbitPassword) {
        try {
            $dockerLogs = docker --config "$ProjectRoot\.docker-cli" logs --tail 400 qbittorrent 2>&1
            $pwLine = $dockerLogs | Select-String "temporary password is provided for this session:" | Select-Object -Last 1
            if ($pwLine) { $qbitPassword = ($pwLine.Line -replace ".*session:\s*", "").Trim() }
        } catch {}
    }
    if ($qbitPassword) {
        Invoke-WebRequest -Uri "http://127.0.0.1:8080/api/v2/auth/login" -Method Post -Body @{ username = "admin"; password = $qbitPassword } -WebSession $session -UseBasicParsing -TimeoutSec 20 | Out-Null
        $result.qbit.login = "ok"
        $torrents = Invoke-RestMethod -Uri "http://127.0.0.1:8080/api/v2/torrents/info" -WebSession $session -UseBasicParsing -TimeoutSec 20
        $items = @($torrents | Where-Object { $_.completion_on -ge $sinceUnix -or $_.added_on -ge $sinceUnix } | Sort-Object completion_on,added_on | Select-Object name,state,progress,category,save_path,@{n="added_local";e={Convert-FromUnixLocal $_.added_on}},@{n="completed_local";e={Convert-FromUnixLocal $_.completion_on}})
        $result.qbit.count = $items.Count
        $result.qbit.items = $items
    } else {
        $result.qbit.login = "no_temp_password_found"
    }
} catch {
    $result.qbit.login = "failed"
    $result.qbit.error = $_.Exception.Message
}

$result | ConvertTo-Json -Depth 8
