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

## Generate a preview only

1. Work in task-specific staging outside the live song folder. Never modify the live banner during preview generation.
2. Simply Love is currently used at 1280x720. The established strong banner reference and approved installed result are 836x328; use 836x328 as final target unless current theme evidence establishes another convention.
3. Check text, crops, color, transparency, and similarity. Decode both source and result and report their dimensions.
4. Present both images inline in the same response, clearly labeled `Before` for the current source banner and `After` for the generated candidate. Show the full images without replacing the before image with a textual description. Use a compact side-by-side presentation when the client supports it; otherwise place `Before` immediately above `After`.
5. Explicitly ask: "Do you want me to install this exact After preview as the live banner?" Stop before a live change without approval of that exact preview.

## Use the durable candidate queue

- `memory/banner-upscale-queue.json` is the checked-in queue for `Misc. Collected`. Its terminal decisions are scoped to the recorded fingerprint, so a changed simfile or source banner is assessed as new content.
- Refresh live state and select deterministically with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/upscale-banner/scripts/Update-BannerQueue.ps1 -Refresh -SelectNext`. Use round-robin ordering: never-attempted eligible fingerprints first by oldest `observedAt` and then `songPath`, followed by returned fingerprints by oldest `lastAttemptedAt`, `observedAt`, and `songPath`.
- Before generating, atomically reserve the exact result with `-SetStatus pending -SongPath <relative-path> -Fingerprint <sha256>`. After staging the preview, repeat that transition with `-PreviewPath <path>` to bind its SHA-256 and set `pendingAction` to `awaiting-install-decision`.
- A pending item does not block later runs. Each automation run may generate at most one new preview, must never duplicate a pending or terminal fingerprint, and should report `no-candidates` then exit when selection is empty.
- If generation fails, a prompt misidentifies source content, or the owner rejects the attempted interpretation before an acceptable preview exists, return the exact pending fingerprint to `eligible` with `-ReturnToQueue -AttemptOutcome <outcome> -AttemptNote <note>`. The helper appends immutable timestamped attempt context, clears active preview and processing fields, and restores `processedAt` to null. Record corrections such as exact visible text verbatim so the next attempt does not repeat the mistake.
- Treat a returned item as unprocessed, but retain `lastAttemptedAt` so it moves behind every never-attempted candidate and previously returned candidates attempted less recently. Read and honor its `attemptHistory` before prompting. Its history does not count as a new run's two permitted generative attempts.
- Treat an ordinary preview decline or correction as `-ReturnToQueue -AttemptOutcome preview-rejected` or `prompt-error`, not terminal `denied`, unless the owner explicitly says never to process that exact fingerprint again. This prevents repeated immediate retries while preserving a permanent opt-out.
- Preview generation remains staging-only. Installation is always an interactive follow-up after explicit approval of the exact recorded preview; mark that fingerprint `installed` or `denied` only from the approving or denying interaction.

## Install only after explicit approval

1. Re-resolve the current simfile and `#BANNER` immediately before writing. Refuse traversal, ambiguity, missing references, or targets outside the song directory.
2. Inspect backup health using the ThraxOS read-only helper. Preserve a recoverable local original regardless.
3. Run `scripts/Install-ApprovedBanner.ps1 -Simfile <path> -Preview <path> -Approved`. It resizes a copy to 836x328, makes a timestamped sibling backup, replaces the target, and validates PNG decode, dimensions, and the unchanged reference.
4. Do not restart or terminate ITGMania. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility data.
5. Report validation and update checked-in memory.

Read `references/banner-conventions.md` when selecting a processing path or diagnosing a nonstandard banner.
