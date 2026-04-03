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

List available issue types:

```bash
gh api graphql -f query='{ organization(login: "black-atom-industries") { issueTypes(first: 20) { nodes { id name } } } }' --jq '.data.organization.issueTypes.nodes[] | "\(.name) | \(.id)"'
```

### Labels

Labels use namespaced conventions: `state:*`, `contrib:*`, `topic:*`. Managed via `sync-labels.sh` in the `.github` repo, driven by `labels.json` config. Labels are assigned per repo category (discovered via GitHub topics).

List labels for a repo:

```bash
gh label list --repo black-atom-industries/REPO
```

List repos by category:

```bash
gh repo list black-atom-industries --topic black-atom-adapter --json name --jq '.[].name'
# Categories: black-atom-core, black-atom-adapter, black-atom-tool, black-atom-plugin, black-atom-meta, black-atom-web
```

### Project Fields

List project fields and their options:

```bash
gh api graphql -f query='{ organization(login: "black-atom-industries") { projectV2(number: 7) { fields(first: 20) { nodes { ... on ProjectV2SingleSelectField { id name options { id name } } } } } } }' --jq '.data.organization.projectV2.fields.nodes[] | select(.name != null) | "\(.name) (\(.id)): \([.options[] | "\(.name)=\(.id)"] | join(", "))"'
```

### Repos

List all org repos:

```bash
gh repo list black-atom-industries --json name --jq '.[].name' --limit 100
```

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
