[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$preflightPath = Join-Path $PSScriptRoot 'Get-DashboardPreflight.ps1'; $launcherPath = Join-Path $PSScriptRoot 'Start-Dashboard.ps1'
foreach ($path in @($preflightPath,$launcherPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing skill helper: $path" }; [void][scriptblock]::Create((Get-Content -Raw -LiteralPath $path)) }
$preflight = Get-Content -Raw -LiteralPath $preflightPath; $launcher = Get-Content -Raw -LiteralPath $launcherPath
if ($preflight -notmatch 'Test-PrivateIpv4' -or $preflight -notmatch "'127.0.0.1'") { throw 'Preflight must constrain local and private-LAN bindings.' }
if ($launcher -notmatch 'if \(-not \$Approved\)' -or $launcher -notmatch 'URL-safe 32-256 character token') { throw 'Launcher must require owner approval and a constrained LAN token.' }
if ($launcher -notmatch 'externalLanDeviceVerified=\$false' -or $launcher -match 'New-NetFirewallRule|netsh\.exe http add') { throw 'Launcher must not claim external LAN verification or alter networking.' }
'Start Dashboard validation passed: parser checks and local/LAN launch guardrails are present.'
