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
  `dashboard/config/capabilities.json`.
- Inputs are validated by type, allowed values, length, and path roots.
- Read-only helper scripts run directly with fixed script paths and argument maps.
- Agent-led and mutating skills create a review request under
  `dashboard/data/requests/`; they do not execute unattended.
- New schedules use the same allowlist. They are dashboard schedules and run only
  while the dashboard service is running. They do not modify Windows Task
  Scheduler or Codex automation configuration.
- Responses omit credentials, profile IDs, serial numbers, and full USB instance
  identifiers.

The dashboard reads the two installed Codex automation TOML files and the
documented backup schedule. Windows Task Scheduler visibility may be degraded on
this host because `Get-ScheduledTask` can be access denied.

## Verify

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File dashboard/Test-ThraxDashboard.ps1
```
