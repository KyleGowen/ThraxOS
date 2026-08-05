[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $CandidateJsonPath,
    [string[]] $SongRoot = @(
        'C:\Games\ITGmania\Songs',
        (Join-Path $env:APPDATA 'ITGmania\Songs')
    )
)

$ErrorActionPreference = 'Stop'

function ConvertTo-NormalizedText {
    param([AllowEmptyString()][string] $Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
    return ($Value.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant() -replace '\b(feat|featuring|ft)\b','' -replace '[^a-z0-9]+','')
}

function Get-SmTag {
    param([string] $Path, [string] $Name)
    $match = Select-String -LiteralPath $Path -Pattern ("^#${Name}:(.*);$") | Select-Object -First 1
    if ($match) { return $match.Matches[0].Groups[1].Value.Trim() }
    return ''
}

$candidatePath = (Resolve-Path -LiteralPath $CandidateJsonPath).Path
$parsedCandidates = Get-Content -LiteralPath $candidatePath -Raw -Encoding UTF8 | ConvertFrom-Json
$candidates = if ($parsedCandidates -is [array]) { @($parsedCandidates | ForEach-Object { $_ }) } else { @($parsedCandidates) }
if (-not $candidates.Count) { throw 'Candidate JSON must contain at least one artist/title object.' }
foreach ($candidate in $candidates) {
    if ([string]::IsNullOrWhiteSpace($candidate.artist) -or [string]::IsNullOrWhiteSpace($candidate.title)) {
        throw 'Every candidate must contain non-empty artist and title strings.'
    }
}

$roots = @($SongRoot | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
if (-not $roots.Count) { throw 'No approved song root exists.' }

$songDirs = [Collections.Generic.List[object]]::new()
foreach ($root in $roots) {
    foreach ($packPath in [IO.Directory]::EnumerateDirectories($root)) {
        foreach ($songPath in [IO.Directory]::EnumerateDirectories($packPath)) {
            $songName = [IO.Path]::GetFileName($songPath)
            $songDirs.Add([pscustomobject]@{ Root=$root; Pack=[IO.Path]::GetFileName($packPath); Song=$songName; FullName=$songPath; FolderKey=(ConvertTo-NormalizedText $songName) })
        }
    }
}

$rg = Get-Command 'rg.exe' -ErrorAction SilentlyContinue
if (-not $rg) { $rg = Get-Command 'rg' -ErrorAction SilentlyContinue }
if (-not $rg) { throw 'ripgrep (rg) is required for bounded simfile metadata lookup.' }
$titleAlternation = (($candidates | ForEach-Object { [regex]::Escape([string]$_.title) }) -join '|')
$combinedPattern = '^#(?:TITLE|TITLETRANSLIT):(?:' + $titleAlternation + ');\s*$'
$metadataPaths = @(& $rg.Source '-i' '-l' '--glob' '*.sm' '--glob' '*.ssc' '--' $combinedPattern @roots 2>$null)

$results = foreach ($candidate in $candidates) {
    $artistKey = ConvertTo-NormalizedText ([string]$candidate.artist)
    $titleKey = ConvertTo-NormalizedText ([string]$candidate.title)
    $folderLeads = @($songDirs | Where-Object { $_.FolderKey -eq $titleKey -or ($_.FolderKey -and $titleKey -and ($_.FolderKey.Contains($titleKey) -or $titleKey.Contains($_.FolderKey))) })
    $leadPaths = @($folderLeads | ForEach-Object { [IO.Directory]::EnumerateFiles($_.FullName) | Where-Object { [IO.Path]::GetExtension($_) -in '.sm','.ssc' } })
    $paths = @($metadataPaths + $leadPaths | Sort-Object -Unique)
    $records = foreach ($path in $paths) {
        $songPath = Split-Path -Parent $path
        $songName = Split-Path -Leaf $songPath
        $packName = Split-Path -Leaf (Split-Path -Parent $songPath)
        $title = Get-SmTag -Path $path -Name 'TITLE'
        $subtitle = Get-SmTag -Path $path -Name 'SUBTITLE'
        $artist = Get-SmTag -Path $path -Name 'ARTIST'
        $titleTranslit = Get-SmTag -Path $path -Name 'TITLETRANSLIT'
        $artistTranslit = Get-SmTag -Path $path -Name 'ARTISTTRANSLIT'
        $displayTitle = if ($subtitle) { "$title $subtitle" } else { $title }
        [pscustomobject]@{
            Pack=$packName; Song=$songName; Artist=$artist; Title=$displayTitle
            ArtistKeys=@((ConvertTo-NormalizedText $artist),(ConvertTo-NormalizedText $artistTranslit)) | Where-Object { $_ } | Sort-Object -Unique
            TitleKeys=@((ConvertTo-NormalizedText $displayTitle),(ConvertTo-NormalizedText $title),(ConvertTo-NormalizedText $titleTranslit),(ConvertTo-NormalizedText $songName)) | Where-Object { $_ } | Sort-Object -Unique
        }
    }
    $exact = @($records | Where-Object { $_.ArtistKeys -contains $artistKey -and $_.TitleKeys -contains $titleKey })
    $likely = if ($exact.Count) { @() } else { @($records | Where-Object { ($_.ArtistKeys -contains $artistKey) -and ($_.TitleKeys | Where-Object { $_ -and $titleKey -and ($_.Contains($titleKey) -or $titleKey.Contains($_)) }) }) }
    $matches = if ($exact.Count) { $exact } else { $likely }
    [pscustomobject]@{
        artist=[string]$candidate.artist
        title=[string]$candidate.title
        overlap=if ($exact.Count) { 'exact' } elseif ($likely.Count) { 'likely_variant' } else { 'none' }
        matches=@($matches | Select-Object -First 10 | ForEach-Object {
            [pscustomobject]@{ pack=$_.Pack; song=$_.Song; metadataArtist=$_.Artist; metadataTitle=$_.Title }
        })
    }
}

[pscustomobject]@{
    observedAt=(Get-Date).ToString('o')
    rootsChecked=$roots
    candidateCount=$candidates.Count
    librarySongFolders=$songDirs.Count
    results=@($results)
} | ConvertTo-Json -Depth 6
