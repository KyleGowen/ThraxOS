[CmdletBinding()]
param([ValidateSet('Local','Lan')][string]$Mode = 'Local', [ValidateRange(1024,65535)][int]$Port = 8765, [string]$BindAddress)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$skillRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = Split-Path (Split-Path (Split-Path $skillRoot -Parent) -Parent) -Parent
$dashboardScript = Join-Path $repoRoot 'dashboard\Start-ThraxDashboard.ps1'
$dashboardTest = Join-Path $repoRoot 'dashboard\Test-ThraxDashboard.ps1'
function Test-PrivateIpv4([string]$Address) {
  $parsed = $null
  if (-not [Net.IPAddress]::TryParse($Address, [ref]$parsed)) { return $false }
  $octets = $parsed.GetAddressBytes()
  return $octets.Length -eq 4 -and ($octets[0] -eq 10 -or ($octets[0] -eq 172 -and $octets[1] -ge 16 -and $octets[1] -le 31) -or ($octets[0] -eq 192 -and $octets[1] -eq 168))
}
if (-not (Test-Path -LiteralPath $dashboardScript -PathType Leaf) -or -not (Test-Path -LiteralPath $dashboardTest -PathType Leaf)) { throw 'The dashboard scripts are missing.' }
$effectiveAddress = if ($Mode -eq 'Local') { '127.0.0.1' } else { $BindAddress }
if ($Mode -eq 'Lan' -and -not (Test-PrivateIpv4 $effectiveAddress)) { throw 'LAN mode requires an explicit RFC1918 IPv4 address.' }
$listeners = @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalAddress -in @($effectiveAddress,'0.0.0.0','::') })
$urlAcl = 'not-applicable'; $firewall = 'not-applicable'
if ($Mode -eq 'Lan') {
  $urlAclResult = & netsh.exe http show urlacl "url=http://$effectiveAddress`:$Port/" 2>&1 | Out-String
  $urlAcl = if ($LASTEXITCODE -eq 0 -and $urlAclResult -match 'Reserved URL') { 'present' } else { 'not-found-or-unreadable' }
  try { $rules = @(Get-NetFirewallRule -DisplayName 'ThraxOS Arcade Console (LAN)' -ErrorAction Stop | Get-NetFirewallPortFilter -ErrorAction Stop | Where-Object { $_.Protocol -eq 'TCP' -and $_.LocalPort -eq [string]$Port }); $firewall = if ($rules.Count -gt 0) { 'matching-rule-present' } else { 'matching-rule-not-found' } } catch { $firewall = 'unreadable' }
}
[pscustomobject]@{ observedAt=(Get-Date).ToString('o'); mode=$Mode; bindAddress=$effectiveAddress; port=$Port; dashboardScriptPresent=$true; dashboardValidationPresent=$true; listenerState=if($listeners.Count -gt 0){'listening'}else{'available'}; urlAcl=$urlAcl; firewall=$firewall; tokenRequired=($Mode -eq 'Lan') }
