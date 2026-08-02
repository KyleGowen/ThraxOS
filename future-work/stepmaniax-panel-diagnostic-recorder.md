# Add a StepManiaX panel diagnostic recorder

Status: proposed by owner on 2026-08-01.

Difficulty: 4/5. Expected impact: 5/5.

## Goal

Build a guided, read-only diagnostic session for Thraximundar's Generation 4 P2 stage. Visualize panel and individual-sensor activity, record press/release behavior and diagnostic logs, summarize intermittent or asymmetric behavior, and produce a privacy-safe maintenance report. The tool must not change sensitivity, enabled sensors, firmware, calibration, lighting configuration, or pad identity.

## Preliminary research

- The official StepManiaX SDK can detect up to two controllers, read input state and configuration, register diagnostic logs, detect enabled sensors, enter sensor-test mode, and retrieve per-sensor test data. It states that each of up to nine panels can expose four sensors: <https://steprevolution.github.io/stepmaniax-sdk/>.
- The SDK's Gen4 support history includes the 25-LED `SMX_SetLights2` layout, directly applicable to the photographed Gen4 stage.
- The official cabinet software provides sensor test mode and diagnostics that visualize sensor pressure. This supports the diagnostic concept but does not document a longitudinal recorder or export workflow: <https://data.stepmaniax.com/docs/Software%20Manual%20Rev2.pdf>.
- A maintained community Rust wrapper exposes SMX events and sensor test data, and its current tooling includes a sensor-sample-rate probe. This is useful implementation prior art, not yet a dependency decision: <https://docs.rs/crate/rustmaniax-sdk/2.0.0>.
- Community reports describe intermittent panel failures where the existing debug tool exposed changing diagnostic values. These reports are leads for useful capture fields, not proof of a defect on Thraximundar: <https://www.reddit.com/r/Stepmania/comments/126b9y1/>.

## Proposed first version

1. Enumerate connected pads without printing serial numbers or full USB instance IDs.
2. Read and display the enabled sensor mask and current input state without calling configuration setters.
3. Run an owner-led sequence—idle baseline, four corners per panel, center press, holds, repeated taps, and release—while recording timestamps and sensor-test values.
4. Summarize missing sensors, stuck activation, slow release, inconsistent corner response, disconnects, and sample-rate gaps without automatically declaring hardware failure.
5. Export a compact sanitized report; raw high-frequency traces should stay temporary unless the owner requests retention.

## Safety and acceptance criteria

- Use only SDK getters, logging, and sensor-test mode in the first implementation. Do not call `SMX_SetConfig`, factory reset, force recalibration, firmware, or sensitivity APIs.
- Confirm whether sensor-test mode itself affects normal game input and require ITGMania to be closed if concurrent access is unsafe.
- Do not use stage lights for visualization until the behavior and automatic-light restoration path are proven on a non-destructive test.
- Establish a healthy baseline before implementing thresholds. Gen4-specific conclusions must not be borrowed from Gen1-3 or Gen5 reports.

## Open questions

- What sampling rate and values does this specific Gen4 firmware expose?
- Can SMXConfig and a recorder safely access the SDK simultaneously?
- Does entering and leaving test mode alter any persistent controller state?
- Which variations are normal mechanical behavior versus actionable degradation?
