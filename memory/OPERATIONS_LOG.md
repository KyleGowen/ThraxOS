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
