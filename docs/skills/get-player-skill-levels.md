# `get-player-skill-levels` skill

Source: [`.agents/skills/get-player-skill-levels/`](../../.agents/skills/get-player-skill-levels/)

Dynamically infers each mapped player's current stretch level from recent dated `Stats.xml` score records and numeric meters resolved from current live simfiles. It never infers musical taste.

## Components and dependencies

- `scripts/Get-PlayerSkillLevels.ps1`: read-only profile mapping, per-profile rolling-window selection, score filtering, simfile meter resolution, aggregation, and privacy-safe JSON output.
- `config/profile-common-name-map.json`: versioned portable common-name to `Stats.xml` display-name mapping. It contains no profile directories or GUIDs.
- Depends on `thraxos`, `docs/context/play-data.md`, local ITGMania profiles, and the approved live song roots.
- Host tools: Windows PowerShell and readable `.sm`/`.ssc` simfiles.

## Method and output

For each mapped profile, use the inclusive 90-day period ending at its latest recorded score. Exclude disqualified and failed records. Join song directory, StepsType, and Difficulty to a current simfile meter. `stretchLevel` is the highest meter supported by at least two resolved successful records.

Output includes common name, window dates, eligible/resolved/unresolved/ambiguous counts, stretch level, supporting-clear count, unmapped display names, roots checked, and an explicit notice that `Stats.xml` is not a complete play log.

## Mapping portability

The mapping file defines its contract at the top through `$schemaDescription`, `formatVersion`, and `matching`. On another host, preserve the structure and replace only `profiles` entries. Match exact display names after trimming and Unicode case-folding. Never map through profile directory names, GUIDs, or score identifiers.

## Safety and verification

The skill is read-only. It must not edit profiles, scores, timestamps, signatures, simfiles, configuration, or taste evidence. Test with mapped, unmapped, sparse, ambiguous, and unresolved fixtures. Verify the PowerShell parser, mapping JSON, skill validator, current live run, and that results are regenerated rather than copied into context as static ranges.
