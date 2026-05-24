param(
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

$RadarrConfigPath = 'C:\media-stack\config\radarr\config.xml'
if (-not (Test-Path -LiteralPath $RadarrConfigPath)) {
    throw "Radarr config not found at $RadarrConfigPath"
}

$RadarrConfig = [xml](Get-Content -LiteralPath $RadarrConfigPath -Raw)
$ApiKey = [string]$RadarrConfig.Config.ApiKey
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw 'Radarr API key was not found in the local config file.'
}

$BaseUrl = 'http://127.0.0.1:7878/api/v3'
$Headers = @{ 'X-Api-Key' = $ApiKey }
$QualityProfileId = 5

$Roots = @(
    @{ Root = '/movies/movies1/Movies'; WindowsPath = 'D:\Movies' },
    @{ Root = '/movies/movies2/Movies'; WindowsPath = 'F:\Movies' },
    @{ Root = '/movies/movies3/Movies'; WindowsPath = 'E:\Movies' }
)

function Invoke-RadarrGet {
    param([string]$Path)
    Invoke-RestMethod -Method Get -Uri "$BaseUrl$Path" -Headers $Headers
}

function Invoke-RadarrPost {
    param(
        [string]$Path,
        [object]$Body
    )

    $requestFile = [System.IO.Path]::GetTempFileName()
    $responseFile = [System.IO.Path]::GetTempFileName()
    try {
        $Body | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $requestFile -Encoding UTF8
        $status = & curl.exe -sS -o $responseFile -w '%{http_code}' -X POST "$BaseUrl$Path" -H "X-Api-Key: $ApiKey" -H 'Content-Type: application/json' --data-binary "@$requestFile"
        $content = Get-Content -LiteralPath $responseFile -Raw
        if ([int]$status -lt 200 -or [int]$status -ge 300) {
            throw "Radarr POST $Path failed with HTTP $status`: $content"
        }
        if ([string]::IsNullOrWhiteSpace($content)) {
            return $null
        }
        return $content | ConvertFrom-Json
    }
    finally {
        Remove-Item -LiteralPath $requestFile, $responseFile -ErrorAction SilentlyContinue
    }
}

function Expand-FlatArray {
    param([object]$Value)

    $items = New-Object System.Collections.Generic.List[object]
    foreach ($item in @($Value)) {
        if ($item -is [array]) {
            foreach ($nested in $item) {
                $items.Add($nested)
            }
        }
        else {
            $items.Add($item)
        }
    }
    return $items.ToArray()
}

function Get-FolderYear {
    param([string]$Name)

    $parentheticalYears = @([regex]::Matches($Name, '\((19|20)\d{2}\)'))
    if ($parentheticalYears.Count -gt 0) {
        return [int]($parentheticalYears[$parentheticalYears.Count - 1].Value.Trim('(', ')'))
    }

    $years = @([regex]::Matches($Name, '(?<!\d)(19|20)\d{2}(?!\d)') | ForEach-Object { [int]$_.Value })
    if ($years.Count -eq 1) {
        return $years[0]
    }
    if ($years.Count -gt 1) {
        return $years[$years.Count - 1]
    }

    return $null
}

function Normalize-Title {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }

    $normalized = $Value
    $normalized = [regex]::Replace($normalized, '\[[^\]]*\]', ' ')
    $normalized = [regex]::Replace($normalized, '\([^\)]*\)', ' ')
    $normalized = [regex]::Replace($normalized, '(?i)\b(19|20)\d{2}\b', ' ')
    $normalized = [regex]::Replace($normalized, '(?i)\b(2160p|1080p|720p|480p|bluray|blu-ray|brrip|webrip|web-dl|hdtv|dvdrip|x264|x265|hevc|aac|dts|truehd|atmos|proper|repack|yify|rarbg|wiki|amiable|etrg|extended|unrated|remastered|limited|internal|multi|remux)\b', ' ')
    $normalized = $normalized -replace '[._+\-]', ' '
    $normalized = [regex]::Replace($normalized, '[^A-Za-z0-9 ]', ' ')
    $normalized = [regex]::Replace($normalized, '\s+', ' ').Trim().ToLowerInvariant()
    $normalized = [regex]::Replace($normalized, '^(the|a|an) ', '')
    return $normalized
}

function Pick-MovieMatch {
    param(
        [object[]]$Lookup,
        [string]$FolderName
    )

    if (-not $Lookup -or $Lookup.Count -eq 0) {
        return $null
    }

    $folderYear = Get-FolderYear -Name $FolderName
    $folderTitle = Normalize-Title -Value $FolderName
    $Lookup = Expand-FlatArray -Value $Lookup
    $candidates = @($Lookup | Where-Object { $_.tmdbId -and $_.title -and $_.year })

    if ($null -ne $folderYear) {
        $candidates = @($candidates | Where-Object { [int]$_.year -eq [int]$folderYear })
    }

    if ($candidates.Count -eq 0) {
        return $null
    }

    $exact = @($candidates | Where-Object { (Normalize-Title -Value $_.title) -eq $folderTitle })
    if ($exact.Count -gt 0) {
        return $exact[0]
    }

    $prefix = @($candidates | Where-Object {
        $movieTitle = Normalize-Title -Value $_.title
        $folderTitle.StartsWith($movieTitle) -or $movieTitle.StartsWith($folderTitle)
    })
    if ($prefix.Count -gt 0) {
        return $prefix[0]
    }

    if ($null -ne $folderYear -and $candidates.Count -eq 1) {
        return $candidates[0]
    }

    return $null
}

$existingMovies = Expand-FlatArray -Value (Invoke-RadarrGet -Path '/movie')
$existingTmdbIds = @{}
$existingPaths = @{}
foreach ($movie in $existingMovies) {
    if ($movie.tmdbId) {
        $existingTmdbIds[[string]$movie.tmdbId] = $true
    }
    if ($movie.path) {
        $existingPaths[$movie.path.ToLowerInvariant()] = $true
    }
}

$seenTmdbIds = @{}
$addable = New-Object System.Collections.Generic.List[object]
$duplicates = New-Object System.Collections.Generic.List[object]
$skipped = New-Object System.Collections.Generic.List[object]
$added = New-Object System.Collections.Generic.List[object]
$failed = New-Object System.Collections.Generic.List[object]
$totalFolders = 0

foreach ($root in $Roots) {
    $folders = @(Get-ChildItem -LiteralPath $root.WindowsPath -Directory -ErrorAction Stop)
    foreach ($folder in $folders) {
        $totalFolders++
        $containerPath = ($folder.FullName -replace '^[A-Z]:\\Movies', $root.Root) -replace '\\', '/'

        if ($existingPaths.ContainsKey($containerPath.ToLowerInvariant())) {
            $duplicates.Add([pscustomobject]@{
                reason = 'pathExists'
                folder = $folder.Name
                path = $containerPath
            })
            continue
        }

        $query = [uri]::EscapeDataString($folder.Name)
        try {
            $lookup = Expand-FlatArray -Value (Invoke-RadarrGet -Path "/movie/lookup?term=$query")
        }
        catch {
            $skipped.Add([pscustomobject]@{
                reason = 'lookupError'
                folder = $folder.Name
                path = $containerPath
                error = $_.Exception.Message
            })
            continue
        }

        $match = Pick-MovieMatch -Lookup $lookup -FolderName $folder.Name
        if (-not $match) {
            $folderYear = Get-FolderYear -Name $folder.Name
            $top = @($lookup)[0]
            $skipped.Add([pscustomobject]@{
                reason = 'noConfidentMatch'
                folder = $folder.Name
                path = $containerPath
                folderYear = $folderYear
                lookupCount = $lookup.Count
                topTitle = $top.title
                topYear = $top.year
            })
            continue
        }

        $tmdbKey = [string]$match.tmdbId
        if ($existingTmdbIds.ContainsKey($tmdbKey) -or $seenTmdbIds.ContainsKey($tmdbKey)) {
            $duplicates.Add([pscustomobject]@{
                reason = 'tmdbDuplicate'
                folder = $folder.Name
                path = $containerPath
                title = $match.title
                year = $match.year
                tmdbId = $match.tmdbId
            })
            continue
        }

        $seenTmdbIds[$tmdbKey] = $true
        $candidate = [pscustomobject]@{
            folder = $folder.Name
            path = $containerPath
            root = $root.Root
            title = $match.title
            year = $match.year
            tmdbId = $match.tmdbId
            folderYear = Get-FolderYear -Name $folder.Name
            lookup = $match
        }
        $addable.Add($candidate)

        if ($Apply) {
            $movieBody = $match
            $movieBody | Add-Member -NotePropertyName qualityProfileId -NotePropertyValue $QualityProfileId -Force
            $movieBody | Add-Member -NotePropertyName monitored -NotePropertyValue $true -Force
            $movieBody | Add-Member -NotePropertyName minimumAvailability -NotePropertyValue 'released' -Force
            $movieBody | Add-Member -NotePropertyName rootFolderPath -NotePropertyValue $root.Root -Force
            $movieBody | Add-Member -NotePropertyName path -NotePropertyValue $containerPath -Force
            $movieBody | Add-Member -NotePropertyName addOptions -NotePropertyValue @{
                searchForMovie = $false
            } -Force

            try {
                $created = Invoke-RadarrPost -Path '/movie' -Body $movieBody
                $added.Add([pscustomobject]@{
                    folder = $folder.Name
                    path = $containerPath
                    title = $created.title
                    year = $created.year
                    tmdbId = $created.tmdbId
                })
                $existingTmdbIds[$tmdbKey] = $true
                $existingPaths[$containerPath.ToLowerInvariant()] = $true
            }
            catch {
                $failed.Add([pscustomobject]@{
                    folder = $folder.Name
                    path = $containerPath
                    title = $match.title
                    year = $match.year
                    tmdbId = $match.tmdbId
                    error = $_.Exception.Message
                })
            }
        }
    }
}

$result = [pscustomobject]@{
    mode = if ($Apply) { 'apply' } else { 'dryRun' }
    totalFolders = $totalFolders
    existingBefore = $existingMovies.Count
    addableCount = $addable.Count
    addedCount = $added.Count
    duplicateCount = $duplicates.Count
    skippedCount = $skipped.Count
    failedCount = $failed.Count
    sampleAddable = @($addable | Select-Object -First 20 -Property folder, path, title, year, tmdbId, folderYear)
    sampleAdded = @($added | Select-Object -First 20)
    sampleSkipped = @($skipped | Select-Object -First 40)
    sampleDuplicates = @($duplicates | Select-Object -First 20)
    sampleFailed = @($failed | Select-Object -First 20)
}

$result | ConvertTo-Json -Depth 8
