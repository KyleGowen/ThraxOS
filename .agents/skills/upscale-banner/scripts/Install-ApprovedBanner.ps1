[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Simfile,
    [Parameter(Mandatory)][string]$Preview,
    [Parameter(Mandatory)][switch]$Approved,
    [string]$FallbackOriginal,
    [string]$ExpectedPreviewSha256,
    [string]$ExpectedSourceSha256,
    [string]$ExpectedSimfileSha256,
    [int]$Width = 836,
    [int]$Height = 328
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
        throw 'ITGMania is running. Close it before installing an approved banner; this script will not terminate it.'
    }
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

if (-not $Approved) { throw 'Explicit -Approved is required after owner approval of the exact preview.' }
Assert-ITGManiaClosed

$inspectScript = Join-Path $PSScriptRoot 'Inspect-Banner.ps1'
$inspect = & $inspectScript -Simfile $Simfile -AllowMissing
$source = (Resolve-Path -LiteralPath $Preview).Path
$target = $inspect.BannerPath
$beforeReference = $inspect.BannerReference
$targetExisted = Test-Path -LiteralPath $target -PathType Leaf
$backupSource = $target

if (-not $targetExisted) {
    if ([string]::IsNullOrWhiteSpace($FallbackOriginal)) {
        throw 'The referenced banner is missing; -FallbackOriginal is required for a recoverable installation.'
    }
    $fallback = (Resolve-Path -LiteralPath $FallbackOriginal).Path
    $songRoot = [IO.Path]::GetFullPath((Split-Path -Parent $inspect.Simfile)).TrimEnd('\') + '\'
    if (-not $fallback.StartsWith($songRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Fallback original is outside the song directory.'
    }
    $backupSource = $fallback
}

$previewSha256 = Get-Sha256 $source
$originalSha256 = Get-Sha256 $backupSource
$simfileSha256 = Get-Sha256 $inspect.Simfile
Assert-ExpectedSha256 $previewSha256 $ExpectedPreviewSha256 'Approved preview'
Assert-ExpectedSha256 $originalSha256 $ExpectedSourceSha256 'Live source'
Assert-ExpectedSha256 $simfileSha256 $ExpectedSimfileSha256 'Simfile'

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "$target.pre-upscale-$stamp.bak"
if (Test-Path -LiteralPath $backup) {
    $backup = "$target.pre-upscale-$stamp-$([guid]::NewGuid().ToString('N').Substring(0, 8)).bak"
}
$temp = Join-Path (Split-Path -Parent $target) ('.banner-install-' + [guid]::NewGuid().ToString('N') + '.png')
$result = $null

Add-Type -AssemblyName System.Drawing
$input = [Drawing.Image]::FromFile($source)
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
            $bitmap.Save($temp, [Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $graphics.Dispose()
        }
    } finally {
        $bitmap.Dispose()
    }
} finally {
    $input.Dispose()
}

try {
    # Close the time-of-check/time-of-use gap immediately before the live write.
    Assert-ITGManiaClosed
    $prewrite = & $inspectScript -Simfile $Simfile -AllowMissing
    $prewriteSimfileSha256 = Get-Sha256 $prewrite.Simfile
    if ($prewrite.BannerReference -cne $beforeReference -or $prewrite.BannerPath -cne $target) {
        throw 'The simfile banner reference changed after preflight.'
    }
    Assert-ExpectedSha256 $prewriteSimfileSha256 $simfileSha256 'Simfile'
    $prewriteSourceSha256 = Get-Sha256 $backupSource
    Assert-ExpectedSha256 $prewriteSourceSha256 $originalSha256 'Live source'

    Copy-Item -LiteralPath $backupSource -Destination $backup
    $backupSha256 = Get-Sha256 $backup
    if ($backupSha256 -cne $originalSha256) { throw 'Rollback backup hash does not match the original source.' }

    Move-Item -LiteralPath $temp -Destination $target -Force
    $after = & $inspectScript -Simfile $Simfile
    if ($after.Width -ne $Width -or $after.Height -ne $Height) { throw 'Installed PNG dimensions failed validation.' }
    if ($after.BannerReference -cne $beforeReference) { throw '#BANNER reference changed unexpectedly.' }
    $afterSimfileSha256 = Get-Sha256 $after.Simfile
    if ($afterSimfileSha256 -cne $simfileSha256) { throw 'Simfile content changed unexpectedly.' }
    $installedSha256 = Get-Sha256 $target

    $result = [pscustomobject]@{
        Installed = $target
        InstalledSha256 = $installedSha256
        Preview = $source
        PreviewSha256 = $previewSha256
        Backup = $backup
        BackupSha256 = $backupSha256
        BackupSource = $backupSource
        OriginalSha256 = $originalSha256
        Simfile = $after.Simfile
        SimfileSha256 = $afterSimfileSha256
        CreatedMissingTarget = (-not $targetExisted)
        Width = $after.Width
        Height = $after.Height
        OutputOpaque = ($targetPixelFormat -eq [Drawing.Imaging.PixelFormat]::Format24bppRgb)
        BannerReference = $after.BannerReference
        ITGManiaClosedVerified = $true
        RestartedITGmania = $false
    }
} catch {
    if ($targetExisted -and (Test-Path -LiteralPath $backup)) {
        Copy-Item -LiteralPath $backup -Destination $target -Force
    } elseif ((-not $targetExisted) -and (Test-Path -LiteralPath $target)) {
        Remove-Item -LiteralPath $target -Force
    }
    throw
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
}

$result
