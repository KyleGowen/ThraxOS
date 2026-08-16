[CmdletBinding()]
param(
    [switch]$SkipFetch
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$configPath = Join-Path $repoRoot 'config\paths.json'
$cachePath = Join-Path $repoRoot 'memory\AGENTOS_INHERITANCE.md'
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$cache = Get-Content -LiteralPath $cachePath -Raw -Encoding UTF8
$cachedSha = [regex]::Match($cache, '(?m)^- Upstream commit: `([0-9a-f]{40})`\.$').Groups[1].Value

if (-not $cachedSha) {
    throw 'The AgentOS inheritance cache does not contain a valid upstream commit SHA.'
}

$relevantSources = @(
    'AGENTS.md',
    'PLAYBOOK.md',
    'os/agents/os-thought-partner.md',
    'os/context/communication-style.md',
    'os/context/design-system.md',
    'os/context/identity.md',
    'os/memory/README.md',
    'os/memory/agentos-memory.md',
    'os/memory/patterns.md'
)

$result = [ordered]@{
    CheckedAt = (Get-Date).ToString('o')
    Repository = [string]$config.agentOSRepository
    ConfiguredCheckout = [string]$config.agentOSCheckout
    CheckoutAvailable = $false
    FetchAttempted = -not $SkipFetch
    FetchSucceeded = $false
    FreshnessVerified = $false
    SourceMode = 'checked-in-cache'
    UpstreamSha = $null
    CachedSha = $cachedSha
    RefreshNeeded = $null
    RelevantChangedFiles = @()
    Note = $null
}

$checkout = [string]$config.agentOSCheckout
if (-not $checkout -or -not (Test-Path -LiteralPath (Join-Path $checkout '.git'))) {
    $result.Note = 'Configured checkout is unavailable. Use committed GitHub main read-only when available; otherwise continue from the checked-in cache.'
    [pscustomobject]$result
    return
}

$result.CheckoutAvailable = $true
if (-not $SkipFetch) {
    # A failed metadata refresh is an expected degraded-mode condition, not a
    # status-script failure. Suppress Git's stderr and retain the fallback path.
    $savedErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git -C $checkout fetch origin 2>$null | Out-Null
        $result.FetchSucceeded = ($LASTEXITCODE -eq 0)
    } finally {
        $ErrorActionPreference = $savedErrorActionPreference
    }
}

if ($SkipFetch -or $result.FetchSucceeded) {
    $upstreamSha = (& git -C $checkout rev-parse origin/main 2>$null).Trim()
    if ($LASTEXITCODE -eq 0 -and $upstreamSha -match '^[0-9a-f]{40}$') {
        $result.SourceMode = 'origin/main'
        $result.UpstreamSha = $upstreamSha
        $result.FreshnessVerified = -not $SkipFetch
    }
}

if (-not $result.UpstreamSha) {
    $localMainSha = (& git -C $checkout rev-parse main 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or $localMainSha -notmatch '^[0-9a-f]{40}$') {
        $result.Note = 'Neither fetched origin/main nor locally committed main could be resolved. Continue from the checked-in cache.'
        [pscustomobject]$result
        return
    }
    $result.SourceMode = 'local-main-fallback'
    $result.UpstreamSha = $localMainSha
    $result.Note = 'Fetch failed or was skipped; freshness could not be verified.'
}

$result.RefreshNeeded = ($result.UpstreamSha -ne $cachedSha)
if ($result.RefreshNeeded) {
    $changed = & git -C $checkout diff --name-only "$cachedSha..$($result.UpstreamSha)" -- @relevantSources 2>$null
    if ($LASTEXITCODE -eq 0) {
        $result.RelevantChangedFiles = @($changed | Where-Object { $_ })
    } else {
        $result.Note = 'The cached commit is not locally comparable. Inspect the recorded source files through committed GitHub main before refreshing.'
    }
}

[pscustomobject]$result
