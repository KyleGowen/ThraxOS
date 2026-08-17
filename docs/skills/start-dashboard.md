# Start Dashboard skill

Source: [`.agents/skills/start-dashboard/`](../../.agents/skills/start-dashboard/)

Start and verify the ThraxOS Arcade Console for localhost use or an explicitly approved private-LAN session. The skill wraps the existing `dashboard/Start-ThraxDashboard.ps1`; it does not duplicate dashboard behavior or add new control capabilities.

## Triggers and dependencies

Use when the owner asks to start, relaunch, make available, or troubleshoot the Arcade Console, Sleep Jukebox, dashboard, or private-LAN dashboard access. It depends on PowerShell, the checked-in dashboard server and test scripts, HTTP.sys, and—only for LAN—an owner-selected private IPv4 address plus existing URLACL/firewall scope.

## Operation

1. Run `Get-DashboardPreflight.ps1` for live evidence of the requested port, binding, listener, and LAN prerequisites.
2. Start localhost only after explicit owner direction with `Start-Dashboard.ps1 -Mode Local -Port <port> -Approved`.
3. For LAN, require a RFC1918 address, URL-safe 32+ character token from a local secret mechanism, verified URLACL, and a matching `ThraxOS Arcade Console (LAN)` private/LocalSubnet firewall rule. Then use `-Mode Lan -BindAddress <address> -AccessToken <token> -Approved`.
4. Verify the local or token-gated response. LAN verification proves the bound endpoint responds locally; test from the intended private-LAN device before claiming phone availability.

## Safety boundary

- Localhost is the default. Never bind to all interfaces, public addresses, or hostnames.
- Do not print, commit, store, or put the LAN tokenized URL in chat. The helper reports the base endpoint only.
- The launcher refuses a listener conflict and never terminates or restarts an existing server.
- The skill does not create URLACLs or firewall rules. Obtain separate explicit approval before any Windows networking mutation, and scope it to the private profile and LocalSubnet.
- Keep public remote access disabled. Use Codex Remote for general remote development.

## Verification and migration

Run `scripts/Test-StartDashboard.ps1`, then the dashboard's `Test-ThraxDashboard.ps1`. On another host, copy the whole skill directory and dashboard folder, adapt only non-secret paths and an owner-selected LAN address, recreate URLACL/firewall configuration with separate approval, and provision the token outside source control.
