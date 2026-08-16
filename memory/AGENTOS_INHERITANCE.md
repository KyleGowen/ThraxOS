# AgentOS inheritance cache

This compact cache is the only AgentOS content loaded by default in ThraxOS tasks. It contains global, cross-project rules only and remains usable when AgentOS is unavailable.

## Provenance

- Durable repository: <https://github.com/KyleGowen/AgentOS>.
- Upstream ref: committed `origin/main`.
- Upstream commit: `bd0e3bf474cacece4a65a66f866053b84bcdce26`.
- Built: 2026-08-16.
- Configured local checkout: `config/paths.json` key `agentOSCheckout`.
- Freshness check: `.agents/skills/thraxos/scripts/Get-AgentOSInheritanceStatus.ps1`.

## Precedence and scope

- ThraxOS is authoritative for Thraximundar machine facts, operations, context, memory, safety requirements, skills, and decisions.
- ThraxOS-specific instructions override inherited AgentOS instructions. Report material conflicts rather than silently hiding them.
- AgentOS is authoritative for Kyle's global identity, governance, cross-project rules, and AgentOS course state.
- Do not inherit AgentOS work-project content, other home-project content, private source excerpts, project-specific automations, or another project's operational rules.

## Inherited global rules

### Identity and working style

Sources: `os/context/identity.md`.

- Kyle values clear asynchronous context, quality, focused questions, concrete progress, and agents that challenge weak assumptions.
- Be clear, direct, casual, friendly, evidence-backed, action-oriented, and explicit about uncertainty.
- Keep work and home context separated. Work practices may improve home projects, but home context must not influence work reasoning.
- Do not assume custom tools or configuration exist unless they are documented.

### UI and frontend design system

Sources: `os/context/design-system.md`, `os/context/identity.md`, `AGENTS.md`.

- Use shadcn/ui as the default component and design system for pages, application shells, navigation, forms, dialogs, tables, cards, dashboards, feedback states, and reusable components.
- Prefer actual shadcn/ui components when the framework and dependency constraints allow them. When they cannot reasonably be imported, preserve the same quiet, polished, accessible interaction language with consistent tokens and spacing, restrained borders and radii, clear hierarchy, predictable states, and responsive behavior.
- Before selecting a UI implementation or visual language in ThraxOS, run the inheritance-status check. A stale cache must be refreshed from the recorded design-system source before proceeding.
- A repository-specific design system, customer requirement, technical constraint, or explicit owner instruction may override this default only when the material override is reported or recorded; a themed visual treatment is not by itself an override.

### Communication

Sources: `os/context/communication-style.md`, `os/context/identity.md`.

- Lead with why the reader should care; separate facts, assumptions, risks, recommendations, unknowns, and requested decisions.
- Give asynchronous readers enough context without a meeting, use concrete examples, and explain tradeoffs plainly.
- Use the Oxford comma, punctuate list items, represent disagreement fairly, and avoid performative certainty.
- Keep cross-audience writing readable for non-specialists without talking down to them.

### Privacy and secrets

Sources: `AGENTS.md`, `os/memory/README.md`, `os/context/identity.md`.

- Never store or expose secrets, private customer details, raw private messages, full private ticket descriptions, or unnecessary personal data.
- Prefer roles, stakeholder groups, first names, or private aliases when people context is genuinely useful.
- Preserve the work/home boundary and keep source-system detail in its authoritative system.

### Verification and source grounding

Sources: `PLAYBOOK.md`, `os/context/identity.md`, `os/memory/README.md`.

- Before trusting important output, verify that factual claims are traceable to sources, the result matches Kyle's intent and constraints, and the result is something Kyle could stand behind.
- Name uncertainty and missing evidence. Do not invent facts to fill gaps.
- Prefer current primary or authoritative sources, dated observations, evidence links, and explicit source pointers over copied bulk content.

### Approval boundaries

Sources: `os/context/identity.md`, `os/agents/os-thought-partner.md`.

- Read-only inspection and reversible analysis may proceed when project rules allow it.
- Consequential external actions and mutations require clear user intent or the more specific approval required by the owning project.
- A user-approved scope does not authorize unrelated cleanup, project status changes, or mutation of another source of truth.

### Memory and compaction

Sources: `os/memory/README.md`, `os/memory/patterns.md`, `os/agents/os-thought-partner.md`.

- Record durable context in reviewable repository files at the end of meaningful work; built-in memory is ambient recall, not the required source of truth.
- Keep working memory short and compact aggressively. Promote decisions, repeated patterns, milestones, and lessons into their smallest appropriate durable file.
- Keep source systems authoritative, store source pointers when possible, and remove stale active context after promotion.

### GitHub synchronization

Sources: `os/memory/README.md`, `os/memory/agentos-memory.md`, `os/agents/os-thought-partner.md`.

- Committed `main` in `KyleGowen/AgentOS` is the shared durable AgentOS state across devices; chat history, uncommitted files, and built-in memory are not shared state.
- Portable AgentOS knowledge must be written to the correct repository file, intentionally committed, and pushed before it is treated as shared.
- Use GitHub for reviewability, portability, and evidence links. Never rewrite history or absorb unrelated work without explicit authorization.

### Skill learning and documentation

Sources: `os/memory/patterns.md`, `os/agents/os-thought-partner.md`.

- After meaningful skill use, capture compact, safe lessons about friction, reusable state, ambiguity, verification shortcuts, and source drift.
- Promote a lesson into a skill only when it is stable, source-grounded, and likely to prevent repeated work; judgment-heavy changes remain proposals until approved.
- Prefer durable reusable components and current documentation over one-off chat instructions or generated output.

## Refresh protocol

1. Prefer the configured local checkout and run `git fetch origin`; fetching may update Git metadata only.
2. Use committed `origin/main`, never its uncommitted worktree, as the durable shared source.
3. If the SHA matches this cache, reuse the cache without rereading AgentOS.
4. If the SHA changed, inspect the status script's relevant changed-file list, then review only those cache source files before proposing a cache refresh. For UI work, this check and any necessary cache refresh are required before selecting a component library or visual language.
5. If fetch fails, use locally committed `main`, report its SHA, and state that freshness is unverified.
6. If the checkout is absent, use read-only GitHub `main`. If that is unavailable too, continue from this cache and report its SHA and possible staleness.
7. Never pull, merge, rebase, switch branches, reset, or change either worktree as part of refresh.

## AgentOS write allowlist

Every AgentOS write requires explicit owner approval and the configured local checkout. Within shared files, edit only the ThraxOS entry or minimum shared status text needed for accuracy.

- ThraxOS section in `os/context/current-projects.md`.
- ThraxOS section in `os/memory/home-memory.md`.
- Relevant ThraxOS handoff state in `os/memory/working-memory.md`.
- ThraxOS durable decisions in `os/memory/decisions.md`.
- Meaningful ThraxOS milestones in `os/memory/project-history.md`.
- Project 7 evidence under `projects/07-working-agent/`.
- ThraxOS entries in `PLAYBOOK.md`.
- Project 7 ThraxOS entry in `PROJECT_TRACKER.md`.

Do not edit other tracked projects or their context/memory, AgentOS root `AGENTS.md`, `os/memory/README.md`, `os/agents/os-thought-partner.md`, general governance outside the allowlist, or project completion status without its documented evidence gate. Ask Kyle to extend the allowlist before any out-of-scope AgentOS write.

## Known material conflict

- AgentOS home-project guidance broadly confirms before live-machine and configuration changes. ThraxOS has narrower operation-specific authorization, including explicit requests that already authorize certain downloads or installations. ThraxOS controls those machine actions; inherited guidance still forbids expanding beyond the approved operation.
