[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9 ._-]*$')][string]$Label,
    [Parameter(Mandatory)][string]$Path,
    [string]$DisplayRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))

function Test-ContainedPath([string]$BasePath, [string]$ChildPath) {
    $base = [IO.Path]::GetFullPath($BasePath).TrimEnd('\') + '\'
    $child = [IO.Path]::GetFullPath($ChildPath)
    $child.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)
}

function ConvertTo-InlinePath([string]$LocalPath) {
    $slashPath = $LocalPath.Replace('\', '/')
    $parts = $slashPath.Split('/')
    $encodedParts = for ($index = 0; $index -lt $parts.Count; $index++) {
        $part = $parts[$index]
        if ($index -eq 0 -and $part -match '^[A-Za-z]:$') {
            $part
        } else {
            ([Uri]::EscapeDataString($part)).Replace('(', '%28').Replace(')', '%29')
        }
    }
    $encodedParts -join '/'
}

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

$hash = (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash
$displayPath = $resolved
$usedDisplayCopy = $false

# The desktop renderer can open native links outside the repository while
# refusing to load those same paths inline. Keep the authoritative source and
# native link unchanged, but render a byte-identical full-resolution copy from
# the repository's ignored staging tree when needed.
if (-not (Test-ContainedPath $repositoryRoot $resolved)) {
    if (-not $DisplayRoot) { $DisplayRoot = Join-Path $repositoryRoot '.tmp\banner-preview-display' }
    $displayRootFull = [IO.Path]::GetFullPath($DisplayRoot)
    if (-not (Test-ContainedPath $repositoryRoot $displayRootFull)) {
        throw "Display-copy root must be contained within the repository: $displayRootFull"
    }

    $displayDirectory = Join-Path $displayRootFull $hash
    New-Item -ItemType Directory -Path $displayDirectory -Force | Out-Null
    $displayPath = Join-Path $displayDirectory ([IO.Path]::GetFileName($resolved))

    if (Test-Path -LiteralPath $displayPath -PathType Leaf) {
        if ((Get-FileHash -LiteralPath $displayPath -Algorithm SHA256).Hash -cne $hash) {
            throw "Existing display copy does not match the authoritative file: $displayPath"
        }
    } else {
        $temporaryCopy = Join-Path $displayDirectory (([IO.Path]::GetFileName($resolved)) + '.' + [guid]::NewGuid().ToString('N') + '.tmp')
        try {
            Copy-Item -LiteralPath $resolved -Destination $temporaryCopy
            if ((Get-FileHash -LiteralPath $temporaryCopy -Algorithm SHA256).Hash -cne $hash) {
                throw "Display copy changed while staging: $resolved"
            }
            try {
                Move-Item -LiteralPath $temporaryCopy -Destination $displayPath -ErrorAction Stop
            } catch {
                if (-not (Test-Path -LiteralPath $displayPath -PathType Leaf) -or
                    (Get-FileHash -LiteralPath $displayPath -Algorithm SHA256).Hash -cne $hash) {
                    throw
                }
            }
        } finally {
            if (Test-Path -LiteralPath $temporaryCopy -PathType Leaf) {
                Remove-Item -LiteralPath $temporaryCopy -Force
            }
        }
    }
    $displayPath = (Resolve-Path -LiteralPath $displayPath -ErrorAction Stop).Path
    $usedDisplayCopy = $true
}

# Markdown image destinations are URL-like. Backslash Windows paths wrapped in
# angle brackets may remain clickable while failing in the inline media loader.
# Keep the drive colon and separators readable, but encode every path segment.
$slashPath = $resolved.Replace('\', '/')
$inlinePath = ConvertTo-InlinePath $displayPath
if ($inlinePath -match '[\\\s<>]') {
    throw "Inline Markdown path is not renderer-safe: $inlinePath"
}

$displayHash = (Get-FileHash -LiteralPath $displayPath -Algorithm SHA256).Hash
if ($displayHash -cne $hash) { throw 'Inline display copy SHA-256 does not match the authoritative image.' }
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
    DisplayPath = $displayPath
    DisplaySha256 = $displayHash
    UsedDisplayCopy = $usedDisplayCopy
    InlinePath = $inlinePath
    Markdown = $markdown.TrimEnd()
}
