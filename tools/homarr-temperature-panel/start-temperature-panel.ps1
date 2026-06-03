param(
    [int]$Port = 8765,
    [string]$SensorPath = "C:\plex-server\docs\crash_logs\thermal\latest-sensors.json"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web

function Get-TemperatureModel {
    if (-not (Test-Path -LiteralPath $SensorPath)) {
        return @{
            generatedAt = (Get-Date).ToString("o")
            stale = $true
            ageSeconds = $null
            cpu = $null
            gpu = $null
            drives = @()
            error = "Sensor snapshot not found"
        }
    }

    $raw = Get-Content -LiteralPath $SensorPath -Raw
    $snapshot = $raw | ConvertFrom-Json
    $timestamp = [datetimeoffset]::Parse($snapshot.timestamp)
    $age = [math]::Round(((Get-Date) - $timestamp.LocalDateTime).TotalSeconds)
    $sensors = @($snapshot.sensors)

    $cpuTemps = @($sensors | Where-Object {
        $_.hardware_type -eq "CpuCoreTemp" -and
        $_.sensor_type -eq "Temperature" -and
        $_.unit -eq "C"
    })

    $gpuCore = $sensors | Where-Object {
        $_.hardware_type -like "Gpu*" -and $_.sensor_type -eq "Temperature" -and $_.sensor_name -eq "GPU Core"
    } | Select-Object -First 1

    $gpuHotspot = $sensors | Where-Object {
        $_.hardware_type -like "Gpu*" -and $_.sensor_type -eq "Temperature" -and $_.sensor_name -like "*Hot Spot*"
    } | Select-Object -First 1

    $drives = @($sensors | Where-Object {
        $_.hardware_type -eq "Smartctl" -and $_.sensor_type -eq "Temperature"
    } | Sort-Object value -Descending | ForEach-Object {
        @{
            name = $_.hardware_name
            value = [math]::Round([double]$_.value, 1)
            unit = "C"
            status = if ([double]$_.value -ge 55) { "hot" } elseif ([double]$_.value -ge 45) { "warm" } else { "ok" }
        }
    })

    $cpuMax = if ($cpuTemps.Count -gt 0) { ($cpuTemps | Measure-Object -Property value -Maximum).Maximum } else { $null }

    return @{
        generatedAt = (Get-Date).ToString("o")
        snapshotAt = $timestamp.ToString("o")
        stale = ($age -gt 300)
        ageSeconds = $age
        cpu = if ($null -ne $cpuMax) {
            @{
                name = "CPU"
                subtitle = "i5-14500 hottest core"
                value = [math]::Round([double]$cpuMax, 1)
                unit = "C"
                status = if ($cpuMax -ge 85) { "hot" } elseif ($cpuMax -ge 70) { "warm" } else { "ok" }
            }
        } else { $null }
        gpu = if ($null -ne $gpuCore) {
            @{
                name = "GPU"
                subtitle = if ($null -ne $gpuHotspot) { "RTX 3050 core / hotspot $([math]::Round([double]$gpuHotspot.value, 1)) C" } else { "RTX 3050 core" }
                value = [math]::Round([double]$gpuCore.value, 1)
                unit = "C"
                status = if ([double]$gpuCore.value -ge 82) { "hot" } elseif ([double]$gpuCore.value -ge 70) { "warm" } else { "ok" }
            }
        } else { $null }
        drives = $drives
        error = $null
    }
}

function Get-GaugeHtml {
    param(
        [string]$Title,
        [string]$Mode
    )

    $titleEscaped = [System.Web.HttpUtility]::HtmlEncode($Title)
    $html = @'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="30">
  <style>
    :root { color-scheme: dark; font-family: Inter, Segoe UI, Arial, sans-serif; }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      color: #f8fafc;
      background: linear-gradient(145deg, rgba(13, 17, 23, .82), rgba(10, 12, 18, .62));
      overflow: hidden;
    }
    .wrap { height: 100vh; padding: 7px; display: flex; flex-direction: column; gap: 5px; }
    .top { display: flex; align-items: baseline; justify-content: space-between; gap: 8px; }
    h1 { margin: 0; font-size: 11px; text-transform: uppercase; letter-spacing: .08em; color: #e5a00d; }
    .age { font-size: 10px; color: #cbd5e1; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(108px, 1fr)); gap: 6px; height: 100%; align-content: start; }
    .gauge {
      min-height: 70px;
      border: 1px solid rgba(255,255,255,.12);
      border-radius: 10px;
      padding: 7px;
      background: rgba(15, 23, 42, .58);
      box-shadow: inset 0 1px 0 rgba(255,255,255,.08), 0 18px 40px rgba(0,0,0,.28);
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      gap: 5px;
    }
    .label { font-size: 11px; color: #cbd5e1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .sub { font-size: 9px; color: #94a3b8; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .value { font-size: clamp(28px, 9vw, 42px); font-weight: 800; line-height: .95; }
    .unit { font-size: 13px; color: #cbd5e1; margin-left: 3px; }
    .bar { height: 6px; border-radius: 99px; overflow: hidden; background: rgba(148, 163, 184, .18); }
    .fill { height: 100%; border-radius: inherit; width: var(--pct); background: var(--color); box-shadow: 0 0 18px var(--color); }
    .ok { --color: #22c55e; }
    .warm { --color: #e5a00d; }
    .hot { --color: #ef4444; }
    .stale { color: #fbbf24; }
    .error { color: #fca5a5; font-size: 13px; line-height: 1.4; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="top">
      <h1>__TITLE__</h1>
      <div id="age" class="age"></div>
    </div>
    <div id="content" class="grid"></div>
  </div>
  <script>
    const mode = "__MODE__";
    const maxFor = (item) => item.name === "CPU" ? 100 : item.name === "GPU" ? 95 : 65;
    const html = (item) => {
      const pct = Math.max(0, Math.min(100, item.value / maxFor(item) * 100)).toFixed(1) + "%";
      if (mode === "cpu" || mode === "gpu") {
        return `<div class="gauge ${item.status}">
          <div><span class="value">${Number(item.value).toFixed(1)}</span><span class="unit">C</span></div>
          <div class="label">${item.name}</div>
          <div class="bar"><div class="fill" style="--pct:${pct}"></div></div>
        </div>`;
      }
      return `<div class="gauge ${item.status}">
        <div>
          <div class="label">${item.name}</div>
          <div class="sub">${item.subtitle || ""}</div>
        </div>
        <div><span class="value">${Number(item.value).toFixed(1)}</span><span class="unit">C</span></div>
        <div class="bar"><div class="fill" style="--pct:${pct}"></div></div>
      </div>`;
    };
    fetch("/temps.json").then(r => r.json()).then(data => {
      document.getElementById("age").textContent = data.stale ? `stale ${Math.round((data.ageSeconds || 0) / 60)}m` : `fresh ${data.ageSeconds}s`;
      if (data.stale) document.getElementById("age").classList.add("stale");
      if (data.error) {
        document.getElementById("content").innerHTML = `<div class="error">${data.error}</div>`;
        return;
      }
      let items = [];
      if (mode === "cpu" && data.cpu) items = [data.cpu];
      if (mode === "gpu" && data.gpu) items = [data.gpu];
      if (mode === "drives") items = data.drives || [];
      if (mode === "all") items = [data.cpu, data.gpu, ...(data.drives || [])].filter(Boolean);
      document.getElementById("content").innerHTML = items.map(html).join("");
    }).catch(err => {
      document.getElementById("content").innerHTML = `<div class="error">${err.message}</div>`;
    });
  </script>
</body>
</html>
'@
    $html.Replace("__TITLE__", $titleEscaped).Replace("__MODE__", $Mode)
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Host "Homarr temperature panel listening on http://127.0.0.1:$Port/"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    try {
        if ($request.Url.AbsolutePath -eq "/temps.json") {
            $json = Get-TemperatureModel | ConvertTo-Json -Depth 8
            $bytes = [Text.Encoding]::UTF8.GetBytes($json)
            $response.ContentType = "application/json; charset=utf-8"
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        else {
            $mode = $request.QueryString["mode"]
            if ([string]::IsNullOrWhiteSpace($mode)) { $mode = "all" }
            $title = switch ($mode) {
                "cpu" { "CPU Temperature" }
                "gpu" { "GPU Temperature" }
                "drives" { "Drive Temperatures" }
                default { "System Temperatures" }
            }
            $html = Get-GaugeHtml -Title $title -Mode $mode
            $bytes = [Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentType = "text/html; charset=utf-8"
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
    }
    catch {
        $response.StatusCode = 500
        $bytes = [Text.Encoding]::UTF8.GetBytes($_.Exception.Message)
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    finally {
        $response.Close()
    }
}
