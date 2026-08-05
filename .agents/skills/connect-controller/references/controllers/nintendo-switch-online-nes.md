# Nintendo Switch Online NES controller rider

## Identity and scope

- Controller: Nintendo Switch Online Nintendo Entertainment System controller, right-hand unit (`NES Controller (R)`).
- Windows name: `Wireless Gamepad` in `joy.cpl`; paired Bluetooth name may be `NES Controller (R)`.
- Connection: native Windows Bluetooth.
- Role: menu-only. Keep StepManiaX as the gameplay controller.

## Pairing and recovery

1. Charge using a Nintendo Switch console or compatible Joy-Con charging stand.
2. Keep the controller close to the NUC. Hold its SYNC button until LEDs sweep, then use **Settings > Bluetooth & devices > Add device > Bluetooth**.
3. For a normal reconnect, press a face button; do not press SYNC. If a paired controller never reconnects, remove only that controller record and pair it again.
4. If Windows shows a Bluetooth driver error, inspect the Realtek radio first. Do not infer missing hardware or buy a dongle before restoring/enabling the OEM driver.

## Observed inputs

| Physical control | Windows test observation | ITGMania input |
| --- | --- | --- |
| D-pad Up | Point of View Hat | `Joy1_H-Up` |
| D-pad Down | Point of View Hat | `Joy1_H-Down` |
| D-pad Left | Point of View Hat | `Joy1_H-Left` |
| D-pad Right | Point of View Hat | `Joy1_H-Right` |
| A | Button 2 | `Joy1_B2` |
| B | Button 1 | `Joy1_B1` |
| L | Button 5 | `Joy1_B5` |
| R | Button 6 | `Joy1_B6` |
| Select | Button 9 | `Joy1_B9` |
| Start | Button 10 | `Joy1_B10` |

## Copy/paste mapping payload

```json
{
  "mode": "dance",
  "mappings": {
    "1_Up": ["Joy1_H-Up", "Key_w"],
    "1_Down": ["Joy1_H-Down", "Key_s"],
    "1_Left": ["Joy1_H-Left", "Joy1_B5"],
    "1_Right": ["Joy1_H-Right", "Joy1_B6"],
    "1_Start": ["Joy1_B2", "Joy1_B10"],
    "1_Back": ["Joy1_B1"],
    "1_Select": ["Joy1_B9"],
    "1_MenuLeft": [],
    "1_MenuRight": []
  }
}
```

The D-pad is a POV hat, not an axis. ITGMania keeps at most two inputs per action: Left/Right intentionally reserve both slots for D-pad and L/R, so keyboard Left/Right are unavailable; keyboard Up/Down remain. Do not add dedicated Menu-left/Menu-right for this host's Simply Love dance configuration, because L/R must reach Player 1 Left+Right for the song-wheel submenu chord.

## Required verification

1. Confirm the controller reconnects after sleeping and still appears in `joy.cpl`.
2. In ITGMania, verify D-pad navigation, A/Start confirm, B Back, and Select.
3. On the song wheel, verify L and R alone navigate and L+R together opens the submenu. Close ITGMania normally and re-read `Keymaps.ini` to confirm the two-binding limit did not discard an input.
4. Verify StepManiaX gameplay inputs still work unchanged.

Select remains a separate Select action. In this theme, the built-in Select-based sort code is hold Select then press Start; do not turn Select alone into a Start alias unless the owner explicitly accepts replacing an existing Start binding.
