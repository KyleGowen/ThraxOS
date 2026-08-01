---
name: itg-packs-search
description: Search and analyze the live ITG Packs Release Spreadsheet efficiently and accurately. Use for recent-pack discovery, author or pack lookups, difficulty-range filtering, pad/keyboard suitability, taste-matched recommendations, download-link retrieval, release comparisons, or installed-pack overlap checks involving itgpacks.com or the Google Sheet with ID 1F1IURV1UAYiICTLhAOKIJfwUN1iG12ZOufHZuDKiP48.
---

# ITG Packs Search

Search the canonical spreadsheet through the Google Sheets connector, then enrich only the strongest matches. Treat saved results as observations, never as a substitute for a fresh read.

## Load the search contract

Read [`references/spreadsheet-schema.md`](references/spreadsheet-schema.md) completely before querying. In ThraxOS, also read `memory/PREFERENCES.md` and `docs/context/song-sources.md` for the owner's current taste and reporting rules.

## Query efficiently

1. Discover the Google Sheets connector actions for spreadsheet metadata, plain range reads, row searches, and cell metadata.
2. Read spreadsheet metadata once per task. Resolve exact tab titles and current grid bounds; do not reuse old row counts.
3. Choose one primary query:
   - Exact author or pack: use a bounded row search on the current-year tab, including known spelling variants. Search `INDEX` only when history is requested or the current year has no match.
   - Difficulty, date, format, or taste filtering: read the current-year `A:P` values once and filter the returned rows locally. Do not issue one row search per difficulty value.
   - Multi-year request: read only the named year tabs. Do not default to `INDEX` plus every year tab.
4. Shortlist before enrichment. Fetch hyperlinks and notes with a cell-metadata read for only the finalist rows.
5. Follow each finalist's `Information`, song-list, or publisher link only when genre, exact charts, archive size, or checksum is needed. Prefer original publisher material.
6. For Thraximundar overlap checks, launch a child PowerShell with process-scoped bypass and array arguments, for example `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '<script>' -CandidatePack @('Pack A','Pack B') -CandidateSong @('Song A')"`. Never dump the full song library into chat.

## Interpret accurately

- Attach the tab year to month/day values; year tabs usually omit the year in `Date`.
- Distinguish `Target block` from `Full block spread`. A requested range matches when either explicitly contains/intersects it, but explain whether it is the pack's focus or merely available lower charts.
- Treat `Format`, `Doubles`, and difficulty-count columns independently. Blank fields mean unknown, not false.
- Do not call illuminated metadata or a broad numeric spread proof of pad suitability. Prefer `Singles`, `Doubles`, `All Around`, `Technical`, and linked chart documentation; flag uncertainty.
- Normalize case and punctuation for comparisons, but preserve display names in the answer.
- Treat suspicious ranges and missing values as spreadsheet data-quality issues. Do not silently repair them.

## Rank recommendations

Rank with this order unless the user overrides it:

1. Explicit requested difficulty coverage.
2. Pad-oriented format and suitable chart style.
3. Owner taste match.
4. Recent release date.
5. No installed pack or likely song overlap.
6. Complete metadata and trustworthy direct source.

Exclude known taste conflicts rather than merely ranking them lower. A single matching song does not make an anime-focused or dubstep-focused pack suitable.

## Report evidence

For each recommendation, report pack, stepartist/author, release date, song count, target and full difficulty ranges, singles/doubles style, content type, source/download link, installed overlap, and why it fits. Report archive size and checksum when the source provides them; otherwise say they are unavailable.

Never download or install a pack unless the owner explicitly requests it. Hand installation work back to the ThraxOS song-pack runbook.
