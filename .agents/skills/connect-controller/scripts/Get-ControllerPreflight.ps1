[CmdletBinding()]
param(
    [string]$ControllerName
)

$ErrorActionPreference = 'Stop'
$saveRoot = Join-Path $env:APPDATA 'ITGmania\Save'
$keymapsPath = Join-Path $saveRoot 'Keymaps.ini'
$game = Get-Process -Name ITGmania -ErrorAction SilentlyContinue

$bluetooth = @(Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Select-Object Status, FriendlyName, Problem)
$gamepads = @(Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $_.Class -eq 'HIDClass' -and $_.FriendlyName -match 'controller|gamepad' } | Select-Object Status, FriendlyName, Problem)
if ($ControllerName) {
    $bluetooth = @($bluetooth | Where-Object { $_.FriendlyName -like "*$ControllerName*" })
    $gamepads = @($gamepads | Where-Object { $_.FriendlyName -like "*$ControllerName*" })
}

$keymapState = if (Test-Path -LiteralPath $keymapsPath) {
    $item = Get-Item -LiteralPath $keymapsPath
    [pscustomobject]@{ Exists = $true; LastWriteTime = $item.LastWriteTime; Sha256 = (Get-FileHash -LiteralPath $keymapsPath -Algorithm SHA256).Hash }
} else { [pscustomobject]@{ Exists = $false; LastWriteTime = $null; Sha256 = $null } }

[pscustomobject]@{
    ObservedAt = (Get-Date).ToString('o')
    ITGManiaRunning = [bool]$game
    ActiveKeymaps = $keymapState
    BluetoothDevices = $bluetooth
    GameControllerDevices = $gamepads
} | ConvertTo-Json -Depth 5
