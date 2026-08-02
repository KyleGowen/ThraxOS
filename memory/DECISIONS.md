# Decisions

## 2026-07-31 repository architecture

- **Decision:** Use `AGENTS.md` for durable operating rules, `.agents/skills/thraxos` for `@ThraxOS`-style discovery, `.codex/agents/thraxos.toml` for the project custom agent, `docs/` for detailed context/runbooks, and `memory/` for reviewable persistence.
- **Rationale:** Codex loads repository guidance automatically, skills are the discoverable reusable workflow surface, and custom agents provide a specialist delegation target.

## 2026-07-31 project boundaries

- **Decision:** ThraxOS is the control plane; `itgmania-backup` remains the backup implementation; `Thraximundar-Backup` remains generated backup data and play history.
- **Decision:** Never store Songs or credentials in ThraxOS.
- **Rationale:** This preserves the stated intent of the existing repositories and avoids GitHub size and secret exposure risks.

## 2026-07-31 initial authorization boundary

- **Decision:** Ask before configuration-file changes, application restarts/termination, software upgrades, or pad-setting changes. Pack downloads and installations require an explicit request or approval. Backup repairs may proceed after diagnosis, but configuration, destination, schedule, credentials, and destructive changes still require approval.
- **Rationale:** This is the owner-confirmed operating boundary. It permits useful autonomous inspection and maintenance while protecting play-critical state.

## 2026-07-31 remote architecture

- **Decision:** Use Codex Remote on the authenticated desktop host rather than create an unauthenticated custom remote-control daemon.
- **Rationale:** Remote uses the host's existing projects, credentials, approvals, sandbox, plugins, and tools through an authenticated relay.

## 2026-07-31 owner choices

- **Decision:** Keep ITGMania 1.0.2 for now and track the 1.3.x upgrade as future work.
- **Decision:** Treat `C:\Games\ITGmania` as canonical and retain the unintended user-root duplicate pack until the owner explicitly requests reconciliation.
- **Decision:** Configure GrooveStats only for Kyle. Do not remove or rewrite pre-existing keys belonging to other profiles without a separate approved change.
- **Decision:** Keep health checks output-only: print the result in the task and do not add alerts or notifications.
- **Decision:** The GitHub repository and the owner-provided non-secret preferences and personal inputs may be public. Secrets and identifiers prohibited by `AGENTS.md` remain excluded.

## 2026-08-01 ITG pack search workflow

- **Decision:** Use the checked-in `itg-packs-search` skill for queries against the ITG Packs Release Spreadsheet.
- **Rationale:** A stable spreadsheet schema, minimal-call query plans, explicit range semantics, targeted hyperlink enrichment, alias handling, and deterministic installed-pack comparison improve accuracy while reducing repeated discovery work.

## 2026-08-01 song-pack installation workflow

- **Decision:** Use the project-local `add-pack` skill for description- or URL-driven song-pack downloads and installations.
- **Rationale:** Resumable downloads, Google Drive confirmation handling, immediate ZIP-signature checks, deterministic archive/layout validation, Defender scanning, collision refusal, explicit installation gating, and post-success cleanup make repeated installations safer and faster.

## 2026-08-01 Stamina RPG 10 upgrade

- **Decision:** Supersede the earlier hold on ITGMania 1.0.2: upgrade the canonical installation to ITGMania 1.3.0 and Simply Love 5.9.0 for native Stamina RPG 10 support.
- **Decision:** Install only the SRPG10 Unaffiliated and Stamina Nation packs for now; do not install Footspeed Empire, DPRT, NEP, doubles, or all-factions bundles without a later request.
- **Decision:** Use Kyle's existing GrooveStats profile integration for SRPG10; do not purchase shop items or alter other profiles.
