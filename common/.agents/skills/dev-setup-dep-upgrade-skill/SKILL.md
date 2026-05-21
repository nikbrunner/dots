---
name: dev-setup-dep-upgrade-skill
description: Use when setting up a dependency upgrade workflow for a project repo. Detects ecosystem, asks targeted questions, then generates a project-level dep-upgrades skill.
argument-hint: "(run in project root)"
metadata:
  argument-hint: "(run in project root)"
---

# Setup Dependency Upgrade Skill

Scaffold a project-specific `dep-upgrades` skill by detecting the ecosystem and asking a few targeted questions.

## Arguments

Unused. Run this in the project root directory. (`$ARGUMENTS` in Claude Code, or `/skill:dev-setup-dep-upgrade-skill` args in Pi — ignored.)

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

The generated skill template and ecosystem-specific values are in [references/generated-skill.md](references/generated-skill.md).
