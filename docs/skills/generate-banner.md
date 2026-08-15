# `generate-banner` skill

Source: [`.agents/skills/generate-banner/`](../../.agents/skills/generate-banner/)

Researches authentic album or single artwork, converts verified visual evidence into an original wide-banner direction, and stages a canonical-text-complete 836 x 328 preview without changing the live song.

## Triggers and ownership

Use this skill when the owner rejects an existing banner, requests a from-scratch redesign, asks for album/single-cover inspiration, or when the banner queue finds one consistent contained `#BANNER` target whose file and every banner-shaped fallback are absent.

The skill owns research routing, reference staging, scratch-generation prompting, candidate validation, queue binding or rotation, and approval presentation. It reuses queue, normalization, formatter, and installer safeguards from `upscale-banner`; it does not own live installation or widen write authority.

## Dependencies and files

- `thraxos`, `upscale-banner`, built-in `imagegen`, and browser control for requested Google Images research.
- `memory/banner-upscale-queue.json` and the scripts under `.agents/skills/upscale-banner/scripts/`.
- `references/release-art-research.md` for source priority, release verification, and prompt evidence.
- Task-local staging outside the live song folder for downloaded references, preserved raw generations, and normalized candidates.

Inputs are an exact song folder or simfile, its current fingerprint, canonical simfile metadata, owner creative direction, and verified release-art references. Output is either one queue-bound opaque 836 x 328 PNG awaiting exact-preview approval or a rotated fingerprint with detailed failure history.

## Safety boundary

- Require consistent contained nonblank `#BANNER` plus exact cross-simfile title, subtitle, and artist metadata. A missing target is allowed only for queue `generationMode=generate-banner`; blank, missing, conflicting, ambiguous, or escaping references remain ineligible.
- Verify Google Images leads on an established release detail page. Do not treat fan art, marketplace composites, tribute pages, or search thumbnails as authoritative.
- Use release art only for palette, era, type category, motifs, material, and layout rhythm. Do not copy sleeve layout, logos, label names, catalog numbers, watermarks, or identifiable people.
- Require complete canonical visible copy and reject missing, changed, duplicated, cropped, unreadable, or extra text.
- Use GPT Image 2 at most twice, preserve raw results, normalize separately to opaque 836 x 328, and never switch to a third call or deterministic fallback silently.
- If release identity cannot be verified, return the reserved fingerprint with precise `prompt-error` research evidence instead of inventing a source or leaving it pending. Before a corrected second generation, record the first candidate's hashes/failure and re-reserve so a later success cannot erase attempt-one evidence.
- Scheduled and interactive generation are preview-only. For source-less work, show a factual missing Before state and never substitute jacket/background art as a fake source. Do not write live banners, edit simfiles, restart ITGMania, or change configuration, charts, scores, profiles, timestamps, signatures, or GrooveStats state.
- Route a later exact-preview approval through `upscale-banner` installation and queue proof. Source-less installation requires explicit `-SourceLessGeneration`, may create only the unchanged declared target, and records delete-created-target rollback semantics.

## Reproduce and verify

1. Copy the complete `.agents/skills/generate-banner/` directory and migrate `thraxos` plus `upscale-banner` first.
2. Adapt the approved song root and queue location; 836 x 328 (209:82, approximately 2.5488:1) is the current Thraximundar convention and must be re-observed on another host.
3. Run a research fixture whose Google Images result points to a Discogs or official release page. Verify exact artist/title relationship, edition details, one task-staged reference hash, and no live write.
4. Run a scratch-generation fixture with title, artist, featuring credit, and remix/version metadata. Require all canonical text exactly once and no unrelated copy after opaque 836 x 328 normalization.
5. Exercise an unviable first result and one corrected retry. Confirm the third-call prohibition and atomic `generation-failed` return with retained attempt history.
6. Exercise a viable result. Confirm exact preview path/hash binding, full-resolution `Before` and `After` rendering for existing art, or a factual missing Before state plus exact After for source-less work, unchanged simfile hashes, and an explicit install question without installation.
7. Exercise a source-less fixture through approved installation. Require creation of only the contained `#BANNER` target, no fabricated original/backup hash, `RollbackAction=RemoveCreatedTarget`, exact installed-preview proof, and unchanged simfile content.
8. Run the official skill validator on `.agents/skills/generate-banner`.
