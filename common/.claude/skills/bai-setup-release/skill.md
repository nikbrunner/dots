---
name: bai-setup-release
description: Set up release-please in a Black Atom Industries repo. Accepts initial version as argument.
user-invocable: true
arguments: "[version]"
---

# Set Up Release-Please for a BAI Repo

## Usage

```
/bai-setup-release 0.1.0
```

The argument is the initial version number (e.g. `0.1.0`, `1.0.0`). Defaults to `0.1.0` if omitted.

## Steps

1. **Detect project type** from repo contents:
   - `deno.json` → Deno project (update version in deno.json via extra-files)
   - `go.mod` → Go project (release-type: go)
   - `package.json` → Node project (release-type: node)
   - `manifest.json` (Obsidian) → Simple with manifest.json extra-file
   - Otherwise → Simple (no extra-files)

2. **Create `.github/release-please-config.json`**:

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

3. **Create `.github/.release-please-manifest.json`**:

```json
{ ".": "<version>" }
```

4. **Create `.github/workflows/release.yml`**:

```yaml
name: Release
on:
    push:
        branches: [main]

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

5. **Check for old release workflows** in `.github/workflows/` and offer to remove them.

6. **Commit** with message: `chore: add release-please configuration`

## Notes

- The default branch is `main` across all BAI repos
- Do NOT add publish jobs unless explicitly requested — most adapters don't need them
- Only `core` and `ai` repos have post-release publish steps (JSR publishing)
- Config and manifest files go in `.github/`, NOT the repo root
