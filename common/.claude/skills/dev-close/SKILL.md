---
name: dev:close
description: "Finish development work — verify, ship (merge/PR/keep/discard), and optionally close the tracked issue."
user-invocable: true
---

# Close

Finish development work. Verify, ship, clean up.

## Step 1: Verify

Invoke `dev:verification` — run the project's test suite, build, lint. No completion claims without evidence.

If verification fails, stop. Fix first, then re-run this skill.

## Step 2: Ship

Invoke `dev:finishing-branch`:
1. Merge locally
2. Push & create PR
3. Keep branch as-is
4. Discard

## Step 3: Close Tracked Issue (optional)

If there's an issue associated with this work (GitHub issue, Linear issue referenced in branch name or conversation):

- Offer to close it
- For GitHub: `gh issue close <number>`
- For Linear/BAI: suggest using `bai:close`

If no issue is tracked, skip this step.

## Step 4: Knowledge Sync (optional)

For medium/large work, consider whether project knowledge artifacts need updating:
- CLAUDE.md changes
- New skills or skill updates
- Documentation updates

Reference `pr-knowledge-sync` if applicable.
