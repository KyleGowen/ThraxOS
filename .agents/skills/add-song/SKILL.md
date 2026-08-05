---
name: add-song
description: Resolve, download, validate, scan, and install one individual ITGMania or StepMania simfile into Thraximundar's Misc. Collected folder with automatic staging cleanup. Use when the owner asks to add, download, install, or import a single song or simfile rather than a complete song pack.
---

# Add Song

Install one publisher-sourced song into `C:\Games\ITGmania\Songs\Misc. Collected` without overwriting library content or leaving download/extraction debris.

## Load context

1. Read repository `AGENTS.md`, `memory/FACTS.md`, `memory/DECISIONS.md`, and `memory/PREFERENCES.md`.
2. Read `docs/context/song-sources.md` and `docs/runbooks/song-pack-install.md`.
3. Use the project `research-itg-community` skill only when provenance, pad suitability, or the correct release remains uncertain.

## Resolve and authorize

- Resolve a description or source page to one unambiguous publisher-provided ZIP. Prefer Zenius-I-vanisher or another owner-approved catalog and follow its download link; do not substitute a search-result URL or unverified mirror.
- Confirm the page identifies a pad chart and capture artist, title, chart difficulties, publisher, source page, and archive URL.
- Treat an explicit request to add or install that named song as authorization for its download and installation. Ask if multiple plausible releases remain.
- Use the default `Misc. Collected` destination unless the owner explicitly names another existing approved pack folder.

## Install efficiently

Run one guarded command from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".agents\skills\add-song\scripts\Install-SingleSong.ps1" -Url '<publisher ZIP URL>' -SourcePage '<source page URL>' -ExpectedArtist '<artist>' -ExpectedTitle '<title>' -Install
```

The script creates GUID-named staging, downloads through the existing resumable ZIP helper, checks backup evidence and the closed-game condition, rejects unsafe paths and executable payloads, requires exactly one song folder with simfile and audio, verifies expected metadata, scans both ZIP and extracted tree with Defender, refuses an existing destination, installs atomically, verifies the result, and removes its staging directory in `finally` on success or failure.

Omit `-Install` for a cleanup-complete validation-only run. Never add collision overrides or manually merge an existing folder. Never terminate, launch, restart, or reload ITGMania.

## Finish

- Report source page, exact destination, byte size, SHA-256, simfile/audio counts, Defender results, backup evidence, cleanup, and whether ITGMania remained closed.
- State that recognition occurs on the next owner-approved launch or reload.
- Record a successful installation in `memory/FACTS.md` and `memory/OPERATIONS_LOG.md`; do not record failed discovery attempts or bulky inventories.
