---
name: dev-handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

## Where to save

Always save to the **main repository root**, never inside a worktree. Handoffs are cross-session artifacts; a worktree's filesystem is ephemeral and gets removed on `/imf-close-worktree`, taking gitignored files with it.

Compute the target directory:

```sh
# Yields the main repo root even when invoked from inside a worktree under .claude/worktrees/<name>/
MAIN_ROOT=$(dirname "$(git rev-parse --absolute-git-dir | sed 's|/worktrees/[^/]*$||')")
```

Save to `${MAIN_ROOT}/handoffs/YYYY-MM-DD-<slug>.md`, where `<slug>` is a short kebab-case identifier for the focus area (e.g. `2026-05-28-brand-color-token.md`).

Before writing:
- Create `${MAIN_ROOT}/handoffs/` if it does not exist.
- Ensure `handoffs/` is listed in `${MAIN_ROOT}/.gitignore`. Handoffs are ephemeral and must not be tracked.
- If the session is inside a worktree, mention in the handoff itself which worktree it came from, so the next agent knows the context.

Suggest the skills to be used, if any, by the next session.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
