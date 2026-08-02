# `add-pack` skill

Source: [`.agents/skills/add-pack/`](../../.agents/skills/add-pack/)

Resolves an approved pack, downloads to staging, validates paths/layout, scans payloads, checks collisions, and installs into an approved song root.

## Components

- `scripts/Get-PackArchive.ps1`: resumable download, redirect handling, ZIP signature, size, and SHA-256.
- `scripts/Install-PackArchive.ps1`: dry-run validation, Defender scan, collision checks, guarded installation, and cleanup.
- Depends on `thraxos`, optionally `itg-packs-search`, `docs/context/song-sources.md`, and `docs/runbooks/song-pack-install.md`.
- Host tools: PowerShell, `curl.exe`, archive support, and Microsoft Defender.

## Safety

A named add/install request authorizes that pack; otherwise ask. Never overwrite a pack, accept traversal/executable payloads, delete library content, change roots, or restart ITGMania silently.

## Reproduce and verify

1. Configure the target machine's approved Songs root.
2. Download a disposable ZIP into task-specific `staging/` with `Get-PackArchive.ps1`.
3. Run `Install-PackArchive.ps1` without `-Install`; verify hash, layout, scan, and collision reporting.
4. Test installation only with owner authorization and a non-colliding pack; verify counts and cleanup.
