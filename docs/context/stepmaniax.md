# StepManiaX stage context

Observed locally and researched on 2026-07-31.

## Connected hardware

- Windows reports a connected USB device with bus description `StepManiaX`.
- Non-unique USB vendor/product ID: `VID_2341&PID_8037`.
- Interfaces include HID game-controller/input and a USB serial interface on COM3.
- StepManiaX Platform software is installed.
- Legacy `SMXConfig.exe` and `SMX.dll` dated 2020-04-03 are installed at `C:\Games\SMXConfig`.
- The owner-provided Settings screenshot reports `Connected: P2` and `SMXConfig version 2020-04-03-01`.
- The screen offers High, Medium, and Low panel sensitivity, calls Medium recommended, and shows a 3x3 panel-color layout. It does not visibly identify which sensitivity is active.
- Local SMXConfig metadata reports application version 1.0.0.0, and its only discovered per-user setting is launch-on-startup enabled.

The exact stage generation, firmware version, panel layout, and physical modifications are not yet confirmed. Do not infer generation solely from the shared Arduino vendor/product identifier.

## Capabilities and maintenance

The official SDK supports regular HID input and direct platform access. It can query up to two controllers, read input state and configuration, control lights, and request test data. A platform may expose up to nine panels, with four sensors per panel. The official guidance recommends using SMXConfig for normal configuration.

The current fifth-generation product uses FSR sensors, four per panel, software sensitivity adjustment, configurable lighting, five standard input panels, USB-C, and optional nine-panel expansion. Those specifications describe the current product and are not yet asserted for this particular stage.

References:

- [Official StepManiaX SDK](https://steprevolution.github.io/stepmaniax-sdk/)
- [Official StepManiaX support and diagnostics](https://stepmaniax.com/support/)
- [Current fifth-generation stage specifications](https://shop.steprevolution.com/products/stepmaniax-stage-5th-generation)
- [Official stage manuals](https://stepmaniax.com/support/)

## Safety

- Never alter sensitivity, calibration, firmware, or lighting configuration without reading the current state and obtaining approval.
- Treat misfires as a diagnostic problem: inspect sensor values and physical alignment before applying software changes.
- Do not apply physical modifications based only on agent inference.
