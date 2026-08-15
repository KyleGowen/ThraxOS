---
name: generate-background
description: Research authentic album or single artwork and create a brand-new opaque 1920 x 1080 ITGMania or StepMania song-background preview from scratch. Use when the owner requests a new background, redesign, release-inspired or cover-inspired art, or a display-maximized replacement rather than a faithful upscale.
---

# Generate a song background

Load `thraxos`, `upscale-background`, and the built-in `imagegen` skill. Follow their operating, queue, presentation, approval, installation, and learning contracts. This skill changes the creative method; it does not weaken any live-library safety boundary.

## Boundary and target

- Work on one explicitly identified song folder and exact simfile/fingerprint.
- Create an original, opaque, single-frame PNG at exactly 1920 x 1080 (16:9) for the host display.
- Use verified release art only as inspiration. Do not reproduce a sleeve, logo, label mark, catalog number, watermark, identifiable person, or copyrighted layout.
- Preserve the song's identity, era, palette, energy, and useful visual motifs. Keep gameplay readability in mind: avoid noisy high-contrast detail where receptors and arrows need separation.
- Keep every source, reference, raw output, normalized candidate, and display copy outside the live Songs tree.
- Generation is preview-only. Never install, restart or terminate ITGMania, or alter charts, scores, profiles, or configuration during this phase.

## Resolve exact identity and live state

1. Follow the `thraxos` start-of-task checks. Read the exact simfile and inspect current live state rather than relying on folder names or old queue data.
2. Use the `upscale-background` resolver and `.agents/skills/upscale-background/scripts/Update-BackgroundQueue.ps1` for all background-ledger reads and transitions. Never edit `memory/background-upscale-queue.json` directly.
3. Require one unambiguous contained static `#BACKGROUND` reference. Treat whitespace-only `#BGCHANGES:;` as empty. Stop on populated or malformed BGCHANGES, traversal, conflicting references, video, GIF/animation, undecodable content, or an unconfirmed implicit/fallback image.
4. Read canonical nonblank `#ARTIST`, `#TITLE`, optional `#SUBTITLE`, transliterations, genre, and credit from the exact simfile. Do not infer missing metadata from artwork or directory names.
5. Inspect the existing background visually and record its decoded dimensions, reduced aspect ratio, decimal ratio, SHA-256, and the exact simfile hashes before generating.

## Reopen only with owner direction

An explicit request for a new from-scratch background authorizes creative replacement for that exact song and fingerprint, including a fingerprint previously marked good-enough `skipped`.

- Preserve all prior attempt and decision history. Record the owner's new direction factually in attempt history through the `upscale-background` queue helper.
- Re-read the record after every transition and reserve the exact fingerprint `pending` before image generation.
- Never reopen a different fingerprint. Never reopen `denied` unless the owner explicitly revokes the never-again instruction. Never replace an `installed` fingerprint unless the owner explicitly asks to replace that installed art.
- If another task owns a pending candidate, do not steal or silently overwrite its binding. Reconcile it through the helper with a factual outcome first.

## Research authentic release art

Read [release-art-research.md](references/release-art-research.md) before searching.

1. Make one focused image-search query containing the canonical artist, title, and relevant version/subtitle plus `single cover` or `album cover`.
2. Treat thumbnails and image-search labels only as discovery leads. Verify the chosen release identity on an official artist/label page or an established catalog such as Bandcamp, Discogs, Apple Music, Spotify, MusicBrainz, or Cover Art Archive.
3. Reject same-name releases, fan art, remixes with the wrong qualifier, compilations presented as the original release, watermarked images, and unverifiable uploads.
4. Save at most two useful references in task-owned staging. Record source URL, claimed identity, decoded dimensions, and SHA-256. Keep them out of the live song folder.
5. Extract only high-level design evidence: palette, era, typography category, materials, texture, motifs, lighting, and compositional rhythm.

## Generate an original 16:9 candidate

1. Visually inspect the Before and references before writing the prompt.
2. Ask for an original full-bleed 16:9 composition with no border, mockup, frame, transparency, or letterboxing. State 1920 x 1080 as the delivery target and preserve room for rhythm-game readability.
3. Describe the verified high-level visual evidence, not a request to copy the reference. Do not name or request an identifiable person's likeness.
4. If text is wanted, use only exact canonical simfile copy, once each, with ordinary punctuation. Do not invent release labels, album names, credits, or decorative pseudo-text. Backgrounds do not require text unless the owner or design direction calls for it.
5. Make at most two genuine image-generation calls. Visually compare each output with the prompt and canonical metadata. A local decode, forwarding, staging, display, or normalization error does not consume a model attempt.
6. If attaching an authentic reference is itself blocked by input moderation, record the failure. One targeted retry may omit the image and use only already-verified, non-sensitive palette/era/material facts. Do not disguise prohibited content, evade safeguards, or make a third call.
7. Preserve each raw output and hash. Do not overwrite a prior attempt.

## Normalize and validate

Use `scripts/Normalize-GeneratedBackgroundPreview.ps1` to create the install candidate. It preserves the raw image, rejects live-Songs destinations and materially non-16:9 inputs, uses an explicit integer destination rectangle to avoid ambiguous `System.Drawing` overload selection, and validates an opaque one-frame 1920 x 1080 PNG.

```powershell
& .\.agents\skills\generate-background\scripts\Normalize-GeneratedBackgroundPreview.ps1 `
  -InputPath <raw-output> `
  -OutputPath <staged-preview>
```

- If a raw generation is materially off 16:9, do not stretch it. Use the remaining model attempt to regenerate or outpaint it as 16:9.
- Treat a correctable normalization bug as `output-handling-error`; fix or rerun deterministic handling without spending another model attempt.
- Run the `upscale-background` image inspector on the normalized file and require 1920 x 1080, reduced `16:9`, decimal `1.7778:1`, one frame, full opacity, and successful decode.

## Bind and present exact approval

1. Bind the exact normalized preview path and SHA-256 to the reserved fingerprint with `.agents/skills/upscale-background/scripts/Update-BackgroundQueue.ps1`; then re-read the record and verify the binding.
2. Always render `Before` and every viable labeled `After`. For each file, run `.agents/skills/upscale-background/scripts/Get-ImagePresentation.ps1` and report decoded dimensions plus reduced and decimal aspect ratios.
3. Generate every inline image block with `.agents/skills/upscale-background/scripts/Format-BackgroundPreviewMarkdown.ps1` and use its `Markdown` value verbatim. Never hand-write an angle-wrapped Windows backslash image path.
4. If a native link works but the inline placeholder fails, revalidate the exact file/hash and make a byte-identical short-path display copy. Report the display copy separately and keep the original exact preview as the install binding.
5. Before asking for a decision, re-read canonical simfile metadata. Lead with full nonblank `ARTIST — TITLE`, append a nonblank subtitle, and include pack, song folder, quality tier or `owner-requested redesign`, Before presentation, every candidate label/presentation, and useful nonblank transliteration, genre, or credit fields.
6. With one installable candidate, ask for `Install`; accept bare `install` or its sole explicit label in this task. With multiple candidates, require `Install A`, `Install B`, and so on; bare `install` is ambiguous.

## Install only through the guarded workflow

After exact approval, follow `upscale-background` completely. Revalidate the task-local preview hash, fingerprint, live source and simfile hashes, current backup evidence, and closed-game state. Use `.agents/skills/upscale-background/scripts/Complete-ApprovedBackgroundInstall.ps1`; do not copy directly into the live folder.

## Failure and learning

- Return ordinary corrections, rejected outputs, moderation failures, and recoverable generation failures through the `upscale-background` queue helper's `-ReturnToQueue` action with a factual outcome/note so rotation continues.
- After two genuine AI attempts, if deterministic fallback needs approval, use `-AwaitOwnerInput` as specified by `upscale-background`; do not return the exhausted fingerprint to selection.
- Only an explicit never-again instruction becomes terminal `denied`.
- End every interaction with the `upscale-background` retrospective and invoke `.agents/skills/upscale-background/scripts/Record-BackgroundLearning.ps1` exactly once. Use `none` when no lesson exists, `fingerprint` for source-specific evidence, and `reusable` only after making and validating the smallest justified durable change.

## Verify this skill

Run both checks after changing this skill or its normalizer:

```powershell
& .\.agents\skills\generate-background\scripts\Test-NormalizeGeneratedBackgroundPreview.ps1
python <skill-creator>\scripts\quick_validate.py .\.agents\skills\generate-background
```
