[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installer = Join-Path $PSScriptRoot 'Install-ApprovedBackground.ps1'
$complete = Join-Path $PSScriptRoot 'Complete-ApprovedBackgroundInstall.ps1'
$queueHelper = Join-Path $PSScriptRoot 'Update-BackgroundQueue.ps1'
$presentationHelper = Join-Path $PSScriptRoot 'Get-ImagePresentation.ps1'
$formatter = Join-Path $PSScriptRoot 'Format-BackgroundPreviewMarkdown.ps1'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('thraxos-background-install-test-' + [guid]::NewGuid().ToString('N'))
$pack = Join-Path $testRoot 'Pack'
$pngSong = Join-Path $pack 'PNG Fixture'
$jpgSong = Join-Path $pack 'JPG Fixture'
$queue = Join-Path $testRoot 'queue.json'
$pngSimfile = Join-Path $pngSong 'fixture.sm'
$jpgSimfile = Join-Path $jpgSong 'fixture.sm'
$pngSource = Join-Path $pngSong 'background.png'
$jpgSource = Join-Path $jpgSong 'background.jpg'
$pngPreview = Join-Path $testRoot 'png-preview.png'
$jpgPreview = Join-Path $testRoot 'jpg-preview.png'
$formatterFixture = Join-Path $testRoot 'Background Preview (A) #1.png'
$queueMutex = $null
$queueLockTaken = $false
$jobs = @()

Add-Type -AssemblyName System.Drawing

function New-TestImage([string]$Path, [int]$Width, [int]$Height, [Drawing.Color]$Color, [Drawing.Imaging.PixelFormat]$PixelFormat = [Drawing.Imaging.PixelFormat]::Format24bppRgb) {
    $bitmap = New-Object Drawing.Bitmap $Width, $Height, $PixelFormat
    try {
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear($Color)
            switch ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
                '.jpg' { $bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Jpeg) }
                default { $bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Png) }
            }
        } finally { $graphics.Dispose() }
    } finally { $bitmap.Dispose() }
}

function Read-Queue {
    [IO.File]::ReadAllText($queue, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
}

try {
    New-Item -ItemType Directory -Path $pngSong -Force | Out-Null
    New-Item -ItemType Directory -Path $jpgSong -Force | Out-Null
    [IO.File]::WriteAllText($pngSimfile, "#TITLE:PNG Fixture;`r`n#ARTIST:Test;`r`n#BACKGROUND:background.png;`r`n#BGCHANGES:;`r`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText($jpgSimfile, "#TITLE:JPG Fixture;`r`n#ARTIST:Test;`r`n#BACKGROUND:background.jpg;`r`n#BGCHANGES:;`r`n", [Text.UTF8Encoding]::new($false))
    New-TestImage $pngSource 640 480 ([Drawing.Color]::DarkBlue)
    New-TestImage $jpgSource 640 480 ([Drawing.Color]::DarkRed)
    New-TestImage $pngPreview 1920 1080 ([Drawing.Color]::CornflowerBlue) ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
    New-TestImage $jpgPreview 1920 1080 ([Drawing.Color]::IndianRed)
    New-TestImage $formatterFixture 1920 1080 ([Drawing.Color]::DarkSlateGray)

    $beforePresentation = & $presentationHelper -Path $pngSource
    $afterPresentation = & $presentationHelper -Path $pngPreview
    if ($beforePresentation.AspectRatio -cne '4:3' -or $beforePresentation.AspectRatioDecimal -ne 1.3333) { throw 'Before aspect-ratio reporting is wrong.' }
    if ($afterPresentation.AspectRatio -cne '16:9' -or $afterPresentation.AspectRatioDecimal -ne 1.7778) { throw 'After aspect-ratio reporting is wrong.' }
    if (-not $afterPresentation.HasAlphaPixelFormat -or -not $afterPresentation.IsFullyOpaque) { throw 'Opaque RGBA presentation detection is wrong.' }

    $formatted = & $formatter -Label 'After A' -Path $formatterFixture
    if ($formatted.InlinePath -match '[\\\s<>]') { throw 'Formatter emitted a renderer-unsafe inline path.' }
    foreach ($escape in @('%20', '%28', '%29', '%23')) {
        if ($formatted.InlinePath -notlike "*$escape*") { throw "Formatter did not emit required escape $escape." }
    }
    if ($formatted.Sha256 -cne (Get-FileHash -LiteralPath $formatterFixture -Algorithm SHA256).Hash) { throw 'Formatter hash does not match the exact fixture.' }
    if ($formatted.Dimensions -cne '1920 x 1080' -or $formatted.AspectRatio -cne '16:9' -or $formatted.AspectRatioDecimal -ne 1.7778) { throw 'Formatter presentation data is wrong.' }
    if ($formatted.Markdown -notmatch [regex]::Escape("![$($formatted.Label)]($($formatted.InlinePath))")) { throw 'Formatter Markdown does not use its renderer-safe inline path.' }

    & $queueHelper -PackPath $pack -QueuePath $queue -Refresh | Out-Null
    $document = Read-Queue
    $pngRecord = @($document.songs | Where-Object songPath -eq 'PNG Fixture')[0]
    $jpgRecord = @($document.songs | Where-Object songPath -eq 'JPG Fixture')[0]
    & $queueHelper -PackPath $pack -QueuePath $queue -SetStatus pending -SongPath $pngRecord.songPath -Fingerprint $pngRecord.fingerprint -PreviewPath $pngPreview | Out-Null
    & $queueHelper -PackPath $pack -QueuePath $queue -SetStatus pending -SongPath $jpgRecord.songPath -Fingerprint $jpgRecord.fingerprint -PreviewPath $jpgPreview | Out-Null

    $pngSourceSha256 = (Get-FileHash -LiteralPath $pngSource -Algorithm SHA256).Hash
    $pngPreviewSha256 = (Get-FileHash -LiteralPath $pngPreview -Algorithm SHA256).Hash
    $pngSimfileSha256 = (Get-FileHash -LiteralPath $pngSimfile -Algorithm SHA256).Hash
    $staleRejected = $false
    try {
        & $installer -Simfile $pngSimfile -Preview $pngPreview -Approved `
            -ExpectedPreviewSha256 ('0' * 64) -ExpectedSourceSha256 $pngSourceSha256 -ExpectedSimfileSha256 $pngSimfileSha256 | Out-Null
    } catch {
        $staleRejected = $_.Exception.Message -like 'Approved preview SHA-256 changed before installation*'
    }
    if (-not $staleRejected) { throw 'Installer did not reject a stale approved-preview hash.' }
    if ((Get-FileHash -LiteralPath $pngSource -Algorithm SHA256).Hash -cne $pngSourceSha256) { throw 'Stale-preview rejection changed the live fixture.' }

    $pngResult = & $complete -Simfile $pngSimfile -SongPath $pngRecord.songPath -Fingerprint $pngRecord.fingerprint `
        -Approved -BackupVerified -DecisionNote 'Owner approved PNG Fixture After A.' -PackPath $pack -QueuePath $queue
    if ($pngResult.InstallMode -cne 'byte-exact-copy') { throw 'Matching opaque 1920x1080 PNG should use the byte-exact fast path.' }
    if ($pngResult.InstalledSha256 -cne $pngPreviewSha256) { throw 'PNG fast path did not install the exact approved bytes.' }
    if ($pngResult.BeforeDimensions -cne '640 x 480' -or $pngResult.BeforeAspectRatio -cne '4:3') { throw 'Completion result omitted correct Before presentation data.' }
    if ($pngResult.AfterDimensions -cne '1920 x 1080' -or $pngResult.AfterAspectRatio -cne '16:9') { throw 'Completion result omitted correct After presentation data.' }
    if ((Get-FileHash -LiteralPath $pngResult.Backup -Algorithm SHA256).Hash -cne $pngSourceSha256) { throw 'PNG rollback does not preserve the original.' }

    $jpgOriginalSha256 = (Get-FileHash -LiteralPath $jpgSource -Algorithm SHA256).Hash
    $jpgApprovedSha256 = (Get-FileHash -LiteralPath $jpgPreview -Algorithm SHA256).Hash
    $jpgResult = & $complete -Simfile $jpgSimfile -SongPath $jpgRecord.songPath -Fingerprint $jpgRecord.fingerprint `
        -Approved -BackupVerified -DecisionNote 'Owner approved JPG Fixture After A.' -PackPath $pack -QueuePath $queue
    if ($jpgResult.InstallMode -cne 'normalized-render') { throw 'PNG-to-JPG installation should use the normalized-render path.' }
    if ($jpgResult.InstalledSha256 -ceq $jpgApprovedSha256) { throw 'Normalized JPG fixture unexpectedly retained PNG bytes.' }
    if ($jpgResult.QueueProofPreviewSha256 -cne $jpgResult.InstalledSha256) { throw 'JPG queue proof was not rebound to the exact installed bytes.' }
    if ((Get-FileHash -LiteralPath $jpgResult.Backup -Algorithm SHA256).Hash -cne $jpgOriginalSha256) { throw 'JPG rollback does not preserve the original.' }

    $document = Read-Queue
    $installed = @($document.songs | Where-Object status -eq 'installed')
    if ($installed.Count -ne 2) { throw 'Both fixture installs should be terminal installed records.' }
    if (@($installed | Where-Object { $_.sourceSha256 -cne $_.previewSha256 }).Count) { throw 'Installed queue proof mismatch remains after completion.' }
    if (@($document.songs | Group-Object songPath | Where-Object Count -ne 1).Count) { throw 'Queue song paths are not unique.' }

    $queueFile = [IO.Path]::GetFullPath($queue)
    $lockHash = [Security.Cryptography.SHA256]::Create()
    try {
        $lockBytes = [Text.Encoding]::UTF8.GetBytes($queueFile.ToLowerInvariant())
        $lockId = ([BitConverter]::ToString($lockHash.ComputeHash($lockBytes))).Replace('-', '')
    } finally { $lockHash.Dispose() }
    $queueMutex = [Threading.Mutex]::new($false, "Local\ThraxOS-BackgroundQueue-$lockId")
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
    Wait-Job -Job $refreshJob -Timeout 20 | Out-Null
    if ($refreshJob.State -ne 'Completed') { throw 'Queue helper did not complete after the mutex was released.' }
    [void]@(Receive-Job -Job $refreshJob)

    [pscustomobject]@{
        Result = 'PASS'
        BeforePresentation = "$($beforePresentation.Dimensions), $($beforePresentation.AspectRatio) ($($beforePresentation.AspectRatioDecimal):1)"
        AfterPresentation = "$($afterPresentation.Dimensions), $($afterPresentation.AspectRatio) ($($afterPresentation.AspectRatioDecimal):1)"
        RendererSafeInlinePath = $formatted.InlinePath
        PngInstallMode = $pngResult.InstallMode
        PngByteExact = ($pngResult.InstalledSha256 -ceq $pngPreviewSha256)
        JpgInstallMode = $jpgResult.InstallMode
        JpgProofRebound = ($jpgResult.QueueProofPreviewSha256 -ceq $jpgResult.InstalledSha256)
        QueueMutexWaitVerified = $true
        InstalledRecords = $installed.Count
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
