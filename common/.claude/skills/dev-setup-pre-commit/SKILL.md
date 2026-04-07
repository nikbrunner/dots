---
name: dev:setup:pre-commit
description: Set up or migrate git pre-commit hooks using .githooks/ with native git core.hooksPath. Detects Node or Deno, handles fresh setup or migration from Husky/lefthook/pre-commit. Use when user wants to add, fix, or migrate pre-commit hooks.
---

# Setup Pre-Commit Hooks

Uses native git `core.hooksPath` — no Husky or wrapper deps.

## Step 0: Detect Existing Setup

Before doing anything, check if the project already has pre-commit hooks configured.

**Look for:**

| Signal                               | Tool                |
| ------------------------------------ | ------------------- |
| `.husky/` directory                  | Husky               |
| `lefthook.yml` or `.lefthook.yml`    | Lefthook            |
| `.pre-commit-config.yaml`            | pre-commit (Python) |
| `.git/hooks/pre-commit` (non-sample) | Manual git hooks    |
| `"husky"` in package.json deps       | Husky               |
| `"prepare": "husky"` in scripts      | Husky               |
| `"lint-staged"` in package.json      | lint-staged (keep)  |

**If an existing setup is found:**

1. **Inventory** what the current hooks do — list every command/check that runs
2. **Present findings** to the user: what tool is in use, what checks it runs, what config files exist
3. **Propose migration** — map each existing check to the `.githooks/` equivalent, flag anything that would be lost or changed
4. **Wait for user approval** before making changes
5. **Clean up** the old tool: remove config files, uninstall deps, remove `prepare` scripts that reference the old tool

**If no existing setup is found:** proceed to Step 1.

## Step 1: Detect Ecosystem

| Signal                      | Ecosystem                 |
| --------------------------- | ------------------------- |
| `deno.json` or `deno.jsonc` | Deno                      |
| `package.json` + lockfile   | Node                      |
| Both present                | Ask user which is primary |

## Step 2: Configure Hooks

### Deno Projects

No extra dependencies needed. Deno has everything built in.

**Create `.githooks/pre-commit`:**

```bash
#!/usr/bin/env sh
set -e

deno fmt --check
deno lint
deno check .
deno test
```

**Adapt**: If the project has no tests yet, omit `deno test` and tell the user. If `deno.json` has a `test` task, use `deno task test` instead.

**Add `install-hooks` task to deno.json:**

```json
{
  "tasks": {
    "install-hooks": "git config core.hooksPath .githooks && echo 'Hooks installed.'"
  }
}
```

> Deno has no `prepare` lifecycle hook like Node's `npm install`. An explicit task is the Deno equivalent — collaborators run `deno task install-hooks` after cloning.

### Node Projects

**Detect package manager**: Check for `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn), `bun.lockb` (bun). Default to npm if unclear.

**Install devDependencies:**

```
lint-staged prettier
```

**Create `.githooks/pre-commit`:**

```bash
#!/usr/bin/env sh
set -e

npx lint-staged
npm run typecheck
npm run test
```

**Adapt**: Replace `npm`/`npx` with detected package manager. If repo has no `typecheck` or `test` script in package.json, omit those lines and tell the user.

**Create `.lintstagedrc`:**

```json
{
  "*": "prettier --ignore-unknown --check"
}
```

> **Why `--check` instead of `--write`**: Using `--write` in a pre-commit hook silently reformats files, but the changes land in the working tree — not in the staged area. This causes phantom diffs after every commit. `--check` fails the commit instead, so the developer runs `prettier --write .` (or an npm script) explicitly, stages the result, and commits clean.

**Create `.prettierrc` (only if no Prettier config exists):**

```json
{
  "useTabs": false,
  "tabWidth": 2,
  "printWidth": 80,
  "singleQuote": false,
  "trailingComma": "es5",
  "semi": true,
  "arrowParens": "always"
}
```

**Add `prepare` script to package.json:**

```json
{
  "scripts": {
    "prepare": "git config core.hooksPath .githooks"
  }
}
```

## Step 3: Enable Hooks

```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

## Step 4: Verify

- [ ] `.githooks/pre-commit` exists and is executable
- [ ] `git config core.hooksPath` returns `.githooks`
- [ ] **Deno only**: `install-hooks` task exists in `deno.json`
- [ ] **Node only**: `.lintstagedrc` exists, Prettier config exists, `prepare` script set
- [ ] Run a dry-run of the hook: `./.githooks/pre-commit`

## Step 5: Commit

Stage all changed/created files and commit: `chore: add pre-commit hooks`

This runs through the new hooks — a good smoke test.

## Formatting Strategy: Check, Don't Write

Both ecosystems use **`--check` mode** in the hook — the hook **rejects** unformatted code rather than silently rewriting it.

Why: `--write` in a pre-commit hook modifies files in the working tree but not the staging area. This causes ghost diffs after every commit. With `--check`, the developer formats explicitly, stages the result, and commits clean.

**Convenience scripts to add to package.json / deno.json:**

- Node: `"format": "prettier --ignore-unknown --write ."` → run before committing
- Deno: `deno fmt` → already available, no config needed

## Notes

- `core.hooksPath` is git-native (git 2.9+), no wrapper needed
- Deno projects need zero extra deps — `deno fmt`/`lint`/`check`/`test` cover everything
- Node's `prepare` script ensures hooks are configured on `npm install` for collaborators
- `prettier --ignore-unknown` skips files Prettier can't parse (images, etc.)
- For non-JS/TS repos, skip lint-staged and write shell commands directly in the hook
