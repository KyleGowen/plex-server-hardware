param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('movie', 'series')]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [int]$Year,

    [string]$QualityProfileName,

    [switch]$NoSearch
)

$ErrorActionPreference = 'Stop'

function Expand-FlatArray {
    param([object]$Value)

    $items = New-Object System.Collections.Generic.List[object]
    foreach ($item in @($Value)) {
        if ($item -is [array]) {
            foreach ($nested in $item) { $items.Add($nested) }
        }
        else { $items.Add($item) }
    }
    return $items.ToArray()
}

function Get-ArrHeaders {
    param([string]$ConfigPath)

    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Arr config not found at $ConfigPath"
    }
    $config = [xml](Get-Content -LiteralPath $ConfigPath -Raw)
    $apiKey = [string]$config.Config.ApiKey
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "API key missing in $ConfigPath"
    }
    return @{ 'X-Api-Key' = $apiKey }
}

function Invoke-ArrGet {
    param([string]$BaseUrl, [hashtable]$Headers, [string]$Path)
    Invoke-RestMethod -Method Get -Uri "$BaseUrl$Path" -Headers $Headers
}

function Invoke-ArrPost {
    param([string]$BaseUrl, [hashtable]$Headers, [string]$Path, [object]$Body)
    Invoke-RestMethod -Method Post -Uri "$BaseUrl$Path" -Headers $Headers -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 30)
}

function Invoke-ArrPut {
    param([string]$BaseUrl, [hashtable]$Headers, [string]$Path, [object]$Body)
    Invoke-RestMethod -Method Put -Uri "$BaseUrl$Path" -Headers $Headers -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 30)
}

function Normalize-Title {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
    $normalized = $Value.ToLowerInvariant()
    $normalized = [regex]::Replace($normalized, '\((19|20)\d{2}\)', ' ')
    $normalized = [regex]::Replace($normalized, '[^a-z0-9 ]', ' ')
    $normalized = [regex]::Replace($normalized, '\s+', ' ').Trim()
    $normalized = [regex]::Replace($normalized, '^(the|a|an) ', '')
    return $normalized
}

function Pick-Match {
    param([object[]]$Lookup, [string]$Title, [Nullable[int]]$Year)

    $candidates = @(Expand-FlatArray $Lookup | Where-Object { $_.title -and ($_.tmdbId -or $_.tvdbId) })
    if ($Year) {
        $yearMatches = @($candidates | Where-Object { $_.year -eq $Year -or ($_.firstAired -and ([datetime]$_.firstAired).Year -eq $Year) })
        if ($yearMatches.Count -gt 0) { $candidates = $yearMatches }
    }
    $target = Normalize-Title $Title
    $exact = @($candidates | Where-Object { (Normalize-Title $_.title) -eq $target })
    if ($exact.Count -gt 0) { return $exact[0] }
    if ($Year -and $candidates.Count -eq 1) { return $candidates[0] }
    $prefix = @($candidates | Where-Object {
        $candidateTitle = Normalize-Title $_.title
        $candidateTitle.StartsWith($target) -or $target.StartsWith($candidateTitle)
    })
    if ($prefix.Count -gt 0) { return $prefix[0] }
    return $null
}

function Get-QualityProfileId {
    param([string]$BaseUrl, [hashtable]$Headers, [string]$PreferredName)

    $profiles = @(Expand-FlatArray (Invoke-ArrGet -BaseUrl $BaseUrl -Headers $Headers -Path '/qualityprofile'))
    $preferred = @($profiles | Where-Object { $_.name -eq $PreferredName } | Select-Object -First 1)[0]
    if ($preferred) { return [int]$preferred.id }
    $fallback = @($profiles | Select-Object -First 1)[0]
    if (-not $fallback) { throw 'No quality profiles found.' }
    return [int]$fallback.id
}

function Get-BestRootFolder {
    param([string]$BaseUrl, [hashtable]$Headers)

    $roots = @(Expand-FlatArray (Invoke-ArrGet -BaseUrl $BaseUrl -Headers $Headers -Path '/rootfolder') | Where-Object { $_.accessible -ne $false })
    $root = @($roots | Sort-Object -Property freeSpace -Descending | Select-Object -First 1)[0]
    if (-not $root) { throw 'No accessible root folders found.' }
    return $root.path
}

if ($Type -eq 'movie') {
    $base = 'http://127.0.0.1:7878/api/v3'
    $headers = Get-ArrHeaders -ConfigPath 'C:\media-stack\config\radarr\config.xml'
    $qualityName = if ($QualityProfileName) { $QualityProfileName } else { 'Ultra-HD' }
    $lookup = Invoke-ArrGet -BaseUrl $base -Headers $headers -Path "/movie/lookup?term=$([uri]::EscapeDataString($Title + $(if ($Year) { " $Year" } else { '' })))"
    $match = Pick-Match -Lookup $lookup -Title $Title -Year $(if ($Year) { $Year } else { $null })
    if (-not $match) { throw "No confident Radarr match found for '$Title'." }

    $movies = @(Expand-FlatArray (Invoke-ArrGet -BaseUrl $base -Headers $headers -Path '/movie'))
    $existing = @($movies | Where-Object { $_.tmdbId -eq $match.tmdbId } | Select-Object -First 1)[0]
    $root = Get-BestRootFolder -BaseUrl $base -Headers $headers
    $qualityProfileId = Get-QualityProfileId -BaseUrl $base -Headers $headers -PreferredName $qualityName

    if ($existing) {
        $media = $existing
        $media.monitored = $true
        $media.qualityProfileId = $qualityProfileId
        $media = Invoke-ArrPut -BaseUrl $base -Headers $headers -Path "/movie/$($media.id)" -Body $media
        $action = 'updatedExisting'
    }
    else {
        $match | Add-Member -NotePropertyName qualityProfileId -NotePropertyValue $qualityProfileId -Force
        $match | Add-Member -NotePropertyName monitored -NotePropertyValue $true -Force
        $match | Add-Member -NotePropertyName minimumAvailability -NotePropertyValue 'released' -Force
        $match | Add-Member -NotePropertyName rootFolderPath -NotePropertyValue $root -Force
        $match | Add-Member -NotePropertyName path -NotePropertyValue "$root/$($match.title) ($($match.year))" -Force
        $match | Add-Member -NotePropertyName addOptions -NotePropertyValue @{ searchForMovie = $false } -Force
        $media = Invoke-ArrPost -BaseUrl $base -Headers $headers -Path '/movie' -Body $match
        $action = 'added'
    }

    $command = $null
    if (-not $NoSearch) {
        $command = Invoke-ArrPost -BaseUrl $base -Headers $headers -Path '/command' -Body @{ name = 'MoviesSearch'; movieIds = @([int]$media.id) }
        Start-Sleep -Seconds 10
    }
    $queue = Invoke-ArrGet -BaseUrl $base -Headers $headers -Path '/queue?page=1&pageSize=200'
    $records = @(Expand-FlatArray $queue.records | Where-Object { $_.movieId -eq $media.id -or $_.title -like "*$($media.title)*" })
    [pscustomobject]@{
        service = 'radarr'
        action = $action
        title = $media.title
        year = $media.year
        tmdbId = $media.tmdbId
        monitored = $media.monitored
        hasFile = $media.hasFile
        commandId = if ($command) { $command.id } else { $null }
        queueMatches = $records.Count
        queue = @($records | Select-Object title,status,trackedDownloadStatus,trackedDownloadState,downloadClient,protocol,@{n='quality';e={$_.quality.quality.name}},@{n='progressPct';e={if($_.size -and $null -ne $_.sizeleft){[math]::Round((1-($_.sizeleft/$_.size))*100,2)}else{$null}}})
    } | ConvertTo-Json -Depth 8
}
else {
    $base = 'http://127.0.0.1:8989/api/v3'
    $headers = Get-ArrHeaders -ConfigPath 'C:\media-stack\config\sonarr\config.xml'
    $qualityName = if ($QualityProfileName) { $QualityProfileName } else { 'HD - 720p/1080p' }
    $lookup = Invoke-ArrGet -BaseUrl $base -Headers $headers -Path "/series/lookup?term=$([uri]::EscapeDataString($Title + $(if ($Year) { " $Year" } else { '' })))"
    $match = Pick-Match -Lookup $lookup -Title $Title -Year $(if ($Year) { $Year } else { $null })
    if (-not $match) { throw "No confident Sonarr match found for '$Title'." }

    $seriesList = @(Expand-FlatArray (Invoke-ArrGet -BaseUrl $base -Headers $headers -Path '/series'))
    $existing = @($seriesList | Where-Object { $_.tvdbId -eq $match.tvdbId } | Select-Object -First 1)[0]
    $root = Get-BestRootFolder -BaseUrl $base -Headers $headers
    $qualityProfileId = Get-QualityProfileId -BaseUrl $base -Headers $headers -PreferredName $qualityName

    if ($existing) {
        $media = $existing
        $media.monitored = $true
        foreach ($season in @($media.seasons)) { $season.monitored = ($season.seasonNumber -ne 0) }
        $media.qualityProfileId = $qualityProfileId
        $media = Invoke-ArrPut -BaseUrl $base -Headers $headers -Path "/series/$($media.id)" -Body $media
        $action = 'updatedExisting'
    }
    else {
        $match | Add-Member -NotePropertyName qualityProfileId -NotePropertyValue $qualityProfileId -Force
        $match | Add-Member -NotePropertyName monitored -NotePropertyValue $true -Force
        $match | Add-Member -NotePropertyName rootFolderPath -NotePropertyValue $root -Force
        $match | Add-Member -NotePropertyName path -NotePropertyValue "$root/$($match.title)" -Force
        foreach ($season in @($match.seasons)) { $season.monitored = ($season.seasonNumber -ne 0) }
        $match | Add-Member -NotePropertyName addOptions -NotePropertyValue @{ monitor = 'all'; searchForMissingEpisodes = $false; searchForCutoffUnmetEpisodes = $false } -Force
        $media = Invoke-ArrPost -BaseUrl $base -Headers $headers -Path '/series' -Body $match
        $action = 'added'
    }

    $command = $null
    if (-not $NoSearch) {
        $command = Invoke-ArrPost -BaseUrl $base -Headers $headers -Path '/command' -Body @{ name = 'SeriesSearch'; seriesId = [int]$media.id }
        Start-Sleep -Seconds 10
    }
    $queue = Invoke-ArrGet -BaseUrl $base -Headers $headers -Path '/queue?page=1&pageSize=200'
    $records = @(Expand-FlatArray $queue.records | Where-Object { $_.seriesId -eq $media.id -or $_.title -like "*$($media.title)*" })
    [pscustomobject]@{
        service = 'sonarr'
        action = $action
        title = $media.title
        year = if ($media.year) { $media.year } elseif ($media.firstAired) { ([datetime]$media.firstAired).Year } else { $null }
        tvdbId = $media.tvdbId
        monitored = $media.monitored
        commandId = if ($command) { $command.id } else { $null }
        queueMatches = $records.Count
        queue = @($records | Select-Object title,status,trackedDownloadStatus,trackedDownloadState,downloadClient,protocol,@{n='quality';e={$_.quality.quality.name}},@{n='progressPct';e={if($_.size -and $null -ne $_.sizeleft){[math]::Round((1-($_.sizeleft/$_.size))*100,2)}else{$null}}})
    } | ConvertTo-Json -Depth 8
}
