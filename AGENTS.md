# ThraxOS operating contract

You are working in the ThraxOS control repository for Thraximundar, a dedicated Windows 11 ITGMania machine.

## Start every machine task

1. Read `memory/AGENTOS_INHERITANCE.md`, then `memory/FACTS.md`, `memory/DECISIONS.md`, and `memory/PREFERENCES.md`.
2. Treat ThraxOS as authoritative for every Thraximundar-specific fact, operation, context, memory, safety requirement, skill, and decision. ThraxOS-specific instructions override inherited AgentOS rules when they conflict; report material conflicts.
3. Read the context file and runbook relevant to the request.
4. Inspect live state before relying on checked-in snapshots; record the observation date.
5. Prefer the read-only scripts under `.agents/skills/thraxos/scripts/` for status, AgentOS inheritance status, and backup health.

## AgentOS inheritance

- Inherit only the compact global rules in `memory/AGENTOS_INHERITANCE.md`; never load unrelated AgentOS project context merely because AgentOS is available.
- Resolve AgentOS through `config/paths.json`: prefer the configured local checkout, fetch `origin` to check freshness without pulling or changing its worktree, and treat committed `origin/main` as shared durable state. Uncommitted AgentOS changes are never inherited.
- Reuse the checked-in cache while its recorded SHA matches `origin/main`. When it differs, inspect only the relevant changed source files recorded in the cache before proposing a refresh.
- Before designing or changing a page, dashboard, frontend, form, dialog, or reusable visual component, run the inheritance-status check. If the cache is stale, inspect the recorded global design-system source and refresh the cache before choosing a component library or visual language. Use the inherited shadcn/ui default unless a repository constraint or explicit owner instruction materially overrides it; report that override.
- If fetch fails, use locally committed `main` and report its SHA and unverified freshness. If the checkout is unavailable, read committed GitHub `main` through a read-only mechanism. The checked-in cache remains the portable recovery source when neither is available.
- AgentOS remains authoritative for Kyle's global identity, governance, cross-project rules, and course state. AgentOS writes require its configured local checkout, explicit approval, and the allowlist in `memory/AGENTOS_INHERITANCE.md`; never perform remote-only mutation.

## System boundaries

- ThraxOS is the orchestration, knowledge, and runbook repository. Do not turn it into a backup destination.
- `KyleGowen/itgmania-backup` owns backup implementation and installation logic.
- `KyleGowen/Thraximundar-Backup` is generated backup data and play-history output. Treat it as a read-mostly downstream artifact; do not hand-edit generated content.
- Live songs remain outside Git under `C:\Games\ITGmania\Songs` or an explicitly approved additional song root.

## Safety and authorization

- Read-only inventory, log inspection, stats analysis, and secret-presence checks may proceed without additional confirmation.
- Ask before changing configuration files, restarting or terminating applications, upgrading software, or changing StepManiaX pad settings.
- A song-pack download or installation may proceed when the owner explicitly requests it; otherwise ask first. Never overwrite, move, or delete existing content silently.
- ThraxOS may perform a narrowly scoped backup repair after diagnosing the failure. Ask before changing backup configuration values, schedule, destination, credentials, or deleting data.
- Backup health checks print their result in the active task. Do not create alerts or notifications unless the owner later requests them.
- Before a live configuration mutation, identify the exact file, verify ITGMania is not writing it, confirm a recent successful backup or make a recoverable local copy, apply the smallest edit, and validate parsing afterward.
- Never alter score history, timestamps, signatures, or GrooveStats eligibility data to manufacture or improve a score.
- Never disable Windows security controls or expose a public unauthenticated remote-control listener.

## Secrets and privacy

- Never commit or print passwords, API keys, GitHub tokens, cookies, browser session data, profile GUIDs, serial numbers, or full USB instance IDs.
- For credentials, report only presence, validity shape such as expected length, and last verified time.
- Prefer GrooveStats API keys or an authenticated browser session over asking for the GrooveStats password in chat.
- Treat household play profiles and health/cardio data as personal data. Summarize only to the level authorized by the owner.

## Song-pack workflow

- Research current pack metadata from the owner-approved sources in `docs/context/song-sources.md`.
- Distinguish pad charts from keyboard charts and report chart style, difficulty range, song count, source, archive size, and checksum when available.
- Download to a staging directory, validate archive paths against traversal, inspect the extracted pack layout, scan with available Windows security tooling, and detect duplicates before proposing installation.
- Install only into an approved song root. Do not overwrite an existing pack silently. Verify the game can reload the pack and record the decision.

## Verification and memory

- After meaningful work, update the appropriate file under `memory/` with date, evidence, and whether the entry is observed, inferred, or owner-confirmed.
- Put architectural or ownership choices in `memory/DECISIONS.md`; stable machine facts in `memory/FACTS.md`; taste and workflow choices in `memory/PREFERENCES.md`; significant actions in `memory/OPERATIONS_LOG.md`.
- Never place secrets or bulky generated inventories in memory.
- Keep documentation links current and favor official or primary sources.
- Apply inherited AgentOS memory and compaction rules only after ThraxOS's file ownership rules above. Keep machine detail in ThraxOS and only summary-level ThraxOS handoff state in AgentOS.
- Documentation hygiene: whenever a ThraxOS skill or scheduled task is created, changed, renamed, or removed, update `docs/skills/README.md`, its corresponding file under `docs/skills/`, `docs/scheduled-tasks/README.md`, and its corresponding file under `docs/scheduled-tasks/` in the same change. Document prerequisites, safety boundaries, dependencies, verification, and migration steps so another ITGMania host can reproduce the capability without copying secrets or machine-unique identifiers.
