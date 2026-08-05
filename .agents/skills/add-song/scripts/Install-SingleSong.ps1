[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Url,
    [string] $SourcePage,
    [Parameter(Mandatory)] [string] $ExpectedArtist,
    [Parameter(Mandatory)] [string] $ExpectedTitle,
    [string] $SongRoot = 'C:\Games\ITGmania\Songs\Misc. Collected',
    [switch] $Install
)

$ErrorActionPreference = 'Stop'

function ConvertTo-NormalizedText {
    param([string] $Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
    return ($Value.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant() -replace '[^a-z0-9]+', '')
}

function Get-SmTag {
    param([string[]] $Paths, [string] $Name)
    foreach ($path in $Paths) {
        $match = Select-String -LiteralPath $path -Pattern ("^#${Name}:(.*);$") | Select-Object -First 1
        if ($match) { return $match.Matches[0].Groups[1].Value.Trim() }
    }
    return $null
}

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$stage = Join-Path (Join-Path $repoRoot 'staging') ('add-song-' + [guid]::NewGuid().ToString('N'))
$archive = Join-Path $stage 'song.zip'
$extract = Join-Path $stage 'extracted'
$result = $null

try {
    if (-not (Test-Path -LiteralPath $SongRoot -PathType Container)) { throw "Song root does not exist: $SongRoot" }
    if (Get-Process -Name 'ITGmania' -ErrorAction SilentlyContinue) { throw 'ITGMania is running; refusing to download or install.' }

    $backupScript = Join-Path $repoRoot '.agents\skills\thraxos\scripts\Test-BackupHealth.ps1'
    $backupText = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $backupScript 2>&1 | Out-String
    try { $backup = $backupText | ConvertFrom-Json } catch { throw "Backup health returned invalid JSON: $backupText" }
    if (-not $backup.latestSuccess) { throw 'No successful backup evidence was reported.' }
    $latestSuccess = [datetime]$backup.latestSuccess
    if (((Get-Date) - $latestSuccess).TotalHours -gt 36) { throw "Latest successful backup is older than 36 hours: $latestSuccess" }

    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    $downloadScript = Join-Path $repoRoot '.agents\skills\add-pack\scripts\Get-PackArchive.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $downloadScript -Url $Url -Destination $archive
    if ($LASTEXITCODE -ne 0) { throw "Download helper failed with exit code $LASTEXITCODE." }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($archive)
    try {
        $entries = @($zip.Entries)
        $unsafe = @($entries | Where-Object { $_.FullName -match '(^|[\\/])\.\.([\\/]|$)' -or $_.FullName -match '^[\\/]' -or $_.FullName -match '^[A-Za-z]:' })
        $payloads = @($entries | Where-Object { [IO.Path]::GetExtension($_.FullName) -match '^\.(exe|dll|com|bat|cmd|ps1|psm1|vbs|vbe|js|jse|msi|msp|scr|lnk|url|hta|reg)$' })
        $topNames = @($entries | ForEach-Object { ($_.FullName -split '[\\/]')[0] } | Where-Object { $_ -and $_ -notin '__MACOSX','.DS_Store' } | Sort-Object -Unique)
        if ($unsafe.Count) { throw "Archive contains $($unsafe.Count) unsafe path(s)." }
        if ($payloads.Count) { throw "Archive contains $($payloads.Count) executable/script payload(s)." }
        if ($topNames.Count -ne 1) { throw "Expected one top-level song folder; found $($topNames.Count)." }
    } finally { $zip.Dispose() }

    $mp = Get-ChildItem 'C:\ProgramData\Microsoft\Windows Defender\Platform' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'MpCmdRun.exe' } | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $mp) { throw 'Microsoft Defender command-line scanner was not found.' }
    & $mp -Scan -ScanType 3 -File $archive
    if ($LASTEXITCODE -ne 0) { throw "Defender archive scan failed or found a threat (exit $LASTEXITCODE)." }

    New-Item -ItemType Directory -Path $extract | Out-Null
    [IO.Compression.ZipFile]::ExtractToDirectory($archive, $extract)
    $songDirs = @(Get-ChildItem -LiteralPath $extract -Directory | Where-Object { $_.Name -ne '__MACOSX' })
    if ($songDirs.Count -ne 1) { throw "Expected one extracted song folder; found $($songDirs.Count)." }
    $song = $songDirs[0]
    $files = @(Get-ChildItem -LiteralPath $song.FullName -Recurse -File)
    $simfiles = @($files | Where-Object { $_.Extension -in '.sm','.ssc' })
    $audio = @($files | Where-Object { $_.Extension -in '.ogg','.mp3','.wav','.flac','.opus','.m4a' })
    if (-not $simfiles.Count -or -not $audio.Count) { throw 'The song folder must contain both a simfile and audio.' }

    $artist = Get-SmTag -Paths $simfiles.FullName -Name 'ARTIST'
    $title = Get-SmTag -Paths $simfiles.FullName -Name 'TITLE'
    if ((ConvertTo-NormalizedText $artist) -ne (ConvertTo-NormalizedText $ExpectedArtist)) { throw "Artist mismatch: expected '$ExpectedArtist', found '$artist'." }
    if ((ConvertTo-NormalizedText $title) -ne (ConvertTo-NormalizedText $ExpectedTitle)) { throw "Title mismatch: expected '$ExpectedTitle', found '$title'." }

    & $mp -Scan -ScanType 3 -File $song.FullName
    if ($LASTEXITCODE -ne 0) { throw "Defender extracted-tree scan failed or found a threat (exit $LASTEXITCODE)." }

    $destination = Join-Path $SongRoot $song.Name
    if (Test-Path -LiteralPath $destination) { throw "Destination already exists: $destination" }
    $archiveInfo = Get-Item -LiteralPath $archive
    $hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    $installed = $false
    if ($Install) {
        if (Get-Process -Name 'ITGmania' -ErrorAction SilentlyContinue) { throw 'ITGMania started during validation; refusing installation.' }
        Move-Item -LiteralPath $song.FullName -Destination $destination
        $installedFiles = @(Get-ChildItem -LiteralPath $destination -Recurse -File)
        if (@($installedFiles | Where-Object { $_.Extension -in '.sm','.ssc' }).Count -ne $simfiles.Count) { throw 'Post-install simfile verification failed.' }
        if (@($installedFiles | Where-Object { $_.Extension -in '.ogg','.mp3','.wav','.flac','.opus','.m4a' }).Count -ne $audio.Count) { throw 'Post-install audio verification failed.' }
        $installed = $true
    }

    $result = [pscustomobject]@{
        ObservedAt=(Get-Date).ToString('o'); SourcePage=$SourcePage; ArchiveUrl=$Url; Artist=$artist; Title=$title; Destination=$destination
        Bytes=$archiveInfo.Length; SHA256=$hash; Simfiles=$simfiles.Count; AudioFiles=$audio.Count
        DefenderArchive='clean'; DefenderExtracted='clean'; LatestBackupSuccess=$latestSuccess.ToString('o')
        BackupTaskInspectionLimited=(-not [bool]$backup.healthy); Installed=$installed
        ITGManiaRunning=[bool](Get-Process -Name 'ITGmania' -ErrorAction SilentlyContinue); StagingCleanup='pending-finally'
    }
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
}

if ($result) {
    $result.StagingCleanup = if (Test-Path -LiteralPath $stage) { 'failed' } else { 'complete' }
    $result | ConvertTo-Json -Depth 4
}
