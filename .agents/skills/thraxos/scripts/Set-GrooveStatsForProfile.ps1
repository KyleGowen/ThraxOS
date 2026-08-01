[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$ProfileDisplayName = 'Kyle'
)

$ErrorActionPreference = 'Stop'
$saveRoot = 'C:\Users\Player.NUCBOXG3_PLUS\AppData\Roaming\ITGmania\Save'
$profilesRoot = Join-Path $saveRoot 'LocalProfiles'
$themePrefsPath = Join-Path $saveRoot 'ThemePrefs.ini'

if (Get-Process -Name 'ITGmania' -ErrorAction SilentlyContinue) {
    throw 'ITGMania is running. Close it normally and rerun this script; the script will not stop or restart the game.'
}

$matchingProfiles = @(
    Get-ChildItem -LiteralPath $profilesRoot -Directory | Where-Object {
        $editablePath = Join-Path $_.FullName 'Editable.ini'
        if (-not (Test-Path -LiteralPath $editablePath)) { return $false }
        $displayLine = Get-Content -LiteralPath $editablePath | Where-Object { $_ -match '^DisplayName=' } | Select-Object -First 1
        $displayLine -eq "DisplayName=$ProfileDisplayName"
    }
)

if ($matchingProfiles.Count -ne 1) {
    throw "Expected exactly one local profile named '$ProfileDisplayName'; found $($matchingProfiles.Count)."
}

$profilePath = $matchingProfiles[0].FullName
$grooveStatsPath = Join-Path $profilePath 'GrooveStats.ini'
if (-not (Test-Path -LiteralPath $grooveStatsPath)) { throw 'The selected profile has no GrooveStats.ini.' }
if (-not (Test-Path -LiteralPath $themePrefsPath)) { throw 'ThemePrefs.ini was not found.' }

$grooveStatsText = [IO.File]::ReadAllText($grooveStatsPath)
$themePrefsText = [IO.File]::ReadAllText($themePrefsPath)
$apiKeyMatch = [regex]::Match($grooveStatsText, '(?m)^ApiKey=(.*)$')
$apiKeyLength = if ($apiKeyMatch.Success) { $apiKeyMatch.Groups[1].Value.Trim().Length } else { 0 }
if ($apiKeyLength -ne 64) { throw 'The selected profile does not have a structurally valid 64-character API key.' }
if ($grooveStatsText -notmatch '(?m)^IsPadPlayer=') { throw 'GrooveStats.ini has no IsPadPlayer field.' }
if ($themePrefsText -notmatch '(?m)^EnableGrooveStats=') { throw 'ThemePrefs.ini has no EnableGrooveStats field.' }

$newGrooveStatsText = [regex]::Replace($grooveStatsText, '(?m)^IsPadPlayer=.*$', 'IsPadPlayer=1')
$newThemePrefsText = [regex]::Replace($themePrefsText, '(?m)^EnableGrooveStats=.*$', 'EnableGrooveStats=true')
$utf8NoBom = [Text.UTF8Encoding]::new($false)

if ($PSCmdlet.ShouldProcess($grooveStatsPath, 'Mark the selected GrooveStats profile as a pad player')) {
    [IO.File]::WriteAllText($grooveStatsPath, $newGrooveStatsText, $utf8NoBom)
}
if ($PSCmdlet.ShouldProcess($themePrefsPath, 'Enable GrooveStats in Simply Love')) {
    [IO.File]::WriteAllText($themePrefsPath, $newThemePrefsText, $utf8NoBom)
}

$result = [ordered]@{
    profile = $ProfileDisplayName
    apiKeyPresent = $true
    apiKeyLengthValid = $true
    isPadPlayer = 1
    grooveStatsEnabled = $true
    credentialValuePrinted = $false
}
$result | ConvertTo-Json
