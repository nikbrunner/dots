---
name: bai:update
user-invocable: false
description: Update a Black Atom issue (status, labels, relations, etc.)
allowed-tools: ["Bash", "AskUserQuestion"]
---

# Black Atom Update

Update an issue's status, add comments, manage relations, or change metadata.

## Arguments

`$ARGUMENTS` - Issue identifier and what to update

Examples:

- `core#50 to In Progress`
- `livery#29 comment: Started working on this`
- `core#53 priority Urgent`
- `core#50 blocks core#53`
- `.github#4 close`

## Context

**Issue format**: `repo#number` (e.g., `core#50`). Accept `#number` and infer repo from cwd.
**Status workflow**: Todo → In Progress → In Review → Done

Load `about:bai` for GitHub project constants (field IDs, option IDs).

## Process

1. Parse issue identifier (e.g., `core#50`)

2. Get current issue state:

   ```bash
   gh issue view <number> --repo black-atom-industries/<repo> --json title,state,labels,milestone,body,url,comments
   ```

3. Determine update type and execute:

   **Status change** ("to [status]"):
   - Get project item ID, then update via GraphQL (load IDs from `about:bai`):

   ```bash
   gh api graphql -f query='mutation { updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwDOCY_EKc4BTDpb", itemId: "<item_id>", fieldId: "PVTSSF_lADOCY_EKc4BTDpbzhAaQ3U", value: {singleSelectOptionId: "<status_option_id>"} }) { projectV2Item { id } } }'
   ```

   **Comment** ("comment: [text]"):

   ```bash
   gh issue comment <number> --repo black-atom-industries/<repo> --body "..."
   ```

   **Priority** ("priority [level]"):
   - Update project item priority field via GraphQL (same pattern as status)

   **Sub-issue** ("sub-issue of [issue]" or "add sub [issue]"):
   - Use `addSubIssue` GraphQL mutation (see `about:bai` for pattern)
   - Works cross-repo
   - To remove: use `removeSubIssue` mutation

   **Blocker** ("blocked by [issue]" or "blocks [issue]"):
   - Use `addBlockedBy` GraphQL mutation (see `about:bai` for pattern)
   - Works cross-repo
   - To remove: use `removeBlockedBy` mutation

   **Close**:

   ```bash
   gh issue close <number> --repo black-atom-industries/<repo>
   ```

   **Labels** ("label [name]"):

   ```bash
   gh issue edit <number> --repo black-atom-industries/<repo> --add-label "blocked"
   ```

4. Confirm what was changed

## Output

```
Updated [core#50]:
Status: Todo → In Progress
https://github.com/black-atom-industries/core/issues/50
```

## Notes

- Show current state before and after for clarity
- For dependencies: use sub-issues (parent-child) via GraphQL, not labels
