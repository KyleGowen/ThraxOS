# ThraxOS skill catalog

Canonical migration index for every project-local skill under `.agents/skills/`. Copy each whole skill directory, including `SKILL.md`, `agents/`, `scripts/`, and `references/`. Reconciled with the repository on 2026-08-14.

| Skill | Purpose | Migration guide |
| --- | --- | --- |
| `thraxos` | Safe router, AgentOS inheritance and UI-design preflight, and operating contract for the host | [ThraxOS](thraxos.md) |
| `connect-controller` | Pair and map handheld menu controllers with verified song-wheel submenu behavior | [Connect Controller](connect-controller.md) |
| `add-pack` | Download, validate, scan, collision-check, and install packs | [Add Pack](add-pack.md) |
| `add-song` | Resolve and safely install one song into `Misc. Collected`, then clean staging | [Add Song](add-song.md) |
| `find-singles` | Find up to 10 family-fit individual songs with live-library deduplication | [Find Singles](find-singles.md) |
| `get-player-skill-levels` | Infer current stretch levels from recent Stats.xml records and live chart meters | [Get Player Skill Levels](get-player-skill-levels.md) |
| `itg-packs-search` | Search the live ITG Packs spreadsheet and compare local overlap | [ITG Packs Search](itg-packs-search.md) |
| `research-itg-community` | Evidence-graded rhythm-game community research | [ITG Community Research](research-itg-community.md) |
| `generate-banner` | Research authentic release art and stage original 836 x 328 previews for redesigns or entirely missing referenced banners | [Generate Banner](generate-banner.md) |
| `generate-background` | Research authentic release art and stage original opaque 1920 x 1080 cover-inspired background previews | [Generate Background](generate-background.md) |
| `upscale-banner` | Reject inconsistent references; restore existing art or route source-less targets through `generate-banner`; render exact approval evidence; hash-bind installs; and preserve UTF-8 fingerprint history | [Upscale Banner](upscale-banner.md) |
| `upscale-background` | Validate explicit pack-scoped backgrounds with separate ledgers, stage faithful previews, render them through safe encoded Windows paths, and proof-complete exact hash-bound installs | [Upscale Background](upscale-background.md) |
| `ship-all` | Review, commit, and push all safe intended work to `origin/main` | [Ship All](ship-all.md) |

## Migration order

1. Clone ThraxOS and review `AGENTS.md`, facts, decisions, and preferences for the new owner.
2. Adapt non-secret paths in `config/` and context files. Never copy credentials, profile GUIDs, score data, serial numbers, Windows SIDs, or full device instance IDs.
3. Install or locate ITGMania, PowerShell, Git, Windows Security, and capability-specific dependencies.
4. Keep `.codex/agents/thraxos.toml` with the checkout and make project skills discoverable in the target Codex environment.
5. Configure the non-secret AgentOS checkout in `config/paths.json`; retain the durable GitHub URL and checked-in `memory/AGENTOS_INHERITANCE.md` fallback.
6. Run read-only validation before authorizing mutations.
7. Recreate recurring work from the [scheduled-task catalog](../scheduled-tasks/README.md).

## Documentation contract

A skill change is incomplete until this index and its guide are updated. Each guide must cover triggers, owned files, dependencies, inputs/outputs, safety boundary, host-specific values, reproduction, and verification.
