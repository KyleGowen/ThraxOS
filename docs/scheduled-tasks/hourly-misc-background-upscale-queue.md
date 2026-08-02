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

Load safety/context; refresh the ledger so added or changed songs receive new fingerprint assessments; exclude missing, changing, animated, video, implicit, conflicting, unsafe, or undecodable backgrounds; then select one candidate by round robin. Visually assess nominally low-resolution candidates before generation so clean art is not processed solely because of dimensions.

Reserve the candidate, stage faithful opaque 1920 x 1080 option(s), and render `Before` plus all labeled `After` options. Prefer outpainting for aspect repair and deterministic scaling only for sound 16:9 art. Bind the preview hash and request exact approval. Never install, touch the live song tree, restart/terminate ITGMania, or change game/configuration/profile data. Return ordinary failures and denials with factual history. Record explicit owner good-as-is feedback as fingerprint-scoped `skipped`; terminal `denied` requires an explicit permanent opt-out. Changed content receives a fresh assessment. End with an evidence-based retrospective without inventing preferences.

Finish every run by invoking `Record-BackgroundLearning.ps1` exactly once. Use `none` for no reusable lesson, `fingerprint` for source-specific evidence, or `reusable` only after making the smallest justified skill and documentation edits and validating them. Refresh preserves an installed decision when the live source hash exactly matches its approved preview hash; genuinely different content receives a new assessment. A scheduled-behavior change also requires updating this automation prompt. Never fabricate a change to avoid recording `none`.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-background`.
2. Initialize the queue with `Update-BackgroundQueue.ps1 -Refresh`.
3. Create a local project Codex cron named `Hourly Misc Background Upscale Queue`, hourly at minute 30 in the host timezone, using the behavioral contract above.
4. Test one preview-only run. Confirm new-song refresh, one selected fingerprint, labeled source/result rendering, recorded preview hash, no live write, an exact install question, and that a skipped fingerprint is not selected again unless its content changes.
