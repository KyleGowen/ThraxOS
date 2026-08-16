# `thraxos` skill

Source: [`.agents/skills/thraxos/`](../../.agents/skills/thraxos/)

Central specialist for ITGMania, handheld menu controllers, GrooveStats, StepManiaX, backups, packs, play data, remote operation, and durable host context.

## Components

- `SKILL.md`: routing, safety, recording, and documentation rules.
- `scripts/Get-ThraxStatus.ps1`: redacted, read-only overall status.
- `scripts/Get-AgentOSInheritanceStatus.ps1`: fetch-aware, worktree-preserving inheritance provenance and staleness status.
- `scripts/Test-BackupHealth.ps1`: redacted backup health.
- `scripts/Set-GrooveStatsForProfile.ps1`: guarded, owner-approved mutation.
- Routes handheld menu-controller pairing and mapping to the project-local `connect-controller` skill.
- Routes individual-song installation for `Misc. Collected` to the project-local `add-song` skill while retaining `add-pack` for pack archives.
- Routes household taste-matched individual-song discovery to `find-singles` while keeping that workflow read-only.
- Routes current player difficulty inference from recent score records to `get-player-skill-levels`.
- Depends on `AGENTS.md`, `memory/AGENTOS_INHERITANCE.md`, `memory/`, `docs/context/`, `docs/runbooks/`, PowerShell, Git, ITGMania, and optionally the configured AgentOS checkout and separately installed backup system.

## AgentOS inheritance

ThraxOS loads the compact checked-in cache instead of rereading AgentOS on every task. The cache contains only Kyle's global identity, communication, privacy, verification, approval, memory, GitHub synchronization, and skill-learning rules, with an upstream commit and category-level source provenance. It deliberately excludes every unrelated AgentOS project's context and operations.

The configured local checkout is preferred. The status script may run `git fetch origin`, but it never pulls, merges, rebases, switches branches, resets, or changes either worktree. Committed `origin/main` is authoritative shared state and uncommitted AgentOS files are ignored. A matching SHA reuses the cache; a changed SHA returns only relevant changed source files for review.

If fetch fails, the script reports locally committed `main` and unverified freshness. If the checkout is missing, use committed GitHub `main` read-only; if that is also unavailable, continue from the portable cache and report possible staleness. ThraxOS rules control Thraximundar conflicts, while AgentOS remains authoritative for global governance and course state. The cache records the exact AgentOS write allowlist and approval boundary.

## Safety

Inventory is read-only. Configuration edits, app termination/restart, upgrades, pad changes, and unrequested pack operations require approval. Never copy or print credentials, profile GUIDs, score history, serial numbers, or full USB identifiers.

## Reproduce and verify

1. Copy the repository and adapt non-secret paths/context.
2. Register `.codex/agents/thraxos.toml` and retain `.agents/skills/thraxos/agents/openai.yaml`.
3. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Get-ThraxStatus.ps1`.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Get-AgentOSInheritanceStatus.ps1` and verify its SHA, source mode, and refresh state.
5. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Test-BackupHealth.ps1`.
6. Confirm redaction, inheritance provenance, and current-host results before enabling mutation workflows.
