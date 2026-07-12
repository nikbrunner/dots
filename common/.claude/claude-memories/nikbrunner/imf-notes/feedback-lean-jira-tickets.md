---
name: feedback-lean-jira-tickets
description: 'Jira ticket descriptions must be lean, not process narration — no dates, no "re-scoped on X", no restating what Jira UI already shows'
metadata:
  node_type: memory
  type: feedback
  originSessionId: d90b7a31-d18f-4a6b-aa8b-902deaa11eae
---

Jira ticket bodies (Context/Goal/Scope/etc.) must describe the current, true state of the work — never narrate the triage/authoring process that produced them. Cut:

- Dates and "settled on YYYY-MM-DD", "re-scoped 2026-07-02 during triage" — nobody reading the ticket later cares when a decision was made, only what it is now.
- Meta-commentary about the ticket's own history: "this ticket is now specifically X, not Y anymore", "took over that role from Z".
- A manual "Scope (as subtasks)" bullet list that just repeats each subtask's key + one-line summary — Jira's UI already renders the subtask list natively. Do not duplicate it in the description body.
- Parenthetical justification trails on every bullet ("(blocked by X, cross-ticket link into Y, no shared parent needed)", "(absorbs Z's concern — resolving W)") — one clause of real signal, not three clauses of rationale.

**Why:** Nik's direct correction, twice in one session — "nobody will read this," "it's just bloat," "tickets should be as lean as possible." He'd rather write terse, current-state descriptions than a changelog of how the ticket got there.

**How to apply:** Before submitting any Jira `description` via `createJiraIssue`/`editJiraIssue`, reread it and cut every sentence whose only job is explaining process, timing, or "why this changed" rather than stating what's true right now. If a fact is redundant with something Jira's UI already surfaces natively (subtask list, parent link, status), don't restate it in the body. See [[jira-ticket-template]] if it exists for the required Context/Goal shape — leanness applies within that shape, not instead of it.
