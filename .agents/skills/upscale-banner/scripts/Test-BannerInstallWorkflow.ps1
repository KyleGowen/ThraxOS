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
    [IO.File]::WriteAllText($simfile, "#TITLE:Fixture Song;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $songB 'fixture.sm'), "#TITLE:Fixture B;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $songC 'fixture.sm'), "#TITLE:Fixture C;`r`n#BANNER:banner.png;`r`n", [Text.UTF8Encoding]::new($false))
    New-TestPng $source 64 20 ([Drawing.Color]::DarkOrange)
    New-TestPng (Join-Path $songB 'banner.png') 64 20 ([Drawing.Color]::DarkBlue)
    New-TestPng (Join-Path $songC 'banner.png') 64 20 ([Drawing.Color]::DarkGreen)
    New-TestPng $preview 836 328 ([Drawing.Color]::Gold)

    $sourceSha256 = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $previewSha256 = (Get-FileHash -LiteralPath $preview -Algorithm SHA256).Hash
    $simfileSha256 = (Get-FileHash -LiteralPath $simfile -Algorithm SHA256).Hash

    $staleRejected = $false
    try {
        & $installer -Simfile $simfile -Preview $preview -Approved `
            -ExpectedPreviewSha256 ('0' * 64) -ExpectedSourceSha256 $sourceSha256 -ExpectedSimfileSha256 $simfileSha256 | Out-Null
    } catch {
        $staleRejected = $_.Exception.Message -like 'Approved preview SHA-256 changed before installation*'
    }
    if (-not $staleRejected) { throw 'Installer did not reject a stale approved-preview hash.' }
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne $sourceSha256) { throw 'Stale-hash rejection changed the source.' }

    $staleSourceRejected = $false
    try {
        & $installer -Simfile $simfile -Preview $preview -Approved `
            -ExpectedPreviewSha256 $previewSha256 -ExpectedSourceSha256 ('0' * 64) -ExpectedSimfileSha256 $simfileSha256 | Out-Null
    } catch {
        $staleSourceRejected = $_.Exception.Message -like 'Live source SHA-256 changed before installation*'
    }
    if (-not $staleSourceRejected) { throw 'Installer did not reject a stale live-source hash.' }
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne $sourceSha256) { throw 'Stale-source rejection changed the source.' }

    $installed = & $installer -Simfile $simfile -Preview $preview -Approved `
        -ExpectedPreviewSha256 $previewSha256 -ExpectedSourceSha256 $sourceSha256 -ExpectedSimfileSha256 $simfileSha256
    if ($installed.PreviewSha256 -cne $previewSha256) { throw 'Installer preview hash evidence is wrong.' }
    if ($installed.OriginalSha256 -cne $sourceSha256 -or $installed.BackupSha256 -cne $sourceSha256) { throw 'Installer rollback hash evidence is wrong.' }
    if ($installed.SimfileSha256 -cne $simfileSha256) { throw 'Installer changed the simfile.' }
    if (-not $installed.ITGManiaClosedVerified -or $installed.RestartedITGmania) { throw 'Installer process-state evidence is wrong.' }
    if (-not (Test-Path -LiteralPath $installed.Backup -PathType Leaf)) { throw 'Installer did not create the rollback backup.' }

    $decoded = [Drawing.Image]::FromFile($source)
    try {
        if ($decoded.Width -ne 836 -or $decoded.Height -ne 328) { throw 'Installed fixture dimensions are wrong.' }
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
    $document = Get-Content -LiteralPath $queue -Raw | ConvertFrom-Json
    if (@($document.songs).Count -ne 3) { throw 'Fixture queue integrity failed after serialized refresh.' }

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
    $document = Get-Content -LiteralPath $queue -Raw | ConvertFrom-Json
    $pendingFixtures = @($document.songs | Where-Object { $_.songPath -in @('Fixture B', 'Fixture C') -and $_.status -eq 'pending' })
    if ($pendingFixtures.Count -ne 2) { throw 'Serialized concurrent updates lost one fixture transition.' }

    [pscustomobject]@{
        Result = 'PASS'
        StalePreviewRejected = $true
        StaleSourceRejected = $true
        InstalledSha256 = $installed.InstalledSha256
        BackupSha256 = $installed.BackupSha256
        SimfileSha256 = $installed.SimfileSha256
        QueueMutexWaitVerified = $true
        ConcurrentPendingUpdates = $pendingFixtures.Count
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
