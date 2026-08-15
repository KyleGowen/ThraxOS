# ITGMania context

Originally inventoried 2026-07-31; live configuration refreshed 2026-08-14 at 22:10 Pacific.

## Installed layout

| Role | Path | Notes |
| --- | --- | --- |
| Program/install root | `C:\Games\ITGmania` | Installed version 1.3.0 |
| Install songs | `C:\Games\ITGmania\Songs` | 75 pack directories observed |
| Portable save | `C:\Games\ITGmania\Save` | Present, but older than the active roaming save during inventory |
| Active user root | `C:\Users\Player.NUCBOXG3_PLUS\AppData\Roaming\ITGmania` | Current active cache and Save root |
| Active save | `...\AppData\Roaming\ITGmania\Save` | Preferences, profiles, uploads, and machine state |
| Additional user songs | `...\AppData\Roaming\ITGmania\Songs` | One observed pack directory |

The agent must inspect both save roots but treat the roaming root as active until live launch behavior proves otherwise.

## Current configuration snapshot

- Theme: Simply Love.
- Game: dance; default theme game mode: ITG.
- Windowed: disabled (fullscreen).
- Internal display setting: 1920 x 1080. Re-read live preferences before relying on refresh rate or VSync.
- Songs per play: 3; coin mode: Home; event mode: off.
- Seven local profiles were observed: elemwarr, Sarah, Kyle, Nicole, Crios, Sam, and Lizy.

These values are snapshots. Re-read the INI files before every configuration task.

## Version context

The owner approved the upgrade on 2026-08-01. This host now runs ITGMania 1.3.0 with Simply Love 5.9.0; live status reconfirmed the engine version and active theme on 2026-08-14. Treat future upgrades as new configuration mutations requiring current backup evidence, release-note review, configuration comparison, a rollback plan, and owner approval.

Primary references:

- [Official ITGMania site and current download](https://www.itgmania.com/)
- [ITGMania 1.3.0 release notes](https://github.com/itgmania/itgmania/releases/tag/v1.3.0)
- [ITGMania source repository](https://github.com/itgmania/itgmania)

## Data integrity

- Never edit `Stats.xml`, upload XML, signatures, or score history to alter results.
- Avoid editing active profile or preference files while ITGMania may write them.
- Profile configuration changes belong in the exact selected local profile, not the machine profile or another household member's profile.
- Cache is rebuildable; Save and profiles are not.
