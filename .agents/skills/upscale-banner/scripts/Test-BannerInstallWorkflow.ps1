[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installer = Join-Path $PSScriptRoot 'Install-ApprovedBanner.ps1'
$queueHelper = Join-Path $PSScriptRoot 'Update-BannerQueue.ps1'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('thraxos-banner-install-test-' + [guid]::NewGuid().ToString('N'))
$pack = Join-Path $testRoot 'Pack'
$song = Join-Path $pack 'Fixture Song'
$songB = Join-Path $pack 'Fixture B'
$songC = Join-Path $pack 'Fixture C'
$songD = Join-Path $pack 'Fixture Inconsistent'
$songE = Join-Path $pack 'Fixture Missing Banner'
$queue = Join-Path $testRoot 'queue.json'
$simfile = Join-Path $song 'fixture.sm'
$source = Join-Path $song 'banner.png'
$preview = Join-Path $testRoot 'preview.png'
$queueMutex = $null
$queueLockTaken = $false
$jobs = @()

Add-Type -AssemblyName System.Drawing

function New-TestPng([string]$Path, [int]$Width, [int]$Height, [Drawing.Color]$Color) {
    $bitmap = New-Object Drawing.Bitmap $Width, $Height, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try { $graphics.Clear($Color); $bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Png) }
        finally { $graphics.Dispose() }
    } finally { $bitmap.Dispose() }
}

try {
    New-Item -ItemType Directory -Path $song -Force | Out-Null
    New-Item -ItemType Directory -Path $songB -Force | Out-Null
    New-Item -ItemType Directory -Path $songC -Force | Out-Null
    New-Item -ItemType Directory -Path $songD -Force | Out-Null
    New-Item -ItemType Directory -Path $songE -Force | Out-Null
    [IO.File]::WriteAllText($simfile, "#TITLE:Fixture Song;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $songB 'fixture.sm'), "#TITLE:Fixture B;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $songC 'fixture.sm'), "#TITLE:Fixture C;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $songD 'fixture.sm'), "#TITLE:Fixture Inconsistent;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $songD 'fixture.ssc'), "#TITLE:Fixture Inconsistent;`r`n#BANNER:;`r`n", [Text.UTF8Encoding]::new($false))
    $missingSimfile = Join-Path $songE 'fixture.sm'
    [IO.File]::WriteAllText($missingSimfile, "#TITLE:Fixture Missing Banner;`r`n#ARTIST:Fixture Artist;`r`n#BANNER:missing-banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    New-TestPng $source 64 20 ([Drawing.Color]::DarkOrange)
    New-TestPng (Join-Path $songB 'banner.png') 64 20 ([Drawing.Color]::DarkBlue)
    New-TestPng (Join-Path $songC 'banner.png') 64 20 ([Drawing.Color]::DarkGreen)
    New-TestPng (Join-Path $songD 'banner.png') 64 20 ([Drawing.Color]::DarkRed)
    New-TestPng $preview 836 328 ([Drawing.Color]::Gold)

    $sourceSha256 = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $previewSha256 = (Get-FileHash -LiteralPath $preview -Algorithm SHA256).Hash
    $simfileSha256 = (Get-FileHash -LiteralPath $simfile -Algorithm SHA256).Hash
    $previewDecoded = [Drawing.Image]::FromFile($preview)
    try {
        if (-not [Drawing.Image]::IsAlphaPixelFormat($previewDecoded.PixelFormat)) { throw 'Fixture must exercise fully opaque RGBA input.' }
    } finally { $previewDecoded.Dispose() }

    $staleRejected = $false
    $stalePreviewError = $null
    try {
        & $installer -Simfile $simfile -Preview $preview -Approved `
            -ExpectedPreviewSha256 ('0' * 64) -ExpectedSourceSha256 $sourceSha256 -ExpectedSimfileSha256 $simfileSha256 | Out-Null
    } catch {
        $stalePreviewError = $_.Exception.Message
        $staleRejected = $_.Exception.Message -like 'Approved preview SHA-256 changed before installation*'
    }
    if (-not $staleRejected) { throw "Installer did not reject a stale approved-preview hash. Actual error: $stalePreviewError" }
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne $sourceSha256) { throw 'Stale-hash rejection changed the source.' }

    $staleSourceRejected = $false
    $staleSourceError = $null
    try {
        & $installer -Simfile $simfile -Preview $preview -Approved `
            -ExpectedPreviewSha256 $previewSha256 -ExpectedSourceSha256 ('0' * 64) -ExpectedSimfileSha256 $simfileSha256 | Out-Null
    } catch {
        $staleSourceError = $_.Exception.Message
        $staleSourceRejected = $_.Exception.Message -like 'Live source SHA-256 changed before installation*'
    }
    if (-not $staleSourceRejected) { throw "Installer did not reject a stale live-source hash. Actual error: $staleSourceError" }
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne $sourceSha256) { throw 'Stale-source rejection changed the source.' }

    $installed = & $installer -Simfile $simfile -Preview $preview -Approved `
        -ExpectedPreviewSha256 $previewSha256 -ExpectedSourceSha256 $sourceSha256 -ExpectedSimfileSha256 $simfileSha256
    if ($installed.PreviewSha256 -cne $previewSha256) { throw 'Installer preview hash evidence is wrong.' }
    if ($installed.OriginalSha256 -cne $sourceSha256 -or $installed.BackupSha256 -cne $sourceSha256) { throw 'Installer rollback hash evidence is wrong.' }
    if ($installed.SimfileSha256 -cne $simfileSha256) { throw 'Installer changed the simfile.' }
    if (-not $installed.ITGManiaClosedVerified -or $installed.RestartedITGmania) { throw 'Installer process-state evidence is wrong.' }
    if (-not $installed.OutputOpaque) { throw 'Installer did not preserve the opaque preview as opaque output.' }
    if (-not (Test-Path -LiteralPath $installed.Backup -PathType Leaf)) { throw 'Installer did not create the rollback backup.' }

    $decoded = [Drawing.Image]::FromFile($source)
    try {
        if ($decoded.Width -ne 836 -or $decoded.Height -ne 328) { throw 'Installed fixture dimensions are wrong.' }
        if ([Drawing.Image]::IsAlphaPixelFormat($decoded.PixelFormat)) { throw 'Installed opaque fixture unexpectedly has an alpha pixel format.' }
    } finally { $decoded.Dispose() }

    # Hold the same named mutex as the queue helper and prove another process waits rather than reading stale state.
    $queueFile = [IO.Path]::GetFullPath($queue)
    $lockHash = [Security.Cryptography.SHA256]::Create()
    try {
        $lockBytes = [Text.Encoding]::UTF8.GetBytes($queueFile.ToLowerInvariant())
        $lockId = ([BitConverter]::ToString($lockHash.ComputeHash($lockBytes))).Replace('-', '')
    } finally { $lockHash.Dispose() }
    $queueMutex = [Threading.Mutex]::new($false, "Local\ThraxOS-BannerQueue-$lockId")
    $queueLockTaken = $queueMutex.WaitOne([TimeSpan]::FromSeconds(5))
    if (-not $queueLockTaken) { throw 'Test could not acquire the fixture queue mutex.' }

    $refreshJob = Start-Job -ScriptBlock {
        param($PowerShellPath, $Helper, $PackPath, $QueuePath)
        & $PowerShellPath -NoProfile -ExecutionPolicy Bypass -File $Helper -PackPath $PackPath -QueuePath $QueuePath -Refresh
    } -ArgumentList (Get-Process -Id $PID).Path, $queueHelper, $pack, $queue
    $jobs += $refreshJob
    Start-Sleep -Milliseconds 800
    if ($refreshJob.State -ne 'Running') { throw 'Queue helper did not wait on the held cross-process mutex.' }
    $queueMutex.ReleaseMutex()
    $queueLockTaken = $false
    Wait-Job -Job $refreshJob -Timeout 15 | Out-Null
    if ($refreshJob.State -ne 'Completed') { throw 'Queue helper did not complete after the mutex was released.' }
    [void]@(Receive-Job -Job $refreshJob)
    if (-not (Test-Path -LiteralPath $queue -PathType Leaf)) { throw 'Queue helper did not write the fixture queue.' }
    $document = [IO.File]::ReadAllText($queue, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    if (@($document.songs).Count -ne 5) { throw 'Fixture queue integrity failed after serialized refresh.' }

    $inconsistent = @($document.songs | Where-Object songPath -eq 'Fixture Inconsistent')
    if ($inconsistent.Count -ne 1 -or $inconsistent[0].status -ne 'ineligible') {
        throw 'Queue helper did not reject inconsistent #BANNER declarations across simfiles.'
    }
    if ($inconsistent[0].reason -ne 'Simfiles have a missing, ambiguous, or inconsistent #BANNER reference.') {
        throw 'Queue helper reported the wrong reason for inconsistent #BANNER declarations.'
    }

    $missingCandidate = @($document.songs | Where-Object songPath -eq 'Fixture Missing Banner')
    if ($missingCandidate.Count -ne 1 -or $missingCandidate[0].status -ne 'eligible' -or -not $missingCandidate[0].eligible) {
        throw 'Queue helper did not select a consistently referenced banner that is entirely missing.'
    }
    if ($missingCandidate[0].generationMode -cne 'generate-banner' -or $missingCandidate[0].sourcePath -or $missingCandidate[0].sourceSha256) {
        throw 'Queue helper did not route the source-less missing banner through generate-banner.'
    }
    if ($missingCandidate[0].reason -ne 'Referenced banner is missing and no decodable banner-shaped fallback was found; generate a new banner from verified release art.') {
        throw 'Queue helper reported the wrong source-less generation reason.'
    }

    $missingSimfileSha256 = (Get-FileHash -LiteralPath $missingSimfile -Algorithm SHA256).Hash
    & $queueHelper -PackPath $pack -QueuePath $queue -SetStatus pending -SongPath $missingCandidate[0].songPath -Fingerprint $missingCandidate[0].fingerprint | Out-Null
    $missingInstall = & $installer -Simfile $missingSimfile -Preview $preview -Approved `
        -SourceLessGeneration -ExpectedPreviewSha256 $previewSha256 -ExpectedSimfileSha256 $missingSimfileSha256
    if (-not $missingInstall.CreatedMissingTarget -or $missingInstall.RollbackAction -cne 'RemoveCreatedTarget') {
        throw 'Source-less installation did not report delete-created-target rollback semantics.'
    }
    if ($missingInstall.Backup -or $missingInstall.BackupSha256 -or $missingInstall.BackupSource -or $missingInstall.OriginalSha256) {
        throw 'Source-less installation fabricated original or backup evidence.'
    }
    & $queueHelper -PackPath $pack -QueuePath $queue -SetStatus installed -SongPath $missingCandidate[0].songPath -Fingerprint $missingCandidate[0].fingerprint `
        -PreviewPath $preview -DecisionNote 'Fixture approval for a source-less generated banner.' | Out-Null
    & $queueHelper -PackPath $pack -QueuePath $queue -Refresh | Out-Null
    $document = [IO.File]::ReadAllText($queue, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    $installedMissing = @($document.songs | Where-Object songPath -eq 'Fixture Missing Banner')
    if ($installedMissing.Count -ne 1 -or $installedMissing[0].status -ne 'installed' -or
        $installedMissing[0].installedSourceSha256 -cne $missingInstall.InstalledSha256) {
        throw 'Queue proof did not terminalize the generated missing banner.'
    }

    $unicodeCandidate = @($document.songs | Where-Object songPath -eq 'Fixture B')
    if ($unicodeCandidate.Count -ne 1) { throw 'UTF-8 history fixture candidate is missing.' }
    $unicodeNote = 'Exact visible text is 植松伸夫.'
    & $queueHelper -PackPath $pack -QueuePath $queue -SetStatus pending -SongPath $unicodeCandidate[0].songPath -Fingerprint $unicodeCandidate[0].fingerprint | Out-Null
    & $queueHelper -PackPath $pack -QueuePath $queue -ReturnToQueue -SongPath $unicodeCandidate[0].songPath -Fingerprint $unicodeCandidate[0].fingerprint -AttemptOutcome generation-failed -AttemptNote $unicodeNote | Out-Null
    & $queueHelper -PackPath $pack -QueuePath $queue -Refresh | Out-Null
    $document = [IO.File]::ReadAllText($queue, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    $unicodeRecord = @($document.songs | Where-Object songPath -eq 'Fixture B')
    if ($unicodeRecord.Count -ne 1 -or @($unicodeRecord[0].attemptHistory).Count -ne 1 -or $unicodeRecord[0].attemptHistory[0].note -cne $unicodeNote) {
        throw 'Queue helper did not preserve UTF-8 attempt history exactly.'
    }

    $candidateB = @($document.songs | Where-Object songPath -eq 'Fixture B')
    $candidateC = @($document.songs | Where-Object songPath -eq 'Fixture C')
    if ($candidateB.Count -ne 1 -or $candidateC.Count -ne 1) { throw 'Concurrent-update fixture candidates are missing.' }

    $queueLockTaken = $queueMutex.WaitOne([TimeSpan]::FromSeconds(5))
    if (-not $queueLockTaken) { throw 'Test could not reacquire the fixture queue mutex.' }
    foreach ($candidate in @($candidateB[0], $candidateC[0])) {
        $statusJob = Start-Job -ScriptBlock {
            param($PowerShellPath, $Helper, $PackPath, $QueuePath, $SongPath, $Fingerprint)
            & $PowerShellPath -NoProfile -ExecutionPolicy Bypass -File $Helper -PackPath $PackPath -QueuePath $QueuePath -SetStatus pending -SongPath $SongPath -Fingerprint $Fingerprint
        } -ArgumentList (Get-Process -Id $PID).Path, $queueHelper, $pack, $queue, $candidate.songPath, $candidate.fingerprint
        $jobs += $statusJob
    }
    Start-Sleep -Milliseconds 800
    if (@($jobs | Select-Object -Last 2 | Where-Object State -ne 'Running').Count) { throw 'Concurrent queue updates did not wait on the held mutex.' }
    $queueMutex.ReleaseMutex()
    $queueLockTaken = $false
    foreach ($statusJob in @($jobs | Select-Object -Last 2)) {
        Wait-Job -Job $statusJob -Timeout 30 | Out-Null
        if ($statusJob.State -ne 'Completed') { throw 'A serialized queue update did not complete.' }
        [void]@(Receive-Job -Job $statusJob)
    }
    $document = [IO.File]::ReadAllText($queue, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    $pendingFixtures = @($document.songs | Where-Object { $_.songPath -in @('Fixture B', 'Fixture C') -and $_.status -eq 'pending' })
    if ($pendingFixtures.Count -ne 2) { throw 'Serialized concurrent updates lost one fixture transition.' }

    [pscustomobject]@{
        Result = 'PASS'
        StalePreviewRejected = $true
        StaleSourceRejected = $true
        InstalledSha256 = $installed.InstalledSha256
        BackupSha256 = $installed.BackupSha256
        SimfileSha256 = $installed.SimfileSha256
        InstalledOpaque = $installed.OutputOpaque
        QueueMutexWaitVerified = $true
        QueueUtf8RoundTripVerified = $true
        ConcurrentPendingUpdates = $pendingFixtures.Count
        InconsistentReferencesRejected = $true
        SourceLessGenerationRouted = $true
        SourceLessInstallRollback = $missingInstall.RollbackAction
        QueueSongs = @($document.songs).Count
    }
} finally {
    foreach ($job in @($jobs)) { Remove-Job -Job $job -Force -ErrorAction SilentlyContinue }
    if ($queueLockTaken -and $queueMutex) { $queueMutex.ReleaseMutex() }
    if ($queueMutex) { $queueMutex.Dispose() }
    $tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
    if ($resolvedTestRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedTestRoot)) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
