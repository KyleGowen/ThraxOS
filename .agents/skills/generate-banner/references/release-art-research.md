# Release-art research sources

Use one focused Google Images query for discovery, then verify the chosen image on an established detail page. Search results and thumbnails are leads, not proof.

## Preferred sources

1. Official artist, label, or release store pages: strongest identity and era evidence.
2. Bandcamp: strong when the artist or label controls the page.
3. Discogs release or master pages: strong for edition, country, format, year, catalog lineage, and uploaded sleeve scans.
4. MusicBrainz plus Cover Art Archive: structured release identity and reusable cover-art retrieval.
5. Apple Music or Spotify: strong current album/single association, sometimes limited historical-edition detail.
6. Established retail catalogs such as Amazon only when stronger release pages are unavailable; distinguish product photography from the cover itself.

Avoid Pinterest, social reposts, fan wikis, lyrics pages, tribute artwork, marketplace composites, AI art, and unsourced blogs as authoritative evidence. They may reveal a lead but cannot establish the release identity.

## Verification checklist

- Match canonical artist and title from every simfile.
- Identify album, single, remix, promo, reissue, country, format, and year when shown.
- Confirm the image is cover or sleeve art rather than a record label, back cover, video thumbnail, merchandise, or seller mockup.
- Record the exact detail-page URL and explain why that page supports the reference.
- Save only the needed image in task staging; record SHA-256 and decoded dimensions.
- Describe reusable visual facts: palette, type category, symbols, geometry, texture, materials, and compositional rhythm.
- Do not infer or copy credits absent from canonical simfile metadata.
- Do not copy source logos, label names, catalog numbers, watermarks, or identifiable faces into the new banner.

## Prompt pattern

```text
Input images: Images 1-N are authentic release-art references for inspiration only.
Create an original ultrawide 836:328 ITGMania banner using the references' palette, era, typography category, and recurring graphic motifs without copying their exact layout, logos, catalog marks, or identities.
Text (verbatim): "<canonical title>" and "<complete canonical artist>".
No other visible words. Keep every required string fully visible and readable at 836 x 328.
```
