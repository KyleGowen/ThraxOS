---
name: upscale-banner
description: Resolve an ITGMania song banner from a song folder or simfile, faithfully regenerate or upscale it, show labeled before-and-after images, and safely install the owner-approved image. Use when a user asks to sharpen, restore, regenerate, enlarge, upscale, replace, or repair an ITGMania or StepMania song banner.
---

# Upscale an ITGMania banner

Follow the ThraxOS operating contract and load the `thraxos` skill before inspecting the host. Treat generation and live installation as separate phases.

## Inspect and resolve

1. Read the required memory files and relevant banner history in `memory/OPERATIONS_LOG.md`.
2. Inspect live state and record the date. Do not assume a checked-in path or snapshot is current.
3. Resolve the song directory from the supplied song name, folder, or `.sm`/`.ssc` file. Search only approved song roots.
4. Run `scripts/Inspect-Banner.ps1 -Simfile <path>` to parse `#BANNER`, contain the path within the song directory, and report decode/dimensions. Every simfile must contain exactly one identical, nonblank `#BANNER`; if any simfile is missing it, leaves it blank, or disagrees, stop.
5. Inspect the source image visually before editing. Use it as the content source; do not substitute unrelated artwork.

## Choose the processing path

- Prefer built-in image generation/editing using GPT Image 2 high-fidelity editing when low-resolution damage needs semantic restoration. Preserve the same composition, subjects, typography, colors, logos, and content; repair only lost detail and artifacts.
- Use deterministic super-resolution or high-quality resampling when exact pixel content must not change. State that it cannot invent genuinely missing detail.
- Ask which fidelity constraint matters if ambiguity would materially affect the result.
- When the preferred high-fidelity generation attempt fails, retry it exactly once with a narrower restoration-only prompt. Do not switch processing paths after only one failure.
- Only after two failed high-fidelity attempts may deterministic super-resolution or high-quality resampling be offered as a fallback. Disclose both failures and ask before changing approach unless the user has already explicitly approved that deterministic fallback.
- Do not make a third generative attempt, silently use a legacy image model, downgrade path, or unrelated reconstruction.
- Distinguish model failure from result-handling failure. For the built-in image tool, forward the returned generation result with the tool runtime's generated-image result handler (for example, `generatedImage(result)`); do not assume it uses generic `content` image blocks. Recover or re-emit an existing result before making another model call.
- Do not consume one of the two generative attempts when generation returned a result but rendering, copying, staging, or response forwarding failed. Count only distinct model calls that actually fail to produce a recoverable image result.
- If the inline result and a later saved-file view appear inconsistent, stop before another model call or queue transition. Hash the saved output, decode it with an independent standard decoder, and run `scripts/Normalize-GeneratedBannerPreview.ps1` to preserve the original while writing a plain staged PNG. Inspect the normalized copy. A successfully decoded result is not missing merely because one visual pass describes it differently.
- When the generated result, saved file, or normalized copy have matching bytes or decoded pixels, treat the disagreement as visual-ingestion uncertainty. Stage and show the verified result for owner review instead of retrying or recording `output-handling-error`. Use that outcome only when the file cannot be recovered or standard-decoded, or when verified pixels actually differ from the generated result.
- Treat a broken inline image with a working full-resolution link as response-rendering failure, not image-generation failure. Revalidate the exact file and hash, regenerate its response block with `scripts/Format-BannerPreviewMarkdown.ps1`, and re-emit it without another model call or queue transition.

## Generate a preview only

1. Work in task-specific staging outside the live song folder. Never modify the live banner during preview generation.
2. Simply Love is currently used at 1280x720. The established strong banner reference and approved installed result are 836x328; use 836x328 as final target unless current theme evidence establishes another convention.
3. Preserve the raw generated file. Normalize the candidate into task staging with `scripts/Normalize-GeneratedBannerPreview.ps1`; pass `-Opaque` when the generated design is intended to be fully opaque so resampling cannot introduce transparent edge pixels. Then check text, crops, color, transparency, similarity, decoded dimensions, and SHA-256 on the normalized copy.
4. Always present the exact full-resolution source file inline under the exact label `Before`, including failure reports and responses that offer no `After`. Generate the response block with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/upscale-banner/scripts/Format-BannerPreviewMarkdown.ps1 -Label Before -Path <exact-source>` and use its `Markdown` value verbatim. The formatter independently decodes the file and emits a renderer-safe Windows image destination with forward slashes and percent-encoded path segments plus a direct full-resolution link. Never hand-write an inline tag as `![Before](<C:\...>)`: angle-wrapped backslash paths can remain clickable while showing a broken inline-image placeholder. Never substitute a thumbnail, screenshot, crop, generated proxy, path-only response, or textual description.
5. Present every viable exact staged file inline in the same response. Label one result `After`; label multiple results `After A`, `After B`, and so on. Generate each block through the same `powershell.exe -NoProfile -ExecutionPolicy Bypass -File` invocation and use its returned `Markdown` verbatim so the inline image and native-file link point to the same exact bytes. Put `Before` immediately before the After option(s), or use a compact comparison layout when supported. Never ask for approval or selection without rendering and linking every referenced full-resolution option. If the client still shows a placeholder, revalidate the file/hash and re-emit the formatter output; do not generate again or rotate the queue.
6. With one result, explicitly ask: "Do you want me to install this exact After preview as the live banner?" With multiple results, ask the owner to select an exact labeled After; bind `previewPath` and SHA-256 only to the selected option before asking to install it. Stop before a live change without approval of the exact selected preview.
7. Interpret bare `install` only as approval of the most recently displayed, explicitly labeled, queue-bound After in the same task. Never substitute the newest pending queue item, an After from another task, or an unlabeled artifact. If the task-local target is not exact, display and bind it before asking again.

## Use the durable candidate queue

- `memory/banner-upscale-queue.json` is the checked-in queue for `Misc. Collected`. Its terminal decisions are scoped to the recorded fingerprint, so a changed simfile or source banner is assessed as new content.
- `Update-BannerQueue.ps1` serializes every read/modify/write cycle with a per-queue cross-process mutex. A lock timeout is a concurrency stop: retry the helper later and never edit or rewrite the JSON directly.
- Refresh live state and select deterministically with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/upscale-banner/scripts/Update-BannerQueue.ps1 -Refresh -SelectNext`. Use round-robin ordering: never-attempted eligible fingerprints first by oldest `observedAt` and then `songPath`, followed by returned fingerprints by oldest `lastAttemptedAt`, `observedAt`, and `songPath`.
- Before generating, atomically reserve the exact result with `-SetStatus pending -SongPath <relative-path> -Fingerprint <sha256>`. After staging the preview, repeat that transition with `-PreviewPath <path>` to bind its SHA-256 and set `pendingAction` to `awaiting-install-decision`.
- A pending item does not block later runs. Each automation run may generate at most one new preview, must never duplicate a pending or terminal fingerprint, and should report `no-candidates` then exit when selection is empty.
- If generation genuinely fails, a prompt misidentifies source content, result handling fails without a recoverable output, or the owner rejects the attempted interpretation before an acceptable preview exists, return the exact pending fingerprint to `eligible` with `-ReturnToQueue -AttemptOutcome <outcome> -AttemptNote <note>`. The helper appends immutable timestamped attempt context, clears active preview and processing fields, and restores `processedAt` to null. Record corrections such as exact visible text verbatim so the next attempt does not repeat the mistake.
- Treat a returned item as unprocessed, but retain `lastAttemptedAt` so it moves behind every never-attempted candidate and previously returned candidates attempted less recently. Read and honor its `attemptHistory` before prompting. Its history does not count as a new run's two permitted generative attempts.
- Treat an ordinary preview decline or correction as `-ReturnToQueue -AttemptOutcome preview-rejected` or `prompt-error`, not terminal `denied`, unless the owner explicitly says never to process that exact fingerprint again. This prevents repeated immediate retries while preserving a permanent opt-out.
- Record explicit owner feedback that the current banner is good as-is with `-SetStatus skipped` and a factual `-DecisionNote`. `skipped` is terminal only for that exact fingerprint, needs no preview binding, and changed source or simfile content receives a fresh assessment. Reserve `denied` for an explicit never-again instruction.
- Preview generation remains staging-only. Installation is always an interactive follow-up after explicit approval of the exact recorded preview. Supply a nonblank `-DecisionNote` that accurately summarizes the owner's decision and any reasoning; state when no reason was provided instead of inventing one.

## Install only after explicit approval

1. Resolve task-local approval first. Re-read the exact pending queue record and require its fingerprint, `previewPath`, and `previewSha256` to match the labeled After approved in this task; do not choose by global pending order.
2. Re-resolve the current simfile and `#BANNER` immediately before writing. Refuse traversal, ambiguity, missing references, targets outside the song directory, or any source/simfile hash drift from the pending record.
3. Inspect backup health using the ThraxOS read-only helper. Preserve a recoverable local original regardless. A task result of `0x41301` means the backup task is currently running, not that its last completed run failed. Proceed in that one degraded state only when a same-day successful log is present, Songs are excluded, and the guarded sibling rollback will be created; otherwise stop without changing the task or live banner.
4. Run `scripts/Install-ApprovedBanner.ps1 -Simfile <path> -Preview <path> -Approved -ExpectedPreviewSha256 <queue-preview-sha256> -ExpectedSourceSha256 <queue-source-sha256> -ExpectedSimfileSha256 <queue-simfile-sha256>`. If the referenced target is missing and the queue resolved a fallback, also pass `-FallbackOriginal <path>`. The installer refuses while ITGMania is open, rechecks the game and all three hashes immediately before writing, resizes a copy to 836x328 while preserving an opaque preview as opaque output, makes and verifies a unique timestamped sibling backup, writes only the referenced target, and returns preview/original/backup/installed/simfile hashes plus output-opacity evidence for direct validation.
5. Do not restart or terminate ITGMania. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility data.
6. After installation, mark the pending fingerprint `installed`. The queue helper independently renders the recorded preview with the installer's exact encoder path, refuses the transition unless its SHA-256 equals the live source, stores that installed-source hash, and preserves terminal history when refresh moves the record to its installed-content fingerprint. When installation creates a previously missing referenced target from a contained fallback, proof must follow that expected fallback-to-target transition and hash the new referenced target, not the unchanged fallback. If an interrupted or legacy flow refreshed first, use `-SetStatus installed -RecordInstalledContent -PreviewPath <exact-preview> -DecisionNote <note>` on the current ineligible fingerprint; the same proof is mandatory. The same command may idempotently re-prove an already-installed record whose installed-source hash is missing; it must preserve `processedAt` and must not duplicate decision history.
7. Refresh and re-read the exact song record. Require one current installed-content fingerprint with terminal `installed`, matching `installedSourceSha256`, exact preview hash, and one decision. Global counts may legitimately change. If a concurrent legacy writer leaves the proofed pre-install fingerprint in place, refresh exactly once more; if exact-item invariants still fail, stop and diagnose without recording another decision.
8. Report the installer-returned hashes, terminal fingerprint, rollback path, closed-game state, and unchanged simfile. Update checked-in memory.

## Learn after every run and decision

1. At the end of every preview attempt, failure, return, installation, or denial interaction, review the current conversation and artifacts for evidence that would improve future runs. Include successful techniques, failed prompts or tooling, source-content corrections, owner selection, and the owner's stated reasoning.
2. Preserve exact-fingerprint evidence in `attemptHistory` or `decisionHistory`. Quote or closely paraphrase concrete corrections and rejection reasons; never invent an explanation the owner did not give.
3. Classify reusable learning before changing durable guidance:
   - Keep banner-specific text, composition, and failure details in the queue.
   - Put stable owner-wide aesthetic or workflow preferences in `memory/PREFERENCES.md` only when owner-confirmed or supported by repeated outcomes.
   - Put reusable processing, prompting, validation, result-handling, or safety improvements in this skill and its matching `docs/skills/` and `docs/scheduled-tasks/` guides.
   - Put significant actions and retrospective conclusions in `memory/OPERATIONS_LOG.md`; use `FACTS.md` or `DECISIONS.md` only for their established scopes.
4. Promote a lesson into the skill only when it is evidence-backed, generalizable beyond one banner, actionable, non-duplicative, and compatible with all safety and approval boundaries. Treat a single aesthetic denial as candidate preference evidence, not a universal rule, unless the owner explicitly generalizes it.
5. When changing the skill, make the smallest useful edit, update its discoverability/migration documentation in the same change, run the skill validator, and report what was learned. Never let self-improvement alter live songs, weaken exact-preview approval, increase model attempts silently, or bypass queue ordering.
6. If the retrospective finds no reusable improvement, say so and retain only the outcome-specific queue or operations note. Do not manufacture a skill change after every run.

Read `references/banner-conventions.md` when selecting a processing path or diagnosing a nonstandard banner.
