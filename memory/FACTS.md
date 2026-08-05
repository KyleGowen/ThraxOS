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

## 2026-08-01 Ninajirachi girl EDM installation

- **Owner-confirmed:** Add `Ninajirachi's girl EDM (disc 1) special edition` to the canonical ITGMania song library.
- **Observed:** The pack is installed at `C:\Games\ITGmania\Songs\Ninajirachi's girl EDM (disc 1) special edition` with 31 song directories, 31 simfiles, 31 audio files, and `Pack.ini`.
- **Observed:** The downloaded 509.76 MiB archive had SHA-256 `7C9396963EB24DE35C61E78E61311748AEC17D33170595B762DAF34C491CE776`; archive and extracted-tree Defender scans found no threats, and no live song-name collisions were found.

## 2026-08-01 Flow Actualized 2 and Notice Me Benpai 3 installations

- **Owner-confirmed:** Install the previously recommended `Flow Actualized 2` and `Notice Me Benpai 3` packs with the `add-pack` workflow.
- **Observed:** `C:\Games\ITGmania\Songs\Flow Actualized 2` contains 22 song directories, 22 simfiles, and 22 audio files. Its 94.66 MiB archive had SHA-256 `3B1F9D94D65122F6C5613CF01F7C9436FCEFA2E7BF62BC9F91EEB060F77B8BFD`.
- **Observed:** `C:\Games\ITGmania\Songs\Notice Me Benpai 3` contains 32 song directories, 64 simfiles, and 32 audio files. Its 203.60 MiB archive had SHA-256 `BDD063CD730B2A57B51808CB74FB908F1ABE7CB7F5145C2F7F9D648B975DFF5D`.
- **Observed:** Defender found no threats in either archive or extracted pack. Reviewed title-only collisions were distinct songs by different artists; no existing pack or song content was overwritten. Both downloaded ZIPs were deleted.

## 2026-08-01 The Starter Pack of Stamina 2 presence check

- **Owner-confirmed:** Add `The Starter Pack of Stamina 2` alongside the existing `The Starter Pack of Stamina` series.
- **Observed:** Before any download, the requested pack was already present at `C:\Games\ITGmania\Songs\The Starter Pack of Stamina 2`, alongside its predecessor in the canonical song root. Its `Pack.ini` assigns `Series=The Starter Pack of Stamina`, matching the predecessor's series assignment.
- **Observed:** The existing sequel contains 100 song directories, 111 simfiles, and 100 audio files. ITGMania was closed and backup health was successful at the time of inspection. No archive was downloaded, no live content was modified, and no checksum or historical archive-scan result was reconstructed.

## 2026-08-01 seven selected pack installations

- **Owner-confirmed:** Install `Albumix 3.V`, `In The Groove Rebirth 2`, `Easy As Pie 6`, `dimocracy`, `dimocracy 2021 - second term`, `dimocracy 3 - raucous caucus`, and `Cosmic Incarnate` in the canonical song root.
- **Observed:** The installed song/simfile/audio counts are respectively 20/20/20, 78/78/78, 24/24/24, 35/47/35, 55/64/55, 59/90/59, and 23/23/23. Every installed pack has zero malformed song directories.
- **Observed:** Downloaded archive sizes and SHA-256 values were: Albumix 115,320,711 bytes / `8ADC2EB5A07F57EFF1F7152CAADC7B0198AD829E054141543F6FAB36FC410C2D`; Rebirth 2 307,096,996 / `62BEB8D07FCCCE511F2351AC06F4EA4F540365D9B6B5CAB61367F0A3C91E7822`; Easy As Pie 6 103,297,840 / `7EE2F95A0A0BB2C60158F14715E0FBFEBA23E24A9BD977BF17038527469F7931`; dimocracy 333,536,354 / `72F4BC881DE6D884CC476FA925656249020A1D3CE5473B174344A7ED60C17E30`; dimocracy 2021 443,311,932 / `8D48B13DD58614C50126B5F51E564CB473527A854455FA7B0765512AA874226E`; dimocracy 3 565,866,360 / `2AC0965D47DE9270FD7B017FE1EDE61DEDD20A310D2DFAB7F2C803D9A1C6067B`; Cosmic Incarnate 102,158,834 / `9CD650320F793C3E12A9BFF13936012C8B35ADAFCA2EEF65E90264F497700ECC`.
- **Observed:** Albumix's flat source ZIP and dimocracy 2021's root credits file were normalized without changing any file contents; installed normalized ZIP hashes were `B06CB9B266DA89EBC7C050189998429B06B41AF137B6DFB97628FCEA8E5E83A5` and `3F6E6B01270A81FA24D7639BE1983DA89D7EF7AA86697DDF3CF7051025BA8A15`.
- **Observed:** All original and normalized archives had zero unsafe paths or executable/script payloads, and Defender found no threats in the archives or extracted pack trees. Twenty-nine song-folder name collisions were reviewed; none would overwrite live content. Two shared identical audio assets but had different simfiles, while all other reviewed audio hashes differed.
- **Observed:** `In The Groove Rebirth` and `In The Groove Rebirth 2` use `Series=In The Groove`; the three dimocracy packs use `Series=dimocracy`; and Cosmic Evolution, Reincarnate, and Incarnate use `Series=Cosmic`. `Easy As Pie 6` was left ungrouped because no other Easy As Pie pack is installed, and Albumix remains ungrouped.

## 2026-08-02 Nintendo NES controller investigation

- **Observed:** Windows' Bluetooth service was running, but read-only device and driver queries found no Bluetooth radio, Bluetooth driver, Bluetooth PnP device, or Wi-Fi adapter. This is a current Windows enumeration finding, not proof that the NucBox hardware is absent.
- **Inferred from manufacturer specification:** The GMKtec NucBox G3 Plus model includes a Realtek 8852BE Wi-Fi 6/Bluetooth 5.2 module. Restore or enable its official driver before considering a USB Bluetooth adapter.

## 2026-08-04 Nintendo NES controller pairing and mapping

- **Observed:** After a transient Bluetooth driver reset, the Realtek Bluetooth adapter re-enumerated normally and Windows reconnected the paired `NES Controller (R)` as the sole installed game controller (`Wireless Gamepad`).
- **Owner-confirmed:** In Windows' controller test, B/A/L/R/Select/Start report as buttons 1/2/5/6/9/10 and the D-pad reports as POV hat directions.
- **Observed:** With ITGMania closed, the active roaming `Keymaps.ini` was updated and parsed successfully: the D-pad uses `Joy1_H-Up`, `Joy1_H-Down`, `Joy1_H-Left`, and `Joy1_H-Right`, matching the controller's Windows POV hat; A and physical Start map to Start; B maps Back; Select maps Select; and L/R map separately to Player 1 Left/Right for the song-wheel submenu chord. The dedicated Menu-left/Menu-right mappings are intentionally empty because the active Simply Love configuration recognizes `Left-Right` and otherwise consumes the individual direct menu actions. ITGMania retains at most two bindings per action, so Left/Right use the D-pad and L/R shoulders; keyboard fallbacks remain on Up/Down only. Hash-verified pre-edit rollback copies are stored beside the active file.
- **Owner-confirmed:** The final in-game menu mapping, including the L+R song-wheel submenu chord, is working perfectly.

## 2026-08-05 Houdini individual-song installation

- **Owner-confirmed:** Install item 1 from the family-taste individual-song recommendations, Dua Lipa's `Houdini (Initial Talk Dua Goes Freestyle Remix)`, in `Misc. Collected`.
- **Observed:** The Zenius-I-vanisher single-song ZIP was installed at `C:\Games\ITGmania\Songs\Misc. Collected\Houdini (Initial Talk Dua Goes Freestyle Remix)`. It contains six files: one `.sm`, one `.ogg`, and four artwork files. The archive was 4,794,620 bytes with SHA-256 `EF0398DBE18B6001B01BFB7BD453D572C3E3FE092F559598857984891ADB6CC6`.
- **Observed:** The ZIP had one contained top-level song folder, no unsafe paths or executable/script payloads, and no existing destination collision. Microsoft Defender found no threats in both the ZIP and extracted song tree. ITGMania remained closed, and the staged ZIP was deleted after verified installation.

## 2026-08-05 seven additional individual-song installations

- **Owner-confirmed:** Install family-taste recommendation items 2, 3, 4, 5, 6, 8, and 9 in `Misc. Collected` using `add-song`.
- **Observed:** Installed `The One That Got Away` by Katy Perry, `Travelling without moving` by Jamiroquai, `Two Is Better Than One (Mike Rizzo Remix)` by Boys Like Girls feat. Taylor Swift, `We Are Never Ever Getting Bad Blood` by Taylor Swift, `Propane Nightmares (Celldweller Remix)` by Pendulum, `Mi Cama` by KAROL G, and `[Prime Time] - Green Light (Chromeo Remix)` by Lorde. Each installed folder contains exactly one simfile and one audio file.
- **Observed:** Zenius-I-vanisher simfile IDs and ZIP size/SHA-256 values were: `19523`, 35,555,359 bytes, `3E96245ADA4F9D6FF35F43FCC23C0A733C003C569BD1547A48475D2215D0F6FB`; `18945`, 3,578,013 bytes, `521E42EA9C8E1EF52EE244C589A50D543310CB2C314A5D8C9E2E6F7CF5CDC0C7`; `24242`, 2,843,272 bytes, `E6EB546160BCF61515E269042763F954EEA4D021DD6BDC2BD369B80FCD85D5A5`; `26180`, 3,287,029 bytes, `F2478E1C490019000A9D1BB6D204C4EFCB7A69C14B971E905CD1CAFA8A8DF3EB`; `16795`, 1,805,333 bytes, `1D0EBD2FC320CC7220D0527151141862E9E564B322926DC7614EDC940DC66DFF`; `68145`, 22,327,827 bytes, `669CCC68D235C833699309DA524932C96160D148A253A50282BF0C1DD53C352F`; and `37994`, 3,704,577 bytes, `9A9C9FD020DAEDDEE78616FC2D729F34FE4CDEA812B062CF867814BA8392ECCB`.
- **Observed:** All seven ZIP and extracted-tree Defender scans found no threats; no unsafe paths, executable/script payloads, metadata mismatches, or destination collisions were accepted. `Propane Nightmares (Celldweller Remix)` was retained as materially distinct from two installed charts of the original song. All task staging was removed and ITGMania remained closed.
