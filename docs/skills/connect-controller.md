# Connect Controller skill

Source: [`.agents/skills/connect-controller/`](../../.agents/skills/connect-controller/)

Pair and configure wired or Bluetooth handheld controllers as menu-only ITGMania inputs. The skill preserves StepManiaX for gameplay, discovers controls through Windows before mapping, and requires explicit owner approval for every live driver, pairing, application, or `Keymaps.ini` change.

## Components

- `SKILL.md`: guarded walkthrough, generic discovery, first-class rider promotion rules, and song-wheel submenu validation.
- `scripts/Get-ControllerPreflight.ps1`: redacted read-only check of ITGMania, Keymaps, Bluetooth, and controller names.
- `scripts/Set-MenuControllerKeymap.ps1`: expected-hash, closed-game, sibling-rollback, dance-only Player 1 mapping writer.
- `references/controllers/`: independently copyable first-class rider files. The Nintendo Switch Online NES rider is the initial controller.
- `references/controller-rider-template.md`: evidence and validation template for future promotions.

## Safety and migration

Copy the entire skill directory when moving to another host. Adapt paths, Bluetooth hardware, theme behavior, and controller observations locally; never copy credentials, profile identifiers, serial numbers, or full device instance IDs. Read the target host's ITGMania context and confirm its active save root before using a rider.

The writer refuses an open game or stale Keymaps hash, creates a timestamped sibling rollback, limits every action to ITGMania's two-input capacity, edits only the `[dance]` Player 1 entries named by the approved payload, and validates every resulting entry. Launch and test only with owner approval.

## Verification

1. Run the preflight script and choose a known rider or collect `joy.cpl` observations.
2. Pair/reconnect and test the controller in Windows.
3. Obtain approval, apply the exact mapping payload, and inspect the returned hashes.
4. Test navigation, confirm, Back, song-wheel submenu, normal-exit persistence, and unchanged StepManiaX gameplay behavior.
5. Promote a new rider only after the owner confirms every check, then update this guide and `docs/skills/README.md`.
