[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[0-9A-Fa-f]{64}$')][string]$ExpectedSha256,
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })][string]$MappingFile,
    [string]$KeymapsPath = (Join-Path $env:APPDATA 'ITGmania\Save\Keymaps.ini'),
    [switch]$Approved
)

$ErrorActionPreference = 'Stop'
if (-not $Approved) { throw 'Refusing to edit Keymaps.ini without -Approved.' }
if (Get-Process -Name ITGmania -ErrorAction SilentlyContinue) { throw 'ITGMania is running; aborting.' }
if (-not (Test-Path -LiteralPath $KeymapsPath -PathType Leaf)) { throw "Missing Keymaps.ini: $KeymapsPath" }
$actualHash = (Get-FileHash -LiteralPath $KeymapsPath -Algorithm SHA256).Hash
if ($actualHash -ne $ExpectedSha256.ToUpperInvariant()) { throw 'Keymaps.ini changed since preflight; aborting without a write.' }

$payload = Get-Content -LiteralPath $MappingFile -Raw | ConvertFrom-Json
if ($payload.mode -ne 'dance' -or $null -eq $payload.mappings) { throw 'Mapping payload must contain mode="dance" and a mappings object.' }
$validAction = '^1_(Back|Coin|Down|EffectDown|EffectUp|Left|MenuDown|MenuLeft|MenuRight|MenuUp|Operator|Restart|Right|Select|Start|Up|UpLeft|UpRight)$'
$validInput = '^(?:Joy(?:[1-9]|[12][0-9]|3[0-2])_[A-Za-z0-9+\- ]+|Key_[A-Za-z0-9+\- ]+)$'
$desired = [ordered]@{}
foreach ($property in $payload.mappings.PSObject.Properties) {
    if ($property.Name -notmatch $validAction) { throw "Unsupported Player 1 action: $($property.Name)" }
    $values = @($property.Value)
    if ($values.Count -gt 2) { throw "$($property.Name) has $($values.Count) bindings; ITGMania retains at most two." }
    foreach ($value in $values) { if ($value -isnot [string] -or $value -notmatch $validInput) { throw "Invalid device input for $($property.Name): $value" } }
    $desired[$property.Name] = ($values -join ':')
}
if ($desired.Count -eq 0) { throw 'Mapping payload contains no actions.' }

$rollbackPath = "$KeymapsPath.before-controller-map-$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
if (Test-Path -LiteralPath $rollbackPath) { throw 'Rollback filename collision.' }
Copy-Item -LiteralPath $KeymapsPath -Destination $rollbackPath -ErrorAction Stop
if ((Get-FileHash -LiteralPath $rollbackPath -Algorithm SHA256).Hash -ne $actualHash) { throw 'Rollback hash validation failed.' }

$text = [System.IO.File]::ReadAllText($KeymapsPath)
$section = [regex]::Match($text, '(?ms)^\[dance\]\r?\n(.*?)(?=^\[|\z)')
if (-not $section.Success) { throw 'The [dance] section is missing.' }
$body = $section.Groups[1].Value
foreach ($name in $desired.Keys) {
    $pattern = "(?m)^$([regex]::Escape($name))=.*$"
    if ([regex]::Matches($body, $pattern).Count -ne 1) { throw "Expected exactly one [dance] entry for $name." }
    $body = [regex]::Replace($body, $pattern, "$name=$($desired[$name])")
}
$updated = $text.Substring(0, $section.Groups[1].Index) + $body + $text.Substring($section.Groups[1].Index + $section.Groups[1].Length)
[System.IO.File]::WriteAllText($KeymapsPath, $updated, [System.Text.UTF8Encoding]::new($false))
$validated = [System.IO.File]::ReadAllText($KeymapsPath)
foreach ($name in $desired.Keys) { if ($validated -notmatch "(?m)^$([regex]::Escape($name))=$([regex]::Escape($desired[$name]))$") { throw "Post-write validation failed for $name." } }

[pscustomobject]@{ KeymapsPath = $KeymapsPath; RollbackPath = $rollbackPath; PreviousSha256 = $actualHash; ActiveSha256 = (Get-FileHash -LiteralPath $KeymapsPath -Algorithm SHA256).Hash; Applied = $desired } | ConvertTo-Json -Depth 4
