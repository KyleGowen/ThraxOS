# Operations log

## 2026-07-31 — Initial foundation

- Inventoried model-level Windows hardware and the connected StepManiaX descriptors without recording serial numbers.
- Located ITGMania program, Save, profile, Songs, GrooveStats, StepManiaX, and backup paths.
- Verified the backup schedule, task result, latest log success marker, and GitHub destination.
- Researched current ITGMania, Simply Love/GrooveStats, StepManiaX, song-source, Codex custom-agent, skill, memory, and Remote behavior from primary sources.
- Created the ThraxOS skill, project custom agent, context, runbooks, checked-in memory, redacted status scripts, and repository Git remote.
- Made no live ITGMania, GrooveStats, StepManiaX, backup, song, or Windows configuration changes.

## 2026-07-31 — Owner answers applied

- Recorded the owner-confirmed authorization boundary, public-repository scope, music preferences, Kyle-only privacy policy, cardio inputs, backup-repair policy, and Codex Remote client.
- Inspected the owner-provided SMXConfig screenshot and local SMXConfig 1.0.0.0 settings; recorded `Connected: P2`, the legacy build identifier, and the remaining hardware-identification unknowns.
- Installed GitHub CLI 2.97.0, created the root commit, and published `main` to the public `KyleGowen/ThraxOS` repository using the existing Windows Git credential flow.
- Prepared a guarded GrooveStats configuration script, but did not run it because ITGMania was open. No live game or pad configuration was changed.

## 2026-08-01 — StepManiaX stage identified

- Inspected three owner-provided stage photos and the connected Windows USB interfaces without recording the visible factory serial number or full USB instance identifiers.
- Compared the 25-LED panel matrices and connector layout with Step Revolution's official Gen4+ manual and identified the platform as Generation 4 with high confidence.
- Recorded the observed nine-panel physical layout and official family-level dimensions, weight, power, sensor, lighting, and interface specifications, clearly separating measured observations from published specifications.
- Made no sensitivity, calibration, firmware, lighting, application, or stage configuration changes.
- Added metadata-free PNG copies of the three owner-provided stage photographs as checked-in evidence. Redacted the unique factory serial number from the label photograph; the original attachments remain outside Git.

## 2026-08-01 — ITG Packs search skill added

- Added a project-local `itg-packs-search` skill for efficient live queries of the canonical ITG Packs Release Spreadsheet.
- Encoded the spreadsheet ID and schema, minimal-call search recipes, difficulty-range semantics, author aliases, hyperlink enrichment, recommendation ranking, and source-quality guardrails.
- Added and tested a read-only helper that checks candidate pack and song names against the approved local song roots without printing the entire library.

## 2026-08-01 — Family music taste assessed

- Performed a read-only scan of the approved live song roots and assessed pack names plus simfile title, artist, and genre metadata without copying the song library into ThraxOS.
- Used the owner-curated `Misc. Collected` pack as the strongest library signal and explicitly discounted DDR/ITG completeness packs and Eliza's `K-Pop Demon Hunters` pack as evidence of Kyle's taste.
- Recorded owner-confirmed musical priorities, representative artists, audio/edit quality gates, chart-style preferences, individual difficulty ranges, content policy, and family-aware recommendation ranking in `docs/context/family-music-taste.md`.
- Replaced duplicated broad taste rules with references to the canonical assessment document. No live songs, charts, profiles, or ITGMania configuration were changed.

## 2026-08-01 — GrooveStats enabled for Kyle

- Confirmed ITGMania was closed and the latest backup log recorded a successful run at 03:02 Pacific; scheduled-task inspection remained unavailable due to access permissions.
- Created recoverable local copies of Kyle's `GrooveStats.ini` and the active `ThemePrefs.ini` without recording the profile identifier or API key.
- Used the guarded project helper to set Kyle's `IsPadPlayer=1` and Simply Love's `EnableGrooveStats=true`; no other household profile was modified.
- Re-read both files, confirmed the existing API key remained structurally valid, and verified through masked comparison that only the two approved fields changed.
- The owner launched ITGMania, selected Kyle, and supplied a screenshot showing a successfully loaded GrooveStats leaderboard with GrooveStats' self row highlighted. No manufactured score was submitted.
- Confirmed through secret-safe hashing that Kyle's structurally valid key is distinct from the legacy keys stored in the `elemwarr` and `Crios` local profiles.

## 2026-08-01 — Stamina RPG 10 installed

- Read the official SRPG10 rules, downloads, quest, progression, faction, and shop information through Kyle's authenticated browser session without printing or storing credentials.
- Downloaded the official Unaffiliated and Stamina Nation archives, recorded local SHA-256 fingerprints, rejected unsafe paths and executables, scanned both with Windows Defender, and found no live song-name collisions.
- Verified a recent successful backup and created a recoverable local rollback set for the pre-upgrade program binaries, Simply Love theme, and roaming Save data.
- Upgraded the canonical installation from ITGMania 1.0.2 to 1.3.0 and replaced Simply Love 5.6.1 with 5.9.0 using verified official release assets.
- Installed 97 Unaffiliated charts and 13 Stamina Nation marathons under the canonical song root without overwriting existing packs or songs.
- Confirmed Kyle's GrooveStats configuration and tournament-compatible timing, life, judgment-window, and fail-mode preferences survived the upgrade. ITGMania was left closed pending owner-led live verification.

## 2026-08-01 — Ninajirachi girl EDM installed

- Followed the owner-approved `girl-edm` source to the publisher's Google Drive archive and downloaded it into a unique ThraxOS staging directory.
- Recorded the 509.76 MiB archive's SHA-256 fingerprint, rejected unsafe archive paths and executable/script payloads, and scanned both the archive and extracted pack with Windows Defender; no threats were found.
- Verified 31 valid song directories, 31 simfiles, 31 audio files, one intentional `__bias-check` image-assets directory, and no existing pack or live song-name collisions.
- Installed `Ninajirachi's girl EDM (disc 1) special edition` into the canonical `C:\Games\ITGmania\Songs` root without overwriting content.
- Deleted the downloaded ZIP and empty staging directory as requested. Did not stop, restart, or reload ITGMania; the application was observed running before installation and closed afterward.

## 2026-08-01 — Add Pack skill created

- Added the project-local `add-pack` skill for resolving a pack from a description, source page, or archive URL and installing it through the guarded ThraxOS workflow.
- Added a resumable `curl.exe` downloader that resolves common short links, handles Google Drive preview and large-file confirmation flows, verifies ZIP signatures immediately, and reports size plus SHA-256.
- Added an explicitly gated installer that rejects traversal, absolute paths, executable/script payloads, malformed layouts, Defender failures, exact-pack collisions, and unreviewed song-name collisions before moving content into the canonical song root.
- Validated the skill with the official validator, a clean synthetic pack in non-installing mode, a local download round-trip, and a malicious traversal archive. No test pack was added to the live library.

## 2026-08-01 — Flow Actualized 2 and Notice Me Benpai 3 installed

- Ran two parallel `add-pack` agents with unique staging directories for the owner-authorized Flow Actualized 2 and Notice Me Benpai 3 installations.
- Verified today's 03:02 backup-log success; scheduled-task inspection remained access-denied. ITGMania stayed running and was not stopped, restarted, or reloaded.
- Downloaded both publisher archives, recorded sizes and SHA-256 fingerprints, rejected unsafe paths and executable/script payloads, and completed archive plus extracted-tree Defender scans with no threats.
- Reviewed Flow's `Body Talk` and `Breathe` and Notice's `Everything`, `Get Down`, and `Journey` title collisions against installed metadata. Different artists and audio evidence established that all five are distinct songs, so the reviewed-collision override was used without overwriting content.
- Improved the installer to ignore only conventional top-level `__MACOSX` and `.DS_Store` metadata during pack-folder counting while continuing to safety-check every archive entry.
- Installed 22 Flow songs and 32 Notice songs into separate new canonical pack folders. Deleted both ZIPs and empty staging directories; live recognition awaits an owner-approved reload/restart or normal game action.

## 2026-08-01 - Song packs organized into Series

- Recorded the owner preference that Series must contain at least two installed packs and that the Elemwarr and `Misc. Collected` packs remain ungrouped.
- Confirmed ITGMania was closed and backup health was successful before editing live pack metadata.
- Assigned 48 canonical packs to 11 lineage-based Series: Anthem Series, Ben Speirs / SPEIRMIX, Cosmic, DanceDanceRevolution, DDR Community Collections, In The Groove, JBEAN, Pendulum, Stamina RPG, Tech-Bit Adventures, and The Starter Pack of Stamina.
- Removed nonblank Series assignments from six singleton packs and validated 20 designated standalone packs as ungrouped. No pack directories, songs, charts, scores, or profiles were removed or modified.
- Created recoverable originals and a created-file manifest under `.tmp/pack-series-rollback-20260801-214045`; a second idempotent validation snapshot is under `.tmp/pack-series-rollback-20260801-214103`.
- Re-read every canonical `Pack.ini` Series value and confirmed that all 11 resulting Series contain between 2 and 12 installed packs.

## 2026-08-01 - Community pack sources expanded

- Researched current pack and individual-simfile discovery practices across Reddit, Zenius-I-vanisher, StepMania forums, Flash Flash Revolution, GrooveStats and tournament pages, International Timing Collective resources, ITG Wiki, creator sites, gameplay channels, and Project OutFox material.
- Added owner-approved community discovery and screening sources to `docs/context/song-sources.md`, with explicit roles and cautions for keyboard-first catalogs, mixed chart styles, engine-specific content, previews, reuploads, and direct file-host links.
- Updated the `research-itg-community` skill to distinguish catalog metadata, announcements, reputation evidence, gameplay previews, publisher provenance, and archive validation in future pack research.
- Downloaded or installed no packs and changed no live ITGMania, GrooveStats, StepManiaX, profile, backup, or Windows state.

## 2026-08-01 - The Starter Pack of Stamina 2 already installed

- For the owner-authorized request to add `The Starter Pack of Stamina 2`, inspected the live canonical song root, current ITGMania process state, and backup health before taking any installation action.
- Found the exact pack already installed beside `The Starter Pack of Stamina`; both packs' `Pack.ini` files assign `Series=The Starter Pack of Stamina`. The sequel has 100 song directories, 111 simfiles, and 100 audio files.
- The live ITG Packs Release Spreadsheet INDEX identifies the sequel as a Stream pack and links its publisher-provided MEGA source. The prior archive was not staged locally, so no trustworthy historic archive checksum or scan result could be recovered.
- Did not download, extract, install, overwrite, delete, restart, or reload anything. The guarded installer would refuse the existing exact destination, preserving the already-installed library content.

## 2026-08-01 - Seven selected packs installed and grouped

- Verified ITGMania was closed and the 2026-08-01 03:02 backup-log success before mutation; scheduled-task inspection remained access-denied. ITGMania was not launched, stopped, restarted, or reloaded.
- Downloaded Albumix from its Zenius-I-vanisher category, Rebirth 2 and Cosmic Incarnate from the current ITGDb-linked StepMania Online records, Easy As Pie 6 from its current ITGDb-linked StepMania Online record, and all three dimocracy archives from the publisher's `omid.gg` download routes.
- Recorded the seven downloaded sizes and SHA-256 fingerprints in `memory/FACTS.md`; rejected unsafe paths and executable/script payloads and completed Defender archive and extracted-tree scans with no threats.
- Normalized Albumix's flat 20-song layout under `Albumix 3.V` and moved dimocracy 2021's harmless root credits text inside its pack folder. File-by-file SHA-256 manifests proved zero content differences across 47 Albumix files and 302 dimocracy 2021 files. A short staging path allowed the unmodified dimocracy 3 ZIP to pass the legacy Windows extraction-path limit.
- Reviewed 29 live song-folder name collisions by artist metadata and audio SHA-256. Twenty-seven used different audio; Albumix `Hypnodancer` and dimocracy 3 `Worst Plan` shared audio with existing packs but had different simfile hashes. Used the reviewed-collision override only for those six affected packs; `dimocracy` needed no override. No existing pack or song was overwritten.
- Installed all seven packs into `C:\Games\ITGmania\Songs` and verified song/simfile/audio counts of 20/20/20, 78/78/78, 24/24/24, 35/47/35, 55/64/55, 59/90/59, and 23/23/23, with zero malformed song directories.
- Preserved the existing Rebirth and Cosmic lineage conventions, assigned all three new dimocracy packs to `Series=dimocracy`, and blanked Easy As Pie 6's singleton `Series` value. Re-read every affected `Pack.ini` and confirmed the requested lineages without altering songs, charts, scores, or profiles.
- After final verification, deleted this task's downloaded archives, normalized copies, temporary short-path copy, and temporary Easy rollback copy: 3,094,143,232 staged bytes total. Both task-specific staging paths were confirmed absent.

## 2026-08-01 - Final Fantasy IV Boss Theme banner repaired

- **Owner-confirmed:** Replace the blurry banner for `Misc. Collected/Boss theme - Final Fantasy IV` with sharp artwork using the working `Boom Shakalaka` banner convention as the resolution reference.
- **Observed:** The simfile references `FF4- Boss theme.png`; the original decoded successfully but was only 255 x 80, while the reference banner is an 836 x 328 PNG. ITGMania remained running throughout and was not restarted or terminated.
- **Observed:** Backup health inspection at 23:39 Pacific found the scheduled task actively running and the most recent completed success at 03:02. Before the artwork-only replacement, preserved the original beside the song as `FF4- Boss theme.png.pre-crisp-20260801-2345.bak`.
- Replaced only the referenced banner with a crisp 836 x 328 PNG built from the song's existing Final Fantasy IV pixel artwork and newly rendered title/artist typography. Post-write validation confirmed PNG decoding, 32-bit color, exact dimensions, and the unchanged `#BANNER:FF4- Boss theme.png;` reference. No simfiles, audio, charts, scores, profiles, configuration, or process state were changed.

## 2026-08-01 - Final Fantasy IV banner replacement reverted

- **Owner-confirmed:** The newly rendered Final Fantasy IV banner was not acceptable and should be undone.
- **Observed:** Restored the original 255 x 80 PNG from `FF4- Boss theme.png.pre-crisp-20260801-2345.bak` and verified that the restored image decodes at its original dimensions.
- Preserved the rejected 836 x 328 replacement as `FF4- Boss theme.png.rejected-crisp-20260801-2359.bak` rather than deleting it. No simfiles, audio, charts, scores, profiles, configuration, or process state were changed.

## 2026-08-01 - Owner-approved regenerated Final Fantasy IV banner installed

- **Owner-confirmed:** After reviewing the generated preview in chat, approved that exact regenerated banner for installation.
- **Observed:** Resized the approved preview to the established 836 x 328 banner dimensions and installed it as the existing `FF4- Boss theme.png` target. Verified PNG decoding, exact dimensions, and the unchanged `#BANNER:FF4- Boss theme.png;` simfile reference.
- Preserved the previously restored 255 x 80 original as `FF4- Boss theme.png.pre-approved-preview-20260801-2359.bak`. ITGMania was not restarted or terminated, and no simfiles, audio, charts, scores, profiles, or configuration were changed.

## 2026-08-02 - Banner restoration skill added

- **Owner-confirmed:** Add a reusable `upscale-banner` workflow that resolves the banner from a simfile, preserves the image content, presents an inline preview, and never installs before explicit approval.
- **Observed:** ITGMania was running during skill development; no live song, banner, process, configuration, score, or profile state was changed.
- Added deterministic inspection and approved-install helpers. The install path creates a timestamped sibling backup, normalizes the approved preview to 836 x 328 PNG, validates decoding and the unchanged `#BANNER` reference, and does not restart ITGMania.

## 2026-08-02 - Children Dream Version banner restored

- **Owner-confirmed:** Approved the exact GPT Image 2 high-fidelity preview shown in chat for `Misc. Collected/Children (Dream ver.)` by Robert Miles.
- **Observed:** The simfile referenced `Children (Dream ver.)-bn.png`, which was missing, while ITGMania had displayed the existing 256 x 80 `Children (Dream ver.).png` fallback. Backup health was successful at 00:13 Pacific with scheduled-task result `0x0`.
- Created the previously missing referenced banner as an 836 x 328 PNG and verified its decoding, dimensions, SHA-256, and unchanged `#BANNER` value. Preserved the original fallback file untouched. ITGMania was not restarted or terminated, and no simfiles, audio, charts, scores, profiles, or configuration were changed.

## 2026-08-02 - Upscale Banner comparison preview added

- **Owner-confirmed:** Require the `upscale-banner` skill to display the current banner and generated candidate together as labeled `Before` and `After` images.
- Updated the preview contract and skill UI prompt without changing the approval-gated installation, backup, validation, or no-restart safeguards. No live ITGMania or song files were changed.

## 2026-08-02 - Upscale Banner two-attempt fallback policy added

- **Owner-confirmed:** Allow deterministic exact-content upscaling only after two failed GPT Image 2 high-fidelity attempts.
- Updated the processing-path contract to retry generation exactly once, disclose both failures, and require approval before deterministic fallback unless already granted. No live ITGMania or song files were changed.

## 2026-08-02 - Chill Dr. Mario banner upscaled

- **Owner-confirmed:** After two GPT Image 2 output-filter failures, approved deterministic exact-content fallback and then approved the labeled 836 x 328 `After` preview for installation.
- **Observed:** The simfile referenced a missing `bn.png`, while ITGMania had used the existing 256 x 80 `Chill (Dr. Mario).png` fallback. Backup health was successful at 00:24 Pacific with scheduled-task result `0x0`.
- Created the missing referenced `bn.png` from the exact approved deterministic preview and verified PNG decoding, 836 x 328 dimensions, SHA-256, and the unchanged `#BANNER:bn.png;` reference. Preserved the original fallback untouched. ITGMania was closed and was not restarted; no simfiles, audio, charts, scores, profiles, or configuration were changed.

## 2026-08-02 - Misc. Collected banner queue seeded

- **Owner-confirmed:** Create a durable candidate queue for hourly preview-only banner restoration, allow distinct candidates to proceed while earlier previews await a response, and keep installation interactive.
- **Observed:** Read-only assessment covered every current song directory in the live canonical `Misc. Collected` pack. The queue records simfile and source fingerprints, dimensions, eligibility reasons, processing state, and exact preview identity when one exists.
- Added a deterministic refresh, selection, and atomic state-transition helper. No live song, banner, simfile, audio, chart, score, profile, configuration, or process state was changed, and no automation was created.

## 2026-08-02 - Hourly banner queue test run stopped after two generation failures

- **Observed:** Refreshed the live `Misc. Collected` banner queue and deterministically selected `80s Fitness`, whose referenced `80s bn.png` decoded at 418 x 164. ITGMania was closed during the observation.
- Atomically reserved fingerprint `99E71968030E09A5C1DA25FE464947C84BF3B44D45FEF41B6D8106E4092F0608` as pending before image work. Both permitted GPT Image 2 high-fidelity restoration attempts returned no usable image payload, so no preview path or preview SHA-256 was recorded and the pending action remains `generate-preview`.
- No deterministic fallback was attempted. No live song, banner, simfile, audio, chart, score, profile, configuration, or process state was changed.

## 2026-08-02 - Banner queue return-with-context behavior added

- **Owner-confirmed:** Return the unsuccessful `80s Fitness` attempt to the queue as unprocessed while preserving that both generation attempts failed and the attempted prompt misread the artist as `KENN YOUNG`; the banner's exact artist text is `KOAN SOUND`.
- Added an atomic return-to-queue transition that records timestamped attempt outcome and notes, preserves any discarded preview identity, clears active preview and processing fields, and restores eligibility with a null `processedAt`.
- Updated the reusable banner skill to require future runs to read and honor attempt history before prompting. No live song, banner, simfile, audio, chart, score, profile, configuration, or process state was changed.
- Extended selection to round-robin ordering using durable `lastAttemptedAt`: never-attempted candidates are exhausted first, then returned candidates rotate from least recently attempted. Ordinary declines rotate; only explicit permanent opt-outs become terminal denials.

## 2026-08-02 - A Little Respect banner preview staged

- **Observed:** Refreshed all 206 live `Misc. Collected` song directories and used the queue helper's round-robin selection, which chose the never-attempted `A Little Respect` fingerprint. ITGMania was closed during the observation.
- The simfile references missing `banner.png`; the queue's decodable source fallback is the existing 512 x 160 `A Little Respect.png`. A single GPT Image 2 high-fidelity attempt preserved the visible `erasure` and `a little respect` text and original composition.
- Staged and validated an 836 x 328 PNG outside the live song folder, then bound its SHA-256 `5E5BE36185314B3C9274E6FE6E4D9B88167271AEB30192B97666D1CA1359CDDB` to the exact pending fingerprint for owner review. No live song, banner, simfile, audio, chart, score, profile, configuration, or process state was changed.

## 2026-08-02 - Round-robin banner automation test run

- **Observed:** A live refresh selected `A Different Point of View`, confirming the returned `80s Fitness` fingerprint did not repeat. ITGMania was closed during the test.
- The simfile's referenced `PoV.png` was missing; the queue-resolved 256 x 80 fallback `A Different Point of View.png` decoded and was used as the sole visual source. The visible title was verified as `A Different Point of View`; the simfile artist is Pet Shop Boys but is not printed on the source banner.
- Both permitted GPT Image 2 high-fidelity restoration attempts returned no usable image payload. The helper atomically recorded the failure context, restored the fingerprint to eligible with null `processedAt`, retained `lastAttemptedAt`, and advanced the next selection to `About Damn Time (Purple Disco Machine Remix)`.
- The active hourly automation began independently at 01:00 Pacific and reserved `A Little Respect`; that separate pending fingerprint was left untouched. No live song, banner, simfile, audio, chart, score, profile, configuration, or process state was changed.

## 2026-08-02 - Banner result handling and comparison contract corrected

- **Observed:** The two test runs classified blank rendered responses as incomplete image payloads because their wrappers inspected generic content blocks instead of forwarding the built-in image-generation result with the generated-image result handler. The underlying model outcome is therefore unknown; those observations do not establish repeated GPT Image 2 generation failure.
- **Owner-confirmed:** Always show the source `Before`, including failure responses, and show every viable generated choice as a clearly labeled After option before asking for selection or installation.
- Updated the skill, UI prompt, scheduled-task guide, and result-handling policy. Recoverable forwarding or staging errors no longer consume a generative attempt. No live song, banner, simfile, audio, chart, score, profile, configuration, or process state was changed.

## 2026-08-02 - Banner post-run learning loop added

- **Owner-confirmed:** After every banner run and install or denial response, inspect the conversation for useful lessons from successes, failures, selections, and stated rejection reasoning, and improve the reusable workflow when justified.
- Added required outcome notes for terminal queue decisions, exact-fingerprint decision history, evidence-tiered retrospective rules, documentation synchronization, and validation requirements. A single aesthetic rejection remains banner-specific unless the owner generalizes it or repeated outcomes support a stable preference.
- The learning loop may update checked-in skill guidance and memory but never live songs, exact-preview approval, application state, scores, profiles, or safety boundaries. No live ITGMania state was changed.

## 2026-08-02 - A Little Respect banner installed

- **Owner-confirmed:** Approved the exact staged `After` preview with SHA-256 `5E5BE36185314B3C9274E6FE6E4D9B88167271AEB30192B97666D1CA1359CDDB` for installation.
- **Observed:** Backup evidence was degraded only because scheduled-task inspection was access-denied; the latest log recorded a successful commit and push at 03:02 Pacific on 2026-08-01.
- Created the previously missing referenced `banner.png` as an 836 x 328 PNG and verified decoding, dimensions, the unchanged `#BANNER:banner.png;` reference, and unchanged simfile hash. The installed PNG SHA-256 is `8F52FEDB3D5560E08681B793DD802801D4177D106E732D037321F7A397D39BAF` after guarded PNG normalization.
- Preserved the 512 x 160 fallback `A Little Respect.png` untouched and saved its exact bytes as `banner.png.pre-upscale-20260802-011310.bak`. Marked the approved queue fingerprint `installed`. ITGMania remained closed and was not restarted; no audio, charts, scores, profiles, or configuration were changed.
