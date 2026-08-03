# Static background conventions

- Owner-confirmed 2026-08-02: windowed ITGMania at 1920 x 1080, 16:9.
- Target 1920 x 1080. Prefer opaque PNG for previews; preserve the live reference's `.png`, `.jpg`/`.jpeg`, or `.bmp` encoding when installing.
- Prefer faithful outpainting to stretching. Crop only when identity-critical subjects, text, logos, and composition remain intact. Letterbox only when outpainting and cropping would materially falsify the artwork.
- Quality tiers are `broken-or-tiny` (either axis below 640 x 360), `aspect-mismatch` (more than 0.02 from 16:9), `sd-or-smaller` (either axis at or below 854 x 480), `sub-hd` (either axis below 1280 x 720), and `soft-review` (remaining candidates below the target). Consider compression, detail, and full-screen appearance within the tier.
- Treat whitespace-only `#BGCHANGES:;` tags as empty metadata. Exclude populated or malformed `BGCHANGES`, GIF, video/movie formats, conflicting references, traversal, and multi-frame decoder results.
- Keep plausible implicit legacy art and missing-reference fallbacks `review-only`; filenames do not establish the runtime source and do not authorize generation or installation.
- Record explicit owner feedback that a valid background is good as-is as fingerprint-scoped `skipped`; changed source or simfile content receives a fresh assessment.

AI restoration may infer detail; compare closely and require approval. Deterministic resampling cannot recover missing semantic detail.
