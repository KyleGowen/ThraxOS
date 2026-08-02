---
name: add-pack
description: Safely find, download, validate, and install ITGMania or StepMania song packs from a pack description, source page, or archive URL. Use when the owner asks to add, download, install, unzip, import, or clean up a song pack in Thraximundar's library, including Google Drive preview links and large-file confirmation pages.
---

# Add Pack

Install song packs through ThraxOS without overwriting library content or trusting an unverified download.

## Load context

1. Read repository `AGENTS.md`, `memory/FACTS.md`, `memory/DECISIONS.md`, and `memory/PREFERENCES.md`.
2. Read `docs/context/song-sources.md` and `docs/runbooks/song-pack-install.md`.
3. Use `$itg-packs-search` when resolving a description through the ITG Packs Release Spreadsheet.
4. Use `C:\Games\ITGmania\Songs` unless the owner explicitly approves another song root.

## Resolve and authorize

- From a description, identify one unambiguous pack from owner-approved sources. Report the exact pack, publisher, archive source, and destination before downloading. Ask if multiple plausible packs remain.
- From a page URL, prefer its publisher-provided archive link. Do not bypass access controls.
- Treat a request to add or install the named pack as authorization to download and install that pack. Otherwise obtain approval.

## Download efficiently

Create a unique repository `staging/` directory and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".agents\skills\add-pack\scripts\Get-PackArchive.ps1" -Url '<url>' -Destination '<staging>\pack.zip'
```

Use `-Resume` after interruption. The helper uses resumable `curl.exe`, resolves common short links, handles Google Drive preview and large-file confirmation pages, verifies a ZIP signature immediately, and reports size plus SHA-256. Do not retry `Invoke-WebRequest` for a large Drive archive.

## Validate and install

1. Run `.agents/skills/thraxos/scripts/Test-BackupHealth.ps1`. Accept a recent log success if scheduled-task inspection alone is access-denied, and report the limitation.
2. Check whether ITGMania is running. Never stop, restart, or reload it automatically.
3. Validate without mutation:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".agents\skills\add-pack\scripts\Install-PackArchive.ps1" -ArchivePath '<staging>\pack.zip'
```

4. Review pack name, counts, unsafe entries, payloads, Defender results, exact-pack collision, and song-name collisions.
5. If clean and authorized, install and remove the archive:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".agents\skills\add-pack\scripts\Install-PackArchive.ps1" -ArchivePath '<staging>\pack.zip' -Install -DeleteArchive
```

Use `-AllowSongNameCollisions` only after reviewing title matches. Never allow an exact pack collision. The installer refuses unsafe paths, executable/script payloads, malformed songs, multiple top-level pack folders, Defender failures, and existing destinations.

## Finish

- Verify the installed folder, simfile/audio counts, and ZIP deletion.
- Do not launch, reload, or restart ITGMania without approval; state when recognition will occur.
- Record source, checksum, validation, destination, counts, cleanup, and game state in `memory/FACTS.md` and `memory/OPERATIONS_LOG.md` without secrets or bulky inventories.
