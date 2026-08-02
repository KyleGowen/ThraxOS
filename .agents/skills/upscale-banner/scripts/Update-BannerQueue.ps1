[CmdletBinding()]
param(
    [string]$PackPath = 'C:\Games\ITGmania\Songs\Misc. Collected',
    [string]$QueuePath,
    [switch]$Refresh,
    [switch]$SelectNext,
    [switch]$ReturnToQueue,
    [ValidateSet('eligible', 'pending', 'installed', 'denied')][string]$SetStatus,
    [string]$SongPath,
    [string]$Fingerprint,
    [string]$PreviewPath,
    [ValidateSet('generation-failed', 'prompt-error', 'preview-rejected')][string]$AttemptOutcome,
    [string]$AttemptNote
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
if (-not $QueuePath) { $QueuePath = Join-Path $repositoryRoot 'memory\banner-upscale-queue.json' }
$targetWidth = 836
$targetHeight = 328
$validStatuses = @('eligible', 'ineligible', 'pending', 'installed', 'denied')

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
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
    $simParts = @()
    foreach ($sim in $simfiles) {
        $text = [IO.File]::ReadAllText($sim.FullName)
        $matches = [regex]::Matches($text, '(?im)^#BANNER\s*:\s*([^;\r\n]+)\s*;')
        if ($matches.Count -eq 1) { $references += $matches[0].Groups[1].Value.Trim() }
        else { $references += $null }
        $simParts += "$($sim.Name):$(Get-Sha256 $sim.FullName)"
    }

    $uniqueReferences = @($references | Where-Object { $_ } | Sort-Object -Unique)
    $bannerReference = if ($uniqueReferences.Count -eq 1 -and $references.Count -eq $simfiles.Count) { $uniqueReferences[0] } else { $null }
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
    }
}

$pack = (Resolve-Path -LiteralPath $PackPath).Path
$queueFile = [IO.Path]::GetFullPath($QueuePath)
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
    if (-not $SongPath -or -not $Fingerprint) { throw '-SetStatus requires -SongPath and -Fingerprint.' }
    $matches = @($existing.songs | Where-Object { $_.songPath -eq $SongPath -and $_.fingerprint -eq $Fingerprint })
    if ($matches.Count -ne 1) { throw 'The exact song path and fingerprint were not found; refresh and reassess instead of updating stale content.' }
    $record = $matches[0]
    if ($SetStatus -eq 'pending' -and $record.status -ne 'eligible' -and $record.status -ne 'pending') { throw "Cannot mark status '$($record.status)' as pending." }
    if ($SetStatus -in @('installed', 'denied') -and $record.status -ne 'pending') { throw "Only a pending exact fingerprint can be marked $SetStatus." }
    if ($PreviewPath) {
        $resolvedPreview = (Resolve-Path -LiteralPath $PreviewPath).Path
        $record.previewPath = $resolvedPreview
        $record.previewSha256 = Get-Sha256 $resolvedPreview
    } elseif ($SetStatus -in @('installed', 'denied') -and (-not $record.previewSha256)) {
        throw "Status '$SetStatus' requires a recorded exact preview."
    }
    $record.status = $SetStatus
    $record.processedAt = if ($SetStatus -eq 'eligible') { $null } else { (Get-Date).ToUniversalTime().ToString('o') }
    if ($SetStatus -eq 'pending') {
        if ($record.PSObject.Properties.Name -contains 'lastAttemptedAt') { $record.lastAttemptedAt = $record.processedAt }
        else { $record | Add-Member -NotePropertyName lastAttemptedAt -NotePropertyValue $record.processedAt }
    }
    $record.pendingAction = if ($SetStatus -eq 'pending' -and $record.previewSha256) { 'awaiting-install-decision' } elseif ($SetStatus -eq 'pending') { 'generate-preview' } else { $null }
    if ($SetStatus -eq 'eligible') { $record.previewPath = $null; $record.previewSha256 = $null }
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
