# ThraxOS

ThraxOS is the checked-in control plane for **Thraximundar**, a dedicated Windows 11 GMKtec NucBox used primarily for ITGMania with a StepManiaX stage. It gives Codex durable machine context, operating rules, runbooks, a project-scoped specialist, and a reviewable memory trail without storing live credentials or large song data.

## Current state

- ITGMania 1.0.2 is installed at `C:\Games\ITGmania`; the active per-user data root is `C:\Users\Player.NUCBOXG3_PLUS\AppData\Roaming\ITGmania`.
- The official current ITGMania release observed on 2026-07-31 is 1.3.0. Upgrade work is intentionally deferred until the owner chooses a maintenance and resync plan.
- The installation has 63 pack directories in the install `Songs` root and one additional user-data pack directory.
- Seven local profiles exist. The `Kyle` profile has a correctly sized GrooveStats API key. Enabling it is prepared but remains pending while ITGMania is running.
- The `ITGManiaBackup` scheduled task is ready, its last result is `0x0`, and the 2026-07-31 backup completed and pushed successfully.
- No secrets, score XML, song audio, serial numbers, or unique USB instance paths are stored in this repository.

See [machine context](docs/context/machine.md), [ITGMania context](docs/context/itgmania.md), and [backup boundaries](docs/context/backups.md) for details.

## Use the ThraxOS specialist

In a Codex project chat, select or mention **ThraxOS** from the skill menu (for example, `@ThraxOS`, or `$thraxos` on surfaces that use dollar-prefixed skill invocation). A project custom agent named `ThraxOS` is also defined for delegated specialist work.

Typical requests:

- “@ThraxOS check ITGMania and backup health.”
- “@ThraxOS inspect my last play session and summarize duration.”
- “@ThraxOS find three pad-friendly packs that match my preferences.”
- “@ThraxOS stage this downloaded pack, validate it, and ask before installing.”
- “@ThraxOS help configure GrooveStats for the Kyle profile.”

The root [AGENTS.md](AGENTS.md) is the durable operating contract. Detailed procedures live under `docs/runbooks/`, and evolving facts and decisions live under `memory/`.

## Remote use

ThraxOS relies on Codex Remote rather than exposing a custom unauthenticated service. Keep the ChatGPT desktop app running on Thraximundar, pair the host from **Set up Remote**, and connect from the ChatGPT mobile or supported desktop app using the same account and workspace. See the [remote access runbook](docs/runbooks/remote-access.md).

## Repository map

```text
.agents/skills/thraxos/   Discoverable ThraxOS skill and read-only scripts
.codex/agents/            Project-scoped custom agent
.codex/config.toml        Project Codex feature defaults
config/                   Non-secret host paths
docs/context/             Machine, software, service, and source context
docs/runbooks/            Safe operational procedures
memory/                   Checked-in facts, preferences, decisions, and log
future-work/              One proposal or deferred change per Markdown file
```

## Status checks

From PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Get-ThraxStatus.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\thraxos\scripts\Test-BackupHealth.ps1
```

Both scripts are read-only and redact credential values. `ExecutionPolicy Bypass` applies only to that child process and does not change the machine's policy.

Approved GrooveStats configuration changes are applied with the guarded `Set-GrooveStatsForProfile.ps1` script. It refuses to write while ITGMania is running and reports only credential presence/shape.
