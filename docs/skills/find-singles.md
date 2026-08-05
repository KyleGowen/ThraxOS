# `find-singles` skill

Source: [`.agents/skills/find-singles/`](../../.agents/skills/find-singles/)

Searches approved individual-song sources, combines owner-confirmed musical tastes with dynamically inferred stretch levels, checks pad suitability and provenance, removes live-library overlap, and returns up to 10 unique candidates. It is research-only; selected installations route to `add-song`.

## Components and dependencies

- `scripts/Compare-InstalledSingles.ps1`: bounded candidate JSON comparison against both approved live song roots using normalized folder names and exact simfile title/artist metadata.
- Depends on `thraxos`, `get-player-skill-levels`, `research-itg-community`, optionally `itg-packs-search`, `docs/context/family-music-taste.md`, and `docs/context/song-sources.md`.
- External access: current public web/catalog access for Zenius-I-vanisher, StepMania Online, and approved community discovery sources.
- Host tools: Windows PowerShell and `rg` (ripgrep).

## Inputs and outputs

- Inputs: an optional player, artist, title, genre, difficulty, or session preference; otherwise use the whole canonical household model.
- Helper input: a bounded JSON array of finalist `{artist,title}` objects, normally no more than 10.
- Output: a numbered list of at most 10 candidates with exact release identity, source page, download availability, chart/style evidence, difficulty coverage, player fit, overlap result, rationale, confidence, and material caveats.

## Safety boundary

The skill performs public research and read-only library inspection only. It never downloads archives, posts requests, launches or reloads ITGMania, edits configuration, or changes the Songs roots. Folder-name similarity is only a lead; exact and likely-variant matches require metadata-aware review. Community posts and videos do not independently prove archive provenance, pad suitability, sync, or compatibility.

## Reproduce and verify

1. Copy the whole `find-singles` directory and retain its documented project dependencies.
2. Adapt the two approved song roots and family taste profile for the destination host.
3. Supply a fixture JSON containing one installed song and one absent song; run `Compare-InstalledSingles.ps1` and verify `exact` and `none` results without a full-library dump.
4. Confirm searches cite exact public source pages, distinguish pad from keyboard charts, preserve rating-scale uncertainty, and stop at 10 supported candidates or fewer.
5. Verify a selected item is handed to `add-song` rather than downloaded by this skill.
