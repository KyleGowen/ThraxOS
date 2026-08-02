# `upscale-banner` skill

Source: [`.agents/skills/upscale-banner/`](../../.agents/skills/upscale-banner/)

Resolves a simfile banner, stages a faithful 836 x 328 preview, binds approval to its exact hash, and performs a guarded replacement only after approval.

## Components

- `scripts/Inspect-Banner.ps1`: resolves and contains `#BANNER` within the song directory.
- `scripts/Install-ApprovedBanner.ps1`: backs up and installs the approved preview.
- `scripts/Update-BannerQueue.ps1`: maintains the fingerprinted queue, atomic status transitions, attempt history, and round-robin selection.
- `references/banner-conventions.md`; image editing capability; `memory/banner-upscale-queue.json` for scheduled state.

## Safety

Preview generation is staging-only and scheduled runs never install. Exact-preview approval is required. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility, and do not restart ITGMania.

## Reproduce and verify

1. Adapt approved song roots and queue scope.
2. Run `Inspect-Banner.ps1` on a test simfile; confirm containment and dimensions.
3. Run `Update-BannerQueue.ps1 -Refresh -SelectNext`; confirm never-attempted candidates are selected first, followed by returned candidates from least recently attempted, without duplicate fingerprints.
4. Validate staged 836 x 328 PNG output. Test installation only after approval; confirm the original backup and unchanged simfile reference.
5. Recreate the optional automation from [its guide](../scheduled-tasks/hourly-misc-banner-upscale-queue.md).

Failed generation, prompt mistakes, and ordinary preview rejection return the exact pending fingerprint with `-ReturnToQueue`, an outcome, and a nonblank note. This clears active preview state while preserving immutable attempt history and `lastAttemptedAt`. Use terminal `denied` only when the owner explicitly opts that fingerprint out permanently.
