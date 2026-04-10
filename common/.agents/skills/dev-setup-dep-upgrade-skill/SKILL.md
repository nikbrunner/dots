---
name: dev-setup-dep-upgrade-skill
description: Use when setting up a dependency upgrade workflow for a project repo. Detects ecosystem, asks targeted questions, then generates a project-level dep-upgrades skill.
argument-hint: (run in project root)
---

# Setup Dependency Upgrade Skill

Scaffold a project-specific `dep-upgrades` skill by detecting the ecosystem and asking a few targeted questions.

## Arguments

`$ARGUMENTS` — unused. Run this in the project root directory.

## Process

### 1. Detect Ecosystem

Automatically gather (no user input needed):

| Check                 | How                                                                                                            |
| --------------------- | -------------------------------------------------------------------------------------------------------------- |
| Package manager       | `package.json` → npm/pnpm/bun (check lock file), `go.mod` → Go, `Cargo.toml` → Rust, `pyproject.toml` → Python |
| Lock file             | `package-lock.json`, `pnpm-lock.yaml`, `bun.lockb`, `go.sum`, `Cargo.lock`                                     |
| Verification commands | Parse scripts from `package.json`, `Makefile`, `justfile`, etc. Look for: check, test, build, lint, typecheck  |
| Dependabot/Renovate   | `.github/dependabot.yml`, `renovate.json`, `.renovaterc`                                                       |
| Commit style          | `git log --oneline -20` — detect conventional commits pattern                                                  |
| CLAUDE.md             | Read for project-specific commands or verification instructions                                                |
| CI config             | `.github/workflows/`, `.gitlab-ci.yml` — extract test/check commands                                           |

### 2. Ask Questions (3 max)

Based on detection results, confirm or override:

**Q1: Verification command(s)**
Pre-fill with detected command(s). Example: "I detected `npm run check` — is this the right verification command, or should I use something else?"

**Q2: Additional verification**
"Any extra verification beyond the main check? (e.g., Storybook, E2E tests, visual regression)" — only ask if Storybook/Playwright/Cypress detected, otherwise skip.

**Q3: Commit style**
Pre-fill with detected style. "I see conventional commits (`feat:`, `fix:`, etc.) — should dependency upgrades use `build(deps):` or `chore(deps):`?" — only ask if conventional commits detected.

### 3. Generate Project Skill

Create `.claude/skills/dep-upgrades/SKILL.md` using the template below, filling in ecosystem-specific values.

After generating, show the user the key details:

- Package manager detected
- Verification command(s) configured
- Commit prefix configured

### 4. Commit

```bash
git add .claude/skills/dep-upgrades/SKILL.md
git commit -m "feat: add dep-upgrades project skill"
```

---

## Generated Skill Template

The template below uses `{{placeholders}}` — replace them with detected/confirmed values.

````markdown
---
name: dev-setup-dep-upgrade-skill
description: Use when upgrading dependencies, reviewing Dependabot/Renovate PRs, or auditing outdated packages in this project.
argument-hint: [package-name|all]
---

# Dependency Upgrades

Upgrade dependencies with changelog review, verification, and safe commits.

## Arguments

`$ARGUMENTS` — optional package name(s) to upgrade. Empty to review all outdated deps.

## Ecosystem

- **Package manager:** {{package_manager}}
- **Lock file:** {{lock_file}}
- **Outdated command:** `{{outdated_command}}`
- **Upgrade command:** `{{upgrade_command}}`
- **Verification:** `{{verify_command}}`
  {{#if extra_verify}}- **Extra verification:** `{{extra_verify}}`{{/if}}
- **Commit prefix:** `{{commit_prefix}}`
  {{#if dependabot}}- **Dependabot:** configured (check PRs with `gh pr list --author "app/dependabot"`){{/if}}

## Workflow

### 1. Survey

Run the outdated command and gather Dependabot PRs if applicable:

```bash
{{outdated_command}}
{{#if dependabot}}gh pr list --author "app/dependabot" --state open --json number,title,headRefName{{/if}}
```

Present a summary table to the user:

| Package | Current | Latest | Bump  | Source                          |
| ------- | ------- | ------ | ----- | ------------------------------- |
| example | 1.0.0   | 2.0.0  | major | npm outdated / Dependabot PR #N |

### 2. Strategy Selection

Ask the user which approach for this session:

- **Batch low-risk, majors one-by-one** — patch+minor together, each major separately
- **All one-by-one** — safest, upgrade and verify each individually
- **All at once** — fast, single upgrade + verify pass

### 3. Per-Upgrade Checklist

For each dependency (or batch):

#### 3a. Research changelog

Use Exa or WebSearch to find the release page / changelog. Summarize:

- **Breaking changes** that affect this project
- **Deprecations** to be aware of
- **New features** relevant to how we use this package

If it's a Dependabot PR, also read the PR description for release notes.

#### 3b. Check usage in project

Grep for imports and usage to understand blast radius:

```bash
# Adjust pattern for the package
grep -r "from ['\"]{{package}}['\"]" src/ --include="*.ts" --include="*.tsx"
grep -r "require(['\"]{{package}}['\"])" src/ --include="*.ts" --include="*.tsx"
```

Report: how many files import it, which areas of the codebase are affected.

#### 3c. Upgrade

```bash
{{upgrade_command}} {{package}}@latest
```

If this is a Dependabot PR, merge it instead:

```bash
gh pr merge <number> --squash
git pull
```

#### 3d. Verify

```bash
{{verify_command}}
```

{{#if extra_verify}}

```bash
{{extra_verify}}
```

{{/if}}

If verification fails:

1. Read the error carefully
2. Check the changelog for migration steps
3. Fix the issue
4. Re-verify

#### 3e. Report

Tell the user:

- What version changed (from → to)
- Any deprecation warnings in the output
- Any new features worth adopting
- Whether verification passed clean

#### 3f. Commit

```bash
git add -A
git commit -m "{{commit_prefix}} upgrade {{package}} from X to Y"
```

### 4. Summary

After all upgrades are complete, present:

- **Upgraded:** list with version changes
- **Deprecation warnings:** anything to address later
- **New features:** worth exploring in a future session
- **Skipped:** any deps not upgraded and why
````

---

## Ecosystem-Specific Values

### npm (package.json + package-lock.json)

| Placeholder        | Value                                       |
| ------------------ | ------------------------------------------- |
| `package_manager`  | npm                                         |
| `lock_file`        | package-lock.json                           |
| `outdated_command` | `npm outdated`                              |
| `upgrade_command`  | `npm install`                               |
| `commit_prefix`    | `build(deps):` or `chore(deps):` (ask user) |

### pnpm (package.json + pnpm-lock.yaml)

| Placeholder        | Value                            |
| ------------------ | -------------------------------- |
| `package_manager`  | pnpm                             |
| `lock_file`        | pnpm-lock.yaml                   |
| `outdated_command` | `pnpm outdated`                  |
| `upgrade_command`  | `pnpm update`                    |
| `commit_prefix`    | `build(deps):` or `chore(deps):` |

### Go (go.mod)

| Placeholder        | Value               |
| ------------------ | ------------------- |
| `package_manager`  | Go modules          |
| `lock_file`        | go.sum              |
| `outdated_command` | `go list -m -u all` |
| `upgrade_command`  | `go get`            |
| `commit_prefix`    | `build(deps):`      |

### Rust (Cargo.toml)

| Placeholder        | Value             |
| ------------------ | ----------------- |
| `package_manager`  | Cargo             |
| `lock_file`        | Cargo.lock        |
| `outdated_command` | `cargo outdated`  |
| `upgrade_command`  | `cargo update -p` |
| `commit_prefix`    | `build(deps):`    |
