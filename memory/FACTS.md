# Facts

## 2026-07-31 initial inventory

- **Owner-confirmed:** The machine is named Thraximundar and is dedicated primarily to ITGMania with a StepManiaX stage.
- **Owner-confirmed:** The owner has played DDR/ITG/StepMania since 1998 and plays with friends and family for fun aerobic exercise.
- **Observed:** The host is a GMKtec NucBox G3 Plus running Windows 11 Pro build 26200 with an Intel N150, 16 GiB DDR4-3200, Intel Graphics, and a 1 TB NVMe SSD.
- **Observed:** ITGMania 1.0.2 is installed at `C:\Games\ITGmania`; active roaming data is under `C:\Users\Player.NUCBOXG3_PLUS\AppData\Roaming\ITGmania`.
- **Observed:** Simply Love is active, the game mode is dance/ITG, and the configured game resolution is 1280×720 windowed at 60 Hz with VSync.
- **Observed:** There are 63 install-root pack directories and one user-root pack directory.
- **Observed:** Seven local profiles exist. Kyle has a structurally valid GrooveStats API key, but GrooveStats is globally disabled and Kyle is not marked as a pad player.
- **Observed:** Windows identifies the connected controller as StepManiaX, and SMXConfig is installed at `C:\Games\SMXConfig`.
- **Observed:** The ITGMania backup is scheduled for 03:00 Pacific daily; the 2026-07-31 run completed and pushed successfully.

## 2026-07-31 owner clarifications and live evidence

- **Owner-confirmed:** `C:\Games\ITGmania` is the canonical ITGMania installation and song root.
- **Owner-confirmed:** The extra user-root copy of `80s Greatest Hits Volume 1` is an unintended duplicate. It must not be deleted without a later explicit request.
- **Owner-confirmed:** Remote operation is through Codex Remote from the ChatGPT mobile app.
- **Owner-confirmed:** Only Kyle is authorized for GrooveStats and remote per-profile play summaries.
- **Owner-confirmed:** Kyle is a 42-year-old man, 6 ft 5 in tall, and 240 lb; these inputs may be used for clearly labeled calorie estimates.
- **Observed:** The StepManiaX Platform app reports `Connected: P2` and identifies itself as `SMXConfig version 2020-04-03-01`. Its Settings view exposes High, Medium, and Low sensitivity choices, a 3x3 panel-color layout, Advanced, and Diagnostics tabs. The screenshot does not reveal the selected sensitivity, hardware generation, or firmware.
- **Observed:** SMXConfig 1.0.0.0 is installed at `C:\Games\SMXConfig`; its per-user settings enable launch on startup. No generation identifier was found in that user configuration.
- **Observed:** ITGMania and SMXConfig were running during the 2026-07-31 configuration pass, so no live ITGMania files were changed.

## 2026-08-01 StepManiaX stage identification

- **Observed (high confidence):** The connected platform is a StepManiaX Generation 4 stage configured/labeled as P2. Owner-provided photos show the Gen4+ 25-LED panel matrices and the Generation 4 connector arrangement (Micro-USB data and no Generation 5 external barrel-power input). The factory serial label was visible but is intentionally not recorded.
- **Observed:** The stage has nine square acrylic panels installed, a stainless-steel frame and fixed-height support bar, integrated 100-240 V AC 50/60 Hz power, and is powered and detected by Windows through HID game-controller and USB-serial interfaces using the non-unique `VID_2341&PID_8037` identifier.
- **Inferred:** The visible hardware matches the official Gen4 platform family specification: approximately 35 x 47 x 7 inches and about 200-220 lb. These dimensions and weight were not physically measured on this particular unit.
- **Unknown:** The installed firmware revision, current sensitivity preset, and whether all four corner panels contain enabled pressure sensors are not exposed by the photos or standard Windows device properties.

## 2026-08-01 GrooveStats configuration

- **Owner-confirmed:** Enable GrooveStats for Kyle and mark Kyle as a pad player, using the existing profile API key.
- **Observed:** With ITGMania closed, Simply Love was configured with `EnableGrooveStats=true` and Kyle's profile with `IsPadPlayer=1`.
- **Observed:** Kyle's API key remained present and structurally valid, rollback copies of both edited INI files were created, and masked before/after comparisons showed no unrelated content changes.
- **Observed:** With Kyle selected in ITGMania, the GrooveStats leaderboard loaded successfully and GrooveStats identified the account's self row. Kyle's API key is structurally valid and does not match the legacy keys stored in the `elemwarr` or `Crios` local profiles.

## 2026-08-01 Stamina RPG 10 installation

- **Owner-confirmed:** Upgrade ITGMania to 1.3.0 and Simply Love to 5.9.0, use Kyle's existing GrooveStats login for SRPG10, and install the Unaffiliated and Stamina Nation downloads.
- **Observed:** ITGMania 1.3.0 and Simply Love 5.9.0 are installed. Kyle's GrooveStats key remains present with a valid shape, `IsPadPlayer=1`, and `EnableGrooveStats=true`.
- **Observed:** `C:\Games\ITGmania\Songs\Stamina RPG 10` contains 97 songs/simfiles and `Stamina RPG 10 - SN` contains 13 songs/simfiles. The official archives had no unsafe paths, executable payloads, Defender detections, or live song-name collisions.
- **Observed:** Tournament-compatible defaults remain present: dance mode, timing and life scales of 1.0 (Judge/Life 4), Decent and Way-Off windows, and `FailImmediateContinue`.
