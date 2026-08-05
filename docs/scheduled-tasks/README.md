# ThraxOS scheduled-task catalog

Canonical catalog of recurring ThraxOS work across Windows Task Scheduler and Codex automations. Live state reconciled 2026-08-05 (America/Los_Angeles).

| Scheduler | Task | Purpose | Guide |
| --- | --- | --- | --- |
| Windows Task Scheduler | `ITGManiaBackup` | Poll backup cron runner every minute; configured backup runs daily at 03:00 Pacific | [ITGManiaBackup](itgmania-backup.md) |
| Codex cron automation | `Hourly Misc Banner Upscale Queue` | Every four hours from midnight, retain fingerprint history, render external Before art through SHA-identical workspace display copies, and support hash-bound opacity-safe installs | [Banner queue](hourly-misc-banner-upscale-queue.md) |
| Codex cron automation | `Hourly Misc Background Upscale Queue` | Every four hours from 02:00, severity-rank static backgrounds, render safe encoded comparisons, and request exact approval with canonical metadata | [Background queue](hourly-misc-background-upscale-queue.md) |

No other root-level Windows task was identified as part of ThraxOS. Standard Windows and vendor tasks are excluded.

`connect-controller` is an on-demand skill, not a scheduled task; it creates no Task Scheduler or Codex automation entry.

## Documentation contract

A task change is incomplete until this index and its guide are updated. Record scheduler, owner, trigger, action, working directory, environment, concurrency, safety limits, dependencies, state, reproduction, and verification. Use placeholders for accounts/project IDs; never commit tokens, Windows SIDs, or unique identifiers.
