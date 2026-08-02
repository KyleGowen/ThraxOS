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

Load repository safety/context, refresh new or changed queue entries, and select exactly one eligible fingerprint. Selection is round-robin: never-attempted entries first by oldest observation/path, then returned entries by least-recent attempt, observation, and path. Atomically mark it pending and stage one 836 x 328 Before/After preview. Record preview path and SHA-256 and ask whether to install that exact preview.

Never install, mutate live songs, restart ITGMania, change configuration/charts/scores/profiles, duplicate a pending or terminal fingerprint, or silently switch processing methods. Generation failure, prompt error, or ordinary preview rejection returns the exact fingerprint to the queue with timestamped attempt context so it rotates behind less-recently attempted work. Only an explicit permanent owner opt-out becomes terminal `denied`. If no candidates remain, report counts and exit.

## Reproduce and verify

1. Migrate and validate `thraxos` and `upscale-banner` first.
2. Initialize/refresh the target queue with `Update-BannerQueue.ps1`.
3. Create a local project Codex cron named `Hourly Misc Banner Upscale Queue`, hourly at minute 0, with the target repository working directory. Copy the behavioral prompt while replacing machine paths and project identity.
4. Select the new checkout's project; do not copy the source internal project ID.
5. Test one preview-only run. Confirm at most one preview, pending fingerprint/hash state, no live write or restart, and a clear approval request.
