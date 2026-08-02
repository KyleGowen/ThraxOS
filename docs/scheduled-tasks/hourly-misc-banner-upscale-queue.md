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

Load repository safety/context, refresh new or changed queue entries, and select exactly one eligible fingerprint. Selection is round-robin: never-attempted entries first by oldest observation/path, then returned entries by least-recent attempt, observation, and path. Atomically mark it pending and stage 836 x 328 preview option(s). Always render the source `Before` and every viable `After` option. Record and request approval for one exact selected preview hash.

Forward built-in image-generation results with the runtime's generated-image result handler. Do not classify a result as an incomplete model payload merely because generic content-block parsing found nothing. Recover or re-emit an existing result before another model call, and do not count output handling as a generative attempt when the image result is recoverable.

Never install, mutate live songs, restart ITGMania, change configuration/charts/scores/profiles, duplicate a pending or terminal fingerprint, or silently switch processing methods. Generation failure, prompt error, or ordinary preview rejection returns the exact fingerprint to the queue with timestamped attempt context so it rotates behind less-recently attempted work. Only an explicit permanent owner opt-out becomes terminal `denied`. If no candidates remain, report counts and exit.

End every scheduled run with a retrospective over the run's prompt, tool results, validation, and queue transition. Record fingerprint-specific evidence in the queue. Promote only evidence-backed, reusable improvements into the skill and matching guides, then validate the skill. The later interactive install/denial response must run the same retrospective and capture the owner's reasoning with `-DecisionNote`; the scheduled preview run cannot infer feedback that has not yet been given.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-banner` first.
2. Initialize/refresh the target queue with `Update-BannerQueue.ps1`.
3. Create a local project Codex cron named `Hourly Misc Banner Upscale Queue`, hourly at minute 0, with the target repository working directory. Copy the behavioral prompt while replacing machine paths and project identity.
4. Select the new checkout's project; do not copy the source internal project ID.
5. Test one preview-only run. Confirm one fingerprint, visible `Before`, every viable labeled After option, pending fingerprint/hash state, no live write or restart, a clear exact-option approval request, and a documented retrospective that does not invent owner feedback.
