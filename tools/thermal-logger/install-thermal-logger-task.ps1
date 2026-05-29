param(
    [string]$LoggerTaskName = "Plex Thermal Sensor Logger",
    [string]$Aida64TaskName = "Plex Thermal AIDA64 Sensor Source",
    [string]$CoreTempTaskName = "Plex Thermal Core Temp Source",
    [string]$ScriptPath = "C:\plex-server\tools\thermal-logger\start-libre-thermal-logger.ps1",
    [string]$Aida64Path = "C:\Program Files\FinalWire\AIDA64 Extreme\aida64.exe",
    [string]$CoreTempPath = "C:\Program Files\Core Temp\Core Temp.exe"
)

$ErrorActionPreference = "Stop"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run this script from an elevated PowerShell session so the logger can access CPU, motherboard, fan, and storage sensors."
}

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Logger script not found at $ScriptPath"
}

if (-not (Test-Path -LiteralPath $Aida64Path)) {
    throw "AIDA64 executable not found at $Aida64Path"
}

if (-not (Test-Path -LiteralPath $CoreTempPath)) {
    throw "Core Temp executable not found at $CoreTempPath"
}

function New-PlexThermalAction {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Execute,

        [string]$Argument
    )

    if ([string]::IsNullOrWhiteSpace($Argument)) {
        return New-ScheduledTaskAction -Execute $Execute
    }

    New-ScheduledTaskAction -Execute $Execute -Argument $Argument
}

function Register-PlexThermalTask {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName,

        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$Action,

        [Microsoft.Management.Infrastructure.CimInstance]$Trigger
    )

    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $settings `
        -Principal $taskPrincipal `
        -Force | Out-Null
}

$sourceTrigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$loggerTrigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$loggerTrigger.Delay = "PT30S"

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -DontStopOnIdleEnd `
    -MultipleInstances IgnoreNew `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

$taskPrincipal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Highest

$aida64Action = New-PlexThermalAction -Execute $Aida64Path -Argument "/SILENT /IDLE"
$coreTempAction = New-PlexThermalAction -Execute $CoreTempPath
$loggerAction = New-PlexThermalAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

Register-PlexThermalTask -TaskName $Aida64TaskName -Action $aida64Action -Trigger $sourceTrigger
Register-PlexThermalTask -TaskName $CoreTempTaskName -Action $coreTempAction -Trigger $sourceTrigger
Register-PlexThermalTask -TaskName $LoggerTaskName -Action $loggerAction -Trigger $loggerTrigger

Start-ScheduledTask -TaskName $Aida64TaskName
Start-ScheduledTask -TaskName $CoreTempTaskName
Start-Sleep -Seconds 20
Start-ScheduledTask -TaskName $LoggerTaskName

Get-ScheduledTask -TaskName $Aida64TaskName, $CoreTempTaskName, $LoggerTaskName |
    Select-Object TaskName, State, @{Name = "RunLevel"; Expression = { $_.Principal.RunLevel } }, @{Name = "UserId"; Expression = { $_.Principal.UserId } }
