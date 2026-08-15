# Codex automation: `Hourly DDR 4th Mix Background Upscale Queue`

Created 2026-08-02; scope and hourly schedule owner-updated 2026-08-14. The stable automation ID remains `hourly-misc-background-upscale-queue` for continuity.

## Definition

- Scheduler/status: active Codex cron automation.
- Frequency: once per hour, America/Los_Angeles.
- Execution: local, scoped to the ThraxOS project working directory.
- Model at observation: `gpt-5.6-sol`, high reasoning; availability is environment-specific.
- Notifications: failed runs only.
- Dependencies: `thraxos`, `upscale-background`, and `memory/ddr-4th-mix-background-upscale-queue.json`.
- Live input: `C:\Games\ITGmania\Songs\DDR 4th Mix`. The task must not expand scope automatically.
- Retained prior state: `memory/background-upscale-queue.json` remains the completed `Misc. Collected` ledger and must not be reused or overwritten by this automation.
- Concurrency: each invocation selects at most one non-pending fingerprint; pending items do not block unrelated work.

## Per-run contract

All queue and retrospective JSON reads and writes must use explicit UTF-8 without a BOM. Every update or retrospective call must pass the exact DDR 4th Mix pack and queue paths above. Do not substitute Windows PowerShell's implicit text decoding; the durable history may contain non-ASCII text and must remain byte-stable across hourly rewrites.

Load safety/context and refresh the ledger so added or changed songs receive new fingerprint assessments. Require the same nonblank explicit `#BACKGROUND` in every `.sm`/`.ssc`; a blank or missing companion tag cannot enter automatic selection. Treat whitespace-only `#BGCHANGES:;` as empty metadata; exclude populated or malformed changes, video, GIF/animation, conflicts, traversal, and undecodable images. Put plausible implicit DWI art and missing-reference fallbacks into the non-selectable `review-only` lane. Select one explicit static candidate by quality tier—broken/tiny, aspect mismatch, SD-or-smaller, sub-HD, then soft-review—then by round-robin history within that tier.

Visually assess the source before generation. Broken/tiny, aspect-mismatched, SD-or-smaller, and sub-HD sources remain processing candidates even if otherwise clean. Skip clean near-16:9 art for adequate runtime quality only in the soft-review tier at 1280 x 720 or better, with a factual fingerprint-scoped decision.

Reserve the candidate, stage faithful opaque 1920 x 1080 option(s), and render `Before` plus all labeled `After` options. For every image, list decoded dimensions and its aspect ratio as reduced `W:H` plus decimal `W/H:1`. Build each local inline block with `Format-BackgroundPreviewMarkdown.ps1` and use its forward-slash, percent-encoded destination verbatim; never hand-write an angle-wrapped Windows backslash path in an image tag. If a working native link accompanies a broken placeholder, revalidate the exact file/hash and re-emit it, using a verified short-path byte-identical display copy if necessary, without another model call or queue transition. Label display-only copies separately from exact candidates. Prefer outpainting for aspect repair and deterministic scaling only for sound 16:9 art. Bind the preview hash and request exact approval. Never install, touch the live song tree, restart/terminate ITGMania, or change game/configuration/profile data. Return ordinary recoverable failures and denials with factual history. If two genuine AI attempts are already exhausted and deterministic fallback requires owner approval, do not return the fingerprint to eligible: call `Update-BackgroundQueue.ps1 -AwaitOwnerInput` with a factual attempt outcome/note so it remains pending with `pendingAction=awaiting-fallback-approval`. This prevents a highest-severity exhausted item from being selected every hour while lower tiers starve. Resume it only through the interactive task after explicit fallback approval or new source material. Record explicit owner good-as-is feedback as fingerprint-scoped `skipped`; terminal `denied` requires an explicit permanent opt-out. Changed content receives a fresh assessment. End with an evidence-based retrospective without inventing preferences.

The approval question must match the displayed candidates. When exactly one installable candidate exists, ask for `Install`; accept either bare `install` or its explicit label such as `Install A` only for that sole task-local hash binding. When several candidates exist, enumerate and require `Install A`, `Install B`, and so on; bare `install` is ambiguous and must not authorize a live write.

Before asking for approval or another owner decision, read canonical metadata from the exact simfile. Lead with the full nonblank `ARTIST — TITLE`, append a nonblank subtitle, and include the pack, song folder, quality tier, Before dimensions/aspect ratio, every candidate label with output dimensions/aspect ratio, and useful nonblank transliteration, genre, or credit fields. Do not infer missing metadata from artwork or folder names. Put artist and title in the inbox item title or summary so the notification is identifiable on its own.

Finish every run by invoking `Record-BackgroundLearning.ps1` exactly once. Use `none` for no reusable lesson, `fingerprint` for source-specific evidence, or `reusable` only after making the smallest justified skill and documentation edits and validating them. Refresh preserves status and history across assessment-rule fingerprint changes when the explicit reference, source hash, and simfile hashes are unchanged; it also preserves installed state when the live source exactly matches its approved preview hash. Genuinely different content receives a new assessment. A scheduled-behavior change also requires updating this automation prompt. Never fabricate a change to avoid recording `none`.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-background`.
2. Run `Test-BackgroundQueue.ps1` and `Test-BackgroundInstallWorkflow.ps1`, validate the skill, then initialize the dedicated queue with `Update-BackgroundQueue.ps1 -PackPath 'C:\Games\ITGmania\Songs\DDR 4th Mix' -QueuePath '<repo>\memory\ddr-4th-mix-background-upscale-queue.json' -Refresh`. Confirm the ledger records the exact resolved pack path, blank companion `#BACKGROUND` tags fail automatic eligibility, Unicode history survives repeated rewrites, formatter fixtures with spaces, parentheses, and `#` produce forward-slash percent-encoded inline paths, mutex serialization works, stale hashes fail closed, and exact/normalized installs preserve terminal proof.
3. Create a local project Codex cron named `Hourly DDR 4th Mix Background Upscale Queue`, once per hour in the host timezone, using the behavioral contract above. Preserve the existing automation ID when updating an installed copy.
4. Test one preview-only run. Confirm empty-tag acceptance, active-change exclusion, review-only nonselection, severity-first ordering, one selected fingerprint, formatter-produced labeled source/result rendering with dimensions and reduced-plus-decimal aspect ratios plus working native links, canonical artist/title plus useful identification metadata in the approval message and inbox item, recorded preview hash, no live write, `Install` acceptance only for one displayed hash-bound candidate, label-required `Install A`/`Install B` choices when several exist, and that skipped or attempt-exhausted fingerprints do not re-enter selection unless their content or owner decision changes.
