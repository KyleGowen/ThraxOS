[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$catalog = Get-Content -Raw (Join-Path $root 'config\capabilities.json') | ConvertFrom-Json
if (@($catalog.skills).Count -ne 15) { throw 'Expected 15 dashboard capabilities.' }
$duplicates = $catalog.skills | Group-Object id | Where-Object Count -gt 1
if ($duplicates) { throw 'Capability IDs must be unique.' }
$allowedActions = @('status','backup-health','inheritance-status','player-levels','request')
foreach ($skill in $catalog.skills) {
    if ($skill.action -notin $allowedActions) { throw "Unapproved action: $($skill.action)" }
    foreach ($field in $skill.fields) {
        if ($field.type -ne 'select' -and (-not $field.PSObject.Properties['maxLength'] -or -not $field.maxLength)) { throw "Field $($field.id) requires maxLength." }
        if ($field.type -eq 'path' -and $field.root -ne 'C:\Games\ITGmania\Songs') { throw 'Path field escapes the approved song root.' }
    }
}
[void][scriptblock]::Create((Get-Content -Raw (Join-Path $root 'Start-ThraxDashboard.ps1')))
$server = Get-Content -Raw (Join-Path $root 'Start-ThraxDashboard.ps1')
if ($server -notmatch 'acknowledged -ne \$true') { throw 'Dashboard schedule creation must require acknowledgement.' }
if ($server -notmatch 'repoPattern') { throw 'Automation discovery must be scoped to the ThraxOS repository.' }
if ($server -notmatch 'scopeText') { throw 'Automation discovery must normalize configured checkout paths before matching.' }
if ($server -notmatch [regex]::Escape('$SongRoot = ''C:\Games\ITGmania\Songs''')) { throw 'Jukebox must use the approved ITGMania Songs root.' }
if ($server -notmatch 'Get-AudioCatalog' -or $server -notmatch 'Get-JukeboxResponse' -or $server -notmatch 'Write-AudioResponse') { throw 'Jukebox catalog and constrained audio serving helpers are required.' }
if ($server -notmatch '\^/api/audio/\(\[0-9a-f\]\{64\}\)\$') { throw 'Jukebox audio route must accept only catalog IDs, never paths.' }
if ($server -notmatch 'StartsWith\(\$root, \[StringComparison\]::OrdinalIgnoreCase\)') { throw 'Jukebox audio serving must revalidate the approved Songs root.' }
if ($server -notmatch 'Get-RecentPlaySessions' -or $server -notmatch '/api/play-sessions') { throw 'The read-only family session API is required.' }
$index = Get-Content -Raw (Join-Path $root 'public\index.html')
$app = Get-Content -Raw (Join-Path $root 'public\app.js')
if ($index -notmatch 'data-tab="sessions"' -or $index -notmatch 'id="sessionGrid"') { throw 'The family play-session view is required.' }
if ($app -notmatch 'loadPlaySessions' -or $app -notmatch 'formatSessionDuration') { throw 'The session view must load and label duration data.' }
foreach ($asset in 'public\index.html','public\styles.css','public\app.js') { if (-not (Test-Path (Join-Path $root $asset))) { throw "Missing $asset" } }
'Dashboard validation passed: 15 unique allowlisted capabilities, constrained fields, local-only jukebox and play-session routing, schedule acknowledgement, ThraxOS-only automation discovery, valid PowerShell syntax, and required assets.'
