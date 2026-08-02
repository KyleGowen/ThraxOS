---
name: ship-all
description: Safely publish all complete, intended repository work to origin/main. Use when the owner says "commit and push everything," "ship all changes," or asks to review the whole worktree, create an intentional commit, and push main while excluding secrets, sensitive attachments, generated data, and junk.
---

# Ship All

## Overview

Publish the complete safe worktree without losing work, leaking private data, or rewriting history. Treat "everything" as all intended, reviewable repository work, not every byte present on disk.

## Establish the boundary

1. Read the repository `AGENTS.md` and applicable project memory.
2. Confirm the repository root, `origin`, intended target `main`, current branch, upstream, HEAD, local `main`, and `origin/main` without displaying credential-bearing URLs.
3. Fetch `origin` before treating remote-tracking state as current.
4. Proceed only when the user explicitly authorized committing and pushing all intended work.

## Inventory the entire worktree

Inspect tracked, staged, unstaged, untracked, renamed, deleted, conflicted, submodule, and relevant ignored state. Use `git status --short --branch --untracked-files=all`; staged and unstaged `git diff` views with `--stat` and `--check`; `git ls-files --others --exclude-standard`; and a bounded ignored-file review when generated output or raw attachments may be present.

Read every changed text file. Identify binaries by type, purpose, size, and provenance. Never print secret values. Stop on unresolved conflicts, unexpected submodule changes, suspicious repository ownership, or any unclear change that cannot be classified safely.

## Classify before staging

Include only complete, safe, in-scope work. Preserve compatible owner and other-agent changes; never revert, discard, overwrite, or silently omit intended work.

Exclude and report by category, without printing contents:

- credentials, tokens, cookies, private keys, session material, or credential-bearing URLs;
- profile GUIDs, serial numbers, full USB instance IDs, Windows SIDs, and other prohibited unique identifiers;
- raw sensitive attachments, personal exports, excessive household profile/health data, or secret-bearing logs;
- generated backup data, live songs, builds, caches, temporary staging, editor files, downloaded archives, and out-of-scope junk;
- partial, broken, unexplained, or suspicious changes.

Use filename checks and content-aware secret scanning that reports only file and finding category. Stop if a suspected secret is tracked or staged. Do not add broad ignore rules merely to make status clean unless reviewed as an intended policy change.

## Protect branch history

Never force push, bypass hooks, amend unrelated commits, reset, clean, discard work, or use destructive checkout/restore commands.

If invoked outside `main`, determine whether the branch has unique commits or intended worktree changes. Do not silently merge, rebase, cherry-pick, move commits, or switch with a dirty worktree. Switch to `main` only when clean, no intended work can be stranded, and all work to publish is already represented safely on `main`. Otherwise stop, explain the exact relationship, and request an explicit integration choice.

After fetching, require local `main` to be safely based on `origin/main`. If clean and strictly behind, update fast-forward-only. If dirty and behind, or local and remote diverged, stop before committing. If equal or only safely ahead, continue. Treat a rejected push as a stop condition: re-fetch and report rather than rewriting history.

## Validate and stage intentionally

1. Run proportional validation selected from changed areas and repository guidance.
2. Resolve only failures caused by intended work; do not absorb unrelated cleanup silently.
3. Stage explicit reviewed paths. Avoid `git add -A` until every exclusion and deletion is adjudicated.
4. Re-run status and review `git diff --cached --stat`, `git diff --cached --check`, and the full staged patch.
5. Confirm excluded files remain unstaged and every safe intended change is represented. Stop if nothing remains.

## Commit and push

1. Derive an informative imperative subject from the complete staged change; add a concise body when useful.
2. Commit normally. Never use `--no-verify`.
3. Confirm the commit contains exactly the reviewed paths and inspect post-commit status.
4. Push with ordinary `git push origin main`. Never use force options.
5. Verify the local/remote relationship. Report commit hash, subject, validation results, target, and excluded categories.

If a hook changes files, validation fails, the remote advances, or new work appears, pause and re-inventory.

## ThraxOS-specific boundary

Keep ThraxOS as the control plane, `itgmania-backup` as backup implementation, and `Thraximundar-Backup` as generated backup data. Do not commit live songs, credentials, raw household profile data, or machine-unique identifiers. Require matching guides and indexes when project skills or scheduled tasks change. Update checked-in memory for meaningful decisions or operations without secrets.
