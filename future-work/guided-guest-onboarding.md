# Add guided guest onboarding and profile handoff

Status: proposed by owner on 2026-08-01.

Difficulty: 2/5. Expected impact: 4/5.

## Goal

Give a first-time player a short, safe path from the title screen to an appropriate chart: explain stage/menu controls, choose Guest versus an explicitly allowed local profile, select Single or Versus, establish a comfortable starting difficulty, and expose only the modifiers a newcomer is likely to understand.

## Preliminary research

- Simply Love 5.6.0 added GrooveStats QR login for Guest and Local Profiles, including configurations where profile selection is disabled. This supplies an optional identity handoff without manually editing an API key: <https://github.com/Simply-Love/Simply-Love-SM5/releases/tag/5.6.0>.
- The same release reset late joiners to Guest rather than silently reusing the last local profile, evidence that accidental profile inheritance is a recognized multiplayer usability and score-integrity problem.
- Older community answers often required switching themes to create profiles or manipulating coin/event modes to change players, illustrating why version-specific onboarding documentation matters: <https://www.reddit.com/r/Stepmania/comments/c0jx0d/> and <https://www.reddit.com/r/Stepmania/comments/edt34b/>.
- The current StepManiaX cabinet introduces difficulty categories before song selection and permits later adjustment, offering a useful onboarding pattern even though its five-panel difficulty scale does not map directly to ITGMania ratings: <https://data.stepmaniax.com/docs/Software%20Manual%20Rev2.pdf>.

## Proposed first version

1. Document and test the stock ITGMania 1.3.0 / Simply Love 5.9.0 guest journey before adding code.
2. Create concise local guidance for pad navigation, Start/Back, Guest versus profile, Single/Versus, difficulty, speed modifier, fail behavior, and stopping safely.
3. Default newcomers to Guest unless they deliberately choose an allowed local profile or complete native GrooveStats QR login.
4. Recommend from an owner-reviewed pool of approachable installed charts; do not equate SMX Beginner/Easy labels with ITG difficulty numbers.
5. Integrate with the future attract dashboard and phone kiosk only through shared content and explicit handoffs, so onboarding remains usable without either feature.

## Safety and acceptance criteria

- Never expose profile directory IDs, API keys, other players' scores, or personal/cardio information.
- Never bind a guest to Kyle's or another household member's profile by default.
- Do not create, rename, or modify a local profile without separate approval.
- Preserve competitive integrity: guest scores must not be attributed to an existing player, and GrooveStats submission must follow the selected authenticated identity.
- A first-time player should reach a suitable song with minimal owner explanation and be able to back out without restarting the game.

## Open questions

- Which household profiles, if any, should be visible to guests rather than only to their owners?
- Should GrooveStats QR login be offered during casual household play or kept behind an advanced choice?
- What installed-song difficulty and content filters best represent a safe first session?
