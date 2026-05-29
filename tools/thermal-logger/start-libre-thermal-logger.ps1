param(
    [string]$LogRoot = "C:\plex-server\docs\crash_logs\thermal",
    [int]$IntervalSeconds = 2,
    [int]$SmartIntervalSeconds = 30,
    [int]$RotateHours = 24,
    [switch]$Once
)

$ErrorActionPreference = "Stop"

function Find-LibreHardwareMonitorLib {
    $candidates = @(
        "C:\Users\Kyle\AppData\Local\Microsoft\WinGet\Packages\LibreHardwareMonitor.LibreHardwareMonitor_Microsoft.Winget.Source_8wekyb3d8bbwe\LibreHardwareMonitorLib.dll"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    $packageRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    if (Test-Path -LiteralPath $packageRoot) {
        $found = Get-ChildItem -Path $packageRoot -Recurse -Filter "LibreHardwareMonitorLib.dll" -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($found) {
            return $found.FullName
        }
    }

    throw "LibreHardwareMonitorLib.dll was not found. Install LibreHardwareMonitor with: winget install --source winget --id LibreHardwareMonitor.LibreHardwareMonitor --exact"
}

function ConvertTo-CsvField {
    param([object]$Value)

    if ($null -eq $Value) {
        return '""'
    }

    $text = [string]$Value
    $text = $text.Replace('"', '""')
    return '"' + $text + '"'
}

function Get-SensorUnit {
    param([string]$SensorType)

    switch ($SensorType) {
        "Temperature" { "C" }
        "Voltage" { "V" }
        "Clock" { "MHz" }
        "Load" { "%" }
        "Fan" { "RPM" }
        "Flow" { "L/h" }
        "Control" { "%" }
        "Level" { "%" }
        "Factor" { "x" }
        "Power" { "W" }
        "Data" { "GB" }
        "SmallData" { "MB" }
        "Throughput" { "B/s" }
        "TimeSpan" { "s" }
        "Energy" { "mWh" }
        "Noise" { "dBA" }
        "Conductivity" { "uS/cm" }
        "Humidity" { "%" }
        default { "" }
    }
}

function Update-HardwareTree {
    param([object]$Hardware)

    $Hardware.Update()
    foreach ($subHardware in $Hardware.SubHardware) {
        Update-HardwareTree -Hardware $subHardware
    }
}

function Get-SensorRows {
    param(
        [object]$Hardware,
        [string]$Timestamp,
        [string]$ParentName = "",
        [hashtable]$HardwareNameMap = @{}
    )

    $baseHardwareName = if ($HardwareNameMap.ContainsKey($Hardware.Identifier.ToString())) {
        $HardwareNameMap[$Hardware.Identifier.ToString()]
    } else {
        $Hardware.Name
    }
    $hardwareName = if ($ParentName) { "$ParentName / $baseHardwareName" } else { $baseHardwareName }
    $hardwareType = $Hardware.HardwareType.ToString()

    foreach ($sensor in $Hardware.Sensors) {
        if ($null -ne $sensor.Value) {
            $sensorType = $sensor.SensorType.ToString()
            [pscustomobject]@{
                timestamp = $Timestamp
                hardware_type = $hardwareType
                hardware_name = $hardwareName
                sensor_type = $sensorType
                sensor_name = $sensor.Name
                value = [math]::Round([double]$sensor.Value, 3)
                unit = Get-SensorUnit -SensorType $sensorType
            }
        }
    }

    foreach ($subHardware in $Hardware.SubHardware) {
        Get-SensorRows -Hardware $subHardware -Timestamp $Timestamp -ParentName $hardwareName -HardwareNameMap $HardwareNameMap
    }
}

function New-HardwareNameMap {
    param([object[]]$Hardware)

    $map = @{}

    $windowsDisks = @(
        Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue |
            Select-Object Index, Model, SerialNumber |
            Sort-Object Index
    )

    $modelQueues = @{}
    foreach ($disk in $windowsDisks) {
        $model = ([string]$disk.Model).Trim()
        $serial = ([string]$disk.SerialNumber).Trim()
        if (-not $model -or -not $serial) {
            continue
        }
        if (-not $modelQueues.ContainsKey($model)) {
            $modelQueues[$model] = New-Object System.Collections.Queue
        }
        $modelQueues[$model].Enqueue($serial)
    }

    $storageHardware = @($Hardware | Where-Object { $_.HardwareType.ToString() -eq "Storage" })
    foreach ($item in $storageHardware) {
        $name = ([string]$item.Name).Trim()
        if ($modelQueues.ContainsKey($name) -and $modelQueues[$name].Count -gt 0) {
            $serial = $modelQueues[$name].Dequeue()
            $map[$item.Identifier.ToString()] = "$name [$serial]"
        }
    }

    return $map
}

function Add-CoreTempReaderType {
    if ("CoreTempMapReader" -as [type]) {
        return
    }

    $code = @'
using System;
using System.Runtime.InteropServices;

[StructLayout(LayoutKind.Sequential, Pack=4, CharSet=CharSet.Ansi)]
public struct CoreTempSharedDataEx {
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=256)] public uint[] uiLoad;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=128)] public uint[] uiTjMax;
    public uint uiCoreCnt;
    public uint uiCPUCnt;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=256)] public float[] fTemp;
    public float fVID;
    public float fCPUSpeed;
    public float fFSBSpeed;
    public float fMultiplier;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=100)] public string sCPUName;
    public byte ucFahrenheit;
    public byte ucDeltaToTjMax;
    public byte ucTdpSupported;
    public byte ucPowerSupported;
    public uint uiStructVersion;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=128)] public uint[] uiTdp;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=128)] public float[] fPower;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=256)] public float[] fMultipliers;
}

public static class CoreTempMapReader {
    const uint FILE_MAP_READ = 0x0004;
    [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)] static extern IntPtr OpenFileMapping(uint dwDesiredAccess, bool bInheritHandle, string lpName);
    [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr MapViewOfFile(IntPtr hFileMappingObject, uint dwDesiredAccess, uint dwFileOffsetHigh, uint dwFileOffsetLow, UIntPtr dwNumberOfBytesToMap);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool UnmapViewOfFile(IntPtr lpBaseAddress);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool CloseHandle(IntPtr hObject);
    public static CoreTempSharedDataEx Read() {
        IntPtr h = OpenFileMapping(FILE_MAP_READ, false, "CoreTempMappingObjectEx");
        if (h == IntPtr.Zero) throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(), "OpenFileMapping failed");
        try {
            UIntPtr size = (UIntPtr)Marshal.SizeOf(typeof(CoreTempSharedDataEx));
            IntPtr view = MapViewOfFile(h, FILE_MAP_READ, 0, 0, size);
            if (view == IntPtr.Zero) throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(), "MapViewOfFile failed");
            try { return (CoreTempSharedDataEx)Marshal.PtrToStructure(view, typeof(CoreTempSharedDataEx)); }
            finally { UnmapViewOfFile(view); }
        } finally { CloseHandle(h); }
    }
}
'@
    Add-Type -TypeDefinition $code
}

function Add-SharedMemoryTextReaderType {
    if ("SharedMemoryTextReader" -as [type]) {
        return
    }

    $code = @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class SharedMemoryTextReader {
    const uint FILE_MAP_READ = 0x0004;
    [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)] static extern IntPtr OpenFileMapping(uint access, bool inherit, string name);
    [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr MapViewOfFile(IntPtr h, uint access, uint offHigh, uint offLow, UIntPtr bytes);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool UnmapViewOfFile(IntPtr addr);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool CloseHandle(IntPtr h);

    public static string Read(string name, int bytes) {
        IntPtr h = OpenFileMapping(FILE_MAP_READ, false, name);
        if (h == IntPtr.Zero) throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(), "OpenFileMapping failed");
        try {
            IntPtr v = MapViewOfFile(h, FILE_MAP_READ, 0, 0, (UIntPtr)bytes);
            if (v == IntPtr.Zero) throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(), "MapViewOfFile failed");
            try {
                byte[] raw = new byte[bytes];
                Marshal.Copy(v, raw, 0, bytes);
                int ansiLen = Array.IndexOf<byte>(raw, 0);
                if (ansiLen < 0) ansiLen = bytes;

                int unicodeLen = -1;
                for (int i = 0; i < raw.Length - 1; i += 2) {
                    if (raw[i] == 0 && raw[i + 1] == 0) {
                        unicodeLen = i;
                        break;
                    }
                }

                string ansi = Encoding.ASCII.GetString(raw, 0, ansiLen).TrimEnd('\0');
                string unicode = unicodeLen > 0 ? Encoding.Unicode.GetString(raw, 0, unicodeLen).TrimEnd('\0') : "";
                return unicode.Contains("<") && unicode.Contains(">") ? unicode : ansi;
            }
            finally { UnmapViewOfFile(v); }
        }
        finally { CloseHandle(h); }
    }
}
'@
    Add-Type -TypeDefinition $code
}

function Find-CoreTempExe {
    $candidates = @(
        "C:\Program Files\Core Temp\Core Temp.exe",
        "C:\Program Files (x86)\Core Temp\Core Temp.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Ensure-CoreTempSharedMemory {
    Add-CoreTempReaderType

    try {
        [CoreTempMapReader]::Read() | Out-Null
        return $true
    }
    catch {
        $coreTemp = Find-CoreTempExe
        if (-not $coreTemp) {
            return $false
        }

        if (-not (Get-Process -Name "Core Temp" -ErrorAction SilentlyContinue)) {
            Start-Process -FilePath $coreTemp -WindowStyle Minimized
            Start-Sleep -Seconds 5
        }

        try {
            [CoreTempMapReader]::Read() | Out-Null
            return $true
        }
        catch {
            return $false
        }
    }
}

function Get-CoreTempRows {
    param([string]$Timestamp)

    try {
        $data = [CoreTempMapReader]::Read()
    }
    catch {
        return
    }

    $cpuName = $data.sCPUName
    $coreCount = [int]$data.uiCoreCnt

    for ($i = 0; $i -lt $coreCount; $i++) {
        $temp = [double]$data.fTemp[$i]
        if ($temp -ne 0) {
            [pscustomobject]@{
                timestamp = $Timestamp
                hardware_type = "CpuCoreTemp"
                hardware_name = $cpuName
                sensor_type = "Temperature"
                sensor_name = "CPU Core #$($i + 1)"
                value = [math]::Round($temp, 3)
                unit = if ($data.ucFahrenheit -eq 1) { "F" } else { "C" }
            }
        }

        [pscustomobject]@{
            timestamp = $Timestamp
            hardware_type = "CpuCoreTemp"
            hardware_name = $cpuName
            sensor_type = "Load"
            sensor_name = "CPU Core #$($i + 1)"
            value = [math]::Round([double]$data.uiLoad[$i], 3)
            unit = "%"
        }

        if ($data.uiStructVersion -ge 2 -and $data.fMultipliers[$i] -ne 0) {
            [pscustomobject]@{
                timestamp = $Timestamp
                hardware_type = "CpuCoreTemp"
                hardware_name = $cpuName
                sensor_type = "Factor"
                sensor_name = "CPU Core #$($i + 1) Multiplier"
                value = [math]::Round([double]$data.fMultipliers[$i], 3)
                unit = "x"
            }
        }
    }

    [pscustomobject]@{
        timestamp = $Timestamp
        hardware_type = "CpuCoreTemp"
        hardware_name = $cpuName
        sensor_type = "Clock"
        sensor_name = "CPU Speed"
        value = [math]::Round([double]$data.fCPUSpeed, 3)
        unit = "MHz"
    }

    if ($data.ucPowerSupported -eq 1 -and $data.fPower[0] -ne 0) {
        [pscustomobject]@{
            timestamp = $Timestamp
            hardware_type = "CpuCoreTemp"
            hardware_name = $cpuName
            sensor_type = "Power"
            sensor_name = "CPU Package"
            value = [math]::Round([double]$data.fPower[0], 3)
            unit = "W"
        }
    }
}

function Convert-Aida64TagToSensorType {
    param([string]$TagName)

    switch -Regex ($TagName) {
        "^temp$" { "Temperature" }
        "^fan$" { "Fan" }
        "^volt$" { "Voltage" }
        "^pwr$|^power$" { "Power" }
        "^curr$|^current$" { "Current" }
        "^duty$" { "Control" }
        "^sys$" { "System" }
        default { $TagName }
    }
}

function Get-Aida64Unit {
    param(
        [string]$SensorType,
        [string]$RawValue
    )

    switch ($SensorType) {
        "Temperature" { "C" }
        "Fan" { "RPM" }
        "Voltage" { "V" }
        "Power" { "W" }
        "Current" { "A" }
        "Control" { "%" }
        default {
            if ($RawValue -match "%") { "%" }
            elseif ($RawValue -match "MHz") { "MHz" }
            elseif ($RawValue -match "GHz") { "GHz" }
            elseif ($RawValue -match "RPM") { "RPM" }
            elseif ($RawValue -match "°C| C$") { "C" }
            else { "" }
        }
    }
}

function Convert-Aida64Value {
    param([string]$RawValue)

    if ($RawValue -match "[-+]?\d+([.,]\d+)?") {
        return [double]($matches[0].Replace(",", "."))
    }

    return $RawValue
}

function Parse-Aida64XmlFragment {
    param(
        [string]$Fragment,
        [string]$Timestamp
    )

    if ([string]::IsNullOrWhiteSpace($Fragment)) {
        return
    }

    $clean = $Fragment.Trim([char]0).Trim()
    if (-not $clean) {
        return
    }

    try {
        [xml]$xml = "<root>$clean</root>"
    }
    catch {
        return
    }

    foreach ($node in $xml.root.ChildNodes) {
        $id = $node.id
        $label = $node.label
        $rawValue = [string]$node.value
        if (-not $label -or -not $rawValue) {
            continue
        }

        $sensorType = Convert-Aida64TagToSensorType -TagName $node.Name
        $unit = Get-Aida64Unit -SensorType $sensorType -RawValue $rawValue
        $value = Convert-Aida64Value -RawValue $rawValue

        [pscustomobject]@{
            timestamp = $Timestamp
            hardware_type = "AIDA64"
            hardware_name = "AIDA64 External Applications"
            sensor_type = $sensorType
            sensor_name = if ($id) { "$label [$id]" } else { $label }
            value = if ($value -is [double]) { [math]::Round($value, 3) } else { $value }
            unit = $unit
        }
    }
}

function Get-Aida64SharedMemoryRows {
    param([string]$Timestamp)

    Add-SharedMemoryTextReaderType

    foreach ($name in @("Global\AIDA64_SensorValues", "Local\AIDA64_SensorValues", "AIDA64_SensorValues")) {
        try {
            $text = [SharedMemoryTextReader]::Read($name, 262144)
            foreach ($row in (Parse-Aida64XmlFragment -Fragment $text -Timestamp $Timestamp)) {
                $row
            }
            return
        }
        catch {
            continue
        }
    }
}

function Get-Aida64RegistryRows {
    param([string]$Timestamp)

    $key = "HKCU:\Software\FinalWire\AIDA64\SensorValues"
    if (-not (Test-Path -LiteralPath $key)) {
        return
    }

    $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
    if (-not $props) {
        return
    }

    $propertyNames = $props.PSObject.Properties.Name | Where-Object { $_ -notmatch "^PS" }
    $ids = @{}
    foreach ($name in $propertyNames) {
        if ($name -match "^(Value|Label)\.(.+)$") {
            $ids[$matches[2]] = $true
        }
    }

    foreach ($id in $ids.Keys) {
        $labelProp = "Label.$id"
        $valueProp = "Value.$id"
        $label = $props.$labelProp
        $rawValue = [string]$props.$valueProp
        if (-not $label -or -not $rawValue) {
            continue
        }

        $sensorType = if ($id -match "^T") { "Temperature" } elseif ($id -match "^F") { "Fan" } elseif ($id -match "^V") { "Voltage" } elseif ($id -match "^P") { "Power" } else { "System" }
        $unit = Get-Aida64Unit -SensorType $sensorType -RawValue $rawValue
        $value = Convert-Aida64Value -RawValue $rawValue

        [pscustomobject]@{
            timestamp = $Timestamp
            hardware_type = "AIDA64"
            hardware_name = "AIDA64 Registry Export"
            sensor_type = $sensorType
            sensor_name = "$label [$id]"
            value = if ($value -is [double]) { [math]::Round($value, 3) } else { $value }
            unit = $unit
        }
    }
}

function Get-Aida64Rows {
    param([string]$Timestamp)

    $rows = @(Get-Aida64SharedMemoryRows -Timestamp $Timestamp)
    if ($rows.Count -gt 0) {
        return $rows
    }

    Get-Aida64RegistryRows -Timestamp $Timestamp
}

function Find-Smartctl {
    $candidates = @(
        "C:\Program Files\smartmontools\bin\smartctl.exe",
        "C:\Program Files (x86)\smartmontools\bin\smartctl.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    $command = Get-Command smartctl.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

function Get-SmartDevices {
    param([string]$Smartctl)

    if (-not $Smartctl) {
        return @()
    }

    $output = & $Smartctl --scan-open 2>$null
    $devices = @()
    foreach ($line in $output) {
        if ($line -match "^(?<device>\S+)\s+-d\s+(?<type>\S+)") {
            $devices += [pscustomobject]@{
                Device = $matches.device
                Type = $matches.type
            }
        }
    }

    return $devices
}

function Get-SmartTemperatureRows {
    param(
        [string]$Timestamp,
        [string]$Smartctl,
        [object[]]$SmartDevices
    )

    if (-not $Smartctl -or -not $SmartDevices -or $SmartDevices.Count -eq 0) {
        return
    }

    foreach ($device in $SmartDevices) {
        $jsonText = (& $Smartctl -A -i -j $device.Device 2>$null) -join "`n"
        if (-not $jsonText) {
            continue
        }

        try {
            $smart = $jsonText | ConvertFrom-Json
        }
        catch {
            continue
        }

        $temperature = $null
        if ($smart.temperature -and $null -ne $smart.temperature.current) {
            $temperature = [double]$smart.temperature.current
        }
        elseif ($smart.ata_smart_attributes -and $smart.ata_smart_attributes.table) {
            $tempAttribute = $smart.ata_smart_attributes.table |
                Where-Object { $_.id -in @(190, 194) -or $_.name -match "Temperature" } |
                Select-Object -First 1
            if ($tempAttribute -and $tempAttribute.raw -and $tempAttribute.raw.string -match "[-+]?\d+([.,]\d+)?") {
                $temperature = [double]($matches[0].Replace(",", "."))
            }
        }

        if ($null -eq $temperature) {
            continue
        }

        $model = ([string]$smart.model_name).Trim()
        $serial = ([string]$smart.serial_number).Trim()
        $label = if ($serial) { "$model [$serial]" } else { "$model [$($device.Device)]" }

        [pscustomobject]@{
            timestamp = $Timestamp
            hardware_type = "Smartctl"
            hardware_name = $label
            sensor_type = "Temperature"
            sensor_name = "Drive Temperature"
            value = [math]::Round($temperature, 3)
            unit = "C"
        }
    }
}

function New-LogFileSet {
    param(
        [string]$Root,
        [string]$SessionId
    )

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $baseName = "libre-sensors-$stamp-$SessionId"
    [pscustomobject]@{
        Csv = Join-Path $Root "$baseName.csv"
        Jsonl = Join-Path $Root "$baseName.jsonl"
        StartedAt = Get-Date
    }
}

New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null

$libPath = Find-LibreHardwareMonitorLib
Add-Type -Path $libPath

$computer = [LibreHardwareMonitor.Hardware.Computer]::new()
$computer.IsCpuEnabled = $true
$computer.IsGpuEnabled = $true
$computer.IsMemoryEnabled = $true
$computer.IsMotherboardEnabled = $true
$computer.IsControllerEnabled = $true
$computer.IsNetworkEnabled = $true
$computer.IsStorageEnabled = $true
$computer.IsPsuEnabled = $true
$computer.Open()
$coreTempAvailable = Ensure-CoreTempSharedMemory
$hardwareNameMap = New-HardwareNameMap -Hardware $computer.Hardware
$smartctl = Find-Smartctl
$smartDevices = @(Get-SmartDevices -Smartctl $smartctl)
$lastSmartSample = [datetime]::MinValue
$lastSmartRows = @()

$sessionId = [guid]::NewGuid().ToString("N").Substring(0, 8)
$metadataPath = Join-Path $LogRoot "libre-thermal-logger-$sessionId.metadata.json"
$metadata = [ordered]@{
    startedAt = (Get-Date).ToString("o")
    host = $env:COMPUTERNAME
    user = "$env:USERDOMAIN\$env:USERNAME"
    processId = $PID
    intervalSeconds = $IntervalSeconds
    smartIntervalSeconds = $SmartIntervalSeconds
    rotateHours = $RotateHours
    logRoot = $LogRoot
    libreHardwareMonitorLib = $libPath
    coreTempAvailableAtStart = $coreTempAvailable
    coreTempExe = Find-CoreTempExe
    aida64SharedMemory = "AIDA64_SensorValues"
    aida64Registry = "HKCU:\Software\FinalWire\AIDA64\SensorValues"
    hardwareNameMap = $hardwareNameMap
    smartctl = $smartctl
    smartDevices = $smartDevices
    note = "CSV is long-form: one row per sensor per sample. JSONL is one sensor object per line for easy searching after crashes. CoreTemp shared memory is used for Intel CPU core/package temperatures when available. AIDA64 shared memory/registry export is merged when AIDA64 External Applications export is enabled. smartctl is used for serial-specific drive temperatures."
}
$metadata | ConvertTo-Json | Set-Content -Path $metadataPath -Encoding UTF8

$currentFiles = New-LogFileSet -Root $LogRoot -SessionId $sessionId
$header = "timestamp,hardware_type,hardware_name,sensor_type,sensor_name,value,unit"
Set-Content -Path $currentFiles.Csv -Value $header -Encoding UTF8
New-Item -ItemType File -Force -Path $currentFiles.Jsonl | Out-Null

try {
    while ($true) {
        $timestamp = (Get-Date).ToString("o")
        $rows = New-Object System.Collections.Generic.List[object]

        foreach ($hardware in $computer.Hardware) {
            Update-HardwareTree -Hardware $hardware
            foreach ($row in (Get-SensorRows -Hardware $hardware -Timestamp $timestamp -HardwareNameMap $hardwareNameMap)) {
                $rows.Add($row)
            }
        }
        foreach ($row in (Get-CoreTempRows -Timestamp $timestamp)) {
            $rows.Add($row)
        }
        foreach ($row in (Get-Aida64Rows -Timestamp $timestamp)) {
            $rows.Add($row)
        }
        if ($Once -or ((Get-Date) - $lastSmartSample).TotalSeconds -ge $SmartIntervalSeconds) {
            $lastSmartRows = @(Get-SmartTemperatureRows -Timestamp $timestamp -Smartctl $smartctl -SmartDevices $smartDevices)
            $lastSmartSample = Get-Date
        }
        foreach ($row in $lastSmartRows) {
            $row.timestamp = $timestamp
            $rows.Add($row)
        }

        $csvLines = foreach ($row in $rows) {
            @(
                ConvertTo-CsvField $row.timestamp
                ConvertTo-CsvField $row.hardware_type
                ConvertTo-CsvField $row.hardware_name
                ConvertTo-CsvField $row.sensor_type
                ConvertTo-CsvField $row.sensor_name
                ConvertTo-CsvField $row.value
                ConvertTo-CsvField $row.unit
            ) -join ","
        }
        Add-Content -Path $currentFiles.Csv -Value $csvLines -Encoding UTF8

        $jsonLines = foreach ($row in $rows) {
            $row | ConvertTo-Json -Compress
        }
        Add-Content -Path $currentFiles.Jsonl -Value $jsonLines -Encoding UTF8

        $latestPath = Join-Path $LogRoot "latest-sensors.json"
        [ordered]@{
            timestamp = $timestamp
            sessionId = $sessionId
            csv = $currentFiles.Csv
            jsonl = $currentFiles.Jsonl
            sensorCount = $rows.Count
            sensors = $rows
        } | ConvertTo-Json -Depth 5 | Set-Content -Path $latestPath -Encoding UTF8

        if ($Once) {
            break
        }

        if (((Get-Date) - $currentFiles.StartedAt).TotalHours -ge $RotateHours) {
            $currentFiles = New-LogFileSet -Root $LogRoot -SessionId $sessionId
            Set-Content -Path $currentFiles.Csv -Value $header -Encoding UTF8
            New-Item -ItemType File -Force -Path $currentFiles.Jsonl | Out-Null
        }

        Start-Sleep -Seconds $IntervalSeconds
    }
}
finally {
    $computer.Close()
}
