# `upscale-background` skill

Source: [`.agents/skills/upscale-background/`](../../.agents/skills/upscale-background/)

Resolves one explicit static `#BACKGROUND`, assesses full-screen fit and quality, stages faithful 1920 x 1080 previews, learns from fingerprint-bound outcomes, and installs only an exact approved candidate.

## Components and dependencies

- `Inspect-Background.ps1`: containment, explicit-reference, static-format, decode, frame, and `BGCHANGES` checks.
- `Update-BackgroundQueue.ps1`: discovery, fingerprinting, atomic transitions, history, and round-robin selection.
- `Record-BackgroundLearning.ps1`: mandatory end-of-interaction retrospective ledger with enforced evidence for reusable skill changes.
- `Install-ApprovedBackground.ps1`: format-correct guarded replacement, sibling rollback copy, and validation.
- `references/background-conventions.md`, image editing capability, `thraxos`, and `memory/background-upscale-queue.json`.

Inputs are an approved pack/folder and a song simfile. Outputs are labeled Before/After previews and ledger transitions. Host defaults are the `Misc. Collected` pack and owner-confirmed windowed 1920 x 1080 16:9 display.

## Safety and behavior

Scheduled runs are preview-only and produce at most one new candidate. Missing backgrounds, video/animation, GIF, `BGCHANGES`, implicit `.dwi` art, conflicts, traversal, and undecodable images are excluded. Pending work does not block later candidates. Ordinary denials rotate; explicit good-as-is feedback becomes fingerprint-scoped `skipped`, while only explicit never-again feedback becomes `denied`. Changed content receives a fresh assessment, except that a source whose hash exactly equals its approved installed preview retains installed decision/history under the refreshed fingerprint. Installation requires ITGMania closed, exact preview/hash approval, backup evidence plus a sibling rollback copy, and leaves the game closed.

Every completed interaction must call `Record-BackgroundLearning.ps1` with `none`, `fingerprint`, or `reusable`. Reusable entries require named changed files and successful skill validation; scheduled-behavior changes also update the live automation prompt. This makes self-improvement auditable while allowing an honest no-change result.

## Reproduce and verify

1. Copy the complete skill and adapt approved paths/display convention.
2. Validate the skill, then run the inspector against static, missing, animated/changing, and traversal fixtures.
3. Refresh a temporary queue and confirm exclusions, fingerprints, new-song discovery, one-at-a-time round robin, pending nonblocking behavior, return history, fingerprint-scoped `skipped`, and terminal decisions.
4. Test installation only on a disposable fixture. Confirm 1920 x 1080, one frame, encoding matching the referenced extension, unchanged simfile/reference, and rollback restoration.
5. Recreate the optional automation from its scheduled-task guide.
6. Test all three learning scopes and confirm `reusable` is rejected without changed files and successful validation evidence.
