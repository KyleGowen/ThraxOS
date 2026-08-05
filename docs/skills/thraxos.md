# `thraxos` skill

Source: [`.agents/skills/thraxos/`](../../.agents/skills/thraxos/)

Central specialist for ITGMania, handheld menu controllers, GrooveStats, StepManiaX, backups, packs, play data, remote operation, and durable host context.

## Components

- `SKILL.md`: routing, safety, recording, and documentation rules.
- `scripts/Get-ThraxStatus.ps1`: redacted, read-only overall status.
- `scripts/Test-BackupHealth.ps1`: redacted backup health.
- `scripts/Set-GrooveStatsForProfile.ps1`: guarded, owner-approved mutation.
- Routes handheld menu-controller pairing and mapping to the project-local `connect-controller` skill.
- Routes individual-song installation for `Misc. Collected` to the project-local `add-song` skill while retaining `add-pack` for pack archives.
- Routes household taste-matched individual-song discovery to `find-singles` while keeping that workflow read-only.
- Routes current player difficulty inference from recent score records to `get-player-skill-levels`.
- Depends on `AGENTS.md`, `memory/`, `docs/context/`, `docs/runbooks/`, PowerShell, ITGMania, Git, and optionally the separately installed backup system.

## Safety

Inventory is read-only. Configuration edits, app termination/restart, upgrades, pad changes, and unrequested pack operations require approval. Never copy or print credentials, profile GUIDs, score history, serial numbers, or full USB identifiers.

## Reproduce and verify

1. Copy the repository and adapt non-secret paths/context.
2. Register `.codex/agents/thraxos.toml` and retain `.agents/skills/thraxos/agents/openai.yaml`.
3. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Get-ThraxStatus.ps1`.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Test-BackupHealth.ps1`.
5. Confirm redaction and current-host results before enabling mutation workflows.
