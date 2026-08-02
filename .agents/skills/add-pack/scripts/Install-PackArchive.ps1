[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ArchivePath,
    [string] $SongRoot = 'C:\Games\ITGmania\Songs',
    [switch] $Install,
    [switch] $DeleteArchive,
    [switch] $AllowSongNameCollisions
)
$ErrorActionPreference = 'Stop'
$archive = (Resolve-Path -LiteralPath $ArchivePath).Path
$root = (Resolve-Path -LiteralPath $SongRoot).Path
if ([IO.Path]::GetExtension($archive) -ne '.zip') { throw 'Only ZIP archives are supported.' }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    $entries = @($zip.Entries)
    $unsafe = @($entries | Where-Object { $_.FullName -match '(^|[\\/])\.\.([\\/]|$)' -or $_.FullName -match '^[\\/]' -or $_.FullName -match '^[A-Za-z]:' })
    $payloads = @($entries | Where-Object { [IO.Path]::GetExtension($_.FullName) -match '^\.(exe|dll|com|bat|cmd|ps1|psm1|vbs|vbe|js|jse|msi|msp|scr|lnk|url|hta|reg)$' })
    # Ignore only conventional macOS metadata wrappers for structural counting.
    # Safety and payload checks above still inspect every entry in those wrappers.
    $topNames = @($entries | ForEach-Object { ($_.FullName -split '[\\/]')[0] } | Where-Object { $_ -and $_ -notin '__MACOSX','.DS_Store' } | Sort-Object -Unique)
    if ($unsafe.Count) { throw "Archive contains $($unsafe.Count) unsafe path(s)." }
    if ($payloads.Count) { throw "Archive contains $($payloads.Count) executable/script payload(s)." }
    if ($topNames.Count -ne 1) { throw "Expected one top-level pack folder; found $($topNames.Count)." }
} finally { $zip.Dispose() }

$mp = Get-ChildItem 'C:\ProgramData\Microsoft\Windows Defender\Platform' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'MpCmdRun.exe' } | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $mp) { throw 'Microsoft Defender command-line scanner was not found.' }
& $mp -Scan -ScanType 3 -File $archive
if ($LASTEXITCODE -ne 0) { throw "Defender archive scan failed or found a threat (exit $LASTEXITCODE)." }

$stage = Join-Path (Split-Path -Parent $archive) ('extracted-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage | Out-Null
try {
    [IO.Compression.ZipFile]::ExtractToDirectory($archive, $stage)
    $packDirs = @(Get-ChildItem -LiteralPath $stage -Directory | Where-Object { $_.Name -ne '__MACOSX' })
    if ($packDirs.Count -ne 1) { throw "Expected one extracted pack folder; found $($packDirs.Count)." }
    $pack = $packDirs[0]
    $dirs = @(Get-ChildItem -LiteralPath $pack.FullName -Directory)
    $songs = @(); $malformed = @()
    foreach ($dir in $dirs) {
        $files = @(Get-ChildItem -LiteralPath $dir.FullName -File)
        $sim = @($files | Where-Object { $_.Extension -in '.sm','.ssc' })
        $audio = @($files | Where-Object { $_.Extension -in '.ogg','.mp3','.wav','.flac','.opus','.m4a' })
        if ($sim.Count -and $audio.Count) { $songs += $dir }
        elseif ($sim.Count -or $audio.Count) { $malformed += $dir.Name }
    }
    if (-not $songs.Count) { throw 'No song directory contains both simfiles and audio.' }
    if ($malformed.Count) { throw "Malformed song directories: $($malformed -join ', ')" }
    & $mp -Scan -ScanType 3 -File $pack.FullName
    if ($LASTEXITCODE -ne 0) { throw "Defender extracted-tree scan failed or found a threat (exit $LASTEXITCODE)." }

    $destination = Join-Path $root $pack.Name
    if (Test-Path -LiteralPath $destination) { throw "Destination already exists: $destination" }
    $liveNames = @(Get-ChildItem -LiteralPath $root -Directory | Get-ChildItem -Directory | ForEach-Object { $_.Name.ToLowerInvariant() })
    $collisions = @($songs | Where-Object { $liveNames -contains $_.Name.ToLowerInvariant() } | Select-Object -ExpandProperty Name)
    if ($collisions.Count -and -not $AllowSongNameCollisions) { throw "Song-name collisions require review: $($collisions -join ', ')" }

    $result = [ordered]@{ PackName=$pack.Name; Destination=$destination; Songs=$songs.Count; Simfiles=@(Get-ChildItem -LiteralPath $pack.FullName -Recurse -File | Where-Object { $_.Extension -in '.sm','.ssc' }).Count; AudioFiles=@(Get-ChildItem -LiteralPath $pack.FullName -Recurse -File | Where-Object { $_.Extension -in '.ogg','.mp3','.wav','.flac','.opus','.m4a' }).Count; AuxiliaryDirectories=@($dirs | Where-Object { $songs.FullName -notcontains $_.FullName }).Count; SongNameCollisions=$collisions; SHA256=(Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash; Installed=$false; ArchiveDeleted=$false }
    if ($Install) {
        Move-Item -LiteralPath $pack.FullName -Destination $destination
        $result.Installed = Test-Path -LiteralPath $destination
        if ($DeleteArchive) { Remove-Item -LiteralPath $archive -Force; $result.ArchiveDeleted = -not (Test-Path -LiteralPath $archive) }
    }
    [pscustomobject]$result
} finally { if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force } }
