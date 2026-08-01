# Backup health runbook

1. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\thraxos\scripts\Test-BackupHealth.ps1`. This bypass is process-local and does not change machine policy.
2. Confirm the `ITGManiaBackup` task exists, is not disabled, and its last result is `0x0`.
3. Confirm the newest `Backup_*.log` contains a recent `Backup completed successfully.` marker.
4. Confirm the log reports a push to the intended `KyleGowen/Thraximundar-Backup` destination.
5. Compare the last generated README backup timestamp on GitHub with the local log.
6. Report status as healthy, degraded, or failed with timestamp and evidence.

Do not expose the backup token. Print the result in the active task; do not send alerts or notifications. If a check fails, inspect logs and configuration read-only first, then ThraxOS may perform the smallest non-destructive repair. Ask before changing configuration values, schedule, destination, credentials, or deleting data.
