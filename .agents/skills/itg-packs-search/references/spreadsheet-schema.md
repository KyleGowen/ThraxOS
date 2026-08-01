# ITG Packs spreadsheet search contract

## Canonical source

- Spreadsheet ID: `1F1IURV1UAYiICTLhAOKIJfwUN1iG12ZOufHZuDKiP48`
- Canonical URL: `https://docs.google.com/spreadsheets/d/1F1IURV1UAYiICTLhAOKIJfwUN1iG12ZOufHZuDKiP48/edit`
- Expected title: `ITG Packs Release Spreadsheet`
- Primary tabs: current calendar year, prior year tabs, `INDEX`, `Beginner Packs`, and `Event/Tournament Packs`.

Always verify metadata live. A new year tab, changed grid size, or column change overrides this reference.

## Current year schema

The current release tabs use columns `A:P`:

| Column | Meaning |
| --- | --- |
| A | Date, usually month/day without year |
| B | Pack name; often the direct download/publisher hyperlink |
| C | Song count |
| D | Stepartist(s) or organizer |
| E | Target block/difficulty |
| F | Full block/difficulty spread |
| G | BPM range |
| H | Difficulty count per song or singles/doubles count notation |
| I | Doubles coverage/count |
| J:L | Information, previews, mirrors, or comments; often hyperlinked |
| M | Content type such as Technical, Stream, All Around, or Double |
| N | `Pack.ini` indicator on newer tabs |
| O | Format such as Singles or Singles+Doubles |
| P | GrooveStats-ranked indicator |

`INDEX` is useful for historical name/author lookup, but may omit details or collapse dates. Prefer the matching year row for authoritative release metadata.

## Query recipes

### Exact author or pack

1. Read metadata.
2. Search the current-year tab within its actual `A:P` bounds.
3. Search spelling variants when evidence supports them, for example `Freya` and `Freyja`.
4. If no current match, stop unless the user asked for older/latest-known results; then search `INDEX` once.
5. Resolve an `INDEX` hit to its year tab before reporting detailed metadata.

### Difficulty range

1. Read the current-year `A:P` range once.
2. Parse numeric endpoints from columns E and F. Preserve suffixes such as `S` and `D` and split them into singles/doubles ranges.
3. A pack contains requested range `[L,H]` when a documented interval overlaps it. Rank exact containment above partial overlap.
4. Prefer target-range matches over full-spread-only matches.
5. Do not infer a range from BPM, difficulty count, or song count.

### Taste-matched discovery

1. Apply difficulty and format filters first.
2. Use content type and pack/title clues only for initial ranking.
3. Read linked song lists for finalists before making strong genre claims.
4. Reject explicit owner conflicts. Mark unknown genre as unknown rather than guessing.

### Hyperlinks and details

Plain range reads omit hyperlinks. After shortlisting, request cell metadata for exact rows with at least `formattedValue,hyperlink,note,userEnteredValue`. The pack-name cell usually holds the download link, while J:L often hold information, song-wheel, or alternate-download links.

## Accuracy traps

- Search is case-insensitive but not typo-aware; explicitly query likely aliases.
- Sheet row numbers are 1-based; connector `startRow` values may be zero-based.
- A large grid can contain hundreds of blank rows. Bound to the metadata row count but ignore empty records.
- Dates inherit the year from the tab.
- `Difficulties` often means number of charts, not difficulty rating.
- `Doubles` may be a ratio such as `7/22`, not a boolean.
- `Format` may be blank even when linked information proves singles or doubles support.
- Values such as `1-6339` are probable source errors and must be reported as suspect.
- `null` or blank metadata is unknown. Do not convert it to zero, no, or unsupported.
- Pack-title overlap is definitive only after normalization; song-title overlap is preliminary because different songs or charts can share names.

## Minimal-call targets

- Exact current author/pack lookup: metadata + one or two variant row searches.
- Current-year range discovery: metadata + one `A:P` range read + one finalist cell-metadata read.
- Recommendation with overlap: add one local comparison-script call.
- Historical lookup: add one `INDEX` search and one matching year-row read.

Do not browse the rendered Google Sheet unless the connector is unavailable or cannot expose required data.
