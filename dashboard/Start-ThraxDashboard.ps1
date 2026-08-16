[CmdletBinding()]
param(
    [ValidateRange(1024, 65535)][int]$Port = 8765,
    [string]$BindAddress = '127.0.0.1',
    [switch]$AllowLan,
    [string]$AccessToken
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $AllowLan -and $BindAddress -notin @('127.0.0.1', 'localhost')) { throw 'Use -AllowLan for a private-LAN binding.' }
if ($AllowLan) {
    $parsedAddress = $null
    if (-not [Net.IPAddress]::TryParse($BindAddress, [ref]$parsedAddress)) { throw 'LAN binding requires an explicit IPv4 address.' }
    $octets = $parsedAddress.GetAddressBytes()
    $isPrivate = $octets.Length -eq 4 -and ($octets[0] -eq 10 -or ($octets[0] -eq 172 -and $octets[1] -ge 16 -and $octets[1] -le 31) -or ($octets[0] -eq 192 -and $octets[1] -eq 168))
    if (-not $isPrivate) { throw 'LAN binding is restricted to RFC1918 private IPv4 addresses.' }
    if ([string]::IsNullOrWhiteSpace($AccessToken) -or $AccessToken.Length -lt 32) { throw 'LAN mode requires an access token of at least 32 characters.' }
}

$DashboardRoot = $PSScriptRoot
$RepoRoot = Split-Path $DashboardRoot -Parent
$PublicRoot = Join-Path $DashboardRoot 'public'
$DataRoot = Join-Path $DashboardRoot 'data'
$RequestRoot = Join-Path $DataRoot 'requests'
$SchedulePath = Join-Path $DataRoot 'schedules.json'
$HistoryPath = Join-Path $DataRoot 'history.jsonl'
$CatalogPath = Join-Path $DashboardRoot 'config\capabilities.json'
$Catalog = Get-Content -Raw -LiteralPath $CatalogPath | ConvertFrom-Json
$tokenBytes = New-Object byte[] 32
$tokenGenerator = [Security.Cryptography.RandomNumberGenerator]::Create()
try { $tokenGenerator.GetBytes($tokenBytes) } finally { $tokenGenerator.Dispose() }
$CsrfToken = [Convert]::ToBase64String($tokenBytes)

New-Item -ItemType Directory -Force -Path $RequestRoot | Out-Null
if (-not (Test-Path -LiteralPath $SchedulePath)) { '[]' | Set-Content -LiteralPath $SchedulePath -Encoding utf8 }

function Write-JsonResponse {
    param($Context, [int]$Status, $Body)
    $json = ConvertTo-Json -InputObject $Body -Depth 12
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $Context.Response.StatusCode = $Status
    $Context.Response.ContentType = 'application/json; charset=utf-8'
    $Context.Response.Headers['Cache-Control'] = 'no-store'
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.Close()
}

function Test-LanAccess($Request) {
    if (-not $AllowLan) { return $true }
    $cookie = $Request.Cookies['ThraxAccess']
    if (-not $cookie) { return $false }
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $left = [Convert]::ToBase64String($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes([string]$cookie.Value)))
        $right = [Convert]::ToBase64String($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($AccessToken)))
        return $left -ceq $right
    } finally { $sha.Dispose() }
}

function Get-RequestJson {
    param($Request)
    $reader = [IO.StreamReader]::new($Request.InputStream, $Request.ContentEncoding)
    try { return ($reader.ReadToEnd() | ConvertFrom-Json) } finally { $reader.Dispose() }
}

function Get-Capability([string]$Id) {
    return @($Catalog.skills | Where-Object id -eq $Id)[0]
}

function Get-DashboardSchedules {
    $value = Get-Content -Raw -LiteralPath $SchedulePath | ConvertFrom-Json
    if ($null -eq $value) { return @() }
    return @($value)
}

function Test-Inputs($Capability, $Inputs) {
    $clean = [ordered]@{}
    foreach ($field in $Capability.fields) {
        $value = [string]$Inputs.($field.id)
        if ($field.required -and [string]::IsNullOrWhiteSpace($value)) { throw "$($field.label) is required." }
        $maxLength = if ($field.PSObject.Properties['maxLength']) { [int]$field.maxLength } else { 200 }
        if ($value.Length -gt $maxLength) { throw "$($field.label) is too long." }
        if ($field.type -eq 'select' -and $value -notin @($field.options)) { throw "$($field.label) has an invalid value." }
        if ($field.type -eq 'url' -and $value) {
            $uri = $null
            if (-not [Uri]::TryCreate($value, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -notin @('https','http')) { throw "$($field.label) must be an HTTP or HTTPS URL." }
        }
        if ($field.type -eq 'path' -and $value) {
            $root = [IO.Path]::GetFullPath([string]$field.root).TrimEnd('\') + '\'
            $candidate = [IO.Path]::GetFullPath($value)
            if (-not $candidate.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw "$($field.label) must be inside $($field.root)." }
        }
        $clean[$field.id] = $value.Trim()
    }
    return $clean
}

function Add-History([string]$Type, [string]$CapabilityId, [string]$Status, [string]$Summary) {
    [ordered]@{ timestamp=(Get-Date).ToString('o'); type=$Type; capabilityId=$CapabilityId; status=$Status; summary=$Summary } |
        ConvertTo-Json -Compress | Add-Content -LiteralPath $HistoryPath -Encoding utf8
}

function Invoke-Capability($Capability, $Inputs, [string]$Source = 'manual') {
    if ($Capability.action -eq 'request') {
        $id = [guid]::NewGuid().ToString('n')
        $record = [ordered]@{ id=$id; createdAt=(Get-Date).ToString('o'); source=$Source; status='awaiting-review'; capabilityId=$Capability.id; skill=$Capability.skill; inputs=$Inputs }
        $record | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $RequestRoot "$id.json") -Encoding utf8
        Add-History $Source $Capability.id 'awaiting-review' "Review request created for $($Capability.name)."
        return [ordered]@{ status='awaiting-review'; requestId=$id; message='Request staged for review. No live changes were made.' }
    }
    $script = switch ($Capability.action) {
        'status' { Join-Path $RepoRoot '.agents\skills\thraxos\scripts\Get-ThraxStatus.ps1' }
        'backup-health' { Join-Path $RepoRoot '.agents\skills\thraxos\scripts\Test-BackupHealth.ps1' }
        'inheritance-status' { Join-Path $RepoRoot '.agents\skills\thraxos\scripts\Get-AgentOSInheritanceStatus.ps1' }
        'player-levels' { Join-Path $RepoRoot '.agents\skills\get-player-skill-levels\scripts\Get-PlayerSkillLevels.ps1' }
        default { throw 'Capability action is not allowlisted.' }
    }
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script 2>&1 | Out-String
    $status = if ($LASTEXITCODE -eq 0) { 'completed' } else { 'attention' }
    if ($Capability.action -eq 'status' -and $output) {
        try {
            $rawStatus = $output | ConvertFrom-Json
            $safeProfiles = @($rawStatus.profiles | ForEach-Object {
                [ordered]@{
                    displayName = $_.displayName
                    grooveStatsApiKeyPresent = $_.grooveStatsApiKeyPresent
                    grooveStatsApiKeyShapeValid = $_.grooveStatsApiKeyShapeValid
                    grooveStatsUsernamePresent = $_.grooveStatsUsernamePresent
                    isPadPlayer = $_.isPadPlayer
                }
            })
            if ($rawStatus.backup.PSObject.Properties['destination']) { $rawStatus.backup.PSObject.Properties.Remove('destination') }
            $rawStatus.profiles = $safeProfiles
            $output = ConvertTo-Json -InputObject $rawStatus -Depth 8
        } catch { throw 'Status helper returned data that could not be safely sanitized.' }
    }
    Add-History $Source $Capability.id $status "$($Capability.name) finished."
    return [ordered]@{ status=$status; output=$output.Trim() }
}

function Convert-RRuleToSchedule([string]$RRule) {
    if ([string]::IsNullOrWhiteSpace($RRule)) { return 'Schedule unavailable' }
    if ($RRule -match '^FREQ=HOURLY;INTERVAL=(\d+)$') { return "Every $($Matches[1]) hour$(if ($Matches[1] -eq '1') { '' } else { 's' })" }
    if ($RRule -match '^FREQ=DAILY;BYHOUR=([0-9,]+);BYMINUTE=(\d+)$') {
        $times = @($Matches[1].Split(',') | ForEach-Object { ('{0:D2}:{1:D2}' -f [int]$_, [int]$Matches[2]) })
        return "Daily at $($times -join ', ') local time"
    }
    return $RRule
}

function Get-Automations {
    $items = @()
    $automationRoot = Join-Path $env:USERPROFILE '.codex\automations'
    $repoPattern = [regex]::Escape($RepoRoot)
    foreach ($file in Get-ChildItem -LiteralPath $automationRoot -Recurse -Filter automation.toml -File -ErrorAction SilentlyContinue) {
        $raw = Get-Content -Raw -LiteralPath $file.FullName
        if ($raw -notmatch "(?im)^cwds\s*=\s*\[[^\]]*$repoPattern") { continue }
        $name = if ($raw -match '(?m)^name\s*=\s*"([^"]+)"') { $Matches[1] } else { $file.Directory.Name }
        $status = if ($raw -match '(?m)^status\s*=\s*"([^"]+)"') { $Matches[1] } else { 'UNKNOWN' }
        $rrule = if ($raw -match '(?m)^rrule\s*=\s*"([^"]+)"') { $Matches[1] } else { '' }
        $items += [ordered]@{ id=$file.Directory.Name; name=$name; scheduler='Codex'; status=$status; rrule=$rrule; schedule=(Convert-RRuleToSchedule $rrule); source='live configuration' }
    }
    $items += [ordered]@{ id='ITGManiaBackup'; name='ITGMania Backup'; scheduler='Windows'; status='visibility degraded'; rrule='Daily at 03:00 Pacific (runner polls every minute)'; schedule='Daily at 03:00 Pacific; runner checks every minute'; source='documented schedule and backup logs' }
    return $items
}

function Invoke-DueSchedules {
    $schedules = @(Get-DashboardSchedules)
    $now = Get-Date
    $changed = $false
    foreach ($schedule in $schedules) {
        if (-not $schedule.enabled -or [datetime]$schedule.nextRunAt -gt $now) { continue }
        $capability = Get-Capability $schedule.capabilityId
        try { $null = Invoke-Capability $capability $schedule.inputs 'schedule' } catch { Add-History 'schedule' $schedule.capabilityId 'failed' $_.Exception.Message }
        $schedule.lastRunAt = $now.ToString('o')
        $schedule.nextRunAt = switch ($schedule.frequency) {
            'hourly' { $now.AddHours(1).ToString('o') }
            'daily' { $now.AddDays(1).ToString('o') }
            'weekly' { $now.AddDays(7).ToString('o') }
        }
        $changed = $true
    }
    if ($changed) { @($schedules) | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $SchedulePath -Encoding utf8 }
}

$listener = [Net.HttpListener]::new()
$listener.Prefixes.Add("http://$BindAddress`:$Port/")
$listener.Start()
Write-Host "ThraxOS Arcade Console: http://$BindAddress`:$Port/" -ForegroundColor Cyan
Write-Host $(if ($AllowLan) { 'Private LAN mode with access token. Press Ctrl+C to stop.' } else { 'Localhost only. Press Ctrl+C to stop.' }) -ForegroundColor DarkGray

try {
    while ($listener.IsListening) {
        Invoke-DueSchedules
        $async = $listener.BeginGetContext($null, $null)
        while (-not $async.AsyncWaitHandle.WaitOne(1000)) { Invoke-DueSchedules }
        $context = $listener.EndGetContext($async)
        $request = $context.Request
        $path = $request.Url.AbsolutePath
        try {
            if ($AllowLan -and -not (Test-LanAccess $request)) {
                if ($request.HttpMethod -eq 'GET' -and $path -eq '/' -and $request.QueryString['access'] -eq $AccessToken) {
                    $cookie = [Net.Cookie]::new('ThraxAccess', $AccessToken, '/')
                    $cookie.HttpOnly = $true
                    $context.Response.Cookies.Add($cookie)
                    $context.Response.StatusCode = 302
                    $context.Response.RedirectLocation = '/'
                    $context.Response.Close()
                    continue
                }
                Write-JsonResponse $context 401 @{error='A valid private-LAN access link is required.'}
                continue
            }
            if ($request.HttpMethod -eq 'GET' -and $path -eq '/api/catalog') { Write-JsonResponse $context 200 ([ordered]@{ csrf=$CsrfToken; skills=$Catalog.skills; automations=(Get-Automations) }); continue }
            if ($request.HttpMethod -eq 'GET' -and $path -eq '/api/schedules') { Write-JsonResponse $context 200 (@(Get-DashboardSchedules)); continue }
            if ($request.HttpMethod -eq 'GET' -and $path -eq '/api/history') {
                $history = if (Test-Path $HistoryPath) { @(Get-Content $HistoryPath -Tail 30 | ForEach-Object { $_ | ConvertFrom-Json }) } else { @() }
                Write-JsonResponse $context 200 $history; continue
            }
            if ($request.HttpMethod -eq 'POST') {
                if ($request.Headers['X-Thrax-CSRF'] -ne $CsrfToken) { Write-JsonResponse $context 403 @{error='Invalid request token.'}; continue }
                $body = Get-RequestJson $request
                $capability = Get-Capability ([string]$body.capabilityId)
                if (-not $capability) { throw 'Unknown capability.' }
                $inputs = Test-Inputs $capability $body.inputs
                if ($path -eq '/api/run') { Write-JsonResponse $context 200 (Invoke-Capability $capability $inputs); continue }
                if ($path -eq '/api/schedules') {
                    if ($body.acknowledged -ne $true) { throw 'Confirm the dashboard-schedule safety notice before creating a schedule.' }
                    if ($body.frequency -notin @('hourly','daily','weekly')) { throw 'Invalid schedule frequency.' }
                    $startAt = [datetime]$body.startAt
                    if ($startAt -lt (Get-Date).AddMinutes(-1)) { throw 'Start time must be in the future.' }
                    $schedules = @(Get-DashboardSchedules)
                    $runPolicy = if ($capability.action -eq 'request') { 'Creates a review request when due' } else { 'Runs the fixed read-only helper when due' }
                    $item = [ordered]@{ id=[guid]::NewGuid().ToString('n'); capabilityId=$capability.id; capabilityName=$capability.name; frequency=$body.frequency; nextRunAt=$startAt.ToString('o'); lastRunAt=$null; enabled=$true; runPolicy=$runPolicy; inputs=$inputs }
                    @($schedules) + $item | ConvertTo-Json -Depth 10 | Set-Content $SchedulePath -Encoding utf8
                    Write-JsonResponse $context 201 $item; continue
                }
            }
            if ($request.HttpMethod -eq 'GET') {
                $relative = if ($path -eq '/') { 'index.html' } else { $path.TrimStart('/') }
                if ($relative -notmatch '^[a-zA-Z0-9._/-]+$' -or $relative.Contains('..')) { throw 'Invalid asset path.' }
                $file = Join-Path $PublicRoot $relative
                if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { Write-JsonResponse $context 404 @{error='Not found'}; continue }
                $types = @{'.html'='text/html; charset=utf-8';'.css'='text/css; charset=utf-8';'.js'='application/javascript; charset=utf-8';'.svg'='image/svg+xml'}
                $bytes = [IO.File]::ReadAllBytes($file)
                $context.Response.ContentType = $types[[IO.Path]::GetExtension($file)]
                $context.Response.Headers['Content-Security-Policy'] = "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'"
                $context.Response.OutputStream.Write($bytes,0,$bytes.Length); $context.Response.Close(); continue
            }
            Write-JsonResponse $context 404 @{error='Not found'}
        } catch { Write-JsonResponse $context 400 @{error=$_.Exception.Message} }
    }
} finally { $listener.Stop(); $listener.Close() }
