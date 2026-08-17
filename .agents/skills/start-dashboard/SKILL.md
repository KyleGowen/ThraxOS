---
name: start-dashboard
description: Start and verify the ThraxOS Arcade Console locally or on an explicitly approved private LAN address. Use when the owner asks to start, relaunch, make available, or troubleshoot the ThraxOS dashboard, Arcade Console, Sleep Jukebox, or its private-LAN access.
---

# Start Dashboard

Launch the existing allowlisted Arcade Console. Do not duplicate the server, expose a public listener, or print a LAN access token.

## Workflow

1. Read `AGENTS.md`, `memory/AGENTOS_INHERITANCE.md`, `memory/FACTS.md`, `memory/DECISIONS.md`, `memory/PREFERENCES.md`, `docs/runbooks/remote-access.md`, and `dashboard/README.md`.
2. Run `scripts/Get-DashboardPreflight.ps1` for the intended mode, port, and LAN address.
3. Confirm the owner explicitly wants a launch. Inspection never authorizes a launch, relaunch, or binding change.
4. For local use, run `scripts/Start-Dashboard.ps1 -Mode Local -Port <port> -Approved`.
5. For LAN use, require an owner-selected RFC1918 IPv4 address, a URL-safe token of at least 32 characters supplied through a local secret mechanism, and matching URLACL/firewall scope. Then run `scripts/Start-Dashboard.ps1 -Mode Lan -BindAddress <private-ip> -Port <port> -AccessToken <local-secret> -Approved`.
6. Report only the base URL, mode, port, and response result. Never print or log the token, tokenized URL, cookies, or profile identifiers.

## Safety boundary

- Default to localhost; never bind to `0.0.0.0`, a public address, or a hostname.
- The launcher never creates or widens URLACL/firewall rules. Obtain separate explicit approval before any Windows networking change, and keep it Private plus LocalSubnet.
- Never terminate or replace a conflicting listener automatically.
- Preserve the dashboard's fixed allowlist; do not add arbitrary shell, command, or path execution.
- Keep Codex Remote as the general remote-control path and never expose Codex or this dashboard publicly.

## Resources

- `scripts/Get-DashboardPreflight.ps1`: read-only server, listener, and LAN-prerequisite check.
- `scripts/Start-Dashboard.ps1`: approval-gated hidden-process launcher and response verifier.
- `scripts/Test-StartDashboard.ps1`: parser and guardrail validation.
