# Add a household attract and dashboard mode

Status: proposed by owner on 2026-08-01.

Difficulty: 3/5. Expected impact: 4/5.

## Goal

When Thraximundar is idle, show an inviting rotation of how-to-play guidance, random installed-song previews, house-safe challenges, aggregate machine statistics, and recent public-safe highlights. The display should encourage friends and family to play without leaking individual scores, profile details, GrooveStats identity, or cardio data.

## Preliminary research

- Users have asked specifically for a theme combining attract mode with search and for Simply Love to show random songs, most-played songs, and high-score lists while idle: <https://www.reddit.com/r/Stepmania/comments/1kenggf> and <https://www.reddit.com/r/Stepmania/comments/1gq4ee3/>.
- Legacy StepMania attract behavior may depend on coin-mode configuration, making a theme-side household experience preferable to changing Thraximundar's Home-mode semantics solely to unlock an old demo loop: <https://www.reddit.com/r/Stepmania/comments/1d6nhb9/>.
- The current commercial StepManiaX UI cycles through high scores, how-to-play material, and demonstrations while idle, providing direct product precedent for a combined attract/dashboard experience: <https://data.stepmaniax.com/docs/Software%20Manual%20Rev2.pdf>.

These sources demonstrate repeated demand and an established cabinet pattern, but not a ready-made Simply Love 5.9.0 module.

## Proposed first version

- Activate only on safe idle screens after a configurable delay; never interrupt active selection, profile login, gameplay, evaluation, downloads, or maintenance.
- Rotate local how-to-play cards, random pack/song artwork, beginner recommendations, total machine songs played, and opt-in household challenges.
- Use an explicit allowlist of fields. Default to machine aggregates and suppress profile names, personal bests, GrooveStats data, and cardio estimates.
- Provide a one-action wake path from pad, keyboard, or the proposed kiosk controller.
- Keep sound off or separately configurable; avoid unexpectedly playing music in the home.

## Acceptance criteria

- Returns cleanly to stock navigation on any valid input.
- Adds negligible load and does not destabilize long-running ITGMania sessions.
- Never selects, deletes, downloads, or starts a song without an explicit player action.
- All displayed statistics have an understandable source and privacy classification.
- Can be removed without changing profiles, scores, songs, or machine preferences.

## Open questions

- Is a narrow Simply Love module sufficient, or does attract behavior require deeper screen-flow changes?
- Which machine-level statistics are available without repeatedly parsing large `Stats.xml` files?
- Should song previews honor a household/family filter, and where should that allowlist live?
