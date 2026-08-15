# Codex automation: `Hourly Misc Banner Upscale Queue`

Observed live and reconciled on 2026-08-14. Automation ID: `hourly-misc-banner-upscale-queue`.

## Definition

- Scheduler/status: Codex cron automation, active.
- Frequency: every four hours at 00:00, 04:00, 08:00, 12:00, 16:00, and 20:00 in the host timezone (America/Los_Angeles on Thraximundar).
- Execution: local, scoped to the ThraxOS project and repository working directory.
- Model at observation: `gpt-5.6-sol`, high reasoning; availability is environment-specific.
- Notifications: no explicit policy is set; use the target Codex environment's default unless the owner chooses a different policy.
- Dependencies: `thraxos`, `upscale-banner`, optional on-demand `generate-banner`, and `memory/banner-upscale-queue.json`.
- Live input: `C:\Games\ITGmania\Songs\Misc. Collected`; adapt path/scope on another host.

## Per-run contract

Load repository safety/context, refresh new or changed queue entries, and select exactly one eligible fingerprint. Every simfile for a selectable song must declare exactly one identical, nonblank, contained `#BANNER`; blank, missing, ambiguous, inconsistent, or escaping declarations remain ineligible. A referenced file that is absent with no decodable banner-shaped fallback is eligible as `generationMode=generate-banner`. Selection remains round-robin: never-attempted entries first by oldest observation/path, then returned entries by least-recent attempt, observation, and path. Atomically mark it pending and stage one 836 x 328 preview.

For existing or fallback art, follow `upscale-banner` restoration and render the exact full-resolution source `Before` plus the exact viable `After` through `Format-BannerPreviewMarkdown.ps1`. For a source-less record, automatically follow `generate-banner`: verify release art, create an original canonical-text-complete design, render a factual `Before` state naming the absent target and lack of fallback, then render the exact After normally. Never fabricate or substitute a Before image. Both branches retain the same two-attempt ceiling, exact preview hash binding, approval question, and preview-only scheduled boundary.

When a later owner-authorized retry creates a banner from scratch or uses existing artwork only as inspiration, parse `#TITLE`, `#ARTIST`, and optional `#SUBTITLE` from every simfile first. Require consistent nonblank title and artist metadata. Put the canonical song title, full artist name, every featuring credit, and every remix/edit/mix/version label into the prompt verbatim and require all of it to remain readable after normalization. Do not infer credits from artwork or filenames. Missing, conflicting, altered, cropped, or unreadable required copy rejects the candidate and must be recorded in exact-fingerprint history.

Route both owner-authorized redesigns and automatic source-less selections through `generate-banner`: run one focused Google Images query, verify the chosen lead on an established release page, and save only one or two hash-recorded references in task staging. Use them for palette, era, typography category, motifs, and layout rhythm, not as direct copies. Reject duplicated, unrelated, missing, altered, cropped, or unreadable canonical text. `generate-banner` remains preview-only and uses the same fingerprint reservation, two-attempt ceiling, normalization, queue binding/return, and exact-preview approval boundaries.

Interactive installation follow-ups resolve bare `install` only to the most recently displayed, explicitly labeled, queue-bound After in that same task. The guarded installer refuses an open game or hash drift and writes only the unchanged contained target. Source-less creation additionally requires explicit `-SourceLessGeneration`. It verifies a sibling backup when an original/fallback exists; when the target was entirely source-less, it reports `RollbackAction=RemoveCreatedTarget` and no fabricated original or backup hash. Record installed only after the helper proves the live banner equals the deterministic rendering of that exact preview and follows the expected fallback-or-source-less transition.

Every queue helper call uses a per-queue cross-process mutex around its read/modify/write cycle and explicitly reads/writes UTF-8 without a BOM so non-ASCII attempt and decision history survives Windows PowerShell. A lock timeout must stop or retry later; it never authorizes direct JSON editing. Global counts may change while other tasks reserve candidates, so interactive verification keys on the exact song, installed-content fingerprint, preview hash, installed-source hash, and single decision history.

Forward built-in image-generation results with the runtime's generated-image result handler. Do not classify a result as an incomplete model payload merely because generic content-block parsing found nothing. Recover or re-emit an existing result before another model call, and do not count output handling as a generative attempt when the image result is recoverable.

If an inline preview shows a broken placeholder while its full-resolution link opens, treat that as response-rendering failure. Revalidate the authoritative file/hash and the formatter's workspace `DisplayPath` / matching `DisplaySha256`, then re-emit the formatter-produced block; do not call the model again, rotate the fingerprint, or classify the generation as missing.

When inline and saved-file views appear inconsistent, stop before another model call or queue transition. Hash and standard-decode the saved file, preserve it, normalize a separate staged copy with `Normalize-GeneratedBannerPreview.ps1`, and inspect that copy. Pass `-Opaque` when the design is intended to be fully opaque so high-quality resampling cannot introduce transparent edge pixels. Matching bytes or decoded pixels override a conflicting visual description: stage the verified result for owner review, and reserve `output-handling-error` for files that genuinely cannot be recovered or decoded.

Never install, mutate live songs, restart ITGMania, change configuration/charts/scores/profiles, duplicate a pending or terminal fingerprint, or silently switch processing methods. Generation failure, prompt error, or ordinary preview rejection returns the exact fingerprint to the queue with timestamped attempt context so it rotates behind less-recently attempted work. Explicit owner feedback that the current banner is good as-is becomes fingerprint-scoped `skipped`; changed content receives a fresh assessment. Only an explicit permanent owner opt-out becomes terminal `denied`. If no candidates remain, report counts and exit.

End every scheduled run with a retrospective over the run's prompt, tool results, validation, and queue transition. Record fingerprint-specific evidence in the queue. Promote only evidence-backed, reusable improvements into the skill and matching guides, then validate the skill. The later interactive install/denial response must run the same retrospective and capture the owner's reasoning with `-DecisionNote`; the scheduled preview run cannot infer feedback that has not yet been given.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-banner` first.
2. Initialize/refresh the target queue with `Update-BannerQueue.ps1`.
3. Create a local project Codex cron named `Hourly Misc Banner Upscale Queue`, every four hours at 00:00, 04:00, 08:00, 12:00, 16:00, and 20:00 in the host timezone, with the target repository working directory. Copy the behavioral prompt while replacing machine paths and project identity.
4. Select the new checkout's project; do not copy the source internal project ID.
5. Run `Test-BannerPreviewMarkdown.ps1`, then test both branches: an external existing source must use a SHA-identical workspace display copy and native link; a source-less candidate must show a factual missing Before state with no fabricated image. Confirm exact opaque 836 x 328 After binding, canonical title/artist/credit text, no live write or restart, and the exact install question. Conflicting cross-simfile metadata must remain ineligible.
6. In a disposable fixture, test both existing-source and source-less approved installs. Confirm expected-hash and closed-game gates, backup evidence for existing art, delete-created-target rollback for absent art, opacity, exact installed-render proof, unchanged simfiles, cross-process queue serialization, and terminal history across fingerprint changes.
