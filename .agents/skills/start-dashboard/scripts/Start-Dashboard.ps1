[CmdletBinding()]
param([ValidateSet('Local','Lan')][string]$Mode = 'Local', [ValidateRange(1024,65535)][int]$Port = 8765, [string]$BindAddress, [string]$AccessToken, [switch]$Approved)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $Approved) { throw 'Starting the dashboard requires the owner to pass -Approved.' }
$skillRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = Split-Path (Split-Path (Split-Path $skillRoot -Parent) -Parent) -Parent
$preflight = Join-Path $PSScriptRoot 'Get-DashboardPreflight.ps1'
$dashboardScript = Join-Path $repoRoot 'dashboard\Start-ThraxDashboard.ps1'
if ($Mode -eq 'Lan') {
  if ($AccessToken -notmatch '^[A-Za-z0-9_-]{32,256}$') { throw 'LAN mode requires a URL-safe 32-256 character token from a local secret mechanism.' }
  $check = & $preflight -Mode Lan -Port $Port -BindAddress $BindAddress
  if ($check.urlAcl -ne 'present' -or $check.firewall -ne 'matching-rule-present') { throw "LAN prerequisites are incomplete (URLACL: $($check.urlAcl); firewall: $($check.firewall)). Do not change Windows networking without separate explicit approval." }
} else { $check = & $preflight -Mode Local -Port $Port }
$address = [string]$check.bindAddress; $endpoint = "http://$address`:$Port/"
if ($check.listenerState -eq 'listening') { throw "A listener already occupies $endpoint. Do not terminate or replace it automatically." }
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$dashboardScript`" -Port $Port -BindAddress $address"
if ($Mode -eq 'Lan') { $arguments += " -AllowLan -AccessToken `"$AccessToken`"" }
$process = Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList $arguments -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 2
if ($process.HasExited) { throw 'The dashboard process exited before verification.' }
try {
  if ($Mode -eq 'Lan') { $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession; $encodedToken = [Uri]::EscapeDataString($AccessToken); $response = Invoke-WebRequest "$endpoint?access=$encodedToken" -WebSession $session -UseBasicParsing -TimeoutSec 8 } else { $response = Invoke-WebRequest $endpoint -UseBasicParsing -TimeoutSec 8 }
} catch { throw "The dashboard process started but the requested $Mode response could not be verified: $($_.Exception.Message)" }
[pscustomobject]@{ state='started'; mode=$Mode; endpoint=$endpoint; port=$Port; processId=$process.Id; responseStatus=$response.StatusCode; accessTokenPrinted=$false; externalLanDeviceVerified=$false }
