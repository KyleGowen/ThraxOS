[CmdletBinding()]
param(
    [string]$QueuePath,
    [Parameter(Mandatory)][ValidateSet('none','fingerprint','reusable')][string]$Scope,
    [Parameter(Mandatory)][string]$Summary,
    [string]$SongPath,
    [string]$Fingerprint,
    [string[]]$ChangedFiles,
    [string]$ValidationResult
)
$ErrorActionPreference='Stop'
$repo=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
if(-not$QueuePath){$QueuePath=Join-Path $repo 'memory\background-upscale-queue.json'}
if([string]::IsNullOrWhiteSpace($Summary)){throw 'Summary must be nonblank and evidence-based.'}
if($Scope-eq'fingerprint'-and([string]::IsNullOrWhiteSpace($SongPath)-or[string]::IsNullOrWhiteSpace($Fingerprint))){throw 'Fingerprint learning requires SongPath and Fingerprint.'}
if($Scope-eq'reusable'){
    if(-not$ChangedFiles-or@($ChangedFiles).Count-eq 0){throw 'Reusable learning requires ChangedFiles.'}
    if([string]::IsNullOrWhiteSpace($ValidationResult)-or$ValidationResult-notmatch '(?i)(valid|pass|success)'){throw 'Reusable learning requires a successful ValidationResult.'}
}
$file=[IO.Path]::GetFullPath($QueuePath);$doc=[IO.File]::ReadAllText($file,[Text.UTF8Encoding]::new($false))|ConvertFrom-Json
$entry=[pscustomobject][ordered]@{recordedAt=(Get-Date).ToUniversalTime().ToString('o');scope=$Scope;summary=$Summary.Trim();songPath=if($SongPath){$SongPath}else{$null};fingerprint=if($Fingerprint){$Fingerprint}else{$null};changedFiles=if($ChangedFiles){@($ChangedFiles)}else{@()};validationResult=if($ValidationResult){$ValidationResult.Trim()}else{$null}}
$history=@();if($doc.PSObject.Properties.Name-contains'learningHistory'){$history=@($doc.learningHistory)};$history+=$entry
if($doc.PSObject.Properties.Name-contains'learningHistory'){$doc.learningHistory=$history}else{$doc|Add-Member -NotePropertyName learningHistory -NotePropertyValue $history}
$doc.generatedAt=$entry.recordedAt;$tmp="$file.$([guid]::NewGuid().ToString('N')).tmp"
try{[IO.File]::WriteAllText($tmp,($doc|ConvertTo-Json -Depth 10)+"`n",[Text.UTF8Encoding]::new($false));Move-Item -LiteralPath $tmp -Destination $file -Force}finally{if(Test-Path -LiteralPath $tmp){Remove-Item -LiteralPath $tmp -Force}}
$entry|ConvertTo-Json -Depth 6
