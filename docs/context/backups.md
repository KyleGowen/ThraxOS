# Backup project boundaries

Originally inventoried locally and from GitHub on 2026-07-31; live configuration and log evidence refreshed 2026-08-14 at 22:10 Pacific.

## `KyleGowen/itgmania-backup`

This is the implementation repository. It owns the PowerShell installer, scheduled backup behavior, configuration schema, cron evaluation, logging, and generated backup process.

Key contract:

- Backs up both portable and AppData Save roots when present.
- Backs up selected install subdirectories.
- Never backs up Songs.
- Skips files above GitHub's 100 MB limit.
- Uses a separate destination repository.
- Treats the destination as a unidirectional generated snapshot and force-pushes updates.
- Stores the real config and GitHub token outside source control.

Source: [itgmania-backup README](https://github.com/KyleGowen/itgmania-backup/blob/main/README.md).

## `KyleGowen/Thraximundar-Backup`

This is the configured backup destination and generated history. It contains selected ITGMania data plus a generated README with recent play time, scores, pack changes, and backup timestamps. Songs and large media are excluded.

Do not hand-edit it. Read it for remote stats and backup verification; change the generator in `itgmania-backup` when output behavior must change.

Source: [Thraximundar-Backup](https://github.com/KyleGowen/Thraximundar-Backup).

## Current live configuration and health

- Config: `C:\ProgramData\ITGManiaBackup\config.json`.
- Destination: `https://github.com/KyleGowen/Thraximundar-Backup.git`.
- Schedule: `0 3 * * *`, Pacific Standard Time.
- Songs: excluded.
- Credential: present; value not inspected or stored.
- Scheduled task: `ITGManiaBackup`. Direct Task Scheduler inspection was access-denied on 2026-08-14, so current state and last-result visibility are degraded.
- Latest inspected log: `Backup_2026-08-14.log`, modified at 03:02 Pacific with a same-day success marker.
- Health interpretation: successful current log evidence and Songs remain excluded, but report degraded scheduler visibility rather than claiming a fully verified healthy task.

## ThraxOS responsibility

ThraxOS monitors health, prints the result in the active task, may perform narrowly scoped repairs after diagnosis, and integrates play-data summaries. It must not duplicate backup code, become the backup destination, silently change configuration/schedule/target, or create alerting without a later request.
