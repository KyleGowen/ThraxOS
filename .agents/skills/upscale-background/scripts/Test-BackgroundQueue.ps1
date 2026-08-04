[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$update = Join-Path $scriptRoot 'Update-BackgroundQueue.ps1'
$inspect = Join-Path $scriptRoot 'Inspect-Background.ps1'
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
$working = Join-Path $tempBase ("thrax-background-queue-test-" + [guid]::NewGuid().ToString('N'))
$pack = Join-Path $working 'Pack'
$queue = Join-Path $working 'queue.json'

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function New-Image([string]$Path, [int]$Width, [int]$Height) {
    Add-Type -AssemblyName System.Drawing
    $bitmap = New-Object Drawing.Bitmap($Width, $Height)
    try {
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([Drawing.Color]::FromArgb(24, 48, 72))
        }
        finally {
            $graphics.Dispose()
        }
        $bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $bitmap.Dispose()
    }
}

function New-SimFixture([string]$Name, [string]$Background, [string]$BgChanges, [int]$Width, [int]$Height) {
    $folder = New-Item -ItemType Directory -Path (Join-Path $pack $Name)
    $sim = Join-Path $folder.FullName "$Name.sm"
    [IO.File]::WriteAllText($sim, "#TITLE:$Name;`n#BACKGROUND:$Background;`n#BGCHANGES:$BgChanges;`n", [Text.UTF8Encoding]::new($false))
    if ($Width -gt 0 -and $Height -gt 0) {
        New-Image (Join-Path $folder.FullName $Background) $Width $Height
    }
    $sim
}

function Invoke-Update([string[]]$Arguments) {
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $update @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Update-BackgroundQueue.ps1 failed with exit code $LASTEXITCODE."
    }
    ($output -join "`n")
}

function Read-Queue([string]$Path) {
    [IO.File]::ReadAllText($Path, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
}

try {
    [void](New-Item -ItemType Directory -Path $pack)
    $emptySim = New-SimFixture 'Empty SD' 'bg.png' '' 854 480
    [void](New-SimFixture 'Populated' 'bg.png' '0.000=movie.mp4=1.000=1=0=1===CrossFade==' 640 480)
    [void](New-SimFixture 'Tiny' 'bg.png' '' 320 240)
    [void](New-SimFixture 'Aspect' 'bg.png' '' 1600 1200)
    [void](New-SimFixture 'Soft HD' 'bg.png' '' 1280 720)

    $legacy = New-Item -ItemType Directory -Path (Join-Path $pack 'Legacy')
    [IO.File]::WriteAllText((Join-Path $legacy.FullName 'Legacy.dwi'), '#TITLE:Legacy;', [Text.UTF8Encoding]::new($false))
    New-Image (Join-Path $legacy.FullName 'Legacy-bg.png') 640 480

    $missing = New-Item -ItemType Directory -Path (Join-Path $pack 'Missing')
    [IO.File]::WriteAllText((Join-Path $missing.FullName 'Missing.sm'), "#TITLE:Missing;`n#BACKGROUND:missing.png;`n#BGCHANGES:;`n", [Text.UTF8Encoding]::new($false))
    New-Image (Join-Path $missing.FullName 'fallback-bg.png') 564 278

    $partial = New-Item -ItemType Directory -Path (Join-Path $pack 'Partial Reference')
    [IO.File]::WriteAllText((Join-Path $partial.FullName 'Partial Reference.sm'), "#TITLE:Partial Reference;`n#BACKGROUND:Partial Reference-bg.png;`n#BGCHANGES:;`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $partial.FullName 'Partial Reference.ssc'), "#TITLE:Partial Reference;`n#BACKGROUND:;`n#BGCHANGES:;`n", [Text.UTF8Encoding]::new($false))
    New-Image (Join-Path $partial.FullName 'Partial Reference-bg.png') 640 640

    $selected = Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-Refresh', '-SelectNext') | ConvertFrom-Json
    Assert ($selected.songPath -eq 'Tiny') 'severity ordering should select the broken-or-tiny candidate first'
    Assert ($selected.qualityRank -eq 0) 'the tiny candidate should have quality rank 0'

    [void](Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-SetStatus', 'pending', '-SongPath', $selected.songPath, '-Fingerprint', $selected.fingerprint))
    [void](Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-AwaitOwnerInput', '-SongPath', $selected.songPath, '-Fingerprint', $selected.fingerprint, '-AttemptOutcome', 'generation-failed', '-AttemptNote', 'Two genuine model attempts are exhausted; deterministic fallback needs owner approval.'))
    $afterDeferral = Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-SelectNext') | ConvertFrom-Json
    Assert ($afterDeferral.songPath -eq 'Aspect') 'an exhausted highest-tier candidate awaiting owner input must not starve lower tiers'
    $deferredDocument = Read-Queue $queue
    $deferred = $deferredDocument.songs | Where-Object songPath -eq 'Tiny'
    Assert ($deferred.status -eq 'pending') 'an exhausted candidate should remain pending while awaiting owner input'
    Assert ($deferred.pendingAction -eq 'awaiting-fallback-approval') 'the required owner decision should be explicit and durable'
    Assert (@($deferred.attemptHistory).Count -eq 1) 'deferral should retain a factual attempt-history entry'

    $document = Read-Queue $queue
    Assert ($document.schemaVersion -eq 2) 'queue schema should be version 2'
    $empty = $document.songs | Where-Object songPath -eq 'Empty SD'
    Assert ($empty.status -eq 'eligible') 'empty BGCHANGES metadata should remain eligible'
    Assert ($empty.bgChangesState -eq 'empty') 'empty BGCHANGES metadata should be recorded as empty'
    Assert ($empty.qualityTier -eq 'sd-or-smaller') '854x480 should use the SD quality tier'
    $populated = $document.songs | Where-Object songPath -eq 'Populated'
    Assert ($populated.status -eq 'ineligible') 'populated BGCHANGES must remain ineligible'
    Assert ($populated.bgChangesState -eq 'populated') 'populated BGCHANGES should be recorded explicitly'
    $legacyRecord = $document.songs | Where-Object songPath -eq 'Legacy'
    Assert ($legacyRecord.status -eq 'review-only') 'implicit DWI art should enter the review-only lane'
    Assert ($legacyRecord.reviewCategory -eq 'implicit-legacy') 'legacy review category should be explicit'
    Assert (@($legacyRecord.reviewCandidates).Count -eq 1) 'legacy fixture should expose one review candidate'
    $missingRecord = $document.songs | Where-Object songPath -eq 'Missing'
    Assert ($missingRecord.status -eq 'review-only') 'missing reference with fallback should be review-only'
    Assert ($missingRecord.reviewCategory -eq 'missing-reference-fallback') 'missing fallback category should be explicit'
    $partialRecord = $document.songs | Where-Object songPath -eq 'Partial Reference'
    Assert ($partialRecord.status -eq 'review-only') 'a blank #BACKGROUND in any companion simfile must prevent automatic selection'
    Assert (-not $partialRecord.eligible) 'a partially explicit background set must never be eligible'
    Assert (-not [string]::IsNullOrWhiteSpace($partialRecord.sourceSha256)) 'a safe static source named by one companion should retain source evidence for installed-proof preservation'

    $empty.status = 'skipped'
    $empty.processedAt = (Get-Date).ToUniversalTime().ToString('o')
    $unicodeNote = 'Unicode round trip: caf' + [char]0x00E9 + ' ' + [char]0x00D7 + ' ' + [char]0x2019
    $empty.decisionHistory = @([pscustomobject]@{ recordedAt = $empty.processedAt; outcome = 'skipped'; note = $unicodeNote; previewPath = $null; previewSha256 = $null })
    $empty.fingerprint = 'RULEVERSIONCHANGE'
    $document.schemaVersion = 1
    [IO.File]::WriteAllText($queue, ($document | ConvertTo-Json -Depth 12) + "`n", [Text.UTF8Encoding]::new($false))
    [void](Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-Refresh'))
    $migrated = Read-Queue $queue
    $empty = $migrated.songs | Where-Object songPath -eq 'Empty SD'
    Assert ($empty.status -eq 'skipped') 'an unchanged source should preserve fingerprint-scoped decisions across rule-version fingerprint changes'
    Assert (@($empty.decisionHistory).Count -eq 1) 'decision history should survive an assessment-rule migration'
    Assert ($empty.decisionHistory[0].note -ceq $unicodeNote) 'queue rewrites must preserve UTF-8 text exactly'

    $inspection = & $inspect -Simfile $emptySim
    Assert ($inspection.BgChangesState -eq 'empty') 'the inspector should accept an empty BGCHANGES tag'
    $populatedRejected = $false
    try {
        & $inspect -Simfile (Join-Path $pack 'Populated\Populated.sm') | Out-Null
    }
    catch {
        $populatedRejected = $_.Exception.Message -match 'active BGCHANGES'
    }
    Assert $populatedRejected 'the inspector should reject populated BGCHANGES content'

    $preview = Join-Path $working 'approved.png'
    New-Image $preview 1920 1080
    $empty.status = 'eligible'
    $empty.processedAt = $null
    $empty.decisionHistory = @()
    [IO.File]::WriteAllText($queue, ($migrated | ConvertTo-Json -Depth 12) + "`n", [Text.UTF8Encoding]::new($false))
    [void](Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-SetStatus', 'pending', '-SongPath', $empty.songPath, '-Fingerprint', $empty.fingerprint))
    [void](Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-SetStatus', 'installed', '-SongPath', $empty.songPath, '-Fingerprint', $empty.fingerprint, '-PreviewPath', $preview, '-DecisionNote', 'Disposable fixture approval.'))
    Copy-Item -LiteralPath $preview -Destination (Join-Path $pack 'Empty SD\bg.png') -Force
    [void](Invoke-Update @('-PackPath', $pack, '-QueuePath', $queue, '-Refresh'))
    $refreshed = Read-Queue $queue
    $installed = $refreshed.songs | Where-Object songPath -eq 'Empty SD'
    Assert ($installed.status -eq 'installed') 'installed decision should survive the refreshed fingerprint'
    Assert ($installed.sourceSha256 -eq $installed.previewSha256) 'installed source should match the approved preview hash'

    'Background queue tests passed.'
}
finally {
    $resolvedWorking = [IO.Path]::GetFullPath($working)
    if ($resolvedWorking.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedWorking)) {
        Remove-Item -LiteralPath $resolvedWorking -Recurse -Force
    }
}
