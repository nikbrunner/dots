# gh CLI Scripting Patterns

## PR Workflows

```bash
# Create PR with HEREDOC body (avoids quoting issues)
gh pr create --title "feat: add caching" --body "$(cat <<'EOF'
## Summary
- Added Redis caching layer
- Reduced API response time by 40%

## Test plan
- [ ] Unit tests pass
- [ ] Load test with 1000 concurrent requests
EOF
)"

# Get current PR number from branch
gh pr view --json number --jq '.number'

# List open PRs as tab-separated values
gh pr list --json number,title,author --jq '.[] | "\(.number)\t\(.author.login)\t\(.title)"'

# Wait for CI then merge
gh pr checks --watch && gh pr merge --squash --delete-branch

# View PR comments (REST API)
gh api repos/{owner}/{repo}/pulls/123/comments --jq '.[].body'

# Update PR branch from base
gh pr update-branch
```

## Issue Workflows

```bash
# Create issue with labels and assignee
gh issue create --title "Bug: login fails" --label bug --assignee "@me"

# Bulk add label to issues
gh issue list --label "needs-triage" --json number --jq '.[].number' | \
  xargs -I{} gh issue edit {} --add-label "triaged"

# Create linked branch for an issue
gh issue develop 123 --checkout

# Close with comment
gh issue close 123 --comment "Fixed in #456"

# Cross-repo issue list
gh issue list -R owner/repo --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

## CI / Actions

```bash
# Watch a run in real-time
gh run watch

# View failed logs only
gh run view 12345 --log-failed

# Rerun failed jobs
gh run rerun 12345 --failed

# Use exit status in scripts (non-zero if failed)
gh run view 12345 --exit-status

# Download artifacts
gh run download 12345 -n artifact-name

# List workflow runs filtered by branch
gh run list --branch main --workflow build.yml --json status,conclusion,url
```

## gh api (REST)

```bash
# List with pagination (critical -- default is only 30 items)
gh api repos/{owner}/{repo}/contributors --paginate --slurp --jq '.[].login'

# Cache expensive calls
gh api repos/{owner}/{repo}/contributors --cache 1h --jq '.[].login'

# POST with typed fields (-F auto-converts types, -f is raw string)
gh api repos/{owner}/{repo}/issues -F title="Bug report" -F "labels[]=bug" -F "labels[]=urgent"

# Read body from file
gh api repos/{owner}/{repo}/issues -F body=@issue-body.md -f title="From file"

# Debug HTTP traffic
GH_DEBUG=api gh api repos/{owner}/{repo}
```

## gh api (GraphQL)

```bash
# Simple query with placeholders
gh api graphql -F owner='{owner}' -F name='{repo}' -f query='
  query($name: String!, $owner: String!) {
    repository(owner: $owner, name: $name) {
      releases(last: 3) { nodes { tagName } }
    }
  }
'

# Paginated GraphQL (requires $endCursor and pageInfo)
gh api graphql --paginate --slurp -f query='
  query($endCursor: String) {
    viewer {
      repositories(first: 100, after: $endCursor) {
        nodes { nameWithOwner }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
' | jq '[.[].data.viewer.repositories.nodes[]] | length'
```

## Releases

```bash
# Create release with auto-generated notes
gh release create v1.2.3 --generate-notes

# Upload assets with display labels
gh release upload v1.2.3 ./build/app.zip#'Application (zip)'

# Create draft release from tag
gh release create v1.2.3 --draft --verify-tag --notes-from-tag
```

## Search

```bash
# Search issues (note -- separator for exclusion)
gh search issues "memory leak" --repo owner/repo --state open
gh search issues -- "auth error -label:wontfix" --repo owner/repo

# Search code across GitHub
gh search code "handleAuth" --repo owner/repo --json path,repository

# Search PRs by author
gh search prs --author="@me" --state open
```

## Non-Interactive Scripting

```bash
# Disable all prompts
export GH_PROMPT_DISABLED=1

# Force terminal-style output in pipes
export GH_FORCE_TTY=120

# Silence output (e.g. for status checks in scripts)
gh api repos/{owner}/{repo} --silent

# Check auth status programmatically
gh auth status 2>&1 | grep -q "Logged in" && echo "authenticated"

# Get current auth token for other tools
TOKEN=$(gh auth token)
```

## Advanced Issue Features (GraphQL)

These features require `gh api graphql` — no REST or CLI shorthand exists.

### Issue Types

Org-level issue types (Bug, Feature, Enhancement, etc.) are set via GraphQL. Requires the issue type ID (org-specific).

```bash
# Get issue node ID
ISSUE_ID=$(gh issue view 42 -R owner/repo --json id --jq '.id')

# Set issue type
gh api graphql -f query='
  mutation {
    updateIssue(input: { id: "'"$ISSUE_ID"'", issueTypeId: "IT_kwDO..." }) {
      issue { title }
    }
  }
'
```

### Sub-Issues (Parent-Child)

```bash
# Add sub-issue to parent
PARENT_ID=$(gh issue view 10 -R owner/repo --json id --jq '.id')
SUB_ID=$(gh issue view 11 -R owner/repo --json id --jq '.id')
gh api graphql -f query='
  mutation {
    addSubIssue(input: { issueId: "'"$PARENT_ID"'", subIssueId: "'"$SUB_ID"'" }) {
      issue { title } subIssue { title }
    }
  }
'

# Remove sub-issue
gh api graphql -f query='
  mutation {
    removeSubIssue(input: { issueId: "'"$PARENT_ID"'", subIssueId: "'"$SUB_ID"'" }) {
      issue { title } subIssue { title }
    }
  }
'
```

Works cross-repo. Up to 100 sub-issues per parent, 8 levels deep.

### Blockers (Blocked-by Relationships)

```bash
# Mark issue as blocked by another
BLOCKED_ID=$(gh issue view 20 -R owner/repo --json id --jq '.id')
BLOCKING_ID=$(gh issue view 21 -R owner/repo --json id --jq '.id')
gh api graphql -f query='
  mutation {
    addBlockedBy(input: { issueId: "'"$BLOCKED_ID"'", blockingIssueId: "'"$BLOCKING_ID"'" }) {
      issue { title } blockingIssue { title }
    }
  }
'

# Remove blocker
gh api graphql -f query='
  mutation {
    removeBlockedBy(input: { issueId: "'"$BLOCKED_ID"'", blockingIssueId: "'"$BLOCKING_ID"'" }) {
      issue { title } blockingIssue { title }
    }
  }
'
```

Visible in the "Relationships" sidebar on each issue.

### Project Field Mutations

Update project board fields (status, priority, custom fields) via GraphQL.

```bash
# Get item ID from project
ITEM_ID=$(gh api graphql -f query='
  query {
    node(id: "PROJECT_ID") {
      ... on ProjectV2 {
        items(first: 100) {
          nodes { id content { ... on Issue { number } } }
        }
      }
    }
  }
' --jq '.data.node.items.nodes[] | select(.content.number == 42) | .id')

# Update a single-select field (e.g. Status, Priority)
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PROJECT_ID"
      itemId: "'"$ITEM_ID"'"
      fieldId: "FIELD_ID"
      value: { singleSelectOptionId: "OPTION_ID" }
    }) { projectV2Item { id } }
  }
'
```

## Template Formatting

```bash
# Table output with color and time
gh pr list --json number,title,headRefName,updatedAt --template \
  '{{range .}}{{tablerow (printf "#%v" .number | autocolor "green") .title .headRefName (timeago .updatedAt)}}{{end}}'

# Hyperlinks in terminal
gh issue list --json title,url --template \
  '{{range .}}{{hyperlink .url .title}}{{"\n"}}{{end}}'
```
