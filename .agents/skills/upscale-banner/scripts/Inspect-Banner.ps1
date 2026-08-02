[CmdletBinding()]
param([Parameter(Mandatory)][string]$Simfile,[switch]$AllowMissing)
$ErrorActionPreference='Stop'; $sim=(Resolve-Path -LiteralPath $Simfile).Path; $song=Split-Path -Parent $sim; $text=[IO.File]::ReadAllText($sim)
$matches=[regex]::Matches($text,'(?im)^#BANNER\s*:\s*([^;\r\n]+)\s*;'); if($matches.Count -ne 1){throw "Expected exactly one #BANNER reference; found $($matches.Count)."}
$reference=$matches[0].Groups[1].Value.Trim(); $target=[IO.Path]::GetFullPath((Join-Path $song $reference)); $root=[IO.Path]::GetFullPath($song).TrimEnd('\')+'\'
if(-not $target.StartsWith($root,[StringComparison]::OrdinalIgnoreCase)){throw '#BANNER resolves outside the song directory.'}; if(-not(Test-Path -LiteralPath $target -PathType Leaf)){if($AllowMissing){return [pscustomobject]@{Simfile=$sim;BannerReference=$reference;BannerPath=$target;Exists=$false;Width=$null;Height=$null;Format=$null}};throw 'Referenced banner does not exist.'}
Add-Type -AssemblyName System.Drawing; $img=[Drawing.Image]::FromFile($target); try{[pscustomobject]@{Simfile=$sim;BannerReference=$reference;BannerPath=$target;Width=$img.Width;Height=$img.Height;Format=$img.RawFormat.ToString()}}finally{$img.Dispose()}
