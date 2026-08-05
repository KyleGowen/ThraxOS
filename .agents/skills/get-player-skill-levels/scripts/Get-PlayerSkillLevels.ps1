[CmdletBinding()]
param(
    [string] $MapPath,
    [string] $ProfileRoot = (Join-Path $env:APPDATA 'ITGmania\Save\LocalProfiles'),
    [string[]] $SongRoot = @('C:\Games\ITGmania\Songs', (Join-Path $env:APPDATA 'ITGmania\Songs')),
    [int] $WindowDays = 90,
    [int] $MinimumClearsAtMeter = 2
)

$ErrorActionPreference = 'Stop'

function ConvertTo-Key {
    param([AllowEmptyString()][string] $Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
    return ($Value.Trim().Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant() -replace '[^a-z0-9]+','')
}

function Get-Tag {
    param([string] $Text, [string] $Name)
    $m = [regex]::Match($Text, '(?im)^#' + [regex]::Escape($Name) + ':\s*(.*?);\s*$')
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return ''
}

function Get-ChartsFromSimfile {
    param([string] $Path)
    $text = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
    if ([IO.Path]::GetExtension($Path) -ieq '.ssc') {
        foreach ($block in [regex]::Split($text, '(?im)^#NOTEDATA:;\s*$') | Select-Object -Skip 1) {
            $stepsType = Get-Tag $block 'STEPSTYPE'; $difficulty = Get-Tag $block 'DIFFICULTY'; $meter = Get-Tag $block 'METER'
            if ($stepsType -and $difficulty -and $meter -match '^\d+$') { [pscustomobject]@{StepsType=$stepsType;Difficulty=$difficulty;Meter=[int]$meter} }
        }
    } else {
        $pattern = '(?ms)#NOTES:\s*([^:]*):\s*([^:]*):\s*([^:]*):\s*([^:]*):'
        foreach ($m in [regex]::Matches($text, $pattern)) {
            $stepsType=$m.Groups[1].Value.Trim(); $difficulty=$m.Groups[3].Value.Trim(); $meter=$m.Groups[4].Value.Trim()
            if ($stepsType -and $difficulty -and $meter -match '^\d+$') { [pscustomobject]@{StepsType=$stepsType;Difficulty=$difficulty;Meter=[int]$meter} }
        }
    }
}

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
if (-not $MapPath) { $MapPath = Join-Path $repoRoot 'config\profile-common-name-map.json' }
$map = Get-Content -LiteralPath $MapPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($map.formatVersion -ne 1 -or -not $map.profiles) { throw 'Unsupported or empty profile common-name map.' }

$aliasToCommon = @{}
$commonNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($entry in $map.profiles) {
    $common = ([string]$entry.commonName).Trim().ToLowerInvariant()
    if (-not $common) { throw 'Every mapping requires commonName.' }
    if (-not $commonNames.Add($common)) { throw "Duplicate commonName: $common" }
    foreach ($alias in @($entry.profileDisplayNames)) {
        $key = ([string]$alias).Trim().Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant()
        if (-not $key) { throw "Empty profile alias for $common." }
        if ($aliasToCommon.ContainsKey($key)) { throw "Duplicate profile alias: $alias" }
        $aliasToCommon[$key] = $common
    }
}

$roots = @($SongRoot | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
$songIndex = @{}
foreach ($root in $roots) {
    foreach ($packPath in [IO.Directory]::EnumerateDirectories($root)) {
        foreach ($songPath in [IO.Directory]::EnumerateDirectories($packPath)) {
            $songKey = ConvertTo-Key ([IO.Path]::GetFileName($songPath))
            if (-not $songIndex.ContainsKey($songKey)) { $songIndex[$songKey] = [Collections.Generic.List[object]]::new() }
            $songIndex[$songKey].Add([pscustomobject]@{PackKey=(ConvertTo-Key ([IO.Path]::GetFileName($packPath)));Path=$songPath})
        }
    }
}

$profiles = @(); $unmapped = @()
foreach ($profileDir in @(Get-ChildItem -LiteralPath $ProfileRoot -Directory -ErrorAction SilentlyContinue)) {
    $statsPath = Join-Path $profileDir.FullName 'Stats.xml'
    if (-not (Test-Path -LiteralPath $statsPath)) { continue }
    try { [xml]$stats = Get-Content -LiteralPath $statsPath -Raw } catch { continue }
    $displayName = ([string]$stats.Stats.GeneralData.DisplayName).Trim()
    $displayKey = $displayName.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant()
    if (-not $aliasToCommon.ContainsKey($displayKey)) { $unmapped += $displayName; continue }
    $commonName = $aliasToCommon[$displayKey]
    $records = @()
    foreach ($highScore in @($stats.SelectNodes('//SongScores/Song/Steps/HighScoreList/HighScore'))) {
        $dateText=[string]$highScore.DateTime
        try { [datetime]$date=$dateText } catch { continue }
        $steps=$highScore.ParentNode.ParentNode; $song=$steps.ParentNode
        $records += [pscustomobject]@{Date=$date;Grade=[string]$highScore.Grade;Disqualified=([string]$highScore.Disqualified -eq '1' -or [string]$highScore.Disqualified -eq 'true');StepsType=[string]$steps.StepsType;Difficulty=[string]$steps.Difficulty;SongDir=[string]$song.Dir}
    }
    $latest = $records.Date | Sort-Object -Descending | Select-Object -First 1
    if (-not $latest) { $profiles += [pscustomobject]@{commonName=$commonName;status='insufficient';reason='no-dated-score-records'}; continue }
    $windowStart = $latest.AddDays(-$WindowDays)
    $eligible = @($records | Where-Object { $_.Date -ge $windowStart -and $_.Date -le $latest -and -not $_.Disqualified -and $_.Grade -notmatch 'Failed' })
    $resolved=@(); $unresolved=0; $ambiguous=0
    foreach ($record in $eligible) {
        $parts=@(($record.SongDir -replace '\\','/' -split '/') | Where-Object { $_ })
        if ($parts.Count -lt 2) { $unresolved++; continue }
        $songKey=ConvertTo-Key $parts[-1]; $packKey=ConvertTo-Key $parts[-2]
        $candidates=@($songIndex[$songKey])
        if (-not $candidates.Count) { $unresolved++; continue }
        $packMatches=@($candidates | Where-Object { $_.PackKey -eq $packKey })
        if ($packMatches.Count) { $candidates=$packMatches }
        $meterMatches=@()
        foreach ($candidate in $candidates) {
            foreach ($sim in @([IO.Directory]::EnumerateFiles($candidate.Path) | Where-Object { [IO.Path]::GetExtension($_) -in '.sm','.ssc' })) {
                foreach ($chart in @(Get-ChartsFromSimfile $sim)) {
                    if ($chart.StepsType -ieq $record.StepsType -and $chart.Difficulty -ieq $record.Difficulty) { $meterMatches += $chart.Meter }
                }
            }
        }
        $meters=@($meterMatches | Sort-Object -Unique)
        if ($meters.Count -eq 1) { $resolved += [int]$meters[0] } elseif ($meters.Count -gt 1) { $ambiguous++ } else { $unresolved++ }
    }
    $groups=@($resolved | Group-Object | ForEach-Object {[pscustomobject]@{Meter=[int]$_.Name;Clears=$_.Count}} | Sort-Object Meter)
    $stretch=$groups | Where-Object Clears -ge $MinimumClearsAtMeter | Sort-Object Meter -Descending | Select-Object -First 1
    $status=if($stretch){'ok'}else{'insufficient'}
    $profiles += [pscustomobject]@{commonName=$commonName;status=$status;latestRecordedPlay=$latest.ToString('o');windowStart=$windowStart.ToString('o');windowEnd=$latest.ToString('o');eligibleRecords=$eligible.Count;resolvedRecords=$resolved.Count;unresolvedRecords=$unresolved;ambiguousRecords=$ambiguous;stretchLevel=if($stretch){$stretch.Meter}else{$null};supportingClears=if($stretch){$stretch.Clears}else{0};evidenceKind='dated-high-score-records-not-complete-play-history'}
}

[pscustomobject]@{observedAt=(Get-Date).ToString('o');windowDays=$WindowDays;minimumClearsAtMeter=$MinimumClearsAtMeter;profiles=@($profiles|Sort-Object commonName);unmappedProfileDisplayNames=@($unmapped|Sort-Object -Unique);songRootsChecked=$roots} | ConvertTo-Json -Depth 6
