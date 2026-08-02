# `upscale-banner` skill

Source: [`.agents/skills/upscale-banner/`](../../.agents/skills/upscale-banner/)

Resolves a simfile banner, stages faithful 836 x 328 preview options, always renders the source Before and every viable After, binds approval to an exact selected hash, and performs a guarded replacement only after approval.

## Components

- `scripts/Inspect-Banner.ps1`: resolves and contains `#BANNER` within the song directory.
- `scripts/Install-ApprovedBanner.ps1`: backs up and installs the approved preview.
- `scripts/Update-BannerQueue.ps1`: maintains the fingerprinted queue, atomic status transitions, attempt history, and round-robin selection.
- `references/banner-conventions.md`; image editing capability; `memory/banner-upscale-queue.json` for scheduled state.

## Safety

Preview generation is staging-only and scheduled runs never install. Exact-preview approval is required. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility, and do not restart ITGMania.

Built-in image generation results must be forwarded with the runtime's generated-image result handler, not parsed as generic content blocks. A forwarding/staging failure does not consume a model attempt when the generated result remains recoverable. Always render `Before`, even on failure; render all viable results as `After` or `After A`, `After B`, and so on before requesting a choice.

## Reproduce and verify

1. Adapt approved song roots and queue scope.
2. Run `Inspect-Banner.ps1` on a test simfile; confirm containment and dimensions.
3. Run `Update-BannerQueue.ps1 -Refresh -SelectNext`; confirm never-attempted candidates are selected first, followed by returned candidates from least recently attempted, without duplicate fingerprints.
4. Validate staged 836 x 328 PNG output and verify the response visibly renders `Before` plus every labeled After option. Test installation only after approval; confirm the original backup and unchanged simfile reference.
5. Recreate the optional automation from [its guide](../scheduled-tasks/hourly-misc-banner-upscale-queue.md).

Failed generation, prompt mistakes, and ordinary preview rejection return the exact pending fingerprint with `-ReturnToQueue`, an outcome, and a nonblank note. This clears active preview state while preserving immutable attempt history and `lastAttemptedAt`. Use terminal `denied` only when the owner explicitly opts that fingerprint out permanently.

Every terminal install or denial requires `-DecisionNote` so the queue preserves the owner's outcome and any supplied reasoning beside the exact preview hash. After every run or interactive decision, perform the skill's retrospective: retain fingerprint-specific evidence in the queue, promote stable owner-wide preferences only with adequate evidence, and update the skill plus matching guides only for reusable, actionable lessons. Validate every skill edit. A run with no reusable lesson should not cause a fabricated skill change.
