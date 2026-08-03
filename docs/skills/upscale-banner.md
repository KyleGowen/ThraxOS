# `upscale-banner` skill

Source: [`.agents/skills/upscale-banner/`](../../.agents/skills/upscale-banner/)

Resolves a simfile banner, stages faithful 836 x 328 preview options, renders and directly links the exact full-resolution source Before and every viable After with decoded dimensions, binds approval to an exact selected hash, and performs a guarded replacement only after approval.

## Components

- `scripts/Inspect-Banner.ps1`: resolves and contains `#BANNER` within the song directory.
- `scripts/Normalize-GeneratedBannerPreview.ps1`: standard-decodes a generated image, preserves the raw original, strips problematic ancillary metadata, optionally flattens intended-opaque art with `-Opaque`, and writes a validated 836 x 328 PNG outside the live song root.
- `scripts/Install-ApprovedBanner.ps1`: hash-binds, backs up, and installs the approved preview; it refuses an open game or changed preview/source/simfile, preserves opaque inputs as opaque 836 x 328 output, reports full hash and opacity evidence, and requires an explicit contained fallback original when the referenced target is missing.
- `scripts/Update-BannerQueue.ps1`: maintains the fingerprinted queue, serializes cross-process updates with a per-queue mutex, performs atomic status transitions, preserves attempt history, selects round-robin candidates, proves fallback-created referenced targets, and retains installed-content history across refreshes.
- `scripts/Test-BannerInstallWorkflow.ps1`: disposable fully opaque RGBA fixture test for expected-hash refusal, rollback/hash evidence, opaque installed dimensions, unchanged simfile, and cross-process queue-lock waiting.
- `references/banner-conventions.md`; image editing capability; `memory/banner-upscale-queue.json` for scheduled state.

## Safety

Preview generation is staging-only and scheduled runs never install. Exact-preview approval is required. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility, and do not restart ITGMania.

Bare `install` applies only to the most recently displayed, explicitly labeled, queue-bound After in the same task. Never resolve it from global pending order or an unlabeled artifact. Interactive installs pass the queue's expected preview, source, and simfile hashes into the guarded installer; a lock timeout or hash mismatch stops the workflow instead of authorizing direct JSON or live-file edits.

Built-in image generation results must be forwarded with the runtime's generated-image result handler, not parsed as generic content blocks. A forwarding/staging failure does not consume a model attempt when the generated result remains recoverable. Always render the exact full-resolution source as `Before`, even on failure; render every exact staged result as `After` or `After A`, `After B`, and so on before requesting a choice. State independently decoded pixel dimensions and provide a direct absolute-path link for each image so native-size access remains available when the client scales inline rendering. Never substitute a thumbnail, screenshot, crop, or proxy.

If an inline generation and a saved-file inspection seem visually different, do not retry or rotate the queue from that impression alone. Hash and standard-decode the saved output, normalize it with `Normalize-GeneratedBannerPreview.ps1`, and inspect the normalized copy. Matching bytes or decoded pixels establish a recoverable result even if a vision pass describes it inconsistently; stage it for owner review rather than recording `output-handling-error`.

## Reproduce and verify

1. Adapt approved song roots and queue scope.
2. Run `Inspect-Banner.ps1` on a test simfile; confirm containment and dimensions.
3. Run `Normalize-GeneratedBannerPreview.ps1` against a generated PNG; for an intended-opaque result, pass `-Opaque`. Confirm the raw input remains unchanged, the output decodes at 836 x 328 outside the live song root, opacity matches intent, and a visually disputed result is independently verified before any retry.
4. Run `Update-BannerQueue.ps1 -Refresh -SelectNext`; confirm never-attempted candidates are selected first, followed by returned candidates from least recently attempted, without duplicate fingerprints.
5. Validate staged 836 x 328 PNG output and verify the response visibly renders the exact full-resolution `Before` plus every exact labeled After option, states decoded dimensions, and links each native file directly. Test installation only after approval. Pass expected preview/source/simfile hashes, confirm the installer refuses stale hashes and an open game, then verify its original/backup/installed/simfile hash evidence, unchanged banner reference, and that an opaque preview remains fully opaque after installation.
6. Mark the pending record installed, refresh, and confirm the helper proves the live source equals the installer's deterministic rendering of the approved preview, follows an expected fallback-to-new-target path change when the referenced target was missing, migrates terminal history plus the installed-source hash to the installed-content fingerprint, and rejects any other source-path or live-file mismatch. Use `-RecordInstalledContent` to recover a flow that refreshed before recording or to idempotently repair a missing installed-source hash; re-proof of an installed record must not change `processedAt` or duplicate its decision. Exercise two concurrent fixture updates and confirm the per-queue mutex preserves both rather than allowing a stale writer to replace newer state.
7. Recreate the optional automation from [its guide](../scheduled-tasks/hourly-misc-banner-upscale-queue.md).

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/upscale-banner/scripts/Test-BannerInstallWorkflow.ps1` after installer or queue-lock changes. It creates and removes only a disposable temp fixture and must never point at a live song root.

Failed generation, prompt mistakes, and ordinary preview rejection return the exact pending fingerprint with `-ReturnToQueue`, an outcome, and a nonblank note. This clears active preview state while preserving immutable attempt history and `lastAttemptedAt`. Explicit good-as-is feedback becomes fingerprint-scoped `skipped`, requires a factual `DecisionNote`, and does not require a preview; changed source or simfile content is assessed anew. Use terminal `denied` only when the owner explicitly opts that fingerprint out permanently.

Every terminal install, denial, or skip requires `-DecisionNote` so the queue preserves the owner's outcome and any supplied reasoning. After every run or interactive decision, perform the skill's retrospective: retain fingerprint-specific evidence in the queue, promote stable owner-wide preferences only with adequate evidence, and update the skill plus matching guides only for reusable, actionable lessons. Validate every skill edit. A run with no reusable lesson should not cause a fabricated skill change.
