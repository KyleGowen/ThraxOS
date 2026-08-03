[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputPath,
    [ValidateRange(1, 16384)][int]$Width = 836,
    [ValidateRange(1, 16384)][int]$Height = 328,
    [switch]$Opaque,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $InputPath).Path
$output = [IO.Path]::GetFullPath($OutputPath)
if ($source -eq $output) { throw 'InputPath and OutputPath must be different so the generated original remains preserved.' }

$songsRoot = [IO.Path]::GetFullPath('C:\Games\ITGmania\Songs').TrimEnd('\') + '\'
if ($output.StartsWith($songsRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Normalized previews must be staged outside the live song root.'
}

$parent = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    throw "Output parent does not exist: $parent"
}
if ((Test-Path -LiteralPath $output) -and -not $Force) {
    throw 'OutputPath already exists. Pass -Force only when replacing an unapproved staging artifact.'
}

$temp = Join-Path $parent ('.banner-normalize-' + [guid]::NewGuid().ToString('N') + '.png')
Add-Type -AssemblyName System.Drawing
$input = [Drawing.Image]::FromFile($source)
try {
    $sourceWidth = $input.Width
    $sourceHeight = $input.Height
    $sourcePixelFormat = $input.PixelFormat.ToString()
    $targetPixelFormat = if ($Opaque) {
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
            $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
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
    $check = [Drawing.Image]::FromFile($temp)
    try {
        if ($check.Width -ne $Width -or $check.Height -ne $Height) {
            throw 'Normalized preview dimensions failed validation.'
        }
        $outputPixelFormat = $check.PixelFormat.ToString()
        $outputOpaque = -not [Drawing.Image]::IsAlphaPixelFormat($check.PixelFormat)
    } finally {
        $check.Dispose()
    }
    Move-Item -LiteralPath $temp -Destination $output -Force
    [pscustomobject]@{
        InputPath = $source
        InputSha256 = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
        InputWidth = $sourceWidth
        InputHeight = $sourceHeight
        InputPixelFormat = $sourcePixelFormat
        OutputPath = $output
        OutputSha256 = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
        OutputWidth = $Width
        OutputHeight = $Height
        OutputPixelFormat = $outputPixelFormat
        OutputOpaque = $outputOpaque
        PreservedGeneratedOriginal = $true
    }
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
}
