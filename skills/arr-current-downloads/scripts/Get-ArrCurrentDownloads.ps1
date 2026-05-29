param(
    [string]$ContainerName = "qbittorrent"
)

$ErrorActionPreference = "Stop"

try {
    $json = docker exec $ContainerName sh -c "wget -qO- http://127.0.0.1:8080/api/v2/torrents/info" 2>&1
} catch {
    [pscustomobject]@{
        ok = $false
        error = "qBittorrent container query failed."
        detail = $_.Exception.Message
        downloads = @()
    } | ConvertTo-Json -Depth 4
    exit 0
}

if ($LASTEXITCODE -ne 0) {
    [pscustomobject]@{
        ok = $false
        error = "qBittorrent container query failed."
        detail = (($json | ForEach-Object { [string]$_ }) -join "`n").Trim()
        downloads = @()
    } | ConvertTo-Json -Depth 4
    exit 0
}

if ([string]::IsNullOrWhiteSpace($json)) {
    [pscustomobject]@{
        ok = $true
        error = $null
        downloads = @()
    } | ConvertTo-Json -Depth 4
    exit 0
}

$activeStates = @(
    "downloading",
    "stalledDL",
    "metaDL",
    "forcedDL",
    "queuedDL",
    "checkingDL",
    "allocating"
)

$arrCategories = @{
    "tv-sonarr" = "Sonarr"
    "sonarr" = "Sonarr"
    "radarr" = "Radarr"
    "lidarr" = "Lidarr"
    "readarr" = "Readarr"
}

$items = $json | ConvertFrom-Json
$downloads = @(
    $items |
        Where-Object {
            $activeStates -contains $_.state -and
            $null -ne $_.category -and
            $arrCategories.ContainsKey([string]$_.category)
        } |
        ForEach-Object {
            $etaSeconds = [int64]$_.eta
            $etaText = if ($etaSeconds -ge 8640000 -or $etaSeconds -lt 0) {
                "unknown"
            } elseif ($etaSeconds -lt 60) {
                "$etaSeconds sec"
            } elseif ($etaSeconds -lt 3600) {
                "$([math]::Round($etaSeconds / 60, 1)) min"
            } else {
                "$([math]::Round($etaSeconds / 3600, 1)) hr"
            }

            [pscustomobject]@{
                media = $_.name
                arrApp = $arrCategories[[string]$_.category]
                category = $_.category
                status = $_.state
                progressPct = [math]::Round([double]$_.progress * 100, 1)
                speedMBps = [math]::Round([double]$_.dlspeed / 1MB, 1)
                eta = $etaText
                sizeGB = [math]::Round([double]$_.size / 1GB, 2)
            }
        } |
        Sort-Object arrApp, media
)

[pscustomobject]@{
    ok = $true
    error = $null
    downloads = @($downloads)
} | ConvertTo-Json -Depth 4
