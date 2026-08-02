# Windows task: `ITGManiaBackup`

Observed live on 2026-08-02. Implementation and installation belong to `KyleGowen/itgmania-backup`, not ThraxOS.

## Effective behavior

- Scheduler/path: Windows Task Scheduler, root `\`; enabled and not hidden.
- Principal: interactive host user, limited privileges. Substitute the target account; never copy the source SID.
- Action: `wscript.exe //B "C:\ProgramData\ITGManiaBackup\RunCronRunner.vbs"`.
- Trigger: time trigger repeating every minute (`PT1M`) for 3650 days (`P3650D`). The VBS launches hidden PowerShell with `-NoProfile` and process-scoped execution-policy bypass, then runs `CronRunner.ps1`.
- Concurrency: `IgnoreNew`; start when available; wake-to-run enabled; no idle/network requirement; battery start/stop restrictions disabled; execution limit 72 hours; no configured restarts.
- The runner evaluates `C:\ProgramData\ITGManiaBackup\config.json`. Effective backup cron: `0 3 * * *`, `Pacific Standard Time` (daily 03:00 Pacific, including Windows time-zone rules).
- Current scope: `C:\Games\ITGMania`, auto-detected portable/AppData Save roots, and `Themes`, `NoteSkins`, `BGAnimations`, `Characters`, `Courses`, `Logs`. Songs excluded. One configured backup task targets the ITGMania subtree.
- Destination is a generated backup repository. A credential is present outside source control and must be provisioned separately.
- Observation health: last result `0`, no missed runs. Runtime state is time-specific.

## Reproduce and verify

1. Use the supported installer from `KyleGowen/itgmania-backup`; do not duplicate its implementation in ThraxOS.
2. Configure target paths, destination, cron, time zone, exclusions, and credentials outside source control.
3. Keep Songs excluded unless the owner explicitly changes the architecture; ThraxOS is not a backup destination.
4. Verify the installer-created action, minute trigger, target principal, and `IgnoreNew` policy.
5. Run `.agents/skills/thraxos/scripts/Test-BackupHealth.ps1` and inspect one completed backup log/push. Health checks print only; do not create alerts.

Never check in exported live XML: it contains a machine-specific SID and timestamp. Generate the task on the new host so identity and paths are correct. Changes to schedule, destination, credentials, or deletion require owner approval.
