[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Simfile,
    [Parameter(Mandatory)][string]$SongPath,
    [Parameter(Mandatory)][string]$Fingerprint,
    [Parameter(Mandatory)][switch]$Approved,
    [Parameter(Mandatory)][switch]$BackupVerified,
    [Parameter(Mandatory)][string]$DecisionNote,
    [string]$PackPath = 'C:\Games\ITGmania\Songs\Misc. Collected',
    [string]$QueuePath,
    [int]$Width = 1920,
    [int]$Height = 1080
)

$ErrorActionPreference = 'Stop'
if (-not $Approved) { throw 'Explicit -Approved is required after owner approval of the exact displayed preview.' }
if (-not $BackupVerified) { throw 'Explicit -BackupVerified is required after current backup evidence is checked.' }
if ([string]::IsNullOrWhiteSpace($DecisionNote)) { throw 'DecisionNote must state what the owner approved.' }

$repo = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
if (-not $QueuePath) { $QueuePath = Join-Path $repo 'memory\background-upscale-queue.json' }
$queueFile = [IO.Path]::GetFullPath($QueuePath)
$pack = (Resolve-Path -LiteralPath $PackPath).Path
$songDirectory = [IO.Path]::GetFullPath((Join-Path $pack $SongPath)).TrimEnd('\')
$resolvedSimfile = (Resolve-Path -LiteralPath $Simfile).Path
if (-not $resolvedSimfile.StartsWith($songDirectory + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The supplied simfile is outside the queue record song directory.'
}

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Read-Queue {
    [IO.File]::ReadAllText($queueFile, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
}

$lockHash = [Security.Cryptography.SHA256]::Create()
try {
    $lockBytes = [Text.Encoding]::UTF8.GetBytes($queueFile.ToLowerInvariant())
    $lockId = ([BitConverter]::ToString($lockHash.ComputeHash($lockBytes))).Replace('-', '')
} finally { $lockHash.Dispose() }
$queueMutex = [Threading.Mutex]::new($false, "Local\ThraxOS-BackgroundQueue-$lockId")
$queueLockTaken = $false

try {
    try { $queueLockTaken = $queueMutex.WaitOne([TimeSpan]::FromSeconds(60)) }
    catch [Threading.AbandonedMutexException] { $queueLockTaken = $true }
    if (-not $queueLockTaken) { throw "Timed out waiting for the background queue lock: $queueFile" }

    $document = Read-Queue
    $matches = @($document.songs | Where-Object { $_.songPath -eq $SongPath -and $_.fingerprint -eq $Fingerprint })
    if ($matches.Count -ne 1) { throw 'The exact current queue fingerprint was not found.' }
    $record = $matches[0]
    if ($record.status -ne 'pending' -or $record.pendingAction -ne 'awaiting-install-decision') {
        throw 'The exact queue record is not awaiting an install decision.'
    }
    if ([string]::IsNullOrWhiteSpace($record.previewPath) -or [string]::IsNullOrWhiteSpace($record.previewSha256)) {
        throw 'The queue record has no exact preview binding.'
    }
    $preview = (Resolve-Path -LiteralPath $record.previewPath).Path
    if ($preview.StartsWith($songDirectory + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'The approved preview must remain staged outside the live song directory.'
    }
    $previewSha256 = Get-Sha256 $preview
    if ($previewSha256 -cne $record.previewSha256) { throw 'The queue-bound approved preview hash changed.' }

    $simRelative = $resolvedSimfile.Substring($songDirectory.Length + 1).Replace('\', '/')
    $selectedSimRecord = @($record.simfiles | Where-Object { $_.path -ceq $simRelative })
    if ($selectedSimRecord.Count -ne 1) { throw 'The supplied simfile is not present in the exact queue fingerprint.' }
    foreach ($simRecord in @($record.simfiles)) {
        $simPath = [IO.Path]::GetFullPath((Join-Path $songDirectory $simRecord.path))
        if (-not $simPath.StartsWith($songDirectory + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'A queue simfile path escaped the song directory.' }
        if ((Get-Sha256 $simPath) -cne $simRecord.sha256) { throw "Simfile SHA-256 changed before installation: $($simRecord.path)" }
    }

    $installer = Join-Path $PSScriptRoot 'Install-ApprovedBackground.ps1'
    $install = & $installer -Simfile $resolvedSimfile -Preview $preview -Approved `
        -ExpectedPreviewSha256 $record.previewSha256 -ExpectedSourceSha256 $record.sourceSha256 `
        -ExpectedSimfileSha256 $selectedSimRecord[0].sha256 -Width $Width -Height $Height

    $boundPreview = $preview
    if ($install.InstalledSha256 -cne $record.previewSha256) {
        $stageDirectory = Split-Path -Parent $preview
        $installedExtension = [IO.Path]::GetExtension($install.Installed)
        $boundPreview = Join-Path $stageDirectory ("Installed-Approved-$($install.InstalledSha256.Substring(0, 12))$installedExtension")
        if (Test-Path -LiteralPath $boundPreview -PathType Leaf) {
            if ((Get-Sha256 $boundPreview) -cne $install.InstalledSha256) { throw 'The installed-proof staging path already contains different bytes.' }
        } else {
            Copy-Item -LiteralPath $install.Installed -Destination $boundPreview
        }
    }

    $proofNote = "$($DecisionNote.Trim()) Approved preview SHA-256 $($record.previewSha256). Installed SHA-256 $($install.InstalledSha256) using $($install.InstallMode); rollback $([IO.Path]::GetFileName($install.Backup)) preserves original SHA-256 $($install.OriginalSha256)."
    $queueHelper = Join-Path $PSScriptRoot 'Update-BackgroundQueue.ps1'
    & $queueHelper -PackPath $pack -QueuePath $queueFile -SetStatus installed -SongPath $SongPath -Fingerprint $Fingerprint -PreviewPath $boundPreview -DecisionNote $proofNote | Out-Null
    & $queueHelper -PackPath $pack -QueuePath $queueFile -Refresh | Out-Null

    $updated = Read-Queue
    $current = @($updated.songs | Where-Object { $_.songPath -eq $SongPath })
    if ($current.Count -ne 1) { throw 'Post-install queue validation did not find one exact song record.' }
    if ($current[0].status -ne 'installed') { throw 'The installed decision did not survive queue refresh.' }
    if ($current[0].sourceSha256 -cne $install.InstalledSha256 -or $current[0].previewSha256 -cne $install.InstalledSha256) {
        throw 'Post-install queue source/preview proof does not match the installed file.'
    }

    [pscustomobject]@{
        SongPath = $SongPath
        PreviousFingerprint = $Fingerprint
        CurrentFingerprint = $current[0].fingerprint
        QueueStatus = $current[0].status
        ApprovedPreview = $preview
        ApprovedPreviewSha256 = $record.previewSha256
        QueueProofPreview = $boundPreview
        QueueProofPreviewSha256 = $current[0].previewSha256
        Installed = $install.Installed
        InstalledSha256 = $install.InstalledSha256
        InstallMode = $install.InstallMode
        Backup = $install.Backup
        BackupSha256 = $install.BackupSha256
        OriginalSha256 = $install.OriginalSha256
        Simfile = $install.Simfile
        SimfileSha256 = $install.SimfileSha256
        BeforeDimensions = "$($install.OriginalWidth) x $($install.OriginalHeight)"
        BeforeAspectRatio = $install.OriginalAspectRatio
        AfterDimensions = "$($install.Width) x $($install.Height)"
        AfterAspectRatio = $install.AspectRatio
        ITGManiaClosedVerified = $install.ITGManiaClosedVerified
        RestartedITGmania = $install.RestartedITGmania
    }
} finally {
    if ($queueLockTaken) { $queueMutex.ReleaseMutex() }
    $queueMutex.Dispose()
}
