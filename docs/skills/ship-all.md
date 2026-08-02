# Ship All skill

## Triggers and purpose

Use `ship-all` when the owner explicitly says "commit and push everything," "ship all changes," or asks to publish the complete intended worktree to `main`. It reviews tracked and untracked work, excludes unsafe material, validates proportionally, creates an intentional commit, and pushes without rewriting history.

## Owned files

- `.agents/skills/ship-all/SKILL.md`: workflow and safety gates.
- `.agents/skills/ship-all/agents/openai.yaml`: discovery metadata.
- `docs/skills/ship-all.md` and `docs/skills/README.md`: migration guide and catalog.

It does not own application code, live ITGMania content, backup implementation, or generated backup data.

## Dependencies

- Git, repository access, and authenticated access to the intended remote.
- Repository guidance and validation tools required by changed files.
- Network access for fetch and push.

No GitHub plugin, CLI, hard-coded account, credential, or host path is required.

## Inputs and outputs

Inputs are explicit owner authorization, the complete worktree, repository policy, branch topology, remote state, and proportional validation commands. Outputs are one reviewed commit on `main`, an ordinary push to `origin/main`, validation evidence, and excluded-file categories. Unsafe or ambiguous state produces a stop report instead.

## Safety boundary

Inspect staged, unstaged, deleted, renamed, untracked, conflicted, submodule, and relevant ignored state. Refuse conflicts, secrets, sensitive attachments, generated data, junk, and unclear partial work. Never print secret values, force push, bypass hooks, reset, clean, discard work, or silently merge, rebase, cherry-pick, or move commits. From another branch, switch only when clean and no intended work can be stranded; otherwise stop for an explicit integration decision.

For ThraxOS, preserve control-plane ownership: backup logic remains in `itgmania-backup`, generated data remains in `Thraximundar-Backup`, and live songs stay outside this repository. Skill and scheduled-task changes require matching guides and indexes.

## Host-specific values

Confirm `origin` and `main` live on every invocation. Discover authentication, checkout paths, validation commands, and Git location on the host. Never migrate credentials, identifiers, or absolute user-profile paths.

## Reproduction and migration

1. Copy `.agents/skills/ship-all` into the target project's skill directory.
2. Copy this guide and add its catalog entry.
3. Review the target contract, remote/default branch, protected-branch rules, hooks, and validations.
4. Adapt only deliberate remote/branch differences; retain all non-destructive and secret-exclusion gates.
5. Configure authentication outside the repository and run structural validation.

No data conversion is needed from an ad hoc workflow. Stop using broad staging or force-capable aliases; retain existing work for explicit classification.

## Verification

Run the official `quick_validate.py` against `.agents/skills/ship-all`, inspect `agents/openai.yaml`, confirm this catalog link, and review the required stop conditions. Do not forward-test by committing or pushing unless the owner separately authorizes that mutation.
