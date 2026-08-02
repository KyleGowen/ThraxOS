# Add a Nintendo Switch Online NES controller as a wireless ITGMania menu controller

Status: owner-requested future work on 2026-08-02. This proposal is not authorization to install drivers, pair a controller, change mappings, or launch ITGMania.

Difficulty: 2/5. Expected impact: 3/5.

## Goal

Use one official Nintendo Switch Online Nintendo Entertainment System controller as a small wireless selector for ITGMania menus while retaining the StepManiaX stage as the gameplay controller. The intended role is menu navigation, not precision gameplay.

## Current evidence

- GMKtec specifies the NucBox G3 Plus with a Realtek 8852BE Wi-Fi 6 module and Bluetooth 5.2: <https://www.gmktec.com/products/nucbox-g3-plus-enhanced-performance-mini-pc-with-intel-n150-processor>.
- On 2026-08-02, Windows' Bluetooth service was running, but read-only Windows queries found no Bluetooth radio, Bluetooth driver, Bluetooth PnP device, or Wi-Fi adapter. This does **not** establish that the installed hardware is missing; it makes a disabled or missing OEM wireless driver the first issue to resolve.
- ITGMania's active roaming save contains the existing StepManiaX mappings in `Keymaps.ini` and has `AutoMapOnJoyChange=1`. A newly connected controller must not replace those mappings.
- Nintendo identifies the two NES controllers as HAC-033 and HAC-034. They are intended primarily for NES - Nintendo Switch Online; use with Windows is not guaranteed by Nintendo: <https://en-americas-support.nintendo.com/app/answers/detail/a_id/41192/>.

## Parts and prerequisites

- One NES controller from Nintendo's Switch Online controller set.
- A Nintendo Switch console or compatible Joy-Con charging stand. The controller charges through its Switch-style rail, not a normal USB port.
- No Bluetooth adapter purchase is currently required: the host model is specified with Bluetooth 5.2.
- Only if the official GMKtec Wi-Fi/Bluetooth driver is installed and Windows still cannot enumerate a radio, obtain a Windows 11-compatible USB Bluetooth 5.x adapter. Use a short extension cable if needed to keep it clear of other USB hardware.

## Guarded setup procedure

1. Charge the controller with a Switch console or compatible Joy-Con charging stand.
2. In Windows, open **Settings > Bluetooth & devices**.
   - If a Bluetooth toggle is present, enable it.
   - If the toggle is absent, inspect Device Manager for **Realtek 8852BE** under Bluetooth or Network adapters.
   - If that device is absent, download and install the official GMKtec G3 Plus wireless driver only after the owner approves that driver installation and any requested restart.
3. Keep the Nintendo Switch powered off or out of range, then hold the NES controller's SYNC button until its LEDs enter pairing mode.
4. In Windows, choose **Add device > Bluetooth** and select the NES controller. Pair one controller only for the first test.
5. Press `Win + R`, run `joy.cpl`, and confirm that the D-pad, A, B, L, and R inputs register before involving ITGMania.
6. Before launching ITGMania, close it normally and make a dated rollback copy of `%APPDATA%\ITGmania\Save\Keymaps.ini`.
7. Launch and test ITGMania only with owner approval. In **Options > Input Options > Configure Key/Joy Mappings**, add the NES inputs without deleting or replacing any StepManiaX entries.

## Intended ITGMania mapping

| NES control | ITGMania action |
| --- | --- |
| D-pad | Up / Down / Left / Right |
| A | Start / confirm |
| B | Back |
| L | Menu-left |
| R | Menu-right |

Mapping L and R separately is required: pressing **L + R together** activates ITGMania's submenu action.

## Verification and rollback

- Pair the NES controller before launching ITGMania; avoid hot-plugging it while the game is running.
- Verify the StepManiaX stage still registers all existing Player 1 inputs before saving the mapping.
- Verify L alone, R alone, and L+R together from a non-gameplay menu.
- If mappings are wrong, leave the game normally and restore the dated `Keymaps.ini` copy. Do not modify StepManiaX pad settings, sensitivity, calibration, or firmware.
- If Windows recognizes the controller but ITGMania does not, investigate a compatibility layer only as a separately approved follow-up. Do not install Steam Input wrappers, BetterJoy, virtual-controller drivers, or other input software as part of the first test.

## Acceptance criteria

- The controller connects through the host's Bluetooth radio without displacing the StepManiaX stage.
- D-pad navigation, A/Start, B/Back, L/Menu-left, R/Menu-right, and L+R submenu operation work in ITGMania.
- Existing pad gameplay works identically after testing.
- All changes are reversible through the mapping rollback copy or Windows device removal.
