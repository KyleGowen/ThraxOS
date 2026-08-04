# Codex automation: `Hourly Misc Background Upscale Queue`

Created 2026-08-02. Automation ID: `hourly-misc-background-upscale-queue`.

## Definition

- Scheduler/status: active Codex cron automation.
- Frequency: every hour at minute 30, America/Los_Angeles.
- Execution: local, scoped to the ThraxOS project working directory.
- Dependencies: `thraxos`, `upscale-background`, and `memory/background-upscale-queue.json`.
- Live input: `C:\Games\ITGmania\Songs\Misc. Collected`. The skill may later accept other explicit folders, but this task must not expand scope automatically.
- Concurrency: each invocation selects at most one non-pending fingerprint; pending items do not block unrelated work.

## Per-run contract

All queue and retrospective JSON reads and writes must use explicit UTF-8 without a BOM. Do not substitute Windows PowerShell's implicit text decoding; the durable history may contain non-ASCII text and must remain byte-stable across hourly rewrites.

Load safety/context and refresh the ledger so added or changed songs receive new fingerprint assessments. Require the same nonblank explicit `#BACKGROUND` in every `.sm`/`.ssc`; a blank or missing companion tag cannot enter automatic selection. Treat whitespace-only `#BGCHANGES:;` as empty metadata; exclude populated or malformed changes, video, GIF/animation, conflicts, traversal, and undecodable images. Put plausible implicit DWI art and missing-reference fallbacks into the non-selectable `review-only` lane. Select one explicit static candidate by quality tier—broken/tiny, aspect mismatch, SD-or-smaller, sub-HD, then soft-review—then by round-robin history within that tier.

Visually assess the source before generation. Broken/tiny, aspect-mismatched, SD-or-smaller, and sub-HD sources remain processing candidates even if otherwise clean. Skip clean near-16:9 art for adequate runtime quality only in the soft-review tier at 1280 x 720 or better, with a factual fingerprint-scoped decision.

Reserve the candidate, stage faithful opaque 1920 x 1080 option(s), and render `Before` plus all labeled `After` options. For every image, list decoded dimensions and its aspect ratio as reduced `W:H` plus decimal `W/H:1`; label display-only copies separately from exact candidates. Prefer outpainting for aspect repair and deterministic scaling only for sound 16:9 art. Bind the preview hash and request exact approval. Never install, touch the live song tree, restart/terminate ITGMania, or change game/configuration/profile data. Return ordinary recoverable failures and denials with factual history. If two genuine AI attempts are already exhausted and deterministic fallback requires owner approval, do not return the fingerprint to eligible: call `Update-BackgroundQueue.ps1 -AwaitOwnerInput` with a factual attempt outcome/note so it remains pending with `pendingAction=awaiting-fallback-approval`. This prevents a highest-severity exhausted item from being selected every hour while lower tiers starve. Resume it only through the interactive task after explicit fallback approval or new source material. Record explicit owner good-as-is feedback as fingerprint-scoped `skipped`; terminal `denied` requires an explicit permanent opt-out. Changed content receives a fresh assessment. End with an evidence-based retrospective without inventing preferences.

The approval question must enumerate exact commands matching the displayed labels: ask for `Install A` when one candidate exists, or `Install A`, `Install B`, and so on when several exist. Never ask for or resolve bare `install`; it is too ambiguous to authorize a live write.

Before asking for approval or another owner decision, read canonical metadata from the exact simfile. Lead with the full nonblank `ARTIST — TITLE`, append a nonblank subtitle, and include the pack, song folder, quality tier, Before dimensions/aspect ratio, every candidate label with output dimensions/aspect ratio, and useful nonblank transliteration, genre, or credit fields. Do not infer missing metadata from artwork or folder names. Put artist and title in the inbox item title or summary so the notification is identifiable on its own.

Finish every run by invoking `Record-BackgroundLearning.ps1` exactly once. Use `none` for no reusable lesson, `fingerprint` for source-specific evidence, or `reusable` only after making the smallest justified skill and documentation edits and validating them. Refresh preserves status and history across assessment-rule fingerprint changes when the explicit reference, source hash, and simfile hashes are unchanged; it also preserves installed state when the live source exactly matches its approved preview hash. Genuinely different content receives a new assessment. A scheduled-behavior change also requires updating this automation prompt. Never fabricate a change to avoid recording `none`.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-background`.
2. Run `Test-BackgroundQueue.ps1` and `Test-BackgroundInstallWorkflow.ps1`, validate the skill, then initialize the queue with `Update-BackgroundQueue.ps1 -Refresh`. Confirm blank companion `#BACKGROUND` tags fail automatic eligibility, Unicode history survives repeated rewrites, mutex serialization works, stale hashes fail closed, and exact/normalized installs preserve terminal proof.
3. Create a local project Codex cron named `Hourly Misc Background Upscale Queue`, hourly at minute 30 in the host timezone, using the behavioral contract above.
4. Test one preview-only run. Confirm empty-tag acceptance, active-change exclusion, review-only nonselection, severity-first ordering, one selected fingerprint, labeled source/result rendering with dimensions and reduced-plus-decimal aspect ratios, canonical artist/title plus useful identification metadata in the approval message and inbox item, recorded preview hash, no live write, an exact label-bearing `Install A`/`Install B` question with no bare-install option, and that skipped or attempt-exhausted fingerprints do not re-enter selection unless their content or owner decision changes.
