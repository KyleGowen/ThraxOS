---
name: connect-controller
description: Pair a wired or Bluetooth handheld controller and configure it as a menu-only ITGMania controller. Use when the owner asks to connect, pair, troubleshoot, test, map, or add a gamepad/controller to ITGMania, including Nintendo Switch Online NES controllers and song-wheel submenu controls.
---

# Connect Controller

Set up handheld controllers for ITGMania menus without changing StepManiaX gameplay controls. Treat every live pairing, driver change, mapping edit, game launch, or restart as owner-approved work only.

## Load context and select a rider

1. Read `AGENTS.md`, `memory/FACTS.md`, `memory/DECISIONS.md`, `memory/PREFERENCES.md`, `docs/context/itgmania.md`, and `docs/runbooks/itgmania-change.md`.
2. Run `scripts/Get-ControllerPreflight.ps1` for live, redacted evidence. Inspect the game process, active roaming `Keymaps.ini`, Bluetooth state, and controller names before relying on snapshots.
3. Identify the controller. For a known controller, read its complete rider under `references/controllers/` before giving pairing or mapping instructions. The Nintendo Switch Online NES controller is a first-class rider.
4. For an unknown controller, follow **Generic discovery**. Do not guess button numbers, D-pad form, Bluetooth capability, or joystick index.

## Core walkthrough

### Pair or connect

- Keep ITGMania closed while pairing and configuring. Never terminate it automatically.
- Prefer native Windows Bluetooth pairing. Missing Windows enumeration is not proof that the NUC lacks Bluetooth; restore the OEM radio/driver before recommending a dongle.
- Keep a Bluetooth controller close to the host during pairing. Ask the owner to charge it and put it in pairing mode. Do not repeatedly remove a working pairing.
- For wired controllers, connect directly and confirm Windows recognizes it before mapping.
- If Windows shows a transient driver error, inspect the radio and recent events read-only. Ask before reinstalling a driver or restarting the host.

### Discover inputs outside ITGMania

Open `joy.cpl` only with the owner's approval. Use **Properties > Test** to record each control. Capture a screenshot or a concise table for D-pad, primary confirm, back, Start, Select, and shoulders.

Classify the D-pad from Windows' test panel:

- **Point of View Hat:** use `JoyN_H-Up`, `JoyN_H-Down`, `JoyN_H-Left`, and `JoyN_H-Right`.
- **X/Y axes:** use the exact `JoyN_Left1`, `Right1`, `Up1`, and `Down1` events confirmed by ITGMania input testing.
- **Buttons:** use the exact `JoyN_B#` values.

Do not substitute `Up1` for a POV hat. Validate the actual form.

### Build a menu-only map

Use Player 1 actions only. Preserve the StepManiaX stage as the gameplay controller.

- Map D-pad to Up/Down/Left/Right.
- Map a primary face button to Start/confirm and a secondary button to Back.
- Map physical Select only to Select unless the active theme explicitly supports Select alone for the requested action.
- Give physical Start a separate Start binding when capacity permits.
- Inspect the active theme metrics and `Preferences.ini` before deciding the song-wheel submenu chord. For Simply Love dance with `OnlyDedicatedMenuButtons=0`, use Player 1 `Left-Right`; do not also bind those shoulders to dedicated Menu-left/Menu-right because the wheel consumes them.
- ITGMania retains at most **two bindings per action**. Read the file again after a normal game exit. If a third binding disappears, choose the owner-approved two inputs instead of assuming the write persisted.
- For a controller without shoulders, ask the owner to choose two controls for the chord. Do not sacrifice an existing Start/confirm binding or change theme metrics without a separate approval.

### Apply and validate

Before a live edit, obtain explicit approval and then:

1. Confirm ITGMania is closed, inspect the active roaming target, check backup evidence, and capture its SHA-256.
2. Create a JSON mapping payload with no more than two values per action. Use `references/controller-rider-template.md` for an unknown controller or copy a rider's mapping payload.
3. Invoke `scripts/Set-MenuControllerKeymap.ps1` with `-ExpectedSha256`, `-MappingFile`, and `-Approved`. The script creates and validates a timestamped sibling rollback, edits only `[dance]` Player 1 entries, and reports the applied hash.
4. Parse and compare only the intended lines. Do not launch ITGMania without approval.
5. With owner approval, verify reconnect, D-pad navigation, confirm, Back, every shoulder/auxiliary control, the song-wheel submenu chord, and unchanged StepManiaX gameplay inputs. Ask the owner to close the game normally, then re-read `Keymaps.ini` to catch the two-binding limit.

If a test fails, diagnose from the active file and the Windows test result. Restore the sibling rollback only with owner approval.

## Generic discovery

Do as much as possible from Windows state and controller-test evidence. Ask only for information that cannot be safely inferred:

1. Controller make/model and wired/Bluetooth connection type.
2. The exact `joy.cpl` controls that light for D-pad, confirm, Back, Start, Select, and optional shoulders.
3. The owner's preferred two-button submenu chord if the controller lacks a known safe layout.

Use those observations to propose the mapping table and final validation checklist before writing it. Never infer a rider from a similar-looking controller.

## First-class controller riders

Each first-class controller has one encapsulated Markdown rider in `references/controllers/`. It must be independently copyable and include pairing behavior, Windows input observations, a JSON mapping payload, submenu rules, safety notes, and owner-confirmed verification criteria.

Promote an unknown controller only after the owner confirms all of: pairing/reconnect, Windows input test, ITGMania navigation, song-wheel submenu, normal-exit persistence, and unchanged StepManiaX gameplay behavior. Copy `references/controller-rider-template.md`, fill it from observed evidence, validate its JSON payload, then update this skill's documentation and the project migration guides in the same change.

## Resources

- `scripts/Get-ControllerPreflight.ps1`: redacted read-only inspection.
- `scripts/Set-MenuControllerKeymap.ps1`: guarded `[dance]` Player 1 mapping writer.
- `references/controllers/nintendo-switch-online-nes.md`: first-class NES controller rider.
- `references/controller-rider-template.md`: promotion template for a newly proven controller.
