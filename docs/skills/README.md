# ThraxOS skill catalog

Canonical migration index for every project-local skill under `.agents/skills/`. Copy each whole skill directory, including `SKILL.md`, `agents/`, `scripts/`, and `references/`. Observed and reconciled with the repository on 2026-08-02.

| Skill | Purpose | Migration guide |
| --- | --- | --- |
| `thraxos` | Safe router and operating contract for the host | [ThraxOS](thraxos.md) |
| `add-pack` | Download, validate, scan, collision-check, and install packs | [Add Pack](add-pack.md) |
| `itg-packs-search` | Search the live ITG Packs spreadsheet and compare local overlap | [ITG Packs Search](itg-packs-search.md) |
| `research-itg-community` | Evidence-graded rhythm-game community research | [ITG Community Research](research-itg-community.md) |
| `upscale-banner` | Stage, approve, and safely install restored song banners | [Upscale Banner](upscale-banner.md) |

## Migration order

1. Clone ThraxOS and review `AGENTS.md`, facts, decisions, and preferences for the new owner.
2. Adapt non-secret paths in `config/` and context files. Never copy credentials, profile GUIDs, score data, serial numbers, Windows SIDs, or full device instance IDs.
3. Install or locate ITGMania, PowerShell, Git, Windows Security, and capability-specific dependencies.
4. Keep `.codex/agents/thraxos.toml` with the checkout and make project skills discoverable in the target Codex environment.
5. Run read-only validation before authorizing mutations.
6. Recreate recurring work from the [scheduled-task catalog](../scheduled-tasks/README.md).

## Documentation contract

A skill change is incomplete until this index and its guide are updated. Each guide must cover triggers, owned files, dependencies, inputs/outputs, safety boundary, host-specific values, reproduction, and verification.
