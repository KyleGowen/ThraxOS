# Codex automation: `Hourly Misc Banner Upscale Queue`

Observed live on 2026-08-02. Automation ID: `hourly-misc-banner-upscale-queue`.

## Definition

- Scheduler/status: Codex cron automation, active.
- Frequency: hourly at minute 0 in the Codex automation environment.
- Execution: local, scoped to the ThraxOS project and repository working directory.
- Model at observation: `gpt-5.6-sol`, high reasoning; availability is environment-specific.
- Dependencies: `thraxos`, `upscale-banner`, and `memory/banner-upscale-queue.json`.
- Live input: `C:\Games\ITGmania\Songs\Misc. Collected`; adapt path/scope on another host.

## Per-run contract

Load repository safety/context, refresh new or changed queue entries, and select exactly one eligible fingerprint. Selection is round-robin: never-attempted entries first by oldest observation/path, then returned entries by least-recent attempt, observation, and path. Atomically mark it pending and stage 836 x 328 preview option(s). Always render and directly link the exact full-resolution source `Before` and every exact viable `After` option, stating independently decoded pixel dimensions for each so native-size access remains available if the client scales the inline image. Record and request approval for one exact selected preview hash.

Interactive installation follow-ups resolve bare `install` only to the most recently displayed, explicitly labeled, queue-bound After in that same task, never to global pending order. Pass the queue's expected preview, source, and simfile hashes to the guarded installer; it refuses an open game or hash drift, verifies the sibling rollback, and returns full hash evidence. If backup state is degraded only because the task is currently running (`0x41301`), proceed only with a same-day success marker, confirmed Songs exclusion, and local rollback. Record the pending fingerprint as installed only after the helper proves the live banner equals the deterministic rendering of that exact preview. If installation created a missing referenced target from a contained fallback, prove the new target rather than the unchanged fallback. Refresh and verify exact-item terminal invariants; one additional refresh may recover a legacy concurrent rewrite, but never append the decision twice.

Every queue helper call uses a per-queue cross-process mutex around its read/modify/write cycle. A lock timeout must stop or retry later; it never authorizes direct JSON editing. Global counts may change while other tasks reserve candidates, so interactive verification keys on the exact song, installed-content fingerprint, preview hash, installed-source hash, and single decision history.

Forward built-in image-generation results with the runtime's generated-image result handler. Do not classify a result as an incomplete model payload merely because generic content-block parsing found nothing. Recover or re-emit an existing result before another model call, and do not count output handling as a generative attempt when the image result is recoverable.

When inline and saved-file views appear inconsistent, stop before another model call or queue transition. Hash and standard-decode the saved file, preserve it, normalize a separate staged copy with `Normalize-GeneratedBannerPreview.ps1`, and inspect that copy. Pass `-Opaque` when the design is intended to be fully opaque so high-quality resampling cannot introduce transparent edge pixels. Matching bytes or decoded pixels override a conflicting visual description: stage the verified result for owner review, and reserve `output-handling-error` for files that genuinely cannot be recovered or decoded.

Never install, mutate live songs, restart ITGMania, change configuration/charts/scores/profiles, duplicate a pending or terminal fingerprint, or silently switch processing methods. Generation failure, prompt error, or ordinary preview rejection returns the exact fingerprint to the queue with timestamped attempt context so it rotates behind less-recently attempted work. Explicit owner feedback that the current banner is good as-is becomes fingerprint-scoped `skipped`; changed content receives a fresh assessment. Only an explicit permanent owner opt-out becomes terminal `denied`. If no candidates remain, report counts and exit.

End every scheduled run with a retrospective over the run's prompt, tool results, validation, and queue transition. Record fingerprint-specific evidence in the queue. Promote only evidence-backed, reusable improvements into the skill and matching guides, then validate the skill. The later interactive install/denial response must run the same retrospective and capture the owner's reasoning with `-DecisionNote`; the scheduled preview run cannot infer feedback that has not yet been given.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-banner` first.
2. Initialize/refresh the target queue with `Update-BannerQueue.ps1`.
3. Create a local project Codex cron named `Hourly Misc Banner Upscale Queue`, hourly at minute 0, with the target repository working directory. Copy the behavioral prompt while replacing machine paths and project identity.
4. Select the new checkout's project; do not copy the source internal project ID.
5. Test one preview-only run. Confirm one fingerprint, independently decoded and normalized output with intended opacity, exact full-resolution `Before` and every viable labeled After rendered from their native files, decoded dimensions plus direct links for each, pending fingerprint/hash state, no live write or restart, a clear exact-option approval request, fingerprint-scoped good-as-is skipping, and a documented retrospective that does not invent owner feedback.
6. In a disposable song/queue fixture, test approved installation recording and refresh preservation. Confirm expected-hash and closed-game gates, rollback/installed hash output, exact installed-render proof, stale-source rejection, cross-process queue serialization, and terminal preview/decision history across the fingerprint change.
