# `upscale-background` skill

Source: [`.agents/skills/upscale-background/`](../../.agents/skills/upscale-background/)

Resolves one explicit static `#BACKGROUND`, assesses full-screen fit and quality, stages faithful 1920 x 1080 previews with explicit dimensions/aspect ratios, learns from fingerprint-bound outcomes, and proof-completes only an exact approved candidate.

## Components and dependencies

- `Get-ImagePresentation.ps1`: deterministic decoded dimensions, reduced and decimal aspect ratios, frame count, pixel format, actual pixel opacity, and format reporting for every Before/After.
- `Inspect-Background.ps1`: containment, explicit-reference, static-format, decode, frame, aspect-ratio, and empty-versus-active `BGCHANGES` checks.
- `Update-BackgroundQueue.ps1`: cross-process serialized discovery, fingerprinting, severity tiers, review-only legacy classification, atomic transitions, history, and round-robin selection.
- `Test-BackgroundQueue.ps1`: disposable fixtures for empty/active `BGCHANGES`, quality priority, review-only classification, inspector behavior, installed-preview history preservation, and exact UTF-8 round trips.
- `Test-BackgroundInstallWorkflow.ps1`: disposable presentation, expected-hash refusal, PNG fast-path, JPG normalization/proof-rebinding, rollback, mutex, and terminal queue tests.
- `Record-BackgroundLearning.ps1`: mandatory end-of-interaction retrospective ledger with enforced evidence for reusable skill changes.
- `Install-ApprovedBackground.ps1`: expected-hash and closed-game guarded replacement, byte-exact fast path, format-correct normalization, verified sibling rollback, and structured proof.
- `Complete-ApprovedBackgroundInstall.ps1`: one-command exact queue binding, guarded install, installed-proof transition, fingerprint refresh, and terminal validation after backup verification.
- `references/background-conventions.md`, image editing capability, `thraxos`, and `memory/background-upscale-queue.json`.

Inputs are an approved pack/folder and a song simfile. Outputs are labeled Before/After previews and ledger transitions. Host defaults are the `Misc. Collected` pack and owner-confirmed windowed 1920 x 1080 16:9 display.

## Safety and behavior

Scheduled runs are preview-only and produce at most one new candidate. Every `.sm`/`.ssc` must contain the same nonblank explicit `#BACKGROUND`; a missing or blank companion reference prevents automatic selection. Empty `#BGCHANGES:;` metadata is accepted; populated or malformed changes, video/animation, GIF, conflicts, traversal, and undecodable images remain excluded. Plausible implicit `.dwi` art and missing-reference fallbacks enter a non-selectable `review-only` lane until the owner confirms a source through a later resolution workflow. Eligible explicit static art is prioritized as broken/tiny, aspect-mismatched, SD-or-smaller, sub-HD, then soft-review, with round-robin rotation within a tier. Only clean near-16:9 soft-review art at 1280 x 720 or better may be skipped for adequate runtime quality. Pending work does not block later candidates. When two genuine AI attempts are exhausted and fallback needs owner approval, `-AwaitOwnerInput` leaves the exact fingerprint pending with `pendingAction=awaiting-fallback-approval`; it must not return to eligible and repeatedly starve lower tiers. Ordinary denials and recoverable failures rotate; explicit good-as-is feedback becomes fingerprint-scoped `skipped`, while only explicit never-again feedback becomes `denied`. Assessment-rule fingerprint migrations preserve status and history when the explicit reference, source hash, and simfile hashes are unchanged. Genuinely changed content receives a fresh assessment, while a source whose hash exactly equals its approved installed preview retains installed decision/history. Installation requires ITGMania closed, exact preview/hash approval, backup evidence plus a sibling rollback copy, and leaves the game closed.

Approval and owner-decision messages lead with canonical simfile `ARTIST — TITLE` and append a nonblank subtitle. They also identify the pack and song folder, source quality tier, every Before/After's decoded dimensions and reduced-plus-decimal aspect ratio, candidate label, and any useful nonblank transliteration, genre, or credit metadata. A display copy is labeled separately from the exact candidate. Missing metadata is not inferred from filenames or artwork. Artist and title also appear in the inbox item so queued work is recognizable without opening the task.

When exactly one installable candidate is displayed and hash-bound, the prompt asks for `Install`; either bare `install` or its explicit label such as `Install A` resolves to that sole task-local candidate. When several candidates are displayed, the prompt enumerates and requires `Install A`, `Install B`, and so on; bare `install` remains ambiguous. A later explicit label may supersede a prior rejection only after that exact staged candidate is rebound and all source, simfile, preview, backup, and closed-game checks pass again.

Every completed interaction must call `Record-BackgroundLearning.ps1` with `none`, `fingerprint`, or `reusable`. Reusable entries require named changed files and successful skill validation; scheduled-behavior changes also update the live automation prompt. This makes self-improvement auditable while allowing an honest no-change result.

The queue and learning helpers read and write `background-upscale-queue.json` explicitly as UTF-8 without a BOM. Queue operations also use a per-queue cross-process mutex so scheduled refreshes and interactive installs cannot overwrite one another. This avoids legacy decoding corruption and lost concurrent transitions.

After exact owner approval and a current backup check, `Complete-ApprovedBackgroundInstall.ps1` is the preferred interactive path. It validates the task-local pending binding and every queued simfile hash while holding the mutex, calls the lower-level installer with expected hashes, records a byte-exact installed proof (including a staged proof copy when target encoding differs), refreshes the content fingerprint, and returns compact evidence. The lower-level installer checks ITGMania twice, verifies rollback bytes, returns all material hashes, and directly copies a matching opaque 1920 x 1080 same-format preview instead of decoding and re-encoding it.

## Reproduce and verify

1. Copy the complete skill and adapt approved paths/display convention.
2. Run `Test-BackgroundQueue.ps1` and `Test-BackgroundInstallWorkflow.ps1`, then validate the skill. Confirm the suites accept empty `BGCHANGES`, reject active changes and blank companion `#BACKGROUND` tags, order quality tiers, report `4:3` and `16:9` presentation correctly, recognize fully opaque RGBA pixels, reject stale hashes, exercise byte-exact and normalized install paths, serialize queue access, preserve installed proof, and round-trip non-ASCII history exactly.
3. Run the inspector against additional static, missing, animated/changing, and traversal fixtures. Refresh a temporary queue and confirm fingerprints, new-song discovery, one-at-a-time tiered round robin, pending nonblocking behavior, return history, fingerprint-scoped `skipped`, and terminal decisions.
4. Test installation only on a disposable fixture. Confirm single-candidate `install` and `Install A` both resolve only to the sole task-local hash binding, while multiple candidates require `Install A`, `Install B`, and so on. Also confirm `-BackupVerified`, expected hashes, closed-game checks, 1920 x 1080 at `16:9`, one frame, encoding matching the referenced extension, unchanged simfiles/reference, verified rollback, refreshed terminal fingerprint, and exact live/proof hash agreement.
5. Recreate the optional automation from its scheduled-task guide.
6. Test all three learning scopes and confirm `reusable` is rejected without changed files and successful validation evidence.
