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
4. Run `scripts/Inspect-Banner.ps1 -Simfile <path>` to parse `#BANNER`, contain the path within the song directory, and report decode/dimensions. If multiple simfiles disagree, stop.
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

## Generate a preview only

1. Work in task-specific staging outside the live song folder. Never modify the live banner during preview generation.
2. Simply Love is currently used at 1280x720. The established strong banner reference and approved installed result are 836x328; use 836x328 as final target unless current theme evidence establishes another convention.
3. Check text, crops, color, transparency, and similarity. Decode both source and result and report their dimensions.
4. Always present the full source image inline under the exact label `Before`, including failure reports and responses that offer no `After`. Never replace it with only a path or textual description.
5. Present every viable staged result inline in the same response. Label one result `After`; label multiple results `After A`, `After B`, and so on. Put `Before` immediately before the After option(s), or use a compact comparison layout when supported. Never ask for approval or selection without rendering all referenced options.
6. With one result, explicitly ask: "Do you want me to install this exact After preview as the live banner?" With multiple results, ask the owner to select an exact labeled After; bind `previewPath` and SHA-256 only to the selected option before asking to install it. Stop before a live change without approval of the exact selected preview.

## Use the durable candidate queue

- `memory/banner-upscale-queue.json` is the checked-in queue for `Misc. Collected`. Its terminal decisions are scoped to the recorded fingerprint, so a changed simfile or source banner is assessed as new content.
- Refresh live state and select deterministically with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/upscale-banner/scripts/Update-BannerQueue.ps1 -Refresh -SelectNext`. Use round-robin ordering: never-attempted eligible fingerprints first by oldest `observedAt` and then `songPath`, followed by returned fingerprints by oldest `lastAttemptedAt`, `observedAt`, and `songPath`.
- Before generating, atomically reserve the exact result with `-SetStatus pending -SongPath <relative-path> -Fingerprint <sha256>`. After staging the preview, repeat that transition with `-PreviewPath <path>` to bind its SHA-256 and set `pendingAction` to `awaiting-install-decision`.
- A pending item does not block later runs. Each automation run may generate at most one new preview, must never duplicate a pending or terminal fingerprint, and should report `no-candidates` then exit when selection is empty.
- If generation genuinely fails, a prompt misidentifies source content, result handling fails without a recoverable output, or the owner rejects the attempted interpretation before an acceptable preview exists, return the exact pending fingerprint to `eligible` with `-ReturnToQueue -AttemptOutcome <outcome> -AttemptNote <note>`. The helper appends immutable timestamped attempt context, clears active preview and processing fields, and restores `processedAt` to null. Record corrections such as exact visible text verbatim so the next attempt does not repeat the mistake.
- Treat a returned item as unprocessed, but retain `lastAttemptedAt` so it moves behind every never-attempted candidate and previously returned candidates attempted less recently. Read and honor its `attemptHistory` before prompting. Its history does not count as a new run's two permitted generative attempts.
- Treat an ordinary preview decline or correction as `-ReturnToQueue -AttemptOutcome preview-rejected` or `prompt-error`, not terminal `denied`, unless the owner explicitly says never to process that exact fingerprint again. This prevents repeated immediate retries while preserving a permanent opt-out.
- Preview generation remains staging-only. Installation is always an interactive follow-up after explicit approval of the exact recorded preview; mark that fingerprint `installed` or `denied` only from the approving or denying interaction. Supply a nonblank `-DecisionNote` that accurately summarizes the owner's decision and any reasoning; state when no reason was provided instead of inventing one.

## Install only after explicit approval

1. Re-resolve the current simfile and `#BANNER` immediately before writing. Refuse traversal, ambiguity, missing references, or targets outside the song directory.
2. Inspect backup health using the ThraxOS read-only helper. Preserve a recoverable local original regardless.
3. Run `scripts/Install-ApprovedBanner.ps1 -Simfile <path> -Preview <path> -Approved`. If the referenced target is missing and the queue resolved a fallback, also pass `-FallbackOriginal <path>`. It resizes a copy to 836x328, makes a timestamped sibling backup from the target or explicit fallback, writes only the referenced target, and validates PNG decode, dimensions, and the unchanged reference.
4. Do not restart or terminate ITGMania. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility data.
5. Report validation and update checked-in memory.

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
