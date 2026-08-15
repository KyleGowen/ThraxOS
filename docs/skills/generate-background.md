# Generate Background skill migration guide

## Source

- Skill: `.agents/skills/generate-background/`
- Entrypoint: `.agents/skills/generate-background/SKILL.md`
- UI metadata: `.agents/skills/generate-background/agents/openai.yaml`
- Normalizer: `.agents/skills/generate-background/scripts/Normalize-GeneratedBackgroundPreview.ps1`
- Normalizer test: `.agents/skills/generate-background/scripts/Test-NormalizeGeneratedBackgroundPreview.ps1`
- Research guidance: `.agents/skills/generate-background/references/release-art-research.md`

Copy the complete directory when migrating. The skill is intentionally source-controlled with ThraxOS and contains no generated artwork, queue data, credentials, or machine-unique identifiers.

## Triggers and ownership

Use `generate-background` when the owner asks for a brand-new song background, a from-scratch redesign, authentic album/single-art inspiration, or the largest clean background for the display rather than a faithful upscale of existing pixels.

The skill owns reference verification, original 16:9 generation direction, deterministic preview normalization, and handoff to the existing approval workflow. `upscale-background` continues to own source eligibility, durable queue transitions, presentation, exact-hash approval, guarded live installation, rollback proof, and learning records. `thraxos` owns host safety and machine-state checks.

## Dependencies and outputs

- Windows PowerShell 5.1 and `System.Drawing`.
- The built-in `imagegen` skill and image-generation tool.
- Project-local `thraxos` and `upscale-background` skills with their helper scripts.
- Web or browser access for one focused image discovery query and release-page verification.
- A task-owned staging path outside `C:\Games\ITGmania\Songs`.

The current Thraximundar target is an opaque, single-frame 1920 x 1080 PNG at 16:9. Raw model output remains preserved; the normalizer writes a distinct staged file, refuses live-Songs destinations, rejects material aspect mismatch, and verifies exact dimensions and opacity.

## Safety boundary

- One explicit song folder and exact content fingerprint per run.
- Static, contained `#BACKGROUND` only; active/malformed BGCHANGES, traversal, conflicting references, video, animation, undecodable art, and unconfirmed fallbacks remain excluded.
- Release artwork is evidence for high-level palette, era, texture, type category, motifs, and compositional rhythm only. Do not copy sleeves, logos, label marks, watermarks, identifiable people, or copyrighted layouts.
- Preserve queue decision and attempt history. A prior `skipped` fingerprint may be reopened only by an explicit owner request for a scratch redesign; a `denied` or `installed` fingerprint needs equally explicit owner reversal/replacement direction.
- At most two genuine AI generation calls. Local normalization, staging, forwarding, or rendering corrections do not consume a model attempt.
- Generation never writes to the live song directory. Installation requires a displayed, exact hash-bound approval and the `upscale-background` proof-gated installer.
- Never restart or terminate ITGMania automatically.

## Reproduce and verify

1. Copy `.agents/skills/generate-background/` into the same project-relative path on the target host.
2. Copy and configure `thraxos` and `upscale-background` first, including their queue, image-presentation, backup, and install helpers.
3. Adapt only documented host paths if ITGMania is installed elsewhere. Keep staging outside every live Songs root.
4. Run the normalizer's forward test:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\generate-background\scripts\Test-NormalizeGeneratedBackgroundPreview.ps1
   ```

5. Run the skill-package validator from the installed `skill-creator` package:

   ```powershell
   python <skill-creator>\scripts\quick_validate.py .\.agents\skills\generate-background
   ```

6. Forward-test a staged sample outside the live library. Confirm preservation of the raw input, exact 1920 x 1080 output, opaque one-frame decode, aspect-mismatch rejection, live-Songs destination rejection, and no live mutation.
