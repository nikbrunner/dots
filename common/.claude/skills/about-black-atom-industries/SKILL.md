---
name: about:black-atom-industries
description: Black Atom Industries theme ecosystem context. Load when BAI, themes, adapters, or colorschemes come up.
user-invocable: false
---

# About Black Atom Industries

My theme/colorscheme ecosystem — a modular system for consistent styling across editors, terminals, and tools.

A central `core` repo (Deno/TypeScript, published on JSR as `@black-atom/core`) defines all theme colors. Platform-specific adapter repos use Eta templates to generate theme files from core definitions. Changing a color in core propagates to every supported platform.

The org contains adapters for various platforms, plus supporting tools like `livery` (theme switcher), `radar.nvim` (file picker plugin), `helm` (multi-repo management CLI), and shared `claude` configuration.

Issues tracked on GitHub Issues across org repos, with an org-level project for cross-repo coordination.

## Local Paths

- Org repos: `~/repos/black-atom-industries/`
- Theme files in dots are symlinks to adapter repos

## GitHub Project Constants

- **Org**: black-atom-industries
- **Project**: "Black Atom V1" (#7) — https://github.com/orgs/black-atom-industries/projects/7
- **Project ID**: `PVT_kwDOCY_EKc4BTDpb`
- **Cross-cutting issues**: `.github` repo

### Issue Types (org-level)

<IMPORTANT>These ID's can be outdated.</IMPORTANT>

| Name           | ID                    |
| -------------- | --------------------- |
| Bug            | `IT_kwDOCY_EKc4BNfT9` |
| Feature        | `IT_kwDOCY_EKc4BNfT-` |
| Design         | `IT_kwDOCY_EKc4BkU29` |
| Enhancement    | `IT_kwDOCY_EKc4BkVJp` |
| Refactor       | `IT_kwDOCY_EKc4BkVJw` |
| Documentation  | `IT_kwDOCY_EKc4BkVJ3` |
| Infrastructure | `IT_kwDOCY_EKc4BkVJ-` |
| Task           | `IT_kwDOCY_EKc4BkVKL` |

### Project Fields

**Status** (field: `PVTSSF_lADOCY_EKc4BTDpbzhAaQ3U`): Todo (`f75ad846`), In Progress (`47fc9ee4`), In Review (`658b9552`), Done (`98236657`)

**Priority** (field: `PVTSSF_lADOCY_EKc4BTDpbzhAaQ60`): Urgent (`e9ee10c3`), High (`8cf9837c`), Medium (`a96685a4`), Low (`d74cfabb`)

### Repos with Issues

`.github`, `core`, `livery`, `helm`, `nvim`, `ghostty`, `tmux`, `zed`, `wezterm`, `obsidian`, `radar.nvim`, `ui`, `website`

### Sub-Issues (Parent-Child Relationships)

Use GitHub's native sub-issues for dependencies and hierarchies.

**Add sub-issue** (GraphQL):

```bash
PARENT_ID=$(gh issue view PARENT_NUM --repo black-atom-industries/REPO --json id --jq '.id')
SUB_ID=$(gh issue view SUB_NUM --repo black-atom-industries/REPO --json id --jq '.id')
gh api graphql -f query="mutation { addSubIssue(input: { issueId: \"$PARENT_ID\", subIssueId: \"$SUB_ID\" }) { issue { title } subIssue { title } } }"
```

**Remove sub-issue** (GraphQL):

```bash
gh api graphql -f query="mutation { removeSubIssue(input: { issueId: \"$PARENT_ID\", subIssueId: \"$SUB_ID\" }) { issue { title } subIssue { title } } }"
```

Works cross-repo. Up to 100 sub-issues per parent, 8 levels deep. Visible in hierarchy view on the project board.

### Blockers (Blocked-by Relationships)

Use GitHub's native blocker relationships — not labels or comments.

**Mark as blocked by** (GraphQL):

```bash
BLOCKED_ID=$(gh issue view BLOCKED_NUM --repo black-atom-industries/REPO --json id --jq '.id')
BLOCKING_ID=$(gh issue view BLOCKING_NUM --repo black-atom-industries/REPO --json id --jq '.id')
gh api graphql -f query="mutation { addBlockedBy(input: { issueId: \"$BLOCKED_ID\", blockingIssueId: \"$BLOCKING_ID\" }) { issue { title } blockingIssue { title } } }"
```

**Remove blocker** (GraphQL):

```bash
gh api graphql -f query="mutation { removeBlockedBy(input: { issueId: \"$BLOCKED_ID\", blockingIssueId: \"$BLOCKING_ID\" }) { issue { title } blockingIssue { title } } }"
```

Visible in the "Relationships" sidebar on each issue.
