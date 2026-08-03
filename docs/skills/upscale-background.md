# `upscale-background` skill

Source: [`.agents/skills/upscale-background/`](../../.agents/skills/upscale-background/)

Resolves one explicit static `#BACKGROUND`, assesses full-screen fit and quality, stages faithful 1920 x 1080 previews, learns from fingerprint-bound outcomes, and installs only an exact approved candidate.

## Components and dependencies

- `Inspect-Background.ps1`: containment, explicit-reference, static-format, decode, frame, and empty-versus-active `BGCHANGES` checks.
- `Update-BackgroundQueue.ps1`: discovery, fingerprinting, severity tiers, review-only legacy classification, atomic transitions, history, and round-robin selection.
- `Test-BackgroundQueue.ps1`: disposable fixtures for empty/active `BGCHANGES`, quality priority, review-only classification, inspector behavior, and installed-preview history preservation.
- `Record-BackgroundLearning.ps1`: mandatory end-of-interaction retrospective ledger with enforced evidence for reusable skill changes.
- `Install-ApprovedBackground.ps1`: format-correct guarded replacement, sibling rollback copy, and validation.
- `references/background-conventions.md`, image editing capability, `thraxos`, and `memory/background-upscale-queue.json`.

Inputs are an approved pack/folder and a song simfile. Outputs are labeled Before/After previews and ledger transitions. Host defaults are the `Misc. Collected` pack and owner-confirmed windowed 1920 x 1080 16:9 display.

## Safety and behavior

Scheduled runs are preview-only and produce at most one new candidate. Empty `#BGCHANGES:;` metadata is accepted; populated or malformed changes, video/animation, GIF, conflicts, traversal, and undecodable images remain excluded. Plausible implicit `.dwi` art and missing-reference fallbacks enter a non-selectable `review-only` lane until the owner confirms a source through a later resolution workflow. Eligible explicit static art is prioritized as broken/tiny, aspect-mismatched, SD-or-smaller, sub-HD, then soft-review, with round-robin rotation within a tier. Only clean near-16:9 soft-review art at 1280 x 720 or better may be skipped for adequate runtime quality. Pending work does not block later candidates. When two genuine AI attempts are exhausted and fallback needs owner approval, `-AwaitOwnerInput` leaves the exact fingerprint pending with `pendingAction=awaiting-fallback-approval`; it must not return to eligible and repeatedly starve lower tiers. Ordinary denials and recoverable failures rotate; explicit good-as-is feedback becomes fingerprint-scoped `skipped`, while only explicit never-again feedback becomes `denied`. Assessment-rule fingerprint migrations preserve status and history when the explicit reference, source hash, and simfile hashes are unchanged. Genuinely changed content receives a fresh assessment, while a source whose hash exactly equals its approved installed preview retains installed decision/history. Installation requires ITGMania closed, exact preview/hash approval, backup evidence plus a sibling rollback copy, and leaves the game closed.

Every completed interaction must call `Record-BackgroundLearning.ps1` with `none`, `fingerprint`, or `reusable`. Reusable entries require named changed files and successful skill validation; scheduled-behavior changes also update the live automation prompt. This makes self-improvement auditable while allowing an honest no-change result.

## Reproduce and verify

1. Copy the complete skill and adapt approved paths/display convention.
2. Run `Test-BackgroundQueue.ps1`, then validate the skill. Confirm the suite accepts empty `BGCHANGES`, rejects active changes, orders quality tiers, records review-only sources, and preserves installed-preview history.
3. Run the inspector against additional static, missing, animated/changing, and traversal fixtures. Refresh a temporary queue and confirm fingerprints, new-song discovery, one-at-a-time tiered round robin, pending nonblocking behavior, return history, fingerprint-scoped `skipped`, and terminal decisions.
4. Test installation only on a disposable fixture. Confirm 1920 x 1080, one frame, encoding matching the referenced extension, unchanged simfile/reference, and rollback restoration.
5. Recreate the optional automation from its scheduled-task guide.
6. Test all three learning scopes and confirm `reusable` is rejected without changed files and successful validation evidence.
