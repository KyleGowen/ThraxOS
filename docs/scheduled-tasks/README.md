# ThraxOS scheduled-task catalog

Canonical catalog of recurring ThraxOS work across Windows Task Scheduler and Codex automations. Live state observed 2026-08-03 (America/Los_Angeles).

| Scheduler | Task | Purpose | Guide |
| --- | --- | --- | --- |
| Windows Task Scheduler | `ITGManiaBackup` | Poll backup cron runner every minute; configured backup runs daily at 03:00 Pacific | [ITGManiaBackup](itgmania-backup.md) |
| Codex cron automation | `Hourly Misc Banner Upscale Queue` | Every four hours from midnight, reject inconsistent simfile banner references, serialize queue updates, retain fingerprint history, stage one renderer-safe linked comparison, and support hash-bound opacity-safe interactive installs | [Banner queue](hourly-misc-banner-upscale-queue.md) |
| Codex cron automation | `Hourly Misc Background Upscale Queue` | Every four hours from 02:00, validate companion simfiles, severity-rank static backgrounds, and request one-option bare or multi-option labeled approval with canonical metadata | [Background queue](hourly-misc-background-upscale-queue.md) |

No other root-level Windows task was identified as part of ThraxOS. Standard Windows and vendor tasks are excluded.

## Documentation contract

A task change is incomplete until this index and its guide are updated. Record scheduler, owner, trigger, action, working directory, environment, concurrency, safety limits, dependencies, state, reproduction, and verification. Use placeholders for accounts/project IDs; never commit tokens, Windows SIDs, or unique identifiers.
