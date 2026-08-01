# GrooveStats configuration runbook

1. Use only the `Kyle` local profile unless the owner explicitly changes the policy.
2. Check API-key presence and length without displaying the value.
3. Confirm whether the profile should be marked as a pad player.
4. Inspect `ThemePrefs.ini` for `EnableGrooveStats` and confirm the active theme/game mode.
5. Verify backup health and ensure ITGMania is closed before editing live INI files.
6. After approval, run `.agents\skills\thraxos\scripts\Set-GrooveStatsForProfile.ps1`; it must refuse to write while ITGMania is running and must never print the key.
7. Re-read the files, confirm valid INI structure, then launch the game only if approved.
8. Verify connection and leaderboard display with a non-destructive in-game check. Do not manufacture a score submission as a test.
9. Record configuration status without copying the API key.

Prefer an API key or authenticated browser session over collecting a GrooveStats password in chat.

Enabling the theme switch is global. Because two other profiles currently contain keys, Kyle-only enforcement is not complete until their credentials are removed or archived in a separately approved configuration change. Do not alter them implicitly.
