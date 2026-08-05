[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$formatter = Join-Path $PSScriptRoot 'Format-BannerPreviewMarkdown.ps1'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('thraxos-banner-preview-test-' + [guid]::NewGuid().ToString('N'))
$fixture = Join-Path $testRoot 'Before fixture (external #1).png'

Add-Type -AssemblyName System.Drawing

try {
    New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
    $bitmap = New-Object Drawing.Bitmap 64,20,([Drawing.Imaging.PixelFormat]::Format24bppRgb)
    try {
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([Drawing.Color]::MidnightBlue)
            $bitmap.Save($fixture, [Drawing.Imaging.ImageFormat]::Png)
        } finally { $graphics.Dispose() }
    } finally { $bitmap.Dispose() }

    $external = & $formatter -Label Before -Path $fixture
    $fixtureHash = (Get-FileHash -LiteralPath $fixture -Algorithm SHA256).Hash
    $displayRoot = Join-Path $repositoryRoot '.tmp\banner-preview-display'
    $displayRootPrefix = [IO.Path]::GetFullPath($displayRoot).TrimEnd('\') + '\'

    if (-not $external.UsedDisplayCopy) { throw 'External fixture did not use a workspace display copy.' }
    if (-not $external.DisplayPath.StartsWith($displayRootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'External fixture display copy is outside the repository staging root.'
    }
    if ($external.Sha256 -cne $fixtureHash -or $external.DisplaySha256 -cne $fixtureHash) {
        throw 'External fixture and display-copy hashes do not match.'
    }
    if ($external.Width -ne 64 -or $external.Height -ne 20) { throw 'Formatter reported incorrect fixture dimensions.' }
    if ($external.InlinePath -match '[\\\s<>]') { throw 'Formatter emitted an unsafe inline destination.' }
    if ($external.InlinePath -notmatch '%20' -or $external.InlinePath -notmatch '%28' -or
        $external.InlinePath -notmatch '%29' -or $external.InlinePath -notmatch '%23') {
        throw 'Formatter did not encode reserved display-copy path characters.'
    }
    if ($external.Markdown -notmatch [regex]::Escape("![$($external.Label)]($($external.InlinePath))")) {
        throw 'Formatter Markdown does not use the workspace display copy inline.'
    }
    $nativePath = $external.Path.Replace('\', '/')
    if ($external.Markdown -notmatch [regex]::Escape("[Open full-resolution Before](<$nativePath>)")) {
        throw 'Formatter Markdown does not preserve the authoritative native-file link.'
    }

    $workspace = & $formatter -Label After -Path $external.DisplayPath
    if ($workspace.UsedDisplayCopy) { throw 'Workspace fixture unexpectedly created another display copy.' }
    if ($workspace.Path -cne $external.DisplayPath -or $workspace.InlinePath -cne $external.InlinePath) {
        throw 'Workspace fixture did not render directly from the existing display copy.'
    }

    [pscustomobject]@{
        Passed = $true
        ExternalSource = $external.Path
        DisplayCopy = $external.DisplayPath
        Sha256 = $external.Sha256
        Width = $external.Width
        Height = $external.Height
        NativeLinkPreserved = $true
        WorkspaceInlinePath = $external.InlinePath
    }
} finally {
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
