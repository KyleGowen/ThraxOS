[CmdletBinding()]
param([Parameter(Mandatory)][string]$Path)

$ErrorActionPreference = 'Stop'

function Get-GreatestCommonDivisor([int]$A, [int]$B) {
    while ($B -ne 0) {
        $remainder = $A % $B
        $A = $B
        $B = $remainder
    }
    [Math]::Abs($A)
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

$resolved = (Resolve-Path -LiteralPath $Path).Path
Add-Type -AssemblyName System.Drawing
$image = [Drawing.Image]::FromFile($resolved)
try {
    $dimension = New-Object Drawing.Imaging.FrameDimension($image.FrameDimensionsList[0])
    $frames = $image.GetFrameCount($dimension)
    $divisor = Get-GreatestCommonDivisor $image.Width $image.Height
    [pscustomobject]@{
        Path = $resolved
        Width = $image.Width
        Height = $image.Height
        Dimensions = "$($image.Width) x $($image.Height)"
        AspectRatio = "$([int]($image.Width / $divisor)):$([int]($image.Height / $divisor))"
        AspectRatioDecimal = [Math]::Round($image.Width / [double]$image.Height, 4)
        FrameCount = $frames
        HasAlphaPixelFormat = [Drawing.Image]::IsAlphaPixelFormat($image.PixelFormat)
        IsFullyOpaque = Test-ImageFullyOpaque $image
        PixelFormat = $image.PixelFormat.ToString()
        Format = $image.RawFormat.ToString()
    }
} finally {
    $image.Dispose()
}
