# Decisions

## 2026-08-15 deferred hygiene follow-ups

- **Owner-confirmed:** Defer inspection of the StepManiaX firmware, sensitivity setting, and physical modifications. Do not launch diagnostics or change stage settings without a later request and the existing approval boundary.
- **Owner-confirmed:** Defer technical enforcement of the Kyle-only GrooveStats policy. Leave the pre-existing `elemwarr` and `Crios` credential files untouched unless the owner later requests a separately approved, recoverable configuration change.

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
- **Decision:** Render each `Before` and `After` from its exact full-resolution file, state independently decoded pixel dimensions, and include a direct native-file link so client-side inline scaling never hides the original size or detail.
- **Decision:** Treat image generation and result forwarding as separate phases. Use the built-in tool's generated-image result handler; do not count a recoverable result-forwarding or staging error as a failed generative attempt.
- **Decision:** When a simfile's contained banner target is missing, installation may create only that referenced target if the queue resolved an existing contained fallback and the installer preserves the fallback's exact bytes as the recoverable timestamped backup. Rollback must remove the newly created target rather than copying fallback bytes into it.
- **Decision:** End every banner run and install/deny follow-up with an evidence-based retrospective. Preserve exact-fingerprint reasoning in the queue, promote only stable owner-wide preferences or reusable workflow lessons, and validate every resulting skill edit. Never invent feedback or weaken safety boundaries in the name of self-improvement.
- **Decision:** Attempt GPT Image 2 high-fidelity restoration at most twice. Offer deterministic exact-content upscaling only after both attempts fail, and require explicit approval before switching unless the owner already approved that fallback.
- **Rationale:** This captures the successful Simply Love banner dimensions while separating creative generation from a minimal, reversible, validated live installation.

## 2026-08-02 banner candidate queue

- **Decision:** Maintain `memory/banner-upscale-queue.json` as the durable `Misc. Collected` banner queue, keyed by relative song path and content fingerprint. A terminal installed, denied, or skipped decision applies only to that fingerprint.
- **Decision:** Scheduled preview runs select eligible content by oldest observation time and then path, create no more than one preview, and atomically mark it pending. Existing pending previews do not block later distinct candidates.
- **Owner-confirmed:** Run the preview-only banner queue every four hours at 00:00, 04:00, 08:00, 12:00, 16:00, and 20:00 Pacific.
- **Decision:** Scheduled runs never install banners. Installation and denial remain interactive decisions bound to the exact preview hash.
- **Decision:** A failed or misidentified preview attempt may be returned to the eligible queue as unprocessed only through an atomic transition that preserves timestamped attempt context and clears active processing and preview fields.
- **Decision:** Queue selection is round-robin. Never-attempted eligible fingerprints precede returned items; returned items retain their last-attempt time and cannot recur until every less-recently attempted eligible fingerprint has had its turn. Ordinary preview declines rotate; explicit good-as-is feedback becomes fingerprint-scoped `skipped`, while terminal denial is reserved for an explicit permanent opt-out of that fingerprint.
- **Rationale:** Durable fingerprint state prevents duplicate work while allowing changed source content to be reassessed without weakening exact-preview approval.

## 2026-08-11 cover-inspired banner generation workflow

- **Owner-confirmed:** Create the project-local `generate-banner` skill for from-scratch banner redesigns after the owner rejects an original or asks for authentic release-art inspiration.
- **Decision:** Discover with one focused Google Images query, then verify the selected image on Discogs, an official artist or label page, Bandcamp, Apple Music, Spotify, MusicBrainz/Cover Art Archive, or another established music catalog before using it as inspiration.
- **Decision:** Generate an original opaque 836 x 328 composition from verified palette, era, typography category, motifs, materials, and layout rhythm. Do not copy sleeve layouts, logos, label names, catalog numbers, watermarks, identifiable people, or noncanonical credits.
- **Decision:** Reuse `upscale-banner` fingerprint reservation, canonical metadata, two-attempt, normalization, presentation, exact-preview approval, queue rotation, and guarded-install boundaries. `generate-banner` never installs during generation.
- **Rationale:** Cover research supports a stronger replacement when faithful restoration is unwanted while preserving release identity, canonical text, owner approval, and live-library safety.

## 2026-08-03 banner installation hardening

- **Decision:** Bare `install` refers only to the most recently displayed, explicitly labeled, queue-bound After in the same task; never resolve it from global pending order or an unlabeled artifact.
- **Decision:** Pass expected preview, live-source, and simfile hashes into the guarded banner installer. The installer must refuse an open game or hash drift, verify the sibling rollback, and return hashes for the preview, original, backup, installed file, and unchanged simfile.
- **Decision:** Serialize banner-queue helper read/modify/write cycles with a per-queue cross-process mutex. Verify exact installed-item invariants after refresh instead of relying on mutable global counts, and never duplicate a decision while recovering from a legacy concurrent rewrite.
- **Decision:** Read and write the banner queue explicitly as UTF-8 without a BOM. Windows PowerShell implicit decoding is prohibited because it can corrupt non-ASCII attempt and decision history during otherwise valid atomic transitions.
- **Decision:** Treat backup result `0x41301` as an active-run degraded state, not a completed failure. Banner installation may proceed in that state only with a same-day successful log, confirmed Songs exclusion, and guarded local rollback.
- **Decision:** Preserve opaque approved previews as fully opaque installed output, and use the identical pixel-format-aware renderer for live installation and queue proof.
- **Decision:** When a banner source outside the repository opens through its native link but cannot render inline, use a SHA-verified, byte-identical full-resolution workspace display copy only for presentation. Keep the authoritative path/hash, native link, preview approval, and queue binding unchanged.
- **Rationale:** Repeated interactive installs exposed avoidable manual hash work, a time-of-check gap, one stale concurrent queue rewrite, and transparent perimeter pixels introduced while resizing an opaque attachment. Hash-bound, opacity-safe installation and serialized queue updates make the same approval-gated workflow faster and more reliable without widening live-write authority.

## 2026-08-02 static background restoration workflow

- **Decision:** Use the project-local `upscale-background` skill for explicit static song backgrounds. Target the owner-confirmed windowed 1920 x 1080 16:9 presentation; prefer faithful restoration and outpainting, and require the exact labeled preview before installation.
- **Decision:** Exclude missing backgrounds, `BGCHANGES`, videos, animated/multi-frame images, GIF, conflicting references, implicit legacy artwork, unsafe paths, and undecodable images. Missing-background creation is a separate future workflow.
- **Decision:** Maintain `memory/background-upscale-queue.json` for `Misc. Collected`, using fingerprint-bound history and terminal decisions. Ordinary denials rotate; only explicit permanent opt-out is terminal. New owner-supplied source material authorizes another attempt and may support a from-scratch composition.
- **Decision:** Record explicit owner feedback that valid artwork is good as-is as fingerprint-scoped `skipped`, distinct from `denied`. A source or simfile change creates a new fingerprint and triggers a fresh assessment.
- **Decision:** Run the preview-only background queue every four hours at 02:00, 06:00, 10:00, 14:00, 18:00, and 22:00 Pacific, one new candidate maximum per run. Pending candidates do not block others. Bare `install` authorizes the sole displayed, task-local hash-bound candidate; when several candidates are displayed, approval must name `Install A`, `Install B`, and so on.
- **Owner-confirmed:** Treat whitespace-only `#BGCHANGES:;` as empty metadata rather than dynamic content. Continue excluding populated or malformed changes.
- **Decision:** Prioritize eligible explicit static art by severity: broken/tiny, aspect mismatch, SD-or-smaller, sub-HD, then soft-review. Preserve round-robin ordering within a tier. Only clean near-16:9 soft-review art at 1280 x 720 or better may be skipped solely for adequate runtime quality.
- **Decision:** When a background fingerprint exhausts both genuine AI attempts and deterministic fallback needs owner approval, retain it as pending with `pendingAction=awaiting-fallback-approval`; do not return it to eligible. Pending work remains non-blocking, so lower quality tiers continue instead of being starved by the exhausted highest-severity item.
- **Decision:** Record plausible implicit DWI artwork and missing-reference fallbacks as non-selectable `review-only` records. A filename heuristic may support owner review but never establishes the runtime source or authorizes generation, simfile edits, or installation.
- **Decision:** Preserve queue status and history across assessment-rule fingerprint migrations only when the explicit reference, source hash, and simfile hashes remain exact. Rule changes must not silently reopen an unchanged owner-skipped or denied source; content changes still receive a fresh assessment.
- **Decision:** Read and write the background queue and retrospective ledger explicitly as UTF-8 without a BOM. Windows PowerShell implicit decoding is prohibited because it can repeatedly corrupt non-ASCII history and expand the queue on subsequent rewrites.
- **Owner-confirmed:** Background approval and owner-decision messages must lead with the full canonical simfile artist and song title, include useful identification metadata such as pack/folder and source/candidate dimensions, and carry artist/title into the inbox item. Do not infer missing metadata from artwork or filenames.
- **Owner-confirmed:** Every rendered background `Before` and `After` must list decoded dimensions and aspect ratio. Report reduced `W:H` plus decimal `W/H:1`, and identify display-only copies separately from the exact install candidate.
- **Decision:** Resolve bare `install` only when exactly one installable candidate was displayed and hash-bound in the same task; also accept its explicit label such as `Install A`. When several candidates were displayed, require `Install A`, `Install B`, and so on. Never infer approval from global pending order or an unlabeled artifact. After current backup verification, prefer `Complete-ApprovedBackgroundInstall.ps1` so one mutex-held workflow consumes queue hashes, invokes the guarded installer, records proof without shell-quoting hazards, refreshes the installed-content fingerprint, and validates terminal state.
- **Decision:** Serialize background queue operations with a per-queue cross-process mutex. The lower-level installer must refuse an open game or expected-hash drift, recheck immediately before the live write, verify a unique sibling rollback, return structured hashes and presentation data, and use a byte-exact same-format fast path when a matching opaque 1920 x 1080 preview needs no normalization.
- **Owner-confirmed:** Background inline previews must render correctly on the first presentation. Generate local image blocks with a forward-slash, percent-encoded Windows path and native-file link; never use an angle-wrapped backslash path inside an image tag. Treat a broken placeholder with a working file/hash as response-rendering failure, and recover from a verified short-path byte-identical display copy without regenerating or changing the exact queue binding.
- **Rationale:** This preserves static-media safety, reversible installation, owner control, and useful iteration while keeping missing or dynamic-background work out of scope.

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

## 2026-08-02 repository publication workflow

- **Decision:** Use the project-local `ship-all` skill when the owner requests "commit and push everything" or equivalent publication of the complete intended worktree to `origin/main`.
- **Rationale:** Whole-worktree review, privacy exclusions, proportional validation, explicit staging, non-destructive branch handling, and ordinary non-force pushes preserve compatible work while preventing secret leakage or history loss.

## 2026-08-05 controller setup workflow

- **Owner-confirmed:** Create the project-local `connect-controller` skill for menu-only handheld controllers, retaining StepManiaX as the gameplay controller. Store each first-class controller as an independently copyable rider file in the skill.
- **Decision:** Promote a controller rider only after owner confirmation of pairing/reconnect, Windows input evidence, ITGMania navigation, song-wheel submenu, normal-exit persistence, and unchanged StepManiaX gameplay behavior.
- **Decision:** Require a final explicit approval before every live driver, pairing, application, or Keymaps mutation; use a hash-gated sibling rollback and honor ITGMania's two-input-per-action limit.

## 2026-08-05 individual-song installation workflow

- **Owner-confirmed:** Create a project-local skill that efficiently resolves, downloads, validates, installs, and cleans up one individual song for `Misc. Collected`.
- **Decision:** Keep single-song handling in `add-song`, separate from the pack-layout assumptions in `add-pack`. Use one deterministic GUID-staged command, require publisher provenance and expected artist/title metadata, retain the existing backup/game/Defender/collision boundaries, and remove only task-owned staging in `finally`.
- **Rationale:** Individual ZIV-style ZIPs place simfile and audio directly in one song folder, while pack archives contain a pack folder with child song folders. Separate validators preserve strict layout checks without manual extraction residue or unsafe pack-script exceptions.

## 2026-08-05 individual-song discovery workflow

- **Owner-confirmed:** Create `find-singles` to reproduce the family-taste individual-song search and return up to 10 candidates for the people who use Thraximundar.
- **Decision:** Keep `find-singles` read-only and separate from `add-song` installation and `itg-packs-search` whole-pack discovery. Require the canonical family taste profile, current approved public sources, exact release/pad evidence, both live song roots, metadata-aware overlap review, and at most 10 genuinely supported unique results.
- **Decision:** Use bounded combined `rg` metadata lookup plus normalized folder leads for finalist overlap, returning only candidate-specific pack/song labels. Do not build or print a complete library inventory.
- **Rationale:** This preserves the earlier successful recommendation logic while making repeated searches current, efficient, household-specific, and resistant to installed-song duplicates and mirrored-chart duplication.

## 2026-08-05 dynamic player skill-level workflow

- **Owner-confirmed:** Replace static per-player difficulty ranges with dynamic evidence derived from each profile's recent `Stats.xml` activity, and never use that evidence to infer musical taste.
- **Owner-confirmed:** For each profile, use the 90 days ending at its latest recorded score. Define stretch as the highest live simfile meter with at least two resolved successful records in that window.
- **Owner-confirmed:** Maintain a portable common-name map seeded as Kyle=`kyle`, Samantha=`sam`, Eliza=`lizy`, Quinn=`elemwarr`, and Rich=`crios`.
- **Decision:** Match only trimmed, Unicode case-insensitive exact `Stats/GeneralData/DisplayName` aliases; omit and report unmapped profiles. Store no profile paths or GUIDs. Join Stats song directory, StepsType, and Difficulty to current simfiles and report unresolved or ambiguous records rather than guessing.
- **Decision:** Treat `Stats.xml` as dated high-score evidence, not a complete play log. Regenerate skill output for every consumer and keep numeric skill levels out of the musical-taste context.

## 2026-08-13 cover-inspired background generation workflow

- **Owner-confirmed:** Create the project-local `generate-background` skill from the successful scratch-background workflow for owner-requested redesigns and display-maximized replacements.
- **Decision:** Verify authentic release art through one focused image search plus an official or established music source, then generate an original opaque single-frame 1920 x 1080 composition from high-level palette, era, typography, texture, motif, lighting, and compositional evidence without copying the cover, logos, watermarks, identifiable people, or release marks.
- **Decision:** Reuse `upscale-background` exact-source resolution, serialized fingerprint history, two-attempt ceiling, presentation, hash-bound approval, proof-gated installation, and once-only learning record. Preserve raw outputs and normalize only near-16:9 generations with the tested helper; material aspect mismatch requires regeneration or outpainting rather than stretching.
- **Rationale:** This makes the successful release-research and original-generation method reproducible while preserving the existing static-background queue and live-library safety model.

## 2026-08-14 DDR 4th Mix hourly background queue

- **Owner-confirmed:** Retarget the existing background-preview automation from `Misc. Collected` to `C:\Games\ITGmania\Songs\DDR 4th Mix` and run it hourly.
- **Decision:** Preserve `memory/background-upscale-queue.json` as the completed `Misc. Collected` ledger. Use the separate `memory/ddr-4th-mix-background-upscale-queue.json` ledger for DDR 4th Mix, and pass its exact pack and queue paths to every update, learning, and completion helper.
- **Decision:** Keep the stable automation ID `hourly-misc-background-upscale-queue` for continuity while renaming the displayed task to `Hourly DDR 4th Mix Background Upscale Queue`.
- **Rationale:** Separate pack-scoped ledgers preserve prior fingerprint decisions and prevent a refresh of one pack from replacing another pack's durable history.

## 2026-08-14 controller coexistence

- **Decision:** Protect StepManiaX gameplay bindings from handheld-controller arrivals by keeping `AutoMapOnJoyChange=0`. Restore the pad's verified Player 1 button bindings first; use the second binding slots for reliable keyboard menu controls when a handheld controller is not enumerated by ITGMania.
- **Rationale:** ITGMania retains only two bindings per action. Its current session exposed StepManiaX but not the paired NES controller, so a three-way pad/NES/keyboard direction map is impossible and would risk breaking the gameplay pad again.
- **Decision applied:** When the NES controller is present as `Joy2`, use its Select button as the second Player 1 Left and Right binding to emit the song-wheel submenu chord. Keep StepManiaX as the first binding on those actions; move keyboard A/D to dedicated menu-left/menu-right instead of replacing a pad binding.

## 2026-08-14 missing-banner queue routing

- **Owner-confirmed:** Expand the `Misc. Collected` banner queue to find entirely missing banner files and route them directly through the project-local `generate-banner` workflow.
- **Decision:** A source-less banner is selectable only when every `.sm` and `.ssc` agrees on one identical, nonblank, contained `#BANNER` target, that file is absent, and no decodable banner-shaped fallback exists. Record it as `generationMode=generate-banner` with null source evidence. Blank, absent, inconsistent, ambiguous, or escaping declarations remain ineligible; the workflow never guesses a filename or edits a simfile.
- **Decision:** A source-less preview shows a factual missing Before state, not fabricated or substituted artwork. Scheduled runs remain preview-only. A later exact-preview installation requires explicit `-SourceLessGeneration`, creates only the unchanged declared target, and records `RollbackAction=RemoveCreatedTarget` because target absence is the recoverable prior state.
- **Rationale:** This adds missing artwork without weakening fingerprint selection, owner approval, live-write, or rollback boundaries.

## 2026-08-16 AgentOS inheritance

- **Owner-confirmed:** Permanently inherit AgentOS's global identity, communication, privacy, verification, approval, memory, GitHub synchronization, and skill-learning rules without importing other projects' context.
- **Decision:** Load the compact commit-pinned `memory/AGENTOS_INHERITANCE.md` cache for relevant tasks. Prefer the configured local AgentOS checkout, fetch metadata only, use committed `origin/main`, ignore uncommitted changes, and inspect only changed recorded source files when the SHA advances.
- **Decision:** ThraxOS remains authoritative for every Thraximundar-specific rule and reports material conflicts. AgentOS remains authoritative for global governance and course state; writes require explicit approval, a local checkout, and the cache's narrow allowlist.
- **Rationale:** Commit provenance and selective refresh make inheritance portable, reviewable, and token-efficient without leaking unrelated project context or weakening machine-specific safety.

## 2026-08-16 Arcade Console capability and schedule board

- **Owner-confirmed:** Provide a StepManiaX/DDR-themed, user-friendly web console that shows every ThraxOS skill and current recurring work, collects only predefined inputs, and can schedule allowlisted future work.
- **Decision:** Reuse the localhost-first Arcade Console. It exposes fixed read-only helpers directly, turns agent-led and mutating work into review requests, discovers only ThraxOS-scoped Codex automations, and translates known recurring schedules into local-time descriptions.
- **Decision:** Dashboard-created schedules require an explicit in-page acknowledgement, run only while the console is open, and either invoke a fixed read-only helper or create a review request. They never create arbitrary commands or alter Windows Task Scheduler/Codex automations.
- **Rationale:** The console makes ThraxOS capabilities discoverable and approachable without weakening the host's approval, remote-access, or allowlist boundaries.
