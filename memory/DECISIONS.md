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

## 2026-08-01 ITG community research workflow

- **Decision:** Use the checked-in `research-itg-community` skill for investigations across Reddit, forums, personal sites, public archives, GitHub discussions, and other unstructured rhythm-game sources.
- **Rationale:** Layered discovery, original-source tracing, claim-level evidence grading, counterevidence searches, version and hardware applicability checks, and explicit uncertainty reporting improve obscure-source research without treating anecdotes as confirmed machine facts.

## 2026-08-02 banner restoration workflow

- **Decision:** Use the project-local `upscale-banner` skill for ITGMania song-banner restoration. Generate and show a faithful staged preview first; require explicit approval of that exact preview before changing the live banner.
- **Decision:** Use 836 x 328 PNG as the current host convention, prefer GPT Image 2 high-fidelity editing for semantic restoration, and use deterministic super-resolution when exact content preservation is required.
- **Decision:** Every `upscale-banner` preview must show the current source and generated candidate as clearly labeled `Before` and `After` images before requesting installation approval.
- **Decision:** Always render `Before`, including failure-only responses. Render every viable generated option as `After` or lettered After choices before requesting selection or installation approval.
- **Decision:** Treat image generation and result forwarding as separate phases. Use the built-in tool's generated-image result handler; do not count a recoverable result-forwarding or staging error as a failed generative attempt.
- **Decision:** When a simfile's contained banner target is missing, installation may create only that referenced target if the queue resolved an existing contained fallback and the installer preserves the fallback's exact bytes as the recoverable timestamped backup. Rollback must remove the newly created target rather than copying fallback bytes into it.
- **Decision:** End every banner run and install/deny follow-up with an evidence-based retrospective. Preserve exact-fingerprint reasoning in the queue, promote only stable owner-wide preferences or reusable workflow lessons, and validate every resulting skill edit. Never invent feedback or weaken safety boundaries in the name of self-improvement.
- **Decision:** Attempt GPT Image 2 high-fidelity restoration at most twice. Offer deterministic exact-content upscaling only after both attempts fail, and require explicit approval before switching unless the owner already approved that fallback.
- **Rationale:** This captures the successful Simply Love banner dimensions while separating creative generation from a minimal, reversible, validated live installation.

## 2026-08-02 banner candidate queue

- **Decision:** Maintain `memory/banner-upscale-queue.json` as the durable `Misc. Collected` banner queue, keyed by relative song path and content fingerprint. A terminal installed or denied decision applies only to that fingerprint.
- **Decision:** Scheduled preview runs select eligible content by oldest observation time and then path, create no more than one preview, and atomically mark it pending. Existing pending previews do not block later distinct candidates.
- **Decision:** Scheduled runs never install banners. Installation and denial remain interactive decisions bound to the exact preview hash.
- **Decision:** A failed or misidentified preview attempt may be returned to the eligible queue as unprocessed only through an atomic transition that preserves timestamped attempt context and clears active processing and preview fields.
- **Decision:** Queue selection is round-robin. Never-attempted eligible fingerprints precede returned items; returned items retain their last-attempt time and cannot recur until every less-recently attempted eligible fingerprint has had its turn. Ordinary preview declines rotate; terminal denial is reserved for an explicit permanent opt-out of that fingerprint.
- **Rationale:** Durable fingerprint state prevents duplicate work while allowing changed source content to be reassessed without weakening exact-preview approval.

## 2026-08-01 community pack-source expansion

- **Owner-confirmed:** Add r/StepMania, the ZIV Simulation Forums, GrooveStats event pages, International Timing Collective downloads, the ITG Wiki pack list, the StepMania Song Packs forum, and AlienSix's gameplay playlists to ThraxOS as approved pack and individual-song discovery or screening sources.
- **Decision:** Keep the ITG Packs spreadsheet, ITGDb, ZIV simfile catalog, and StepMania Online as the primary structured catalogs. Community posts, tournament pages, wikis, forums, and videos supplement catalog research but do not independently establish archive provenance or safety.
- **Rationale:** Current community research found durable value in combining structured metadata, active release discussions, competitive curation, historical context, and gameplay previews while preserving explicit pad, compatibility, provenance, and validation checks.

## 2026-08-01 Stamina RPG 10 upgrade

- **Decision:** Supersede the earlier hold on ITGMania 1.0.2: upgrade the canonical installation to ITGMania 1.3.0 and Simply Love 5.9.0 for native Stamina RPG 10 support.
- **Decision:** Install only the SRPG10 Unaffiliated and Stamina Nation packs for now; do not install Footspeed Empire, DPRT, NEP, doubles, or all-factions bundles without a later request.
- **Decision:** Use Kyle's existing GrooveStats profile integration for SRPG10; do not purchase shop items or alter other profiles.

## 2026-08-01 community-inspired future-work selection

- **Owner-confirmed:** Track five community-inspired proposals: a song-library integrity report, a private-LAN phone controller and guest kiosk, a StepManiaX panel diagnostic recorder, a household attract/dashboard mode, and guided guest onboarding.
- **Decision:** Treat these as researched proposals, not implementation authorization. Preserve the existing approval boundaries for live configuration, restarts, pad settings, profiles, downloads, and destructive cleanup.
- **Decision:** Keep the phone kiosk separate from Codex Remote and restrict any prototype to a private LAN, short-lived capability sessions, and allowlisted game actions. Do not expose public or arbitrary remote control.
- **Rationale:** The selected proposals address observed household usability, library integrity, and Gen4 maintenance needs while fitting ThraxOS's control-plane role.
