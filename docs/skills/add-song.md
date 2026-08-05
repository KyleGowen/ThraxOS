# `add-song` skill

Source: [`.agents/skills/add-song/`](../../.agents/skills/add-song/)

Resolves one individual simfile to its publisher ZIP, downloads it once, validates and scans its single-song layout, installs it into `Misc. Collected`, and removes all task staging.

## Components and dependencies

- `scripts/Install-SingleSong.ps1`: GUID-scoped staging, existing resumable download helper invocation, archive and metadata validation, Defender scans, guarded installation, verification, and unconditional staging cleanup.
- Depends on `thraxos`, the `add-pack` download helper, `docs/context/song-sources.md`, and `docs/runbooks/song-pack-install.md`.
- Host tools: Windows PowerShell, `curl.exe`, ZIP support, and Microsoft Defender.

## Inputs and outputs

- Inputs: publisher ZIP URL, source page, expected artist/title, optional approved existing song-group root, and `-Install` authorization switch.
- Default destination: `C:\Games\ITGmania\Songs\Misc. Collected\<archive song folder>`.
- Output: JSON evidence containing source, metadata, destination, size, SHA-256, content counts, scan results, backup evidence, game state, install state, and cleanup state.

## Safety boundary

An explicit named-song add/install request authorizes that song only. The script refuses an open ITGMania process, stale or absent backup evidence, unsafe paths, executable payloads, multiple top-level folders, missing simfile/audio, expected-metadata drift, Defender failures, and existing destinations. It never merges, overwrites, launches, reloads, or restarts the game. Its own task staging is removed after success or failure.

## Reproduce and verify

1. Copy the whole `add-song` directory and retain the sibling `add-pack` and `thraxos` dependencies.
2. Adapt the default destination only if the new host uses a different approved curated song folder.
3. Run without `-Install` against a disposable publisher ZIP; verify JSON evidence and zero remaining `staging/add-song-*` directories.
4. Test rejection fixtures for unsafe paths, executable payloads, missing audio, metadata mismatch, and an existing destination.
5. With explicit authorization and ITGMania closed, run once with `-Install`; verify installed counts, clean staging, and unchanged game process state.
