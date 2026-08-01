[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$CandidatePack,

    [string[]]$CandidateSong = @(),

    [string[]]$SongRoot = @(
        'C:\Games\ITGmania\Songs',
        (Join-Path $env:APPDATA 'ITGmania\Songs')
    )
)

$existingRoots = $SongRoot | Where-Object { Test-Path -LiteralPath $_ }
$installedPacks = foreach ($root in $existingRoots) {
    Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue
}

function ConvertTo-NormalizedName {
    param([AllowEmptyString()][string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }

    return ($Value.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant() -replace '[^a-z0-9]+', '')
}

$packResults = foreach ($candidate in $CandidatePack) {
    $normalizedCandidate = ConvertTo-NormalizedName $candidate
    $matches = @($installedPacks | Where-Object {
        (ConvertTo-NormalizedName $_.Name) -eq $normalizedCandidate
    })

    [pscustomobject]@{
        candidate = $candidate
        installed = [bool]$matches
        matchedPaths = @($matches | ForEach-Object { $_.FullName })
    }
}

$songResults = @()
if ($CandidateSong.Count -gt 0) {
    $installedSongs = foreach ($pack in $installedPacks) {
        Get-ChildItem -LiteralPath $pack.FullName -Directory -ErrorAction SilentlyContinue
    }

    $songResults = foreach ($candidate in $CandidateSong) {
        $normalizedCandidate = ConvertTo-NormalizedName $candidate
        $matches = @($installedSongs | Where-Object {
            (ConvertTo-NormalizedName $_.Name) -eq $normalizedCandidate
        })

        [pscustomobject]@{
            candidate = $candidate
            possibleOverlap = [bool]$matches
            matchedPaths = @($matches | ForEach-Object { $_.FullName })
        }
    }
}

[pscustomobject]@{
    observedAt = (Get-Date).ToString('o')
    rootsChecked = @($existingRoots)
    packs = @($packResults)
    songs = @($songResults)
} | ConvertTo-Json -Depth 5
