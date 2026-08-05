# First-class controller rider template

Use this entire file as the starting point for one proven controller type. Replace every bracketed value with observed evidence; do not promote an untested device.

## Identity and scope

- Controller: [manufacturer and exact model]
- Windows name: [observed non-unique friendly name]
- Connection: [wired/Bluetooth]
- Role: menu-only; StepManiaX remains gameplay controller.

## Pairing and discovery

1. [controller-specific pairing or cable steps]
2. [Windows verification]
3. [joy.cpl test procedure]

## Observed inputs

| Physical control | Windows observation | ITGMania input |
| --- | --- | --- |
| D-pad Up | [hat/axis/button] | [JoyN input] |
| D-pad Down | [hat/axis/button] | [JoyN input] |
| D-pad Left | [hat/axis/button] | [JoyN input] |
| D-pad Right | [hat/axis/button] | [JoyN input] |
| Confirm | [button] | [JoyN input] |
| Back | [button] | [JoyN input] |
| Select | [button or absent] | [JoyN input or blank] |
| Submenu Left | [button] | [JoyN input] |
| Submenu Right | [button] | [JoyN input] |

## Copy/paste mapping payload

```json
{
  "mode": "dance",
  "mappings": {
    "1_Up": ["[input]"],
    "1_Down": ["[input]"],
    "1_Left": ["[input]", "[input]"],
    "1_Right": ["[input]", "[input]"],
    "1_Start": ["[input]"],
    "1_Back": ["[input]"],
    "1_Select": ["[input]"]
  }
}
```

Keep every action at two bindings or fewer. Leave dedicated Menu-left/Menu-right blank when the active Simply Love configuration uses Player 1 Left+Right for the song-wheel submenu.

## Required promotion proof

- Owner confirms pairing/reconnect and every Windows test observation.
- Owner confirms ITGMania navigation, confirm, Back, song-wheel submenu, and normal-exit persistence.
- Owner confirms StepManiaX gameplay inputs remain unchanged.
