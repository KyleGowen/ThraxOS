---
name: thraxos
description: Safely inspect, configure, and maintain Thraximundar, its ITGMania installation and profiles, StepManiaX stage, GrooveStats integration, song packs, play statistics, backup health, remote operation, and checked-in machine memory. Use when the user mentions ThraxOS, Thraximundar, ITGMania, GrooveStats, the SMX pad, packs or simfiles, play sessions, cardio estimates, or either Thrax backup repository.
---

# ThraxOS

Operate the dedicated Windows ITGMania host from live evidence and the repository's durable context. Preserve scores, credentials, recoverability, and the ownership boundaries between the three Thrax projects.

## Load context

1. Read `AGENTS.md` at the repository root.
2. Read the compact inherited global rules in `memory/AGENTOS_INHERITANCE.md`.
3. Read `memory/FACTS.md`, `memory/DECISIONS.md`, and `memory/PREFERENCES.md`.
4. Load only the relevant file under `docs/context/` and `docs/runbooks/`.
5. Inspect current state. Treat dated context as a snapshot, not a substitute for live verification.

For inheritance freshness or AgentOS coordination, run `scripts/Get-AgentOSInheritanceStatus.ps1`. It may fetch Git metadata but never pulls, switches branches, or changes either worktree. Continue from the checked-in cache when AgentOS is unavailable, and report stale or unverified provenance.

## Route the request

- For overall status, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/thraxos/scripts/Get-ThraxStatus.ps1`.
- For backup health, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/thraxos/scripts/Test-BackupHealth.ps1` and read `docs/runbooks/backup-health.md`.
- For ITGMania configuration, read `docs/context/itgmania.md` and `docs/runbooks/itgmania-change.md`.
- For a wired or Bluetooth handheld controller used for ITGMania menus, use the project-local `connect-controller` skill.
- For GrooveStats, read `docs/context/groovestats.md` and `docs/runbooks/groovestats.md`.
- For pack discovery or installation, read `docs/context/song-sources.md` and `docs/runbooks/song-pack-install.md`.
- For one individual song installed into `Misc. Collected`, use the project-local `add-song` skill.
- For taste-matched discovery of individual songs not yet installed, use the project-local `find-singles` skill.
- For current player difficulty evidence from recent `Stats.xml` records, use the project-local `get-player-skill-levels` skill.
- For searches of the ITG Packs Release Spreadsheet, also use the project skill `itg-packs-search`.
- For the stage, read `docs/context/stepmaniax.md`.
- For remote access, read `docs/runbooks/remote-access.md`.
- For play stats or cardio, read `docs/context/play-data.md` and honor the privacy boundary in `AGENTS.md`.

## Act safely

- Proceed with read-only inspection and analysis.
- Follow the authorization boundary recorded in `AGENTS.md` and `memory/DECISIONS.md` for any mutation.
- Never echo secret values. Report credential presence and structural validity only.
- Before a live configuration edit, verify game state, backup health, exact target, and rollback path.
- Use `.agents/skills/thraxos/scripts/Set-GrooveStatsForProfile.ps1` only after the owner approves the configuration change; it refuses to run while ITGMania is open and never prints the API key.
- Stage and validate archives before installing packs; never overwrite or delete silently.
- Never edit score history to change competitive results.
- ThraxOS-specific rules win over inherited AgentOS rules for this machine. Report a material conflict instead of silently dropping either rule.
- Keep AgentOS changes inside the approved ThraxOS allowlist recorded in `memory/AGENTOS_INHERITANCE.md`, and require owner approval before every AgentOS write.

## Record the result

Update the relevant checked-in memory file after meaningful decisions or operations. Label new knowledge as owner-confirmed, observed, or inferred, include the date, and omit secrets and bulky raw data.

## Keep the ecosystem documented

Whenever creating, changing, renaming, or removing a project skill or scheduled task, update the discoverability indexes and matching migration guide under `docs/skills/` and `docs/scheduled-tasks/` in the same commit. Include prerequisites, dependencies, invocation or schedule, safety boundaries, verification, and reproduction steps. Never embed credentials, profile identifiers, Windows SIDs, serial numbers, or other machine-unique secrets in those guides.
