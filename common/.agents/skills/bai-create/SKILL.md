---
name: bai-create
description: Create a new Black Atom Industries issue
metadata:
  user-invocable: false
allowed-tools: ["Bash", "AskUserQuestion"]
---

# Black Atom Create

Create a new issue in the Black Atom Industries GitHub org.

## Arguments

Issue title and optional details (`$ARGUMENTS` in Claude Code, or `/skill:bai-create` args in Pi).

Examples:

- `Fix theme contrast in dark mode`
- `"Add nvim telescope support" repo:livery`
- `Design new logo for v1 repo:.github`

## Context

**Repos**: .github, core, livery, helm, nvim, ghostty, tmux, zed, wezterm, obsidian, radar.nvim, ui, website

**Issue Types**: Bug, Feature, Design, Enhancement, Refactor, Documentation, Infrastructure, Task

**Milestones** (per repo): livery → v1.0.0, helm → v1.0.0, radar.nvim → v1.0.0, core → Monitor, ui → v1.0.0

Load `about:bai` for GitHub project constants (Issue Type IDs, project field IDs).

## Process

1. **Parse** title and any inline hints (repo, type) from arguments

2. **Determine repo**:
   - Infer from current working directory if inside a BAI repo
   - Match by content (neovim-related → `nvim`, ghostty → `ghostty`, etc.)
   - Cross-cutting issues (branding, CI, naming, org-wide) → `.github`
   - Design tasks → `.github`
   - **Push back** if repo choice seems wrong

3. **Check milestones** for the target repo:

   ```bash
   gh api repos/black-atom-industries/<repo>/milestones --jq '.[].title'
   ```

4. **Ask with `AskUserQuestion`** — combine into a single call for what's missing:
   - **Priority** — Urgent, High, Medium (default), Low
   - **Issue Type** — suggest based on content (default: Feature)
   - **Milestone** — suggest from fetched milestones if any
   - **Status** — Todo (default) or In Progress if starting now

5. **Check for related issues** — search briefly, suggest linking if relevant

6. **Create issue**:

   ```bash
   gh issue create --repo black-atom-industries/<repo> --title "..." --body "..." --milestone "<milestone>" --project "Black Atom V1"
   ```

7. **Set Issue Type** via GraphQL (load IDs from `about:bai`):

   ```bash
   ISSUE_ID=$(gh issue view <number> --repo black-atom-industries/<repo> --json id --jq '.id')
   gh api graphql -f query='mutation { updateIssue(input: { id: "'$ISSUE_ID'", issueTypeId: "<type_id>" }) { issue { id } } }'
   ```

8. **Set Priority** on project via GraphQL (load field/option IDs from `about:bai`)

## Output

```
Created issue:
[core#70] Fix theme contrast in dark mode
Repo: core | Type: Bug | Priority: Medium | Status: Todo
Milestone: Monitor
https://github.com/black-atom-industries/core/issues/70
```

## Notes

- Always suggest a repo — pick the most relevant one, don't default blindly
- If creating multiple related issues, use native `addBlockedBy` relationships (see `about:bai`) and `state:blocked` label for non-issue blockers
- Push back on repo choice if it seems mismatched
