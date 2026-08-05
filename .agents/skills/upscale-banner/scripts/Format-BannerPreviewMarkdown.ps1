[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9 ._-]*$')][string]$Label,
    [Parameter(Mandatory)][string]$Path
)

$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    throw "Preview file does not exist: $resolved"
}

Add-Type -AssemblyName System.Drawing
$image = [Drawing.Image]::FromFile($resolved)
try {
    $width = $image.Width
    $height = $image.Height
} finally {
    $image.Dispose()
}

# Markdown image destinations are URL-like. Backslash Windows paths wrapped in
# angle brackets may remain clickable while failing in the inline media loader.
# Keep the drive colon and separators readable, but encode every path segment.
$slashPath = $resolved.Replace('\', '/')
$parts = $slashPath.Split('/')
$encodedParts = for ($index = 0; $index -lt $parts.Count; $index++) {
    $part = $parts[$index]
    if ($index -eq 0 -and $part -match '^[A-Za-z]:$') {
        $part
    } else {
        ([Uri]::EscapeDataString($part)).Replace('(', '%28').Replace(')', '%29')
    }
}
$inlinePath = $encodedParts -join '/'
if ($inlinePath -match '[\\\s<>]') {
    throw "Inline Markdown path is not renderer-safe: $inlinePath"
}

$hash = (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash
$markdown = @"
### $Label

![$Label]($inlinePath)

Full resolution: $width x $height - [Open full-resolution $Label](<$slashPath>)
"@

[pscustomobject]@{
    Label = $Label
    Path = $resolved
    Sha256 = $hash
    Width = $width
    Height = $height
    InlinePath = $inlinePath
    Markdown = $markdown.TrimEnd()
}
