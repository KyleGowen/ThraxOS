# `itg-packs-search` skill

Source: [`.agents/skills/itg-packs-search/`](../../.agents/skills/itg-packs-search/)

Searches the live ITG Packs Release Spreadsheet with bounded reads, finalist-only hyperlink enrichment, explicit difficulty-range semantics, taste filtering, and installed overlap checks.

## Components

- `references/spreadsheet-schema.md`: spreadsheet interpretation and query plan.
- `scripts/Compare-InstalledPacks.ps1`: redacted local overlap comparison.
- Requires the Google Sheets connector and live spreadsheet access; rediscover metadata per query.
- Uses `memory/PREFERENCES.md` and `docs/context/song-sources.md`.

## Safety

Search and overlap checks are read-only. Blank cells remain unknown. Recommendations do not authorize downloads or installation, and full song inventories must not be printed.

## Reproduce and verify

1. Configure Google Sheets access in the target Codex environment.
2. Read live metadata and one bounded current-year range; enrich one finalist's link cells.
3. Run `Compare-InstalledPacks.ps1` against approved target roots using explicit candidate arrays.
4. Confirm installed, absent, and ambiguous matches remain distinct without exposing the library.
