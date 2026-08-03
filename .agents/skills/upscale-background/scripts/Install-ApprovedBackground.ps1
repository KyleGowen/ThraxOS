[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Simfile,
    [Parameter(Mandatory)][string]$Preview,
    [Parameter(Mandatory)][switch]$Approved,
    [string]$ExpectedPreviewSha256,
    [string]$ExpectedSourceSha256,
    [string]$ExpectedSimfileSha256,
    [int]$Width = 1920,
    [int]$Height = 1080
)

$ErrorActionPreference = 'Stop'

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Assert-ExpectedSha256([string]$Actual, [string]$Expected, [string]$Label) {
    if (-not [string]::IsNullOrWhiteSpace($Expected) -and $Actual -cne $Expected.Trim().ToUpperInvariant()) {
        throw "$Label SHA-256 changed before installation. Expected $Expected; found $Actual."
    }
}

function Assert-ITGManiaClosed {
    if (Get-Process -Name 'ITGmania' -ErrorAction SilentlyContinue) {
        throw 'ITGMania is running. Close it before installing an approved background; this script will not terminate it.'
    }
}

if (-not $Approved) { throw 'Explicit -Approved is required after owner approval of the exact preview.' }
Assert-ITGManiaClosed

$inspectScript = Join-Path $PSScriptRoot 'Inspect-Background.ps1'
$presentationScript = Join-Path $PSScriptRoot 'Get-ImagePresentation.ps1'
$inspect = & $inspectScript -Simfile $Simfile
$source = (Resolve-Path -LiteralPath $Preview).Path
$previewPresentation = & $presentationScript -Path $source
if ($previewPresentation.FrameCount -ne 1) { throw 'Approved preview must be a one-frame image.' }
$target = $inspect.BackgroundPath
$beforeReference = $inspect.BackgroundReference
$previewSha256 = Get-Sha256 $source
$originalSha256 = Get-Sha256 $target
$simfileSha256 = Get-Sha256 $inspect.Simfile
Assert-ExpectedSha256 $previewSha256 $ExpectedPreviewSha256 'Approved preview'
Assert-ExpectedSha256 $originalSha256 $ExpectedSourceSha256 'Live source'
Assert-ExpectedSha256 $simfileSha256 $ExpectedSimfileSha256 'Simfile'

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$target.pre-upscale-$stamp.bak"
if (Test-Path -LiteralPath $backup) {
    $backup = "$target.pre-upscale-$stamp-$([guid]::NewGuid().ToString('N').Substring(0, 8)).bak"
}
$temp = Join-Path (Split-Path -Parent $target) ('.background-install-' + [guid]::NewGuid().ToString('N') + $inspect.Extension)
$previewExtension = [IO.Path]::GetExtension($source).ToLowerInvariant()
$byteExactCopy = $previewExtension -ceq $inspect.Extension -and $previewPresentation.Width -eq $Width -and $previewPresentation.Height -eq $Height -and $previewPresentation.IsFullyOpaque
$result = $null

if ($byteExactCopy) {
    Copy-Item -LiteralPath $source -Destination $temp
} else {
    Add-Type -AssemblyName System.Drawing
    $input = [Drawing.Image]::FromFile($source)
    try {
        $bitmap = New-Object Drawing.Bitmap $Width, $Height, ([Drawing.Imaging.PixelFormat]::Format24bppRgb)
        try {
            $graphics = [Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.Clear([Drawing.Color]::Black)
                $graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($input, 0, 0, $Width, $Height)
                switch ($inspect.Extension) {
                    '.png' { $bitmap.Save($temp, [Drawing.Imaging.ImageFormat]::Png) }
                    '.bmp' { $bitmap.Save($temp, [Drawing.Imaging.ImageFormat]::Bmp) }
                    default { $bitmap.Save($temp, [Drawing.Imaging.ImageFormat]::Jpeg) }
                }
            } finally { $graphics.Dispose() }
        } finally { $bitmap.Dispose() }
    } finally { $input.Dispose() }
}

try {
    Assert-ITGManiaClosed
    $prewrite = & $inspectScript -Simfile $Simfile
    if ($prewrite.BackgroundReference -cne $beforeReference -or $prewrite.BackgroundPath -cne $target) {
        throw 'The simfile background reference changed after preflight.'
    }
    Assert-ExpectedSha256 (Get-Sha256 $source) $previewSha256 'Approved preview'
    Assert-ExpectedSha256 (Get-Sha256 $target) $originalSha256 'Live source'
    Assert-ExpectedSha256 (Get-Sha256 $prewrite.Simfile) $simfileSha256 'Simfile'

    Copy-Item -LiteralPath $target -Destination $backup
    $backupSha256 = Get-Sha256 $backup
    if ($backupSha256 -cne $originalSha256) { throw 'Rollback backup hash does not match the original source.' }

    Move-Item -LiteralPath $temp -Destination $target -Force
    $after = & $inspectScript -Simfile $Simfile
    if ($after.Width -ne $Width -or $after.Height -ne $Height -or $after.FrameCount -ne 1) { throw 'Installed background failed static dimension validation.' }
    if ($after.BackgroundReference -cne $beforeReference) { throw '#BACKGROUND reference changed unexpectedly.' }
    $afterSimfileSha256 = Get-Sha256 $after.Simfile
    if ($afterSimfileSha256 -cne $simfileSha256) { throw 'Simfile content changed unexpectedly.' }
    $installedSha256 = Get-Sha256 $target

    $result = [pscustomobject]@{
        Installed = $target
        InstalledSha256 = $installedSha256
        Preview = $source
        PreviewSha256 = $previewSha256
        PreviewWidth = $previewPresentation.Width
        PreviewHeight = $previewPresentation.Height
        PreviewAspectRatio = $previewPresentation.AspectRatio
        PreviewAspectRatioDecimal = $previewPresentation.AspectRatioDecimal
        Backup = $backup
        BackupSha256 = $backupSha256
        OriginalSha256 = $originalSha256
        OriginalWidth = $inspect.Width
        OriginalHeight = $inspect.Height
        OriginalAspectRatio = $inspect.AspectRatio
        OriginalAspectRatioDecimal = $inspect.AspectRatioDecimal
        Simfile = $after.Simfile
        SimfileSha256 = $afterSimfileSha256
        Width = $after.Width
        Height = $after.Height
        AspectRatio = $after.AspectRatio
        AspectRatioDecimal = $after.AspectRatioDecimal
        Encoding = $after.Format
        BackgroundReference = $after.BackgroundReference
        InstallMode = if ($byteExactCopy) { 'byte-exact-copy' } else { 'normalized-render' }
        ITGManiaClosedVerified = $true
        RestartedITGmania = $false
    }
} catch {
    if (Test-Path -LiteralPath $backup) { Copy-Item -LiteralPath $backup -Destination $target -Force }
    throw
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
}

$result
