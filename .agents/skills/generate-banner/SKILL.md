---
name: generate-banner
description: Research authentic album or single artwork and create a brand-new 836 x 328 ITGMania or StepMania song-banner preview from scratch. Use when the owner rejects an existing banner, requests a redesign or cover-inspired artwork, or when a consistent contained #BANNER target and every banner-shaped fallback are entirely missing.
---

# Generate a new ITGMania banner

Load the project-local `thraxos` and `upscale-banner` skills first. Use the built-in `imagegen` skill for raster generation and the `browser` skill when the owner requests Google Images or browser-visible research. Treat research, generation, approval, and installation as separate phases.

## Resolve and reserve the exact song

1. Read `AGENTS.md`, required machine memory, relevant banner history, and `references/release-art-research.md`.
2. Inspect current ITGMania, backup, live song, and queue state. Never rely on a prior snapshot.
3. Resolve the song only inside an approved root. Run the `upscale-banner` inspector with `-AllowMissing` on every `.sm` and `.ssc`; require one identical contained nonblank `#BANNER` reference. Accept an absent referenced file only when the exact queue record is eligible with `generationMode=generate-banner`, null source path/hash, and no decodable banner-shaped fallback. Blank, missing, conflicting, ambiguous, or escaping references remain ineligible.
4. Parse trimmed `#TITLE`, `#SUBTITLE`, and `#ARTIST` from every simfile. Require exact agreement, one nonblank title and artist, and preserve every featuring, remix, edit, mix, or version qualifier verbatim.
5. Re-read the exact queue record. Preserve all owner corrections and attempt history. If the owner is correcting an already-pending preview, return it with `-AttemptOutcome preview-rejected` or `prompt-error`; if the fingerprint is eligible and the correction is not yet recorded, reserve it, append the correction through `-ReturnToQueue -AttemptOutcome prompt-error`, and re-reserve it. This history entry records owner direction, not a model attempt. A newly selected source-less queue record needs no synthetic owner-direction entry; reserve it once and proceed.
6. Before research or generation, require the exact record to be pending for only that song path and fingerprint. Use `Update-BannerQueue.ps1`; never edit queue JSON directly.

## Research release artwork

1. Run one focused Google Images query using the canonical artist, title, and `single cover` or `album cover`. Verify the visible query and result labels before using any result.
2. Open a strong result on an established music source and verify that it belongs to the canonical artist and exact song, album, single, or relevant release. Prefer Discogs release/master pages, official artist or label pages, Bandcamp, Apple Music, Spotify, MusicBrainz/Cover Art Archive, or another established catalog listed in the reference.
3. Distinguish the original recording from remixes, tribute covers, unrelated songs, marketplace mockups, fan art, and search-result contamination. A remix release may inspire graphics only when its relationship is explicit; never copy its remix credit into canonical banner text.
4. Save only one or two useful reference images into task-specific staging outside the live song folder. Record each detail-page URL, release identity, reference role, decoded dimensions, and SHA-256.
5. Treat artwork as inspiration, not an installable source. Extract palette, typography category, recurring symbols, materials, era, and layout rhythm; create a new composition without duplicating the sleeve, logo, catalog marks, or identifiable people.
6. If no established detail page verifies an applicable release, stop before generation. Atomically return the pending fingerprint with `-AttemptOutcome prompt-error` and a precise note describing the query, rejected leads, and missing identity evidence. Do not leave it pending and do not invent a release association.

## Generate the design

1. Generate from scratch with GPT Image 2. Do not use the rejected live banner as an edit target unless the owner explicitly asks to retain part of it. For a source-less record, do not substitute jacket, background, or unrelated local art as an edit target; use only verified release art as inspiration.
2. Design a true-wide composition for the current host convention: opaque PNG, exactly 836 x 328 after normalization, aspect ratio 209:82 (approximately 2.5488:1). Generate at a compatible wide size, then normalize with the `upscale-banner` helper.
3. Put the complete canonical title, artist, and required subtitle or version text in the prompt verbatim. Make the title prominent and the complete artist/credit line readable at song-wheel size. Permit no unrelated or duplicated words.
4. Label every input image by role. State which files are inspiration references and which, if any, are edit targets. Require original composition rather than a direct replica.
5. Preserve the raw output. Normalize a separate staged copy with `Normalize-GeneratedBannerPreview.ps1 -Opaque`, then inspect the exact 836 x 328 file for spelling, duplicated or missing text, crop, readability, composition, opacity, dimensions, and unintended copied marks.
6. Reject a candidate when any required string is absent, altered, duplicated, cropped, or unreadable, or when unrelated text appears. Before the one targeted corrected retry, return the pending fingerprint with the first raw/normalized hashes and exact failure as `generation-failed`, then atomically re-reserve it. This preserves attempt one even if attempt two succeeds. Never make a third model call or silently switch to deterministic fallback.

## Bind or rotate the result

- For one viable candidate, bind its exact staged path through the queue helper so `previewSha256` is calculated and `pendingAction` becomes `awaiting-install-decision`.
- Render an existing exact full-resolution live source as `Before` and the bound candidate as `After` using `Format-BannerPreviewMarkdown.ps1`. For a source-less queue record, render a `Before` heading that names the missing contained `#BANNER` target and states that no banner-shaped fallback exists; do not fabricate a Before image. Render the exact After normally with decoded dimensions and a direct native link.
- Ask exactly: "Do you want me to install this exact After preview as the live banner?"
- Do not install, modify a live banner, edit simfiles, restart ITGMania, or change configuration, charts, scores, profiles, timestamps, signatures, or GrooveStats state during generation.
- If both attempts are unviable, atomically return the fingerprint with `generation-failed` and precise reference, prompt, raw/normalized hash, text, crop, and composition evidence. Clear no history manually and offer no deterministic replacement without separate approval.
- Route an explicitly approved install through the `upscale-banner` guarded installer and exact queue-proof workflow; `generate-banner` itself does not widen live-write authority. For a source-less record, pass `-SourceLessGeneration`; installation may create only the unchanged contained `#BANNER` target, records `RollbackAction=RemoveCreatedTarget`, and never edits a simfile.

## Learn and document

Keep release-specific findings and aesthetic corrections in queue attempt or decision history. Promote only owner-generalized preferences into `memory/PREFERENCES.md`. Record significant work in `memory/OPERATIONS_LOG.md`. If this skill changes, update `docs/skills/generate-banner.md`, both skill/task indexes, and the banner scheduled-task guide, then run the skill validator.
