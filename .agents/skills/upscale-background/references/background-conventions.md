# Static background conventions

- Owner-confirmed 2026-08-02: windowed ITGMania at 1920 x 1080, 16:9.
- Target 1920 x 1080. Prefer opaque PNG for previews; preserve the live reference's `.png`, `.jpg`/`.jpeg`, or `.bmp` encoding when installing.
- Prefer faithful outpainting to stretching. Crop only when identity-critical subjects, text, logos, and composition remain intact. Letterbox only when outpainting and cropping would materially falsify the artwork.
- Dimensions are a review trigger, not the sole verdict. Consider aspect, compression, detail, and full-screen appearance.
- Exclude GIF, video/movie formats, `BGCHANGES`, missing backgrounds, conflicting/implicit references, and multi-frame decoder results.
- Record explicit owner feedback that a valid background is good as-is as fingerprint-scoped `skipped`; changed source or simfile content receives a fresh assessment.

AI restoration may infer detail; compare closely and require approval. Deterministic resampling cannot recover missing semantic detail.
