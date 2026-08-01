# GrooveStats context

Observed locally and researched on 2026-07-31.

GrooveStats tracks and ranks dance-game scores. ITGMania and Simply Love support online leaderboards and automated submissions through profile-specific API keys.

## Local integration model

Each local profile has a `GrooveStats.ini` under:

```text
C:\Users\Player.NUCBOXG3_PLUS\AppData\Roaming\ITGmania\Save\LocalProfiles\<profile>\GrooveStats.ini
```

Simply Love uses these fields:

- `ApiKey`: expected to be exactly 64 characters when configured.
- `Username`: optional local field.
- `IsPadPlayer`: must be explicitly `1` to mark the profile as a pad player.

The theme also requires `EnableGrooveStats=true` in `ThemePrefs.ini`, an ITG-compatible game mode and scoring configuration, a successful network connection, and at least one valid API key.

## Observed state

- `EnableGrooveStats=false` globally.
- `Kyle` has a non-empty 64-character API key but `IsPadPlayer=0`.
- `elemwarr` and `Crios` also have 64-character API keys and are marked as pad players.
- Other household profiles have no API key.
- No secret values were copied into this repository.

The owner confirmed that only Kyle should use GrooveStats and approved enabling Kyle with the existing key. The change is still pending because ITGMania was running during the configuration pass. The pre-existing keys for `elemwarr` and `Crios` remain untouched; removing them requires a separate approved configuration change.

## Credential handling

Prefer an existing API key, a newly generated GrooveStats API key, or an authenticated browser session. Do not ask the owner to commit a password or paste it into documentation. If interactive login is needed, keep it in the browser/password manager and store only the profile API key in the existing live `GrooveStats.ini`.

References:

- [GrooveStats login and service description](https://groovestats.com/index.php?action=login)
- [ITGMania built-in GrooveStats support](https://www.itgmania.com/)
- [Simply Love GrooveStats integration source](https://github.com/Simply-Love/Simply-Love-SM5/blob/dd06138b15492f4136796dfe4b6708ced0f7b9eb/Scripts/SL-Helpers-GrooveStats.lua)
