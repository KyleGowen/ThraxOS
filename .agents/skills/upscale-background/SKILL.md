---
name: upscale-background
description: Resolve, assess, faithfully restore, upscale, outpaint, preview, and safely install a static ITGMania or StepMania song background in an explicitly specified folder. Use when asked to repair, regenerate, enlarge, replace, or improve a song background, or when the Misc. Collected queue selects one. Exclude missing backgrounds, video, animation, BGCHANGES, conflicting references, and implicit legacy artwork.
---

# Restore a static song background

Load `thraxos` and follow its operating contract. Keep preview and installation separate.

## Resolve and assess

1. Read required memory, inspect live state, and operate only in the explicitly supplied folder. Scheduled scope is initially `C:\Games\ITGmania\Songs\Misc. Collected`.
2. Run `scripts/Inspect-Background.ps1 -Simfile <path>`. Across all `.sm`/`.ssc` files, require one consistent, explicit, contained `#BACKGROUND` static image.
3. Exclude missing backgrounds, `BGCHANGES`, disagreement, implicit `.dwi` art, video/unsupported extensions, undecodable content, and animation.
4. Visually inspect the source. Process when below 1920 x 1080, poorly fitting 16:9, or visibly compressed/damaged. Leave a clean lower-resolution image alone if it already looks good at runtime.

## Generate previews

1. Stage outside the live song folder. Target opaque, static 1920 x 1080 output for the owner-confirmed windowed 16:9 setup.
2. Default to faithful restoration: preserve subjects, characters, logos, text, composition, palette, and style. Prefer outpainting over stretching for aspect-ratio repair. Prefer deterministic scaling for sound 16:9 art that only lacks resolution.
3. Make at most two faithful AI restoration attempts. After two genuine model failures, offer deterministic fallback only with approval. Recoverable forwarding/staging errors do not consume an attempt.
4. Always render `Before`, including failures, and every viable `After` (`After A`, `After B`, etc.). Bare `install` selects the latest displayed After; an unambiguous pasted or named candidate overrides it. Bind the exact selected file and SHA-256.
5. New owner-supplied source material after a denial authorizes another attempt and may support a from-scratch composition, while preserving recognizable song identity and exact-preview approval.

## Use the durable queue

- Maintain `memory/background-upscale-queue.json` with `scripts/Update-BackgroundQueue.ps1`.
- Refresh/select with `-Refresh -SelectNext`. Never-attempted candidates precede returned items; returned items sort least-recent attempt first. Stage at most one candidate per scheduled run. Pending records do not block other songs.
- Reserve with `-SetStatus pending -SongPath <path> -Fingerprint <hash>`, then bind `-PreviewPath`.
- Return ordinary denials, corrections, generation failures, and output errors with `-ReturnToQueue`, `-AttemptOutcome`, and a factual note. Record explicit good-as-is feedback with `-SetStatus skipped` and a `-DecisionNote`; it is terminal only for that fingerprint and needs no preview. Terminal `denied` means only an explicit never-again instruction for that fingerprint. `installed`, `denied`, and `skipped` require `-DecisionNote`.

## Install after approval

1. Re-resolve and verify the fingerprint and selected preview hash. Require ITGMania closed. Check recent backup evidence and preserve a timestamped sibling rollback copy.
2. Run `scripts/Install-ApprovedBackground.ps1 -Simfile <path> -Preview <path> -Approved`. It changes only the referenced image, preserves extension/encoding, targets 1920 x 1080, and validates static decode, dimensions, and unchanged reference.
3. Leave ITGMania closed. Never edit simfiles, BGCHANGES, audio, charts, scores, profiles, timestamps, signatures, or GrooveStats data.

## Learn carefully

1. End every preview, failure, skip, denial, and installation interaction with a retrospective over the prompt, artifacts, validation, queue transition, and owner feedback actually received.
2. Retain fingerprint-specific prompts, corrections, hashes, decisions, outcomes, and supplied reasoning in that song's queue history. Promote durable guidance only from explicit owner generalization or repeated evidence.
3. Run `scripts/Record-BackgroundLearning.ps1` exactly once per completed interaction. Record `none` when no lesson exists, `fingerprint` when evidence belongs only to one source, or `reusable` when a general workflow improvement was implemented.
4. For `reusable`, make the smallest justified edit to this skill and its matching `docs/skills/` and `docs/scheduled-tasks/` guides; update the live automation prompt when scheduled behavior changes. Validate the skill, then supply every changed file and the successful validation result to the learning helper. The helper rejects a reusable entry without both.
5. Never invent feedback, generalize one denial, weaken static-only rules, bypass approval, or change the skill merely to claim self-improvement. A `none` retrospective is a valid outcome.

Read `references/background-conventions.md` before choosing crop, outpaint, format, or quality thresholds.
