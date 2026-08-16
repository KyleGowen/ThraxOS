[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$catalog = Get-Content -Raw (Join-Path $root 'config\capabilities.json') | ConvertFrom-Json
if (@($catalog.skills).Count -ne 14) { throw 'Expected 14 dashboard capabilities.' }
$duplicates = $catalog.skills | Group-Object id | Where-Object Count -gt 1
if ($duplicates) { throw 'Capability IDs must be unique.' }
$allowedActions = @('status','backup-health','player-levels','request')
foreach ($skill in $catalog.skills) {
    if ($skill.action -notin $allowedActions) { throw "Unapproved action: $($skill.action)" }
    foreach ($field in $skill.fields) {
        if ($field.type -ne 'select' -and (-not $field.PSObject.Properties['maxLength'] -or -not $field.maxLength)) { throw "Field $($field.id) requires maxLength." }
        if ($field.type -eq 'path' -and $field.root -ne 'C:\Games\ITGmania\Songs') { throw 'Path field escapes the approved song root.' }
    }
}
[void][scriptblock]::Create((Get-Content -Raw (Join-Path $root 'Start-ThraxDashboard.ps1')))
foreach ($asset in 'public\index.html','public\styles.css','public\app.js') { if (-not (Test-Path (Join-Path $root $asset))) { throw "Missing $asset" } }
'Dashboard validation passed: 14 unique allowlisted capabilities, constrained fields, valid PowerShell syntax, and required assets.'
