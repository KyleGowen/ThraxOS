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
- Do not silently use a legacy image model, downgrade path, or unrelated reconstruction. Disclose an unavailable preferred path and ask before changing approach.

## Generate a preview only

1. Work in task-specific staging outside the live song folder. Never modify the live banner during preview generation.
2. Simply Love is currently used at 1280x720. The established strong banner reference and approved installed result are 836x328; use 836x328 as final target unless current theme evidence establishes another convention.
3. Check text, crops, color, transparency, and similarity. Decode both source and result and report their dimensions.
4. Present both images inline in the same response, clearly labeled `Before` for the current source banner and `After` for the generated candidate. Show the full images without replacing the before image with a textual description. Use a compact side-by-side presentation when the client supports it; otherwise place `Before` immediately above `After`.
5. Explicitly ask: "Do you want me to install this exact After preview as the live banner?" Stop before a live change without approval of that exact preview.

## Install only after explicit approval

1. Re-resolve the current simfile and `#BANNER` immediately before writing. Refuse traversal, ambiguity, missing references, or targets outside the song directory.
2. Inspect backup health using the ThraxOS read-only helper. Preserve a recoverable local original regardless.
3. Run `scripts/Install-ApprovedBanner.ps1 -Simfile <path> -Preview <path> -Approved`. It resizes a copy to 836x328, makes a timestamped sibling backup, replaces the target, and validates PNG decode, dimensions, and the unchanged reference.
4. Do not restart or terminate ITGMania. Never touch simfiles, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats eligibility data.
5. Report validation and update checked-in memory.

Read `references/banner-conventions.md` when selecting a processing path or diagnosing a nonstandard banner.
