# Remote access runbook

Use Codex Remote instead of creating a new public service.

1. Keep the latest ChatGPT desktop app running on Thraximundar and signed into the intended account/workspace.
2. In the desktop app, select **Set up Remote** in the sidebar.
3. Scan the QR code with the ChatGPT mobile app and finish pairing with the same account/workspace.
4. Review **Settings > Connections** and choose whether the host should be kept awake.
5. Keep the Windows session unlocked only when remote work needs foreground Computer Use; filesystem and shell tasks do not require a new unauthenticated listener.
6. Test a read-only `@ThraxOS check status` request from the remote device.
7. Retain normal Codex sandbox and approval behavior for remote sessions.

Remote availability stops if the host sleeps, goes offline, signs out, or closes the desktop app. Do not expose Codex, PowerShell, SMB, or a custom HTTP control endpoint directly to the public internet.

Reference: [Codex Remote connections](https://learn.chatgpt.com/docs/remote-connections).
