---
name: get-player-skill-levels
description: Dynamically infer mapped ITGMania players' current stretch levels from recent dated Stats.xml score records joined to live simfile meters. Use when recommendations, pack research, or player summaries need current difficulty evidence instead of static skill ranges.
---

# Get Player Skill Levels

Infer difficulty only. Never infer musical taste, genre preference, chart-style preference, health, or identity from play records.

## Load context

1. Read repository `AGENTS.md`, `memory/FACTS.md`, `memory/DECISIONS.md`, and `memory/PREFERENCES.md`.
2. Read `docs/context/play-data.md` and `config/profile-common-name-map.json`.
3. Treat the mapping file's top-level schema description, version, matching rules, and profile entries as the portable contract. Never expose profile directories, GUIDs, machine identifiers, or raw score histories.

## Run the dynamic inference

From the repository root, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".agents\skills\get-player-skill-levels\scripts\Get-PlayerSkillLevels.ps1"
```

The script, independently for each mapped profile:

1. Finds the latest dated score record in `Stats.xml`.
2. Uses the inclusive window from 90 days before that timestamp through that timestamp.
3. Keeps non-disqualified records whose grade is not failed.
4. Joins the recorded song directory, StepsType, and Difficulty to the current live simfile and reads its numeric meter.
5. Defines `stretchLevel` as the highest meter with at least two resolved successful records in the window.
6. Reports insufficient evidence, unmapped profiles, ambiguous joins, and unresolved joins instead of filling gaps with static ranges.

`Stats.xml` retains dated high-score records, not a complete history of every play. Describe results as recent recorded-score evidence, not exhaustive activity or certified ability.

## Consume the result

- Use `stretchLevel` as the dynamic difficulty input for `find-singles`, pack discovery, or player-level reporting.
- Re-run the script for every recommendation task; do not copy its output into a context file as a permanent range.
- Keep musical taste exclusively in the owner-confirmed taste context. A played song or pack does not establish preference.
- If a mapped player lacks two resolved clears at any meter, say the dynamic level is unavailable. Do not silently fall back to the retired static range.

## Safety and privacy

Operate read-only. Do not edit `Stats.xml`, scores, timestamps, signatures, profiles, simfiles, or the mapping during inference. Return aggregate counts, dates, meter, and confidence only; never print raw score rows, profile paths, GUIDs, or household-wide health inferences.
