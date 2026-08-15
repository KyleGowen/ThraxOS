[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputPath,
    [ValidateRange(1, 16384)][int]$Width = 1920,
    [ValidateRange(1, 16384)][int]$Height = 1080,
    [ValidateRange(0.0001, 1.0)][double]$AspectTolerance = 0.01,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$source = [IO.Path]::GetFullPath($InputPath)
$output = [IO.Path]::GetFullPath($OutputPath)
if ($source -eq $output) {
    throw 'InputPath and OutputPath must differ so the raw generated image remains preserved.'
}
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Input image does not exist: $source"
}

$songsRoot = [IO.Path]::GetFullPath('C:\Games\ITGmania\Songs').TrimEnd('\') + '\'
if (($output + '\').StartsWith($songsRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputPath must remain outside the live ITGMania Songs tree.'
}
if ([IO.Path]::GetExtension($output) -ine '.png') {
    throw 'OutputPath must use the .png extension.'
}
if ((Test-Path -LiteralPath $output) -and -not $Force) {
    throw 'OutputPath already exists. Pass -Force only when replacing an unapproved staging artifact.'
}

$outputDirectory = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$temporary = Join-Path $outputDirectory ('.background-normalize-' + [Guid]::NewGuid().ToString('N') + '.png')

try {
$inputImage = $null
$bitmap = $null
$graphics = $null
$inputWidth = 0
$inputHeight = 0
$inputRatio = 0.0
try {
    $inputImage = [Drawing.Image]::FromFile($source)
    $inputWidth = $inputImage.Width
    $inputHeight = $inputImage.Height
    if ($inputWidth -lt 1 -or $inputHeight -lt 1) {
        throw 'Input image decoded with invalid dimensions.'
    }
    if ($inputImage.FrameDimensionsList.Count -ne 1) {
        throw 'Input image exposes multiple frame dimensions and is not supported.'
    }
    $frameDimension = New-Object Drawing.Imaging.FrameDimension(,$inputImage.FrameDimensionsList[0])
    if ($inputImage.GetFrameCount($frameDimension) -ne 1) {
        throw 'Animated or multi-frame inputs are not supported.'
    }

    $inputRatio = [double]$inputWidth / [double]$inputHeight
    $targetRatio = [double]$Width / [double]$Height
    $aspectDelta = [Math]::Abs($inputRatio - $targetRatio)
    if ($aspectDelta -gt $AspectTolerance) {
        throw ('Input aspect ratio {0:N6}:1 differs from target {1:N6}:1 by {2:N6}; regenerate or outpaint instead of stretching.' -f $inputRatio, $targetRatio, $aspectDelta)
    }

    $bitmap = New-Object Drawing.Bitmap $Width, $Height, ([Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.Clear([Drawing.Color]::Black)

    $destination = New-Object Drawing.Rectangle 0, 0, $Width, $Height
    $graphics.DrawImage(
        $inputImage,
        $destination,
        0,
        0,
        $inputWidth,
        $inputHeight,
        [Drawing.GraphicsUnit]::Pixel
    )
    $bitmap.Save($temporary, [Drawing.Imaging.ImageFormat]::Png)
}
finally {
    if ($graphics) { $graphics.Dispose() }
    if ($bitmap) { $bitmap.Dispose() }
    if ($inputImage) { $inputImage.Dispose() }
}

$check = $null
try {
    $check = [Drawing.Image]::FromFile($temporary)
    if ($check.Width -ne $Width -or $check.Height -ne $Height) {
        throw "Normalized image is $($check.Width) x $($check.Height), expected $Width x $Height."
    }
    if ($check.FrameDimensionsList.Count -ne 1) {
        throw 'Normalized image exposes multiple frame dimensions.'
    }
    $checkFrameDimension = New-Object Drawing.Imaging.FrameDimension(,$check.FrameDimensionsList[0])
    if ($check.GetFrameCount($checkFrameDimension) -ne 1) {
        throw 'Normalized image is animated or multi-frame.'
    }
    if ([Drawing.Image]::IsAlphaPixelFormat($check.PixelFormat)) {
        throw 'Normalized image still has an alpha-capable pixel format.'
    }
}
finally {
    if ($check) { $check.Dispose() }
}

Move-Item -LiteralPath $temporary -Destination $output -Force
[pscustomobject]@{
    InputPath = $source
    InputSha256 = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    InputWidth = $inputWidth
    InputHeight = $inputHeight
    InputAspectRatio = ('{0:N4}:1' -f $inputRatio)
    OutputPath = $output
    OutputSha256 = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
    OutputWidth = $Width
    OutputHeight = $Height
    OutputAspectRatio = ('{0:N4}:1' -f ([double]$Width / [double]$Height))
    Opaque = $true
    FrameCount = 1
}
}
finally {
    if (Test-Path -LiteralPath $temporary) {
        Remove-Item -LiteralPath $temporary -Force
    }
}
