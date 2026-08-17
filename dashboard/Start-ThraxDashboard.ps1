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
$SongRoot = 'C:\Games\ITGmania\Songs'
$ItgUserDataRoot = Join-Path $env:APPDATA 'ITGmania'
$PlayableAudioExtensions = @('.mp3', '.ogg', '.opus', '.wav')
$AudioMimeTypes = @{ '.mp3' = 'audio/mpeg'; '.ogg' = 'audio/ogg'; '.opus' = 'audio/ogg'; '.wav' = 'audio/wav' }
$AudioCatalog = @()
$AudioCatalogById = @{}
$AudioCatalogBuiltAt = $null
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

function Get-AudioId([string]$Path) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Path))
        return ([BitConverter]::ToString($bytes) -replace '-', '').ToLowerInvariant()
    } finally { $sha.Dispose() }
}

function Get-AudioCatalog {
    $refreshAfter = [TimeSpan]::FromMinutes(10)
    if ($AudioCatalogBuiltAt -and ((Get-Date) - $AudioCatalogBuiltAt) -lt $refreshAfter) { return @($AudioCatalog) }
    if (-not (Test-Path -LiteralPath $SongRoot -PathType Container)) { throw 'The approved ITGMania Songs root is unavailable.' }

    $entries = @()
    $byId = @{}
    foreach ($file in Get-ChildItem -LiteralPath $SongRoot -File -Recurse -ErrorAction Stop | Where-Object { $_.Extension.ToLowerInvariant() -in $PlayableAudioExtensions }) {
        $relativePath = $file.FullName.Substring($SongRoot.Length).TrimStart('\')
        $segments = @($relativePath -split '[\\/]')
        $folder = if ($segments.Count -gt 0) { $segments[0] } else { 'Unsorted' }
        $songFolder = if ($segments.Count -gt 2) { $segments[$segments.Count - 2] } else { $file.Directory.Name }
        $id = Get-AudioId $file.FullName
        $entry = [pscustomobject][ordered]@{
            id = $id
            title = [IO.Path]::GetFileNameWithoutExtension($file.Name)
            folder = $folder
            songFolder = $songFolder
            extension = $file.Extension.ToLowerInvariant()
            lengthBytes = $file.Length
            fullPath = $file.FullName
        }
        $entries += $entry
        $byId[$id] = $entry
    }
    $script:AudioCatalog = @($entries | Sort-Object folder, title)
    $script:AudioCatalogById = $byId
    $script:AudioCatalogBuiltAt = Get-Date
    return @($script:AudioCatalog)
}

function Get-QueryValue {
    param($Request, [string]$Name)
    foreach ($key in @($Request.QueryString.AllKeys)) {
        if ($key -ceq $Name) { return [string]$Request.QueryString[$key] }
    }
    return ''
}

function Get-JukeboxResponse($Request) {
    $catalog = @(Get-AudioCatalog)
    $query = Get-QueryValue $Request 'q'
    $folder = Get-QueryValue $Request 'folder'
    if ($query.Length -gt 120 -or $folder.Length -gt 200) { throw 'Jukebox search input is too long.' }
    $matches = $catalog
    if (-not [string]::IsNullOrWhiteSpace($folder)) { $matches = @($matches | Where-Object { $_.folder -ceq $folder }) }
    if (-not [string]::IsNullOrWhiteSpace($query)) {
        $needle = $query.Trim()
        $matches = @($matches | Where-Object { $_.title.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or $_.songFolder.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or $_.folder.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -ge 0 })
    }
    $safeTracks = @($matches | Select-Object -First 160 | ForEach-Object { [ordered]@{ id=$_.id; title=$_.title; folder=$_.folder; songFolder=$_.songFolder; extension=$_.extension } })
    return [ordered]@{
        trackCount = $catalog.Count
        resultCount = $matches.Count
        folders = @($catalog | Select-Object -ExpandProperty folder -Unique | Sort-Object)
        tracks = $safeTracks
        indexedAt = $AudioCatalogBuiltAt.ToString('o')
    }
}

function Get-RandomJukeboxTrack($Request) {
    $catalog = @(Get-AudioCatalog)
    $folder = Get-QueryValue $Request 'folder'
    if ($folder.Length -gt 200) { throw 'Jukebox folder input is too long.' }
    $matches = if ([string]::IsNullOrWhiteSpace($folder)) { $catalog } else { @($catalog | Where-Object { $_.folder -ceq $folder }) }
    if ($matches.Count -eq 0) { throw 'No playable tracks match that folder.' }
    $track = $matches | Get-Random
    return [ordered]@{ id=$track.id; title=$track.title; folder=$track.folder; songFolder=$track.songFolder; extension=$track.extension }
}

function Get-SongIdentity([string]$SongDir, [string]$StepsType, [string]$Difficulty) {
    $relative = ($SongDir -replace '^[\\/]*Songs[\\/]', '').TrimEnd('/', '\')
    $parts = @($relative -split '[\\/]')
    $fallback = if ($parts.Count) { $parts[-1] } else { 'Unknown song' }
    $simfile = Get-ChildItem -LiteralPath (Join-Path $SongRoot $relative) -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.ssc','.sm') } | Select-Object -First 1
    if (-not $simfile) { return [ordered]@{ title=$fallback; artist='Unknown artist'; difficulty=$Difficulty; meter=$null } }
    $raw = Get-Content -Raw -LiteralPath $simfile.FullName
    $title = if ($raw -match '(?im)^#TITLE:([^;]+);') { $Matches[1].Trim() } else { $fallback }
    $artist = if ($raw -match '(?im)^#ARTIST:([^;]+);') { $Matches[1].Trim() } else { 'Unknown artist' }
    $meter = $null
    if ($simfile.Extension -ieq '.ssc') {
        foreach ($block in [regex]::Split($raw, '(?im)^#NOTEDATA:;\s*$') | Select-Object -Skip 1) {
            $blockSteps = if ($block -match '(?im)^#STEPSTYPE:([^;]+);') { $Matches[1].Trim() } else { '' }
            $blockDifficulty = if ($block -match '(?im)^#DIFFICULTY:([^;]+);') { $Matches[1].Trim() } else { '' }
            if ($blockSteps -ieq $StepsType -and $blockDifficulty -ieq $Difficulty -and $block -match '(?im)^#METER:(\d+);') { $meter=[int]$Matches[1]; break }
        }
    } else {
        foreach ($match in [regex]::Matches($raw, '(?ms)#NOTES:\s*([^:]*):\s*([^:]*):\s*([^:]*):\s*(\d+):')) {
            if ($match.Groups[1].Value.Trim() -ieq $StepsType -and $match.Groups[3].Value.Trim() -ieq $Difficulty) { $meter=[int]$match.Groups[4].Value; break }
        }
    }
    return [ordered]@{ title=$title; artist=$artist; difficulty=$Difficulty; meter=$meter }
}

function Get-RecentPlaySessions {
    $targets = [ordered]@{ Kyle='kyle'; Sam='sam'; Eliza='lizy' }; $guidToPerson = @{}
    foreach ($profile in Get-ChildItem -LiteralPath (Join-Path $ItgUserDataRoot 'Save\LocalProfiles') -Directory -ErrorAction Stop) {
        $statsPath = Join-Path $profile.FullName 'Stats.xml'; if (-not (Test-Path -LiteralPath $statsPath)) { continue }; [xml]$stats = Get-Content -Raw -LiteralPath $statsPath
        $displayName = ([string]$stats.Stats.GeneralData.DisplayName).Trim().ToLowerInvariant()
        foreach ($person in $targets.Keys) { if ($displayName -eq $targets[$person]) { $guidToPerson[[string]$stats.Stats.GeneralData.Guid] = $person } }
    }
    $playsByPerson = @{}; foreach ($person in $targets.Keys) { $playsByPerson[$person] = @() }
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $ItgUserDataRoot 'Save\Upload') -Filter '*.xml' -File -ErrorAction Stop) {
        try { [xml]$upload = Get-Content -Raw -LiteralPath $file.FullName; foreach ($entry in @($upload.Stats.RecentSongScores.HighScoreForASongAndSteps)) {
            if (-not $entry) { continue }; $score=$entry.HighScore; $person=$guidToPerson[[string]$score.PlayerGuid]; if (-not $person) { continue }
            $playedAt=[datetime]::ParseExact([string]$score.DateTime,'yyyy-MM-dd HH:mm:ss',[Globalization.CultureInfo]::InvariantCulture)
            $playsByPerson[$person] += [pscustomobject]@{ playedAt=$playedAt; songDir=[string]$entry.Song.Dir; stepsType=[string]$entry.Steps.StepsType; difficulty=[string]$entry.Steps.Difficulty; percent=[double]$score.PercentDP; surviveSeconds=[double]$score.SurviveSeconds }
        } } catch { continue }
    }
    $people=@(); foreach ($person in $targets.Keys) {
        $groups=@(); $current=@(); foreach ($play in @($playsByPerson[$person] | Sort-Object playedAt)) { if ($current.Count -and ($play.playedAt-$current[-1].playedAt).TotalHours -gt 2) { $groups+=,@($current); $current=@() }; $current+=$play }; if ($current.Count) { $groups+=,@($current) }
        $sessions=@($groups | Select-Object -Last 2 | ForEach-Object { $session=@($_); $start=$session[0].playedAt; $end=$session[-1].playedAt.AddSeconds($session[-1].surviveSeconds); $topSongs=@($session | Sort-Object @{Expression='percent';Descending=$true},playedAt | Select-Object -First 3 | ForEach-Object { $identity=Get-SongIdentity $_.songDir $_.stepsType $_.difficulty; [ordered]@{title=$identity.title;artist=$identity.artist;difficulty=$identity.difficulty;meter=$identity.meter;percent=[Math]::Round($_.percent*100,2)} }); [ordered]@{startedAt=$start.ToString('o');durationSeconds=[Math]::Max(0,[Math]::Round(($end-$start).TotalSeconds));songCount=$session.Count;topSongs=$topSongs} }); [array]::Reverse($sessions)
        $people += [ordered]@{name=$person;sessions=$sessions}
    }
    return [ordered]@{observedAt=(Get-Date).ToString('o');durationKind='wall-clock span from first recorded score start to final song end';sessionGapHours=2;people=$people}
}

function Write-AudioResponse($Context, [string]$Id) {
    $null = Get-AudioCatalog
    $track = $AudioCatalogById[$Id]
    if (-not $track) { throw 'Unknown jukebox track.' }
    $path = [string]$track.fullPath
    $root = [IO.Path]::GetFullPath($SongRoot).TrimEnd('\') + '\'
    $resolvedPath = [IO.Path]::GetFullPath($path)
    if (-not $resolvedPath.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) { throw 'The requested jukebox track is unavailable.' }

    $length = (Get-Item -LiteralPath $resolvedPath).Length
    $start = [int64]0
    $end = [int64]($length - 1)
    $range = [string]$Context.Request.Headers['Range']
    if ($range -and $range -match '^bytes=(\d*)-(\d*)$') {
        if ($Matches[1]) { $start = [int64]$Matches[1] }
        if ($Matches[2]) { $end = [int64]$Matches[2] }
        if ($start -ge $length -or $start -gt $end) { Write-JsonResponse $Context 416 @{error='Requested audio range is unavailable.'}; return }
        if ($end -ge $length) { $end = $length - 1 }
        $Context.Response.StatusCode = 206
        $Context.Response.Headers['Content-Range'] = "bytes $start-$end/$length"
    }
    $Context.Response.ContentType = $AudioMimeTypes[[string]$track.extension]
    $Context.Response.Headers['Accept-Ranges'] = 'bytes'
    $Context.Response.Headers['Cache-Control'] = 'no-store'
    $Context.Response.ContentLength64 = $end - $start + 1
    $stream = [IO.File]::Open($resolvedPath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try {
        $stream.Seek($start, [IO.SeekOrigin]::Begin) | Out-Null
        $remaining = $end - $start + 1
        $buffer = New-Object byte[] 65536
        while ($remaining -gt 0) {
            $read = $stream.Read($buffer, 0, [Math]::Min($buffer.Length, [int]$remaining))
            if ($read -le 0) { break }
            $Context.Response.OutputStream.Write($buffer, 0, $read)
            $remaining -= $read
        }
    } finally {
        $stream.Dispose()
        $Context.Response.Close()
    }
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
        $scopeText = $raw -replace '\\\\','\'
        if ($scopeText -notmatch "(?im)^cwds\s*=\s*\[[^\]]*$repoPattern") { continue }
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
            if ($request.HttpMethod -eq 'GET' -and $path -eq '/api/jukebox') { Write-JsonResponse $context 200 (Get-JukeboxResponse $request); continue }
            if ($request.HttpMethod -eq 'GET' -and $path -eq '/api/jukebox/random') { Write-JsonResponse $context 200 (Get-RandomJukeboxTrack $request); continue }
            if ($request.HttpMethod -eq 'GET' -and $path -eq '/api/play-sessions') { Write-JsonResponse $context 200 (Get-RecentPlaySessions); continue }
            if ($request.HttpMethod -eq 'GET' -and $path -match '^/api/audio/([0-9a-f]{64})$') { Write-AudioResponse $context $Matches[1]; continue }
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
        } catch {
            # A tab can cancel a request while a response is being written.  Do
            # not let that secondary write failure take down the entire local
            # dashboard listener.
            $requestError = $_.Exception.Message
            try {
                Write-JsonResponse $context 400 @{error=$requestError}
            } catch {
                Write-Warning "Dashboard request ended before an error response could be sent: $requestError"
            }
        }
    }
} finally { $listener.Stop(); $listener.Close() }
