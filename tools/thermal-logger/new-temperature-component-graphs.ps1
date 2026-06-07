param(
    [string]$LogRoot = "C:\plex-server\docs\crash_logs\thermal",
    [string]$OutputPath = "",
    [int]$Hours = 12,
    [int]$BucketMinutes = 5
)

$ErrorActionPreference = "Stop"

function Escape-Xml([string]$Value) {
    return [System.Security.SecurityElement]::Escape($Value)
}

$csvFiles = Get-ChildItem -LiteralPath $LogRoot -Filter "libre-sensors-*.csv" |
    Sort-Object LastWriteTime
if (-not $csvFiles) {
    throw "No thermal CSV files found in $LogRoot"
}

$latestTimestamp = [datetimeoffset]::MinValue
foreach ($file in ($csvFiles | Sort-Object LastWriteTime -Descending)) {
    $reader = [System.IO.StreamReader]::new($file.FullName)
    try {
        $lastLine = $null
        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ($line) { $lastLine = $line }
        }
        if ($lastLine -and $lastLine.StartsWith('"')) {
            $timestampText = $lastLine.Substring(1, $lastLine.IndexOf('","') - 1)
            $latestTimestamp = [datetimeoffset]::Parse($timestampText)
            break
        }
    }
    finally {
        $reader.Dispose()
    }
}
if ($latestTimestamp -eq [datetimeoffset]::MinValue) {
    throw "Could not determine the latest thermal timestamp"
}

$startTimestamp = $latestTimestamp.AddHours(-$Hours)
$bucketSeconds = $BucketMinutes * 60
$series = @{}

function Add-Reading {
    param(
        [string]$Key,
        [string]$Label,
        [datetimeoffset]$Timestamp,
        [double]$Value,
        [string]$Kind
    )

    if (-not $series.ContainsKey($Key)) {
        $series[$Key] = @{
            Label = $Label
            Kind = $Kind
            Buckets = @{}
        }
    }
    $bucket = [math]::Floor(($Timestamp - $startTimestamp).TotalSeconds / $bucketSeconds)
    if ($bucket -lt 0) { return }

    $buckets = $series[$Key].Buckets
    if (-not $buckets.ContainsKey($bucket)) {
        $buckets[$bucket] = @{
            Timestamp = $Timestamp
            Sum = 0.0
            Count = 0
            Max = [double]::MinValue
        }
    }
    $entry = $buckets[$bucket]
    $entry.Sum += $Value
    $entry.Count++
    if ($Value -gt $entry.Max) { $entry.Max = $Value }
}

foreach ($file in $csvFiles) {
    if ($file.LastWriteTime -lt $startTimestamp.LocalDateTime.AddHours(-24)) { continue }

    $reader = [System.IO.StreamReader]::new($file.FullName)
    try {
        [void]$reader.ReadLine()
        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if (-not $line -or $line.IndexOf('","Temperature","') -lt 0 -or -not $line.EndsWith(',"C"')) {
                continue
            }

            $fields = $line.Trim('"') -split '","'
            if ($fields.Count -ne 7) { continue }
            $timestamp = [datetimeoffset]::Parse($fields[0])
            if ($timestamp -lt $startTimestamp -or $timestamp -gt $latestTimestamp) { continue }

            $hardwareType = $fields[1]
            $hardwareName = $fields[2]
            $sensorName = $fields[4]
            $value = [double]::Parse($fields[5], [Globalization.CultureInfo]::InvariantCulture)

            if ($hardwareType -eq "CpuCoreTemp" -and $sensorName -like "CPU Core #*") {
                Add-Reading -Key "CPU" -Label "Intel Core i5-14500 - hottest core" `
                    -Timestamp $timestamp -Value $value -Kind "cpu"
            }
            elseif ($hardwareType -like "Gpu*" -and $sensorName -eq "GPU Core") {
                Add-Reading -Key "GPU Core" -Label "NVIDIA RTX 3050 - core" `
                    -Timestamp $timestamp -Value $value -Kind "gpu"
            }
            elseif ($hardwareType -like "Gpu*" -and $sensorName -like "*Hot Spot*") {
                Add-Reading -Key "GPU Hotspot" -Label "NVIDIA RTX 3050 - hotspot" `
                    -Timestamp $timestamp -Value $value -Kind "gpu-hotspot"
            }
            elseif ($hardwareType -eq "Smartctl") {
                Add-Reading -Key "Drive: $hardwareName" -Label $hardwareName `
                    -Timestamp $timestamp -Value $value -Kind "drive"
            }
        }
    }
    finally {
        $reader.Dispose()
    }
}

# CPU buckets contain all core readings, so graph their maximum rather than average.
$plots = @()
foreach ($key in $series.Keys) {
    $item = $series[$key]
    $points = @($item.Buckets.GetEnumerator() | Sort-Object { [int]$_.Key } | ForEach-Object {
        $entry = $_.Value
        [pscustomobject]@{
            Time = $startTimestamp.AddSeconds(([int]$_.Key * $bucketSeconds) + ($bucketSeconds / 2))
            Value = if ($item.Kind -eq "cpu") { $entry.Max } else { $entry.Sum / $entry.Count }
        }
    })
    if ($points.Count -gt 0) {
        $plots += [pscustomobject]@{
            Key = $key
            Label = $item.Label
            Kind = $item.Kind
            Points = $points
            Min = ($points.Value | Measure-Object -Minimum).Minimum
            Max = ($points.Value | Measure-Object -Maximum).Maximum
            Avg = ($points.Value | Measure-Object -Average).Average
        }
    }
}

$kindOrder = @{ cpu = 0; gpu = 1; "gpu-hotspot" = 2; drive = 3 }
$plots = @($plots | Sort-Object @{ Expression = { $kindOrder[$_.Kind] } }, Label)
if (-not $plots) {
    throw "No temperature readings found between $startTimestamp and $latestTimestamp"
}

$width = 1400
$panelWidth = 650
$panelHeight = 235
$columns = 2
$rows = [math]::Ceiling($plots.Count / $columns)
$height = 145 + ($rows * $panelHeight)
$left = 58
$top = 78
$chartWidth = 555
$chartHeight = 145
$colors = @{
    cpu = "#f59e0b"
    gpu = "#38bdf8"
    "gpu-hotspot" = "#a78bfa"
    drive = "#22c55e"
}

$sb = [Text.StringBuilder]::new()
[void]$sb.AppendLine("<svg xmlns='http://www.w3.org/2000/svg' width='$width' height='$height' viewBox='0 0 $width $height' role='img' aria-label='Plex server component temperatures over the most recent captured 12 hours'>")
[void]$sb.AppendLine("<rect width='100%' height='100%' fill='#0f172a'/>")
[void]$sb.AppendLine("<style>text{font-family:Segoe UI,Arial,sans-serif;fill:#e2e8f0}.title{font-size:26px;font-weight:700}.subtitle{font-size:14px;fill:#94a3b8}.label{font-size:15px;font-weight:600}.stat{font-size:12px;fill:#cbd5e1}.axis{font-size:11px;fill:#94a3b8}.grid{stroke:#334155;stroke-width:1}.frame{fill:#111c31;stroke:#334155;stroke-width:1}</style>")
[void]$sb.AppendLine("<text x='40' y='38' class='title'>Plex Server Temperatures - Most Recent Captured $Hours Hours</text>")
$rangeText = "{0:MMM d, h:mm tt} to {1:MMM d, h:mm tt zzz}" -f $startTimestamp, $latestTimestamp
[void]$sb.AppendLine("<text x='40' y='62' class='subtitle'>$(Escape-Xml $rangeText) | $BucketMinutes-minute buckets | Logger stopped after this range</text>")

for ($index = 0; $index -lt $plots.Count; $index++) {
    $plot = $plots[$index]
    $column = $index % $columns
    $row = [math]::Floor($index / $columns)
    $panelX = 35 + ($column * 690)
    $panelY = 90 + ($row * $panelHeight)
    $chartX = $panelX + $left
    $chartY = $panelY + $top

    $yMin = [math]::Floor(($plot.Min - 3) / 5) * 5
    $yMax = [math]::Ceiling(($plot.Max + 3) / 5) * 5
    if (($yMax - $yMin) -lt 10) { $yMax = $yMin + 10 }

    [void]$sb.AppendLine("<rect x='$panelX' y='$panelY' width='$panelWidth' height='$($panelHeight - 15)' rx='10' class='frame'/>")
    [void]$sb.AppendLine("<text x='$($panelX + 18)' y='$($panelY + 28)' class='label'>$(Escape-Xml $plot.Label)</text>")
    $stats = "min {0:N1} C | avg {1:N1} C | max {2:N1} C" -f $plot.Min, $plot.Avg, $plot.Max
    [void]$sb.AppendLine("<text x='$($panelX + 18)' y='$($panelY + 49)' class='stat'>$stats</text>")

    for ($grid = 0; $grid -le 4; $grid++) {
        $gy = $chartY + ($grid * $chartHeight / 4)
        $gridValue = $yMax - ($grid * ($yMax - $yMin) / 4)
        [void]$sb.AppendLine("<line x1='$chartX' y1='$gy' x2='$($chartX + $chartWidth)' y2='$gy' class='grid'/>")
        [void]$sb.AppendLine("<text x='$($chartX - 8)' y='$($gy + 4)' text-anchor='end' class='axis'>$([math]::Round($gridValue))</text>")
    }
    for ($tick = 0; $tick -le 4; $tick++) {
        $gx = $chartX + ($tick * $chartWidth / 4)
        $tickTime = $startTimestamp.AddSeconds($tick * ($latestTimestamp - $startTimestamp).TotalSeconds / 4)
        [void]$sb.AppendLine("<line x1='$gx' y1='$chartY' x2='$gx' y2='$($chartY + $chartHeight)' class='grid'/>")
        [void]$sb.AppendLine("<text x='$gx' y='$($chartY + $chartHeight + 18)' text-anchor='middle' class='axis'>$($tickTime.ToString('h:mm tt'))</text>")
    }

    $pointText = @($plot.Points | ForEach-Object {
        $x = $chartX + ((($_.Time - $startTimestamp).TotalSeconds / ($latestTimestamp - $startTimestamp).TotalSeconds) * $chartWidth)
        $y = $chartY + (($yMax - $_.Value) / ($yMax - $yMin) * $chartHeight)
        "{0:N1},{1:N1}" -f $x, $y
    }) -join " "
    [void]$sb.AppendLine("<polyline points='$pointText' fill='none' stroke='$($colors[$plot.Kind])' stroke-width='2' stroke-linejoin='round' stroke-linecap='round'/>")
}

[void]$sb.AppendLine("</svg>")

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputPath = Join-Path "C:\plex-server\docs\health_reports" "temperature-components-most-recent-12h-$stamp.svg"
}
[System.IO.File]::WriteAllText($OutputPath, $sb.ToString(), [Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    OutputPath = $OutputPath
    Start = $startTimestamp
    End = $latestTimestamp
    Components = $plots.Count
    Series = $plots | Select-Object Label, Min, Avg, Max
}
