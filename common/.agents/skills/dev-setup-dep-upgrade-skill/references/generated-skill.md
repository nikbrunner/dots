# Generated Skill Template

This is the template used by `dev-setup-dep-upgrade-skill` when generating a project-level `dep-upgrades` skill. `{{placeholders}}` are replaced with detected/confirmed values.

````markdown
---
name: dep-upgrades
description: Use when upgrading dependencies, reviewing Dependabot/Renovate PRs, or auditing outdated packages in this project.
metadata:
  argument-hint: "[package-name|all]"
---

# Dependency Upgrades

Upgrade dependencies with changelog review, verification, and safe commits.

## Arguments

The argument (`$ARGUMENTS` in Claude Code, or `/skill:dep-upgrades` args in Pi) — optional package name(s) to upgrade. Empty to review all outdated deps.

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

### 2. Strategy Selection

- **Batch low-risk, majors one-by-one** — patch+minor together, each major separately
- **All one-by-one** — safest, upgrade and verify each individually
- **All at once** — fast, single upgrade + verify pass

### 3. Per-Upgrade Checklist

Research changelog, check usage in project (`grep` for imports), upgrade, verify, report, commit:

```bash
{{upgrade_command}} {{package}}@latest
{{verify_command}}
git add -A
git commit -m "{{commit_prefix}} upgrade {{package}} from X to Y"
```

### 4. Summary

Upgraded list, deprecation warnings, new features, skipped deps.
````

## Ecosystem-Specific Values

### npm

| Placeholder | Value |
|---|---|
| `package_manager` | npm |
| `lock_file` | package-lock.json |
| `outdated_command` | `npm outdated` |
| `upgrade_command` | `npm install` |
| `commit_prefix` | `build(deps):` or `chore(deps):` |

### pnpm

| Placeholder | Value |
|---|---|
| `package_manager` | pnpm |
| `lock_file` | pnpm-lock.yaml |
| `outdated_command` | `pnpm outdated` |
| `upgrade_command` | `pnpm update` |
| `commit_prefix` | `build(deps):` or `chore(deps):` |

### Go

| Placeholder | Value |
|---|---|
| `package_manager` | Go modules |
| `lock_file` | go.sum |
| `outdated_command` | `go list -m -u all` |
| `upgrade_command` | `go get` |
| `commit_prefix` | `build(deps):` |

### Rust (Cargo)

| Placeholder | Value |
|---|---|
| `package_manager` | Cargo |
| `lock_file` | Cargo.lock |
| `outdated_command` | `cargo outdated` |
| `upgrade_command` | `cargo update -p` |
| `commit_prefix` | `build(deps):` |
