[CmdletBinding()]
param([Parameter(Mandatory)][string]$Simfile)

$ErrorActionPreference = 'Stop'
$sim = (Resolve-Path -LiteralPath $Simfile).Path
$song = Split-Path -Parent $sim
$references = @()
$changeStates = @()
$simfiles = @(Get-ChildItem -LiteralPath $song -File | Where-Object Extension -in @('.sm', '.ssc') | Sort-Object Name)
if ($simfiles.Count -eq 0) { throw 'No .sm or .ssc simfile found.' }

foreach ($candidateSim in $simfiles) {
    $text = [IO.File]::ReadAllText($candidateSim.FullName)
    $markers = [regex]::Matches($text, '(?im)^#BGCHANGES\s*:')
    $tags = [regex]::Matches($text, '(?is)#BGCHANGES\s*:(.*?);')
    if ($markers.Count -ne $tags.Count) { throw "Malformed or unterminated BGCHANGES metadata is excluded: $($candidateSim.Name)" }
    $state = if ($markers.Count -eq 0) { 'none' } elseif (@($tags | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Groups[1].Value) }).Count -gt 0) { 'populated' } else { 'empty' }
    if ($state -eq 'populated') { throw "Songs with active BGCHANGES content are excluded: $($candidateSim.Name)" }
    $changeStates += $state
    $matches = [regex]::Matches($text, '(?im)^#BACKGROUND\s*:\s*([^;\r\n]+)\s*;')
    if ($matches.Count -ne 1) { throw "Expected exactly one explicit #BACKGROUND reference in $($candidateSim.Name); found $($matches.Count)." }
    $references += $matches[0].Groups[1].Value.Trim()
}

$unique = @($references | Sort-Object -Unique)
if ($unique.Count -ne 1) { throw 'Simfiles disagree on #BACKGROUND.' }
$reference = $unique[0]
$extension = [IO.Path]::GetExtension($reference).ToLowerInvariant()
if ($extension -notin @('.png', '.jpg', '.jpeg', '.bmp')) { throw "Unsupported or non-static background extension: $extension" }
$target = [IO.Path]::GetFullPath((Join-Path $song $reference))
$root = [IO.Path]::GetFullPath($song).TrimEnd('\') + '\'
if (-not $target.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw '#BACKGROUND resolves outside the song directory.' }
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'Referenced background does not exist.' }

$presentation = & (Join-Path $PSScriptRoot 'Get-ImagePresentation.ps1') -Path $target
if ($presentation.FrameCount -ne 1) { throw "Animated or multi-frame background is excluded; found $($presentation.FrameCount) frames." }
[pscustomobject]@{
    Simfile = $sim
    BackgroundReference = $reference
    BackgroundPath = $target
    Width = $presentation.Width
    Height = $presentation.Height
    AspectRatio = $presentation.AspectRatio
    AspectRatioDecimal = $presentation.AspectRatioDecimal
    FrameCount = $presentation.FrameCount
    Extension = $extension
    Format = $presentation.Format
    BgChangesState = if ($changeStates -contains 'empty') { 'empty' } else { 'none' }
}
