# Add a private-LAN phone controller and guest kiosk

Status: proposed by owner on 2026-08-01; high-interest concept requiring a prototype and security review.

Difficulty: 5/5. Expected impact: 5/5.

## Vision

Let a friend or family member scan a QR code on Thraximundar and use a temporary phone interface to search installed songs, choose difficulty and style, select Guest or an allowed profile, and request basic game actions without needing a keyboard, arcade selector box, or direct filesystem access.

The desired experience is appliance-like: walk up, scan, choose, and dance. This proposal is distinct from Codex Remote, which remains the authenticated owner administration channel.

## Saved interface concepts

The owner wants to retain all four preliminary single-player interface directions for later evaluation. The interactive phone-and-tablet mockups are saved in [`phone-controller-interface-mockups.html`](phone-controller-interface-mockups.html):

1. **Arcade Deck:** album-forward selection with direct difficulty and Start controls.
2. **Jukebox:** search-first browsing, recommendations, packs, and a lightweight queue.
3. **Smart Remote:** minimal directional controls that keep the television as the primary interface.
4. **Family First:** guided energy and music choices that hide chart jargon from new guests.

Each concept includes a transient phone layout and a persistent small-tablet layout. Both assume one player and one pad; no two-player arbitration or player-side selector is required for Thraximundar.

## Community history and lineage

This idea combines several older community patterns rather than beginning with the 2026 prototype:

1. **Dedicated arcade controls:** dance cabinets traditionally separate gameplay input from hand-operated menu controls. Home users still buy small selector boxes because navigating menus by stepping is awkward, especially for guests: <https://ddrpad.com/products/arcade-button-selector-control-box>.
2. **Web song catalogs and queues:** SMRequests evolved a web-searchable StepMania catalog, request queue, difficulty limits, moderation, and stats-driven completion for streamers. It demonstrates that a StepMania library can be indexed and safely exposed through a narrower web interface, although its public/Twitch architecture is broader than Thraximundar needs: <https://smrequests.com/>.
3. **Theme-side integration:** Simply Love and ITGMania have supported external modules such as Twitch-related integrations, and ITGMania 1.0 release work explicitly addressed module-related shutdown stability. This makes a theme harness plausible, but not automatically stable across theme upgrades: <https://github.com/itgmania/itgmania/releases/tag/v1.0.0>.
4. **QR identity handoff:** Simply Love 5.6.0 added GrooveStats QR login for Guest and Local Profiles, establishing QR codes as a familiar ITGMania interaction rather than a foreign UI convention: <https://github.com/Simply-Love/Simply-Love-SM5/releases/tag/5.6.0>.
5. **ITGMania phone-controller prototype:** Dustin Westaby documented a February 2026 kiosk modification that boots to song selection, displays a QR code, and uses a phone for search, selection, stats, profile, Single/Versus, play, pause, and stop. Communication tests and a Simply Love harness were published, but the phone app and web server were not publicly released at research time. The author described the beta as stable while listing party queue and cloud profiles as unfinished: <https://www.westaby.net/2026/02/itgmania-phone-controller/>.
6. **Commercial touchscreen precedent:** the current StepManiaX cabinet uses its touchscreen for all menu interactions, cycles through attract/how-to-play/high-score screens, and leaves the stage for gameplay. That is strong product-design precedent, though its proprietary game UI is not reusable code: <https://data.stepmaniax.com/docs/Software%20Manual%20Rev2.pdf>.

Confidence is high that the interaction model is useful and technically plausible. Confidence is only moderate that the published harness remains compatible with Thraximundar's ITGMania 1.3.0 and Simply Love 5.9.0. Confidence is low regarding the unreleased beta server's implementation, security, and maintenance prospects.

## Recommended architecture

- Bind only to a trusted private LAN interface; never expose the controller to the public internet.
- Display a short-lived QR session URL containing a random, expiring capability token. Do not encode profile IDs, credentials, hostnames, or durable secrets.
- Use an allowlisted command protocol with explicit game states. Never accept arbitrary keyboard input, shell commands, paths, Lua, or URLs from the phone.
- Begin with a read-only catalog and request/preview mode. Add game-control commands only after a version-matched harness prototype proves state synchronization and failure recovery.
- Keep owner administration, pack installation, configuration changes, and restarts in Codex Remote/ThraxOS—not in the guest UI.
- Prefer a sidecar service that can be stopped independently and a minimal, documented Simply Love module. Avoid maintaining a broad private theme fork if a narrow module is sufficient.
- Provide a visible Disconnect/End Guest Session control and automatically revoke access after inactivity or game exit.

## Phased investigation

### Phase 0: provenance and compatibility

- Review the two published repositories, licenses, commit activity, issue history, and exact integration protocol.
- Ask the author for beta access only if the owner separately authorizes contact; do not rely on unpublished software for the design.
- Test whether Simply Love 5.9.0 exposes or preserves the harness hooks used by the prototype.

### Phase 1: read-only proof of concept

- Serve a local catalog of installed songs and charts with search, pack, difficulty, BPM, length, and banner data.
- Display the QR code outside live gameplay and prove token expiry, LAN binding, and simultaneous-client behavior.
- Allow a phone to place a non-executing song request visible on a separate test page.

### Phase 2: constrained kiosk control

- Add song selection, difficulty, Guest/profile choice, and Single/Versus through explicit state transitions.
- Add pause/stop only after deciding which actions are safe during active play and how accidental taps are prevented.
- Design party queuing as a later extension, not a prerequisite.

## Acceptance criteria

- A new guest can reach a playable chart without a keyboard or owner intervention.
- No unauthenticated client outside the trusted LAN can reach the service.
- Expired or reused QR sessions fail closed.
- The phone cannot access files, secrets, Windows, Codex, configuration screens, profile identifiers, or unrestricted game inputs.
- Loss of Wi-Fi, phone sleep, multiple guests, theme reload, or service failure cannot crash ITGMania or strand it in an unrecoverable state.
- Uninstalling the integration restores stock Simply Love behavior without affecting profiles, scores, or songs.

## Open questions

- Does the community harness communicate through theme messages, simulated input, a local socket, files, or another interface?
- Can song selection be driven robustly without maintaining a fork of Simply Love?
- Should profiles be limited to Guest plus an owner-configured allowlist, given household privacy and Kyle-only remote summary rules?
- Is pause appropriate for scored play, or should the guest interface offer only request, back, and abort with confirmation?
- How should two phones arbitrate control during Versus or a party queue?
