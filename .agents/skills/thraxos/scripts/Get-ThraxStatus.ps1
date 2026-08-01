[CmdletBinding()]
param(
    [string]$InstallPath = 'C:\Games\ITGmania',
    [string]$UserDataPath = "$env:APPDATA\ITGmania",
    [string]$BackupConfigPath = 'C:\ProgramData\ITGManiaBackup\config.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-IniMap {
    param([Parameter(Mandatory)][string]$Path)
    $result = [ordered]@{}
    if (-not (Test-Path -LiteralPath $Path)) { return $result }
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match '^\s*[;#\[]' -or $line -notmatch '=') { continue }
        $pair = $line -split '=', 2
        $result[$pair[0].Trim()] = $pair[1].Trim()
    }
    return $result
}

$status = [ordered]@{
    observedAt = (Get-Date).ToString('o')
    machine = $null
    itgmania = [ordered]@{}
    profiles = @()
    backup = [ordered]@{}
    stepmaniaX = [ordered]@{}
    warnings = @()
}

try {
    $computer = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $status.machine = [ordered]@{
        manufacturer = $computer.Manufacturer
        model = $computer.Model
        os = $os.Caption
        osBuild = $os.BuildNumber
        cpu = $cpu.Name
        memoryBytes = [int64]$computer.TotalPhysicalMemory
    }
} catch {
    $status.warnings += "Hardware inventory unavailable: $($_.Exception.Message)"
}

$installed = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.PSObject.Properties['DisplayName'] -and $_.DisplayName -eq 'ITGmania' } |
    Select-Object -First 1

$preferencesPath = Join-Path $UserDataPath 'Save\Preferences.ini'
$themePreferencesPath = Join-Path $UserDataPath 'Save\ThemePrefs.ini'
$preferences = Get-IniMap -Path $preferencesPath
$themePreferences = Get-IniMap -Path $themePreferencesPath
$installSongs = Join-Path $InstallPath 'Songs'
$userSongs = Join-Path $UserDataPath 'Songs'

$status.itgmania = [ordered]@{
    installed = (Test-Path -LiteralPath $InstallPath)
    version = $installed.DisplayVersion
    installPath = $InstallPath
    userDataPath = $UserDataPath
    theme = $preferences['Theme']
    game = $preferences['CurrentGame']
    resolution = if ($preferences['DisplayWidth'] -and $preferences['DisplayHeight']) { "$($preferences['DisplayWidth'])x$($preferences['DisplayHeight'])" } else { $null }
    windowed = $preferences['Windowed']
    grooveStatsEnabled = $themePreferences['EnableGrooveStats']
    installPackCount = if (Test-Path -LiteralPath $installSongs) { @(Get-ChildItem -LiteralPath $installSongs -Directory).Count } else { 0 }
    userPackCount = if (Test-Path -LiteralPath $userSongs) { @(Get-ChildItem -LiteralPath $userSongs -Directory).Count } else { 0 }
}

$profileRoot = Join-Path $UserDataPath 'Save\LocalProfiles'
if (Test-Path -LiteralPath $profileRoot) {
    $status.profiles = @(Get-ChildItem -LiteralPath $profileRoot -Directory | ForEach-Object {
        $editable = Get-IniMap -Path (Join-Path $_.FullName 'Editable.ini')
        $grooveStats = Get-IniMap -Path (Join-Path $_.FullName 'GrooveStats.ini')
        $apiKey = [string]$grooveStats['ApiKey']
        [ordered]@{
            id = $_.Name
            displayName = $editable['DisplayName']
            grooveStatsApiKeyPresent = -not [string]::IsNullOrWhiteSpace($apiKey)
            grooveStatsApiKeyShapeValid = $apiKey.Length -eq 64
            grooveStatsUsernamePresent = -not [string]::IsNullOrWhiteSpace([string]$grooveStats['Username'])
            isPadPlayer = $grooveStats['IsPadPlayer']
        }
    })
}

if (Test-Path -LiteralPath $BackupConfigPath) {
    $config = Get-Content -Raw -LiteralPath $BackupConfigPath | ConvertFrom-Json
    $status.backup.configPresent = $true
    $status.backup.destination = $config.BackupRepoUrl
    $status.backup.schedule = $config.ScheduleCron
    $status.backup.timezone = $config.ScheduleTimezone
    $status.backup.songsIncluded = [bool]$config.BackupSongs
    $status.backup.credentialPresent = -not [string]::IsNullOrWhiteSpace([string]$config.BackupRepoAccessToken)
} else {
    $status.backup.configPresent = $false
}

try {
    $task = Get-ScheduledTask -TaskName 'ITGManiaBackup'
    $taskInfo = Get-ScheduledTaskInfo -TaskName 'ITGManiaBackup'
    $status.backup.task = [ordered]@{
        state = $task.State.ToString()
        lastRun = $taskInfo.LastRunTime.ToString('o')
        lastResult = ('0x{0:X}' -f $taskInfo.LastTaskResult)
        nextRun = $taskInfo.NextRunTime.ToString('o')
    }
} catch {
    $status.warnings += "Scheduled task inspection unavailable: $($_.Exception.Message)"
}

try {
    $smx = $null
    foreach ($device in Get-PnpDevice -PresentOnly | Where-Object InstanceId -match 'VID_2341&PID_8037') {
        $property = Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName 'DEVPKEY_Device_BusReportedDeviceDesc' -ErrorAction SilentlyContinue
        if ($property -and $property.PSObject.Properties['Data'] -and $property.Data -eq 'StepManiaX') {
            $smx = $device
            break
        }
    }
    if ($smx) {
        $status.stepmaniaX = [ordered]@{
            connected = $true
            busDescription = 'StepManiaX'
            vendorProduct = 'VID_2341&PID_8037'
        }
    } else {
        $status.stepmaniaX.connected = $false
    }
} catch {
    $status.warnings += "StepManiaX device inspection unavailable: $($_.Exception.Message)"
}

$status | ConvertTo-Json -Depth 8
