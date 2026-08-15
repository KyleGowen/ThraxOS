[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$scriptPath = Join-Path $PSScriptRoot 'Normalize-GeneratedBackgroundPreview.ps1'
$systemTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
$testRoot = Join-Path $systemTemp ('thraxos-generate-background-test-' + [Guid]::NewGuid().ToString('N'))
$resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
if (-not ($resolvedTestRoot + '\').StartsWith($systemTemp, [StringComparison]::OrdinalIgnoreCase) -or
    -not ([IO.Path]::GetFileName($resolvedTestRoot)).StartsWith('thraxos-generate-background-test-', [StringComparison]::Ordinal)) {
    throw 'Refusing to use an unexpected test directory.'
}

New-Item -ItemType Directory -Path $resolvedTestRoot -Force | Out-Null
try {
    $inputPath = Join-Path $resolvedTestRoot 'near-16x9-input.png'
    $outputPath = Join-Path $resolvedTestRoot 'normalized-1920x1080.png'
    $mismatchPath = Join-Path $resolvedTestRoot 'four-by-three.png'

    $fixture = New-Object Drawing.Bitmap 1672, 941, ([Drawing.Imaging.PixelFormat]::Format24bppRgb)
    try {
        $fixtureGraphics = [Drawing.Graphics]::FromImage($fixture)
        try {
            $fixtureGraphics.Clear([Drawing.Color]::FromArgb(20, 30, 50))
            $fixtureGraphics.FillRectangle([Drawing.Brushes]::OrangeRed, 80, 80, 700, 420)
            $fixtureGraphics.FillEllipse([Drawing.Brushes]::DeepSkyBlue, 900, 180, 600, 600)
        }
        finally {
            $fixtureGraphics.Dispose()
        }
        $fixture.Save($inputPath, [Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $fixture.Dispose()
    }

    $inputHashBefore = (Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash
    $result = & $scriptPath -InputPath $inputPath -OutputPath $outputPath
    $inputHashAfter = (Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash
    if ($inputHashBefore -ne $inputHashAfter) { throw 'Normalizer changed the raw input.' }
    if ($result.OutputWidth -ne 1920 -or $result.OutputHeight -ne 1080) { throw 'Normalizer returned incorrect dimensions.' }
    if (-not $result.Opaque -or $result.FrameCount -ne 1) { throw 'Normalizer returned incorrect opacity/frame metadata.' }

    $decoded = [Drawing.Image]::FromFile($outputPath)
    try {
        if ($decoded.Width -ne 1920 -or $decoded.Height -ne 1080) { throw 'Normalized file decoded at incorrect dimensions.' }
        if ([Drawing.Image]::IsAlphaPixelFormat($decoded.PixelFormat)) { throw 'Normalized file has an alpha-capable pixel format.' }
    }
    finally {
        $decoded.Dispose()
    }

    $mismatch = New-Object Drawing.Bitmap 640, 480, ([Drawing.Imaging.PixelFormat]::Format24bppRgb)
    try { $mismatch.Save($mismatchPath, [Drawing.Imaging.ImageFormat]::Png) }
    finally { $mismatch.Dispose() }

    $rejectedMismatch = $false
    try {
        & $scriptPath -InputPath $mismatchPath -OutputPath (Join-Path $resolvedTestRoot 'must-not-exist.png') | Out-Null
    }
    catch {
        if ($_.Exception.Message -match 'regenerate or outpaint') { $rejectedMismatch = $true }
        else { throw }
    }
    if (-not $rejectedMismatch) { throw 'Normalizer did not reject a materially non-16:9 image.' }

    $rejectedLivePath = $false
    try {
        & $scriptPath -InputPath $inputPath -OutputPath 'C:\Games\ITGmania\Songs\must-not-write.png' | Out-Null
    }
    catch {
        if ($_.Exception.Message -match 'outside the live ITGMania Songs tree') { $rejectedLivePath = $true }
        else { throw }
    }
    if (-not $rejectedLivePath) { throw 'Normalizer did not reject a live-Songs destination.' }

    [pscustomobject]@{
        Passed = $true
        OutputDimensions = '1920 x 1080'
        OutputOpaque = $true
        RejectedAspectMismatch = $true
        RejectedLiveSongsDestination = $true
        InputPreserved = $true
    }
}
finally {
    if (Test-Path -LiteralPath $resolvedTestRoot) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
