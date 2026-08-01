# ThraxOS memory

This directory is the reviewable, checked-in memory system. It complements Codex's optional local generated memories; it is the authoritative source for facts and rules that must survive across sessions and machines.

- `FACTS.md`: stable observed or owner-confirmed facts.
- `PREFERENCES.md`: owner and household preferences relevant to operation.
- `DECISIONS.md`: architectural and operational decisions with rationale.
- `OPEN-QUESTIONS.md`: unresolved owner choices.
- `RESOLVED-QUESTIONS.md`: dated answers retained for provenance.
- `OPERATIONS_LOG.md`: concise record of significant actions and verified outcomes.

Every entry must include a date and evidence type: **owner-confirmed**, **observed**, or **inferred**. Never store secrets, profile GUIDs, serial numbers, or bulky raw output.
