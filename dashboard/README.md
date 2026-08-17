# ThraxOS Arcade Console

A localhost-only dashboard for discovering and operating ThraxOS capabilities.

## Start

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File dashboard/Start-ThraxDashboard.ps1
```

Open `http://127.0.0.1:8765/`. The server deliberately refuses non-loopback
bindings. Press `Ctrl+C` in the terminal to stop it.

For private-LAN phone access, bind to an explicit RFC1918 address and supply a
random access token of at least 32 characters:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File dashboard/Start-ThraxDashboard.ps1 -BindAddress 192.168.1.16 -AllowLan -AccessToken '<random-token>'
```

Open `http://192.168.1.16:8765/?access=<random-token>` once. The token is moved
into an HTTP-only session cookie and removed from the address bar. LAN mode also
requires a Windows Firewall inbound rule restricted to the private profile and
local subnet. Never port-forward this service or expose it to the public internet.

## Safety model

- The browser can select only capability IDs defined in
  `dashboard/config/capabilities.json`; the catalog covers every project-local skill and a small set of fixed ThraxOS diagnostics.
- Inputs are validated by type, allowed values, length, and path roots.
- Read-only helper scripts run directly with fixed script paths and argument maps.
- Agent-led and mutating skills create a review request under
  `dashboard/data/requests/`; they do not execute unattended.
- New schedules use the same allowlist and require an in-page acknowledgement.
  They are dashboard schedules that run only while the dashboard service is
  running: fixed helpers remain read-only, while other due items create review
  requests. They do not modify Windows Task Scheduler or Codex automation
  configuration.
- Responses omit credentials, profile IDs, serial numbers, and full USB instance
  identifiers.
- The Sleep Jukebox indexes browser-playable `.mp3`, `.ogg`, `.opus`, and `.wav`
  files only from `C:\Games\ITGmania\Songs`. It returns display metadata and
  opaque catalog IDs, never absolute paths; audio requests are revalidated
  against that root and support byte ranges for normal browser playback. The
  player uses the browser's native audio output; its animated waveform is
  decorative and cannot prevent a track from starting.
- The Play Sessions page reads local `Save\Upload` score exports and profile
  display-name mappings in memory. It returns only Kyle, Sam, and Eliza's
  display labels, session aggregates, canonical simfile title/artist, and the
  top three PercentDP scores. Profile directories and GUIDs never reach the
  browser. A gap longer than two hours starts a new recorded session; duration
  is the wall-clock span from the first score timestamp through the final
  song's recorded end, not active song time. Each ranked result also joins its
  recorded steps type and difficulty to the current `.ssc` or `.sm` chart and
  shows both the named difficulty and numeric meter.

## UI inheritance preflight

Before changing this dashboard's pages, forms, dialogs, cards, or reusable
components, run the `thraxos` AgentOS inheritance-status helper. Refresh a
stale cache before selecting a visual language or component library. shadcn/ui
is the inherited default; this no-build host may instead preserve its accessible
component and interaction language when importing the library is not reasonable.
A StepManiaX/DDR treatment complements that default and is not, by itself, an
override.

The current implementation is a clean, zero-dependency application shell: a
responsive navigation rail, capability cards, semantic dialogs, accessible form
states, task rows, activity history, and small StepManiaX arrow accents. Keep
that component language consistent when extending the console.

The current visual treatment takes direct local inspiration from the installed
Simply Love music wheel: flat dark blue-gray panels, compact header strips,
wheel rows, and its cyan/gold/green/pink status palette. It remains an original
dashboard implementation rather than copying theme assets or code.

The dashboard reads only installed Codex automations scoped to the ThraxOS
repository, plus the documented backup schedule. It translates known cron rules
into local-time descriptions. Windows Task Scheduler visibility may be degraded
on this host because `Get-ScheduledTask` can be access denied.

## Verify

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File dashboard/Test-ThraxDashboard.ps1
```
