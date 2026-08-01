# StepManiaX stage context

Observed locally and researched on 2026-07-31; stage generation identified from new physical evidence on 2026-08-01.

## Connected hardware

- Windows reports a connected USB device with bus description `StepManiaX`.
- Non-unique USB vendor/product ID: `VID_2341&PID_8037`.
- Interfaces include HID game-controller/input and a USB serial interface on COM3.
- StepManiaX Platform software is installed.
- Legacy `SMXConfig.exe` and `SMX.dll` dated 2020-04-03 are installed at `C:\Games\SMXConfig`.
- The owner-provided Settings screenshot reports `Connected: P2` and `SMXConfig version 2020-04-03-01`.
- The screen offers High, Medium, and Low panel sensitivity, calls Medium recommended, and shows a 3x3 panel-color layout. It does not visibly identify which sensitivity is active.
- Local SMXConfig metadata reports application version 1.0.0.0, and its only discovered per-user setting is launch-on-startup enabled.

Owner-provided photos identify this as a **Generation 4 StepManiaX stage** with high confidence. The visible 25-LED matrices establish Gen4 or newer, while its Micro-USB/no-barrel-input connector arrangement matches the official Gen4 wiring diagram rather than Gen5's USB-C and external barrel-power input. The stage is labeled/configured as P2 and has all nine square acrylic panels installed. The factory serial label was visible but is intentionally not recorded.

The firmware revision, selected sensitivity, and enabled sensor mask remain unconfirmed. Illuminated corner panels prove lighting is installed but do not by themselves prove that pressure sensors are installed and enabled in those corners. Do not infer firmware or sensor enablement from the shared Arduino vendor/product identifier.

## Capabilities and maintenance

The official SDK supports regular HID input and direct platform access. It can query up to two controllers, read input state and configuration, control lights, and request test data. A platform may expose up to nine panels, with four sensors per panel. The official guidance recommends using SMXConfig for normal configuration.

The photographed Gen4 platform uses the Gen4+ architecture documented by Step Revolution: software sensitivity adjustment, configurable lighting, up to nine panels, four sensors per input panel, Micro-USB data, integrated standalone AC power, dimensions of roughly 35 x 47 x 7 inches, and weight around 200-220 lb. Dimensions and weight are official family specifications rather than measurements of this unit. Gen5 differs visibly through USB-C data and an additional external barrel-power input.

References:

- [Official StepManiaX SDK](https://steprevolution.github.io/stepmaniax-sdk/)
- [Official StepManiaX support and diagnostics](https://stepmaniax.com/support/)
- [Current fifth-generation stage specifications](https://shop.steprevolution.com/products/stepmaniax-stage-5th-generation)
- [Official stage manuals](https://stepmaniax.com/support/)

## Safety

- Never alter sensitivity, calibration, firmware, or lighting configuration without reading the current state and obtaining approval.
- Treat misfires as a diagnostic problem: inspect sensor values and physical alignment before applying software changes.
- Do not apply physical modifications based only on agent inference.
