[CmdletBinding()]
param(
    [string]$PackPath = 'C:\Games\ITGmania\Songs\Misc. Collected',
    [string]$QueuePath,
    [switch]$Refresh,
    [switch]$SelectNext,
    [switch]$ReturnToQueue,
    [switch]$RecordInstalledContent,
    [ValidateSet('eligible', 'pending', 'installed', 'denied', 'skipped')][string]$SetStatus,
    [string]$SongPath,
    [string]$Fingerprint,
    [string]$PreviewPath,
    [ValidateSet('generation-failed', 'output-handling-error', 'prompt-error', 'preview-rejected')][string]$AttemptOutcome,
    [string]$AttemptNote,
    [string]$DecisionNote
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
if (-not $QueuePath) { $QueuePath = Join-Path $repositoryRoot 'memory\banner-upscale-queue.json' }
$targetWidth = 836
$targetHeight = 328
$validStatuses = @('eligible', 'ineligible', 'pending', 'installed', 'denied', 'skipped')

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Test-ImageFullyOpaque($Image) {
    if (-not [Drawing.Image]::IsAlphaPixelFormat($Image.PixelFormat)) { return $true }
    $copy = New-Object Drawing.Bitmap $Image.Width, $Image.Height, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $graphics = [Drawing.Graphics]::FromImage($copy)
        try {
            $graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.DrawImageUnscaled($Image, 0, 0)
        } finally { $graphics.Dispose() }
        $rect = New-Object Drawing.Rectangle 0, 0, $copy.Width, $copy.Height
        $data = $copy.LockBits($rect, [Drawing.Imaging.ImageLockMode]::ReadOnly, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $bytes = New-Object byte[] ([Math]::Abs($data.Stride) * $data.Height)
            [Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
            for ($index = 3; $index -lt $bytes.Length; $index += 4) {
                if ($bytes[$index] -ne 255) { return $false }
            }
            return $true
        } finally { $copy.UnlockBits($data) }
    } finally { $copy.Dispose() }
}

function Get-InstallRenderSha256([string]$Preview, [int]$Width, [int]$Height) {
    Add-Type -AssemblyName System.Drawing
    $input = [Drawing.Image]::FromFile($Preview)
    try {
        $targetPixelFormat = if (Test-ImageFullyOpaque $input) {
            [Drawing.Imaging.PixelFormat]::Format24bppRgb
        } else {
            [Drawing.Imaging.PixelFormat]::Format32bppArgb
        }
        $bitmap = New-Object Drawing.Bitmap $Width, $Height, $targetPixelFormat
        try {
            $graphics = [Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($input, 0, 0, $Width, $Height)
                $stream = New-Object IO.MemoryStream
                try {
                    $bitmap.Save($stream, [Drawing.Imaging.ImageFormat]::Png)
                    $sha = [Security.Cryptography.SHA256]::Create()
                    try { return ([BitConverter]::ToString($sha.ComputeHash($stream.ToArray()))).Replace('-', '') }
                    finally { $sha.Dispose() }
                } finally { $stream.Dispose() }
            } finally { $graphics.Dispose() }
        } finally { $bitmap.Dispose() }
    } finally { $input.Dispose() }
}

function Get-RelativePath([string]$BasePath, [string]$ChildPath) {
    $base = [IO.Path]::GetFullPath($BasePath).TrimEnd('\') + '\'
    $child = [IO.Path]::GetFullPath($ChildPath)
    if (-not $child.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)) { throw "Path is outside base directory: $child" }
    $child.Substring($base.Length).Replace('\', '/')
}

function Get-ImageInfo([string]$Path) {
    Add-Type -AssemblyName System.Drawing
    try {
        $image = [Drawing.Image]::FromFile($Path)
        try { return [pscustomobject]@{ Width = $image.Width; Height = $image.Height } }
        finally { $image.Dispose() }
    } catch { return $null }
}

function Write-QueueDocument([object]$Document, [string]$Path) {
    $json = $Document | ConvertTo-Json -Depth 8
    $temporary = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temporary, $json + "`n", [Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temporary -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    }
}

function Get-FallbackImage([string]$SongPath) {
    $images = foreach ($file in Get-ChildItem -LiteralPath $SongPath -File) {
        if ($file.Extension -notin @('.png', '.jpg', '.jpeg', '.bmp', '.gif')) { continue }
        $info = Get-ImageInfo $file.FullName
        if (-not $info) { continue }
        $ratio = if ($info.Height) { $info.Width / $info.Height } else { 0 }
        $nameHint = $file.BaseName -match '(?i)(banner|(^|[-_ ])bn($|[-_ ]))'
        if ($nameHint -or $ratio -ge 2.5) {
            [pscustomobject]@{ File = $file; Info = $info; NameHint = $nameHint; Area = $info.Width * $info.Height }
        }
    }
    $images | Sort-Object @{ Expression = 'NameHint'; Descending = $true }, @{ Expression = 'Area'; Descending = $true }, @{ Expression = { $_.File.Name } } | Select-Object -First 1
}

function Get-Assessment([IO.DirectoryInfo]$Song, [string]$PackRoot, [string]$Now) {
    $relative = Get-RelativePath $PackRoot $Song.FullName
    $simfiles = @(Get-ChildItem -LiteralPath $Song.FullName -File | Where-Object Extension -in @('.sm', '.ssc') | Sort-Object Name)
    $references = @()
    $allSimfilesHaveOneBannerReference = $true
    $simParts = @()
    foreach ($sim in $simfiles) {
        $text = [IO.File]::ReadAllText($sim.FullName)
        $matches = [regex]::Matches($text, '(?im)^#BANNER\s*:\s*([^;\r\n]+)\s*;')
        if ($matches.Count -eq 1) {
            $reference = $matches[0].Groups[1].Value.Trim()
            if ([string]::IsNullOrWhiteSpace($reference)) { $allSimfilesHaveOneBannerReference = $false }
            else { $references += $reference }
        } else {
            $allSimfilesHaveOneBannerReference = $false
        }
        $simParts += "$($sim.Name):$(Get-Sha256 $sim.FullName)"
    }

    $uniqueReferences = @($references | Where-Object { $_ } | Sort-Object -Unique)
    $bannerReference = if ($allSimfilesHaveOneBannerReference -and $uniqueReferences.Count -eq 1 -and $references.Count -eq $simfiles.Count) { $uniqueReferences[0] } else { $null }
    $sourcePath = $null
    $sourceInfo = $null
    $usedFallback = $false
    $reason = $null
    $eligible = $false

    if ($simfiles.Count -eq 0) { $reason = 'No .sm or .ssc file.' }
    elseif (-not $bannerReference) { $reason = 'Simfiles have a missing, ambiguous, or inconsistent #BANNER reference.' }
    else {
        $candidate = [IO.Path]::GetFullPath((Join-Path $Song.FullName $bannerReference))
        $songRoot = [IO.Path]::GetFullPath($Song.FullName).TrimEnd('\') + '\'
        if (-not $candidate.StartsWith($songRoot, [StringComparison]::OrdinalIgnoreCase)) {
            $reason = '#BANNER resolves outside the song directory.'
        } elseif (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $sourcePath = $candidate
            $sourceInfo = Get-ImageInfo $candidate
            if (-not $sourceInfo) { $reason = 'Referenced banner does not decode.' }
            elseif ($sourceInfo.Width -lt $targetWidth -or $sourceInfo.Height -lt $targetHeight) { $eligible = $true; $reason = 'Referenced banner is below the 836 x 328 host convention.' }
            else { $reason = 'Referenced banner already meets the 836 x 328 host convention.' }
        } else {
            $fallback = Get-FallbackImage $Song.FullName
            if ($fallback) {
                $sourcePath = $fallback.File.FullName
                $sourceInfo = $fallback.Info
                $usedFallback = $true
                $eligible = $true
                $reason = 'Referenced banner is missing; a decodable banner-shaped fallback is available.'
            } else { $reason = 'Referenced banner is missing and no decodable banner-shaped fallback was found.' }
        }
    }

    $sourceRelative = if ($sourcePath) { Get-RelativePath $Song.FullName $sourcePath } else { $null }
    $sourceHash = if ($sourcePath) { Get-Sha256 $sourcePath } else { $null }
    $fingerprintText = @($relative, ($simParts -join '|'), $bannerReference, $sourceRelative, $sourceHash) -join "`n"
    $bytes = [Text.Encoding]::UTF8.GetBytes($fingerprintText)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $fingerprint = ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '') } finally { $sha.Dispose() }

    [ordered]@{
        songPath = $relative
        fingerprint = $fingerprint
        simfiles = @($simParts | ForEach-Object { $name, $hash = $_ -split ':', 2; [ordered]@{ path = $name; sha256 = $hash } })
        bannerReference = $bannerReference
        sourcePath = $sourceRelative
        sourceSha256 = $sourceHash
        sourceWidth = if ($sourceInfo) { $sourceInfo.Width } else { $null }
        sourceHeight = if ($sourceInfo) { $sourceInfo.Height } else { $null }
        usedFallback = $usedFallback
        observedAt = $Now
        assessedAt = $Now
        eligible = $eligible
        reason = $reason
        status = if ($eligible) { 'eligible' } else { 'ineligible' }
        processedAt = $null
        lastAttemptedAt = $null
        pendingAction = $null
        previewPath = $null
        previewSha256 = $null
        attemptHistory = @()
        decisionHistory = @()
    }
}

$pack = (Resolve-Path -LiteralPath $PackPath).Path
$queueFile = [IO.Path]::GetFullPath($QueuePath)
$lockHash = [Security.Cryptography.SHA256]::Create()
try {
    $lockBytes = [Text.Encoding]::UTF8.GetBytes($queueFile.ToLowerInvariant())
    $lockId = ([BitConverter]::ToString($lockHash.ComputeHash($lockBytes))).Replace('-', '')
} finally {
    $lockHash.Dispose()
}
$queueMutex = [Threading.Mutex]::new($false, "Local\ThraxOS-BannerQueue-$lockId")
$queueLockTaken = $false
try {
    try {
        $queueLockTaken = $queueMutex.WaitOne([TimeSpan]::FromSeconds(60))
    } catch [Threading.AbandonedMutexException] {
        $queueLockTaken = $true
    }
    if (-not $queueLockTaken) { throw "Timed out waiting for the banner queue lock: $queueFile" }

$existing = $null
if (Test-Path -LiteralPath $queueFile -PathType Leaf) {
    $existing = Get-Content -LiteralPath $queueFile -Raw | ConvertFrom-Json
}
if (-not $existing) { $existing = [pscustomobject]@{ schemaVersion = 1; packPath = 'C:\Games\ITGmania\Songs\Misc. Collected'; generatedAt = $null; songs = @() } }

if ($Refresh) {
    $now = (Get-Date).ToUniversalTime().ToString('o')
    $oldByPath = @{}
    foreach ($item in @($existing.songs)) { $oldByPath[$item.songPath] = $item }
    $songs = @()
    $changed = $false
    foreach ($dir in Get-ChildItem -LiteralPath $pack -Directory | Sort-Object Name) {
        $fresh = Get-Assessment $dir $pack $now
        $old = $oldByPath[$fresh.songPath]
        if ($old -and $old.fingerprint -eq $fresh.fingerprint) {
            if ($old.status -notin $validStatuses) { throw "Invalid status '$($old.status)' for $($old.songPath)." }
            $songs += $old
        } elseif ($old -and $old.status -eq 'installed' -and
                  ($old.PSObject.Properties.Name -contains 'installedSourceSha256') -and
                  $old.installedSourceSha256 -eq $fresh.sourceSha256) {
            $fresh.status = 'installed'
            $fresh.reason = 'The exact owner-approved preview is installed.'
            $fresh.processedAt = $old.processedAt
            $fresh.lastAttemptedAt = $old.lastAttemptedAt
            $fresh.previewPath = $old.previewPath
            $fresh.previewSha256 = $old.previewSha256
            $fresh.attemptHistory = @($old.attemptHistory | Where-Object { $_ })
            $fresh.decisionHistory = @($old.decisionHistory | Where-Object { $_ })
            $fresh['installedSourceSha256'] = $old.installedSourceSha256
            $songs += [pscustomobject]$fresh
            $changed = $true
        } else {
            $songs += [pscustomobject]$fresh
            $changed = $true
        }
    }
    if (@($existing.songs).Count -ne $songs.Count) { $changed = $true }
    if ($changed) {
        $document = [ordered]@{ schemaVersion = 1; packPath = 'C:\Games\ITGmania\Songs\Misc. Collected'; generatedAt = $now; songs = $songs }
        $parent = Split-Path -Parent $queueFile
        if (-not (Test-Path -LiteralPath $parent)) { throw "Queue parent does not exist: $parent" }
        Write-QueueDocument $document $queueFile
        $existing = [pscustomobject]$document
    }
}

if ($SetStatus) {
    if ($RecordInstalledContent -and $SetStatus -ne 'installed') { throw '-RecordInstalledContent can only be combined with -SetStatus installed.' }
    if (-not $SongPath -or -not $Fingerprint) { throw '-SetStatus requires -SongPath and -Fingerprint.' }
    $matches = @($existing.songs | Where-Object { $_.songPath -eq $SongPath -and $_.fingerprint -eq $Fingerprint })
    if ($matches.Count -ne 1) { throw 'The exact song path and fingerprint were not found; refresh and reassess instead of updating stale content.' }
    $record = $matches[0]
    if ($SetStatus -eq 'pending' -and $record.status -ne 'eligible' -and $record.status -ne 'pending') { throw "Cannot mark status '$($record.status)' as pending." }
    $recordingInstalledContent = $SetStatus -eq 'installed' -and $RecordInstalledContent
    $reprovingInstalledContent = $recordingInstalledContent -and $record.status -eq 'installed'
    if ($SetStatus -in @('installed', 'denied') -and $record.status -ne 'pending' -and
        -not ($recordingInstalledContent -and $record.status -in @('ineligible', 'installed'))) { throw "Only a pending exact fingerprint can be marked $SetStatus." }
    if ($SetStatus -eq 'skipped' -and $record.status -notin @('eligible', 'pending')) { throw "Only an eligible or pending exact fingerprint can be marked skipped." }
    if ($SetStatus -in @('installed', 'denied', 'skipped') -and [string]::IsNullOrWhiteSpace($DecisionNote)) { throw "Status '$SetStatus' requires a nonblank -DecisionNote that captures the owner's outcome and any reasoning provided." }
    if ($recordingInstalledContent -and [string]::IsNullOrWhiteSpace($PreviewPath)) { throw '-RecordInstalledContent requires the exact approved -PreviewPath.' }
    if ($PreviewPath) {
        $resolvedPreview = (Resolve-Path -LiteralPath $PreviewPath).Path
        $record.previewPath = $resolvedPreview
        $record.previewSha256 = Get-Sha256 $resolvedPreview
    } elseif ($SetStatus -in @('installed', 'denied') -and (-not $record.previewSha256)) {
        throw "Status '$SetStatus' requires a recorded exact preview."
    }
    if ($SetStatus -eq 'installed') {
        $songDirectory = [IO.Path]::GetFullPath((Join-Path $pack $record.songPath)).TrimEnd('\')
        if (-not (Test-Path -LiteralPath $songDirectory -PathType Container)) { throw 'The installed song directory no longer exists.' }
        if ([string]::IsNullOrWhiteSpace($record.sourcePath)) { throw 'The installed record has no contained source path.' }
        $freshInstalled = Get-Assessment (Get-Item -LiteralPath $songDirectory) $pack ((Get-Date).ToUniversalTime().ToString('o'))
        $simfilesUnchanged = ((@($freshInstalled.simfiles) | ConvertTo-Json -Compress) -ceq (@($record.simfiles) | ConvertTo-Json -Compress))
        $fallbackBecameReferencedTarget = $record.usedFallback -and -not $freshInstalled.usedFallback -and
            $freshInstalled.sourcePath -ceq $freshInstalled.bannerReference -and
            $freshInstalled.bannerReference -ceq $record.bannerReference
        if ($freshInstalled.bannerReference -cne $record.bannerReference -or -not $simfilesUnchanged -or
            ($freshInstalled.sourcePath -cne $record.sourcePath -and -not $fallbackBecameReferencedTarget)) {
            throw 'The simfile or banner reference changed before the installed-content decision could be recorded.'
        }
        $installedSource = [IO.Path]::GetFullPath((Join-Path $songDirectory $freshInstalled.sourcePath))
        if (-not $installedSource.StartsWith($songDirectory + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'The installed source path escaped the song directory.' }
        if (-not (Test-Path -LiteralPath $installedSource -PathType Leaf)) { throw 'The installed source file is missing.' }
        $installedSourceSha256 = Get-Sha256 $installedSource
        $expectedInstalledSha256 = Get-InstallRenderSha256 $record.previewPath $targetWidth $targetHeight
        if ($installedSourceSha256 -cne $expectedInstalledSha256) { throw 'The live banner is not the deterministic installed rendering of the exact approved preview.' }
        if ($record.PSObject.Properties.Name -contains 'installedSourceSha256') { $record.installedSourceSha256 = $installedSourceSha256 }
        else { $record | Add-Member -NotePropertyName installedSourceSha256 -NotePropertyValue $installedSourceSha256 }
        $record.reason = 'The exact owner-approved preview is installed.'
    }
    $record.status = $SetStatus
    $record.processedAt = if ($SetStatus -eq 'eligible') { $null } elseif ($reprovingInstalledContent) { $record.processedAt } else { (Get-Date).ToUniversalTime().ToString('o') }
    if ($SetStatus -eq 'pending') {
        if ($record.PSObject.Properties.Name -contains 'lastAttemptedAt') { $record.lastAttemptedAt = $record.processedAt }
        else { $record | Add-Member -NotePropertyName lastAttemptedAt -NotePropertyValue $record.processedAt }
    }
    $record.pendingAction = if ($SetStatus -eq 'pending' -and $record.previewSha256) { 'awaiting-install-decision' } elseif ($SetStatus -eq 'pending') { 'generate-preview' } else { $null }
    if ($SetStatus -eq 'eligible') { $record.previewPath = $null; $record.previewSha256 = $null }
    if ($SetStatus -in @('installed', 'denied', 'skipped') -and -not $reprovingInstalledContent) {
        $decisions = @($record.decisionHistory | Where-Object { $_ })
        $decisions += [pscustomobject][ordered]@{
            recordedAt = $record.processedAt
            outcome = $SetStatus
            note = $DecisionNote.Trim()
            previewPath = $record.previewPath
            previewSha256 = $record.previewSha256
        }
        if ($record.PSObject.Properties.Name -contains 'decisionHistory') { $record.decisionHistory = $decisions }
        else { $record | Add-Member -NotePropertyName decisionHistory -NotePropertyValue $decisions }
    }
    $existing.generatedAt = (Get-Date).ToUniversalTime().ToString('o')
    Write-QueueDocument $existing $queueFile
}

if ($ReturnToQueue) {
    if ($SetStatus) { throw '-ReturnToQueue cannot be combined with -SetStatus.' }
    if (-not $SongPath -or -not $Fingerprint) { throw '-ReturnToQueue requires -SongPath and -Fingerprint.' }
    if (-not $AttemptOutcome -or [string]::IsNullOrWhiteSpace($AttemptNote)) { throw '-ReturnToQueue requires -AttemptOutcome and a nonblank -AttemptNote.' }
    $matches = @($existing.songs | Where-Object { $_.songPath -eq $SongPath -and $_.fingerprint -eq $Fingerprint })
    if ($matches.Count -ne 1) { throw 'The exact song path and fingerprint were not found; refresh and reassess instead of updating stale content.' }
    $record = $matches[0]
    if ($record.status -ne 'pending') { throw "Only a pending exact fingerprint can be returned to the queue; current status is '$($record.status)'." }
    $history = @($record.attemptHistory | Where-Object { $_ })
    $returnedAt = (Get-Date).ToUniversalTime().ToString('o')
    $history += [pscustomobject][ordered]@{
        recordedAt = $returnedAt
        outcome = $AttemptOutcome
        note = $AttemptNote.Trim()
        priorProcessedAt = $record.processedAt
        discardedPreviewPath = $record.previewPath
        discardedPreviewSha256 = $record.previewSha256
    }
    if ($record.PSObject.Properties.Name -contains 'attemptHistory') { $record.attemptHistory = $history }
    else { $record | Add-Member -NotePropertyName attemptHistory -NotePropertyValue $history }
    if ($record.PSObject.Properties.Name -contains 'lastAttemptedAt') { $record.lastAttemptedAt = $returnedAt }
    else { $record | Add-Member -NotePropertyName lastAttemptedAt -NotePropertyValue $returnedAt }
    $record.status = 'eligible'
    $record.processedAt = $null
    $record.pendingAction = $null
    $record.previewPath = $null
    $record.previewSha256 = $null
    $existing.generatedAt = (Get-Date).ToUniversalTime().ToString('o')
    Write-QueueDocument $existing $queueFile
}

if ($SelectNext) {
    $next = @($existing.songs | Where-Object { $_.eligible -and $_.status -eq 'eligible' } | Sort-Object @{ Expression = { if ($_.lastAttemptedAt -or @($_.attemptHistory | Where-Object { $_ }).Count) { 1 } else { 0 } } }, @{ Expression = { if ($_.lastAttemptedAt) { [datetime]$_.lastAttemptedAt } elseif (@($_.attemptHistory | Where-Object { $_ }).Count) { [datetime](@($_.attemptHistory | Where-Object { $_ } | Select-Object -Last 1)[0].recordedAt) } else { [datetime]::MinValue } } }, @{ Expression = { [datetime]$_.observedAt } }, songPath | Select-Object -First 1)
    if ($next.Count) { $next[0] | ConvertTo-Json -Depth 8 }
    else { [pscustomobject]@{ result = 'no-candidates' } | ConvertTo-Json }
} else {
    $counts = @($existing.songs) | Group-Object status | Sort-Object Name | ForEach-Object { [pscustomobject]@{ status = $_.Name; count = $_.Count } }
    [pscustomobject]@{ queuePath = $queueFile; total = @($existing.songs).Count; counts = $counts } | ConvertTo-Json -Depth 4
}
} finally {
    if ($queueLockTaken) { $queueMutex.ReleaseMutex() }
    $queueMutex.Dispose()
}
