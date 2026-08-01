# ITGMania context

Observed locally and researched on 2026-07-31.

## Installed layout

| Role | Path | Notes |
| --- | --- | --- |
| Program/install root | `C:\Games\ITGmania` | Installed version 1.0.2 |
| Install songs | `C:\Games\ITGmania\Songs` | 63 pack directories observed |
| Portable save | `C:\Games\ITGmania\Save` | Present, but older than the active roaming save during inventory |
| Active user root | `C:\Users\Player.NUCBOXG3_PLUS\AppData\Roaming\ITGmania` | Cache and Save updated on 2026-07-31 |
| Active save | `...\AppData\Roaming\ITGmania\Save` | Preferences, profiles, uploads, and machine state |
| Additional user songs | `...\AppData\Roaming\ITGmania\Songs` | One observed pack directory |

The agent must inspect both save roots but treat the roaming root as active until live launch behavior proves otherwise.

## Current configuration snapshot

- Theme: Simply Love.
- Game: dance; default theme game mode: ITG.
- Windowed: enabled.
- Internal display setting: 1280×720 at 60 Hz with VSync.
- Songs per play: 3; coin mode: Home; event mode: off.
- Seven local profiles were observed: elemwarr, Sarah, Kyle, Nicole, Crios, Sam, and Lizy.

These values are snapshots. Re-read the INI files before every configuration task.

## Version context

The official site reported ITGMania 1.3.0 as current on 2026-07-31, while this host runs 1.0.2. The current release adds features including Series, engine-level Couples/Routine support, and a WASAPI audio option. Do not upgrade in place until a successful backup, release-note review, configuration diff, resync plan, and owner-approved maintenance window exist.

Primary references:

- [Official ITGMania site and current download](https://www.itgmania.com/)
- [ITGMania 1.3.0 release notes](https://github.com/itgmania/itgmania/releases/tag/v1.3.0)
- [ITGMania source repository](https://github.com/itgmania/itgmania)

## Data integrity

- Never edit `Stats.xml`, upload XML, signatures, or score history to alter results.
- Avoid editing active profile or preference files while ITGMania may write them.
- Profile configuration changes belong in the exact selected local profile, not the machine profile or another household member's profile.
- Cache is rebuildable; Save and profiles are not.
