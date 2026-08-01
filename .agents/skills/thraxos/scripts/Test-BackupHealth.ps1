[CmdletBinding()]
param(
    [string]$TaskName = 'ITGManiaBackup',
    [string]$LogDirectory = 'C:\ProgramData\ITGManiaBackup\Logs',
    [int]$MaximumSuccessfulBackupAgeHours = 36
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$result = [ordered]@{
    observedAt = (Get-Date).ToString('o')
    healthy = $false
    task = $null
    latestLog = $null
    latestSuccess = $null
    reasons = @()
}

try {
    $task = Get-ScheduledTask -TaskName $TaskName
    $info = Get-ScheduledTaskInfo -TaskName $TaskName
    $result.task = [ordered]@{
        state = $task.State.ToString()
        lastRun = $info.LastRunTime.ToString('o')
        lastResult = ('0x{0:X}' -f $info.LastTaskResult)
        nextRun = $info.NextRunTime.ToString('o')
    }
    if ($info.LastTaskResult -ne 0) { $result.reasons += "Task last result is not success: $($result.task.lastResult)" }
    if ($task.State.ToString() -eq 'Disabled') { $result.reasons += 'Scheduled task is disabled.' }
} catch {
    $result.reasons += "Could not inspect scheduled task: $($_.Exception.Message)"
}

$latestLog = Get-ChildItem -LiteralPath $LogDirectory -Filter 'Backup_*.log' -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $latestLog) {
    $result.reasons += 'No backup log was found.'
} else {
    $result.latestLog = [ordered]@{
        path = $latestLog.FullName
        modified = $latestLog.LastWriteTime.ToString('o')
    }
    $successLine = Get-Content -LiteralPath $latestLog.FullName | Where-Object { $_ -match '\[INFO\] Backup completed successfully\.$' } | Select-Object -Last 1
    if (-not $successLine) {
        $result.reasons += 'The latest log has no successful completion marker.'
    } elseif ($successLine -match '^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
        $successTime = [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
        $result.latestSuccess = $successTime.ToString('o')
        if (((Get-Date) - $successTime).TotalHours -gt $MaximumSuccessfulBackupAgeHours) {
            $result.reasons += "Latest successful backup is older than $MaximumSuccessfulBackupAgeHours hours."
        }
    }
}

$result.healthy = $result.reasons.Count -eq 0
$result | ConvertTo-Json -Depth 6
if (-not $result.healthy) { exit 1 }
