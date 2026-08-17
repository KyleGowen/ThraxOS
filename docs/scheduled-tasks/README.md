# ThraxOS scheduled-task catalog

Canonical catalog of recurring ThraxOS work across Windows Task Scheduler and Codex automations. Live state reconciled 2026-08-14 (America/Los_Angeles).

| Scheduler | Task | Purpose | Guide |
| --- | --- | --- | --- |
| Windows Task Scheduler | `ITGManiaBackup` | Poll backup cron runner every minute; configured backup runs daily at 03:00 Pacific | [ITGManiaBackup](itgmania-backup.md) |
| Codex cron automation | `Hourly Misc Banner Upscale Queue` | Every four hours from midnight, restore undersized banners and route consistently referenced source-less targets through `generate-banner`, retaining exact approval and queue history | [Banner queue](hourly-misc-banner-upscale-queue.md) |
| Codex cron automation | `Hourly DDR 4th Mix Background Upscale Queue` | Hourly, severity-rank explicit static DDR 4th Mix backgrounds, render safe encoded comparisons, and request exact approval with canonical metadata | [Background queue](hourly-misc-background-upscale-queue.md) |
| On-demand service capability | `Start Dashboard` | Owner-approved local or private-LAN Arcade Console startup and verification; creates no scheduler entry | [Start Dashboard](start-dashboard.md) |

No other root-level Windows task was identified as part of ThraxOS. Standard Windows and vendor tasks are excluded.

`connect-controller` is an on-demand skill, not a scheduled task; it creates no Task Scheduler or Codex automation entry.

`start-dashboard` is also on-demand. It starts the existing dashboard only with explicit approval and does not create, alter, or monitor a Windows Task Scheduler or Codex automation entry.

`generate-banner` is also on-demand for owner-requested redesigns and is an automatic preview-only dependency when the banner queue selects a consistently referenced target with no banner or fallback. It does not create a separate scheduler entry or let the scheduled run install live content.

`generate-background` is also on-demand. It may service an owner-authorized scratch redesign of an exact background fingerprint, but it adds no scheduler entry, does not change the hourly queue behavior, and keeps generation preview-only.

Any change to a scheduled task's dashboard, form, or other user-facing interface must first pass the `thraxos` AgentOS UI inheritance preflight. The visual treatment may be StepManiaX/DDR-themed, but the inherited shadcn/ui component and interaction default remains in force unless a material override is recorded.

## Documentation contract

A task change is incomplete until this index and its guide are updated. Record scheduler, owner, trigger, action, working directory, environment, concurrency, safety limits, dependencies, state, reproduction, and verification. Use placeholders for accounts/project IDs; never commit tokens, Windows SIDs, or unique identifiers.
