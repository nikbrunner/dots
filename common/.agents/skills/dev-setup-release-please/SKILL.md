---
name: dev-setup-release-please
description: Set up release-please in any repo. Detects project type, creates config/workflow, enables GitHub Actions PR permissions.
user-invocable: true
arguments: "[version]"
---

# Set Up Release-Please

## Usage

```
/setup-release-please 0.1.0
```

The argument is the initial version number (e.g. `0.1.0`, `1.0.0`). If omitted, suggest a starting version based on project maturity (check git history, existing tags, README, etc.) and confirm with the user before proceeding.

## Steps

1. **Detect default branch** from git:

```bash
git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
```

2. **Detect project type** from repo contents:
   - `deno.json` → Deno project (release-type: simple, with extra-files for deno.json)
   - `go.mod` → Go project (release-type: go)
   - `package.json` → Node project (release-type: node)
   - `manifest.json` (Obsidian plugin) → Simple with manifest.json extra-file
   - Otherwise → Simple (no extra-files)

3. **Create `.github/release-please-config.json`**:

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {
      "release-type": "<detected-type>",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": false,
      "changelog-sections": [
        { "type": "feat", "section": "Features" },
        { "type": "refactor", "section": "Refactors" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "docs", "section": "Documentation" },
        { "type": "perf", "section": "Performance" }
      ],
      "extra-files": []
    }
  }
}
```

**Extra-files by project type:**

- Deno: `{ "type": "json", "path": "deno.json", "jsonpath": "$.version" }`
- Obsidian: `{ "type": "json", "path": "manifest.json", "jsonpath": "$.version" }`
- Go: none (native versioning)
- Node: none (native versioning)

4. **Create `.github/.release-please-manifest.json`**:

```json
{ ".": "<version>" }
```

5. **Create `.github/workflows/release.yml`** (use detected default branch):

```yaml
name: dev-setup-release-please
on:
  push:
    branches: [<default-branch>]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          config-file: .github/release-please-config.json
          manifest-file: .github/.release-please-manifest.json
```

6. **Enable GitHub Actions PR permissions** so release-please can create PRs:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api --method PUT "/repos/${REPO}/actions/permissions/workflow" \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=true
```

Confirm with the user before running this — it changes a repo-level setting.

7. **Check for old release workflows** in `.github/workflows/` and offer to remove them.

8. **Add a "Releases" section to the README** (if one exists) noting that the project uses [release-please](https://github.com/googleapis/release-please) for automated versioning and changelog generation via [Conventional Commits](https://www.conventionalcommits.org/).

9. **Commit** with message: `chore: add release-please configuration`

## Notes

- Config and manifest files go in `.github/`, NOT the repo root
- Do NOT add publish jobs unless explicitly requested
- The workflow YAML declares its own `permissions` block, so the repo default can stay restrictive (`read`)
- The API call in step 6 requires admin access to the repo
