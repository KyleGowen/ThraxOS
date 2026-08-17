# On-demand service capability: `Start Dashboard`

This is not a Windows Task Scheduler task or Codex automation. It is the scheduled-task-catalog companion to the `start-dashboard` skill so migration and safety boundaries remain discoverable.

## Trigger and action

- **Trigger:** Explicit owner request to start, relaunch, or make the Arcade Console available.
- **Action:** Run the fixed dashboard server through the project-local guarded launcher, then verify its HTTP response.
- **Working directory:** ThraxOS checkout.
- **Concurrency:** Refuse to replace an existing listener. There is no recurring trigger or unattended restart.

## LAN boundary

LAN mode requires a private RFC1918 address, a local-secret URL-safe token, URLACL, and a private-profile/LocalSubnet firewall rule. The skill will not create those prerequisites; Windows networking changes require separate owner approval. It never exposes the service to the public internet or prints the access token.

## Reproduce and verify

Copy the dashboard and `start-dashboard` skill, then run its preflight and validation scripts. Confirm a local response first and test from the intended private-LAN device before claiming LAN availability. Do not create a scheduled task for this capability.
