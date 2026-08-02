[CmdletBinding()]
param(
    [Parameter(Mandatory)] [uri] $Url,
    [Parameter(Mandatory)] [string] $Destination,
    [switch] $Resume
)
$ErrorActionPreference = 'Stop'

function Test-ZipSignature([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $stream = [IO.File]::OpenRead($Path)
    try { return $stream.Length -ge 4 -and $stream.ReadByte() -eq 0x50 -and $stream.ReadByte() -eq 0x4B }
    finally { $stream.Dispose() }
}
function Invoke-Curl([string[]] $Arguments) {
    & curl.exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "curl.exe failed with exit code $LASTEXITCODE" }
}

$destinationFull = [IO.Path]::GetFullPath($Destination)
$parent = Split-Path -Parent $destinationFull
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
if ((Test-Path -LiteralPath $destinationFull) -and -not $Resume) { throw "Destination exists; use -Resume only for a known partial ZIP: $destinationFull" }
if ((Test-Path -LiteralPath $destinationFull) -and $Resume -and -not (Test-ZipSignature $destinationFull)) { throw "Existing destination is not a resumable partial ZIP: $destinationFull" }

$resolvedUrl = $Url.AbsoluteUri
if ($Url.Host -match '(^|\.)(tinyurl\.com|bit\.ly|t\.co)$') {
    $resolvedUrl = (& curl.exe --fail --location --silent --show-error --head --output NUL --write-out '%{url_effective}' $resolvedUrl)
    if ($LASTEXITCODE -ne 0 -or -not $resolvedUrl) { throw 'Could not resolve shortened URL.' }
}
$driveId = $null
if ($resolvedUrl -match '/file/d/([^/?]+)') { $driveId = $Matches[1] }
elseif ($resolvedUrl -match '[?&]id=([^&]+)') { $driveId = $Matches[1] }

if ($driveId) {
    $probe = "$destinationFull.drive-probe.html"
    try {
        Invoke-Curl @('--fail','--location','--silent','--show-error','--output',$probe,"https://drive.usercontent.google.com/uc?id=$driveId&export=download")
        if (Test-ZipSignature $probe) {
            if (Test-Path -LiteralPath $destinationFull) { throw 'Drive returned a complete ZIP but a partial destination exists.' }
            Move-Item -LiteralPath $probe -Destination $destinationFull
        } else {
            $html = Get-Content -LiteralPath $probe -Raw
            $confirm = [regex]::Match($html, 'name="confirm" value="([^"]+)"').Groups[1].Value
            $uuid = [regex]::Match($html, 'name="uuid" value="([^"]+)"').Groups[1].Value
            if (-not $confirm -or -not $uuid) { throw 'Drive returned neither a ZIP nor a recognized large-file confirmation form.' }
            $downloadUrl = "https://drive.usercontent.google.com/download?id=$driveId&export=download&confirm=$confirm&uuid=$uuid"
            $args = @('--fail','--location','--show-error','--output',$destinationFull)
            if ($Resume) { $args += @('--continue-at','-') }
            Invoke-Curl ($args + $downloadUrl)
        }
    } finally { if (Test-Path -LiteralPath $probe) { Remove-Item -LiteralPath $probe -Force } }
} else {
    $args = @('--fail','--location','--show-error','--output',$destinationFull)
    if ($Resume) { $args += @('--continue-at','-') }
    Invoke-Curl ($args + $resolvedUrl)
}
if (-not (Test-ZipSignature $destinationFull)) { throw "Downloaded content is not a ZIP: $destinationFull" }
$item = Get-Item -LiteralPath $destinationFull
[pscustomobject]@{ Archive=$destinationFull; Bytes=$item.Length; MiB=[math]::Round($item.Length/1MB,2); SHA256=(Get-FileHash -LiteralPath $destinationFull -Algorithm SHA256).Hash; Source=$Url.AbsoluteUri }
