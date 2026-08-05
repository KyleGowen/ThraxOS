---
name: find-singles
description: Find and rank up to 10 non-installed individual ITGMania or StepMania songs for Thraximundar using owner-confirmed musical tastes, dynamically inferred player stretch levels, approved public sources, pad-suitability evidence, and live-library deduplication. Use when the owner asks to search for, discover, recommend, or shortlist individual songs or simfiles rather than complete packs.
---

# Find Singles

Research individual song candidates for `Misc. Collected`. Return a short, evidence-backed list; never download or install through this skill.

## Load current context

1. Read repository `AGENTS.md`, `memory/FACTS.md`, `memory/DECISIONS.md`, and `memory/PREFERENCES.md`.
2. Read `docs/context/family-music-taste.md` only for musical and chart-style preferences and `docs/context/song-sources.md` as the source policy.
3. Run the `get-player-skill-levels` skill and use its current per-player `stretchLevel` output for difficulty fit. Never infer taste from Stats.xml or played content.
4. Read the `research-itg-community` skill and its required references for broad source research. Use `itg-packs-search` only when a pack catalog helps trace an individual chart.
5. Inspect both currently approved live song roots and record the observation date. Treat checked-in library counts as historical snapshots.

## Build the search target

- Match candidate meters to each requested player's dynamically inferred stretch level. Report unavailable or insufficient dynamic evidence rather than using old static ranges.
- Apply owner-confirmed musical and chart-style preferences separately. A song need not serve all players.
- Give the curated `Misc. Collected` evidence more weight than installed DDR/ITG completeness packs.
- Reject evidenced spins/gimmicks, keyboard-first charts, poor volume consistency, or incoherently shortened edits. Treat dubstep and anime focus only as mild negatives.

## Search and verify

1. Search Zenius-I-vanisher and StepMania Online first. Then use the current r/StepMania request thread and ZIV requests forum as discovery leads only. Do not post requests or interact with communities.
2. Search exact artists/titles plus featured-artist, punctuation, transliteration, remix, edit, and alias variants.
3. Resolve every finalist to an exact chart release and publisher/catalog page. A request, video, search-result link, or unverified mirror is not provenance.
4. Verify artist/title, stepartist, pad evidence, singles/doubles, chart meters, release/update date, edit/remix identity, and current source availability. Preserve uncertainty when ratings are not known to use the local ITG scale.
5. Treat StepMania Online, ZIV, OutFox, Etterna, and FFR content as mixed until exact real-pad and ITGMania compatibility evidence applies. Videos can screen chart motion but cannot prove sync, archive safety, or revision identity.

## Remove installed and duplicate results

Create a JSON array containing only the finalists:

```json
[
  {"artist":"Example Artist","title":"Example Song (Remix)"}
]
```

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".agents\skills\find-singles\scripts\Compare-InstalledSingles.ps1" -CandidateJsonPath '<candidate-json>'
```

The helper reads title/artist metadata from the two approved roots and emits only candidate-specific evidence. Exclude `exact` matches. Investigate `likely_variant` matches before retaining them; do not collapse distinct remixes or distinct chart releases silently.

Deduplicate across sources by musical recording and chart release. One chart mirrored on several sites is one candidate. Keep a materially distinct remix or independently authored chart only when clearly labeled.

## Rank and report

Rank by:

1. Requested player, artist, and current dynamic stretch-level fit.
2. Evidenced pad/singles suitability.
3. Household taste and useful multi-player coverage.
4. No installed or likely-variant overlap.
5. Credible provenance, coherent edit/audio evidence, and complete metadata.
6. Recency only after the stronger criteria.

Return at most 10 genuinely supported candidates; fewer is correct. Number the list. For each item report:

- exact artist and title, including remix/edit;
- stepartist or release identity;
- direct source page and whether a publisher download is currently offered;
- pad/style evidence, singles/doubles, chart meters, and rating-scale caveat;
- player fit for Kyle, Samantha, and/or Eliza;
- installed-overlap result and why it fits;
- material sync, audio, edit, gimmick, compatibility, or provenance uncertainty.

Lead with observation date, roots checked, and sources searched. Mention meaningful excluded or unresolved leads briefly. Never claim archive size, checksum, safety, or sync unless the source actually establishes it.

## Hand off selection

Do not download, scan, extract, install, launch, reload, restart, or change live files. When the owner selects a candidate, hand its exact source page, archive link, artist, and title to `add-song`, which must independently revalidate it.
