# dev:claude-setup — Design Spec

## Overview

A skill that sets up and maintains Claude Code configuration for any project repo. Replaces `migrate-to-skills` by handling three repo states: fresh (no `.claude/`), legacy (commands/agents pattern), and modern (skills/hooks pattern).

**Skill identity:**

- Name: `dev:claude-setup`
- Directory: `dev-claude-setup/SKILL.md`
- Location: `common/.claude/skills/dev-claude-setup/` (global, available in all projects)
- User-invocable: yes — `/dev-claude-setup [path]`
- Argument: optional path to project root (defaults to cwd)
- Replaces: `migrate-to-skills` (deleted after this ships)

## Arguments

`$ARGUMENTS` — Optional path to project root. Defaults to current working directory.

## Architecture: Phased Pipeline

Three phases run in order. Each adapts to what it finds.

### Phase 1: Scan

Autonomous exploration — no user questions yet.

**Scan targets:**

| Target | How |
|-|-|
| Language/framework | `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `Makefile`, etc. |
| Existing `.claude/` | `CLAUDE.md`, `settings.json`, `skills/`, `hooks/`, `commands/`, `agents/` |
| Other AI config | `.cursorrules`, `.github/copilot-instructions.md`, `AGENTS.md`, `GEMINI.md` |
| Project docs | `README.md`, `docs/`, `CONTRIBUTING.md` |
| CI/CD | `.github/workflows/`, scripts for test/lint/build commands |

**Output:** Structured status report classifying the repo as:

- **Fresh** — No `.claude/` directory
- **Legacy** — Has `.claude/commands/` or `.claude/agents/` but no skills
- **Modern** — Has `.claude/skills/` — audit for improvements

Report lists everything found before any plan is generated.

### Phase 2: Plan

Generate a plan tailored to repo state. Present as a table. Wait for user approval before executing.

#### Fresh repo plan

| Item | Description |
|-|-|
| `CLAUDE.md` | Lean project context derived from scanned README/docs/package.json. Max ~50 lines. |
| `settings.json` | Base structure with `allowedTools`, `hooks` keys. Reference the dots repo's `settings.json` as template for hook registration format. |
| `skills/` | Use judgment based on detected stack and available global skills. E.g., TS project → suggest TypeScript/testing conventions; React → component patterns. No fixed mapping — adapt to what's found. |
| `hooks/enforce/` | Suggest enforcement hooks based on ecosystem. |

#### Legacy repo plan

Subsumes all `migrate-to-skills` logic:

- Categorize each item as: Skill / Hook / Keep in CLAUDE.md / Cut
- Apply "discoverable from codebase" rule aggressively
- Map old commands to new skill names with namespace conventions

#### Modern repo plan

- Audit CLAUDE.md for bloat — flag anything discoverable from code
- Check skills for staleness or missing patterns
- Suggest new skills/hooks based on codebase evolution
- Flag orphaned or redundant config

#### Plan format

Table with columns: source, action (create/migrate/update/delete), target path, rationale.

### Phase 3: Execute

After user approval, execute the plan.

**Actions:**

| Action | What happens |
|-|-|
| Create | Write `CLAUDE.md`, `settings.json`, skill/hook files |
| Migrate | Convert command to skill, register hook, update settings.json |
| Update | Edit existing files to trim bloat or update content |
| Delete | Remove old `commands/`, `agents/` dirs after migration |
| Symlink | If `AGENTS.md` exists, symlink `CLAUDE.md → AGENTS.md` (CLAUDE.md is canonical) |

**Guardrails:**

- Each file write goes through normal tool approval — no silent changes
- No backup logic needed (git handles this)
- Verification runs after execution

**Verification checklist:**

- `ls -la .claude/skills/*/SKILL.md`
- `ls -la .claude/hooks/enforce/`
- `wc -l .claude/CLAUDE.md` (or root `CLAUDE.md` depending on project structure)
- Suggest testing a skill invocation

## Baked-in Conventions

### CLAUDE.md

- Max ~50 lines for most projects
- Only content Claude would get wrong without — nothing discoverable from codebase
- **Decision test:** "Would Claude make a costly mistake without this line? If no, cut it."
- If `AGENTS.md` exists, symlink `CLAUDE.md → AGENTS.md` (CLAUDE.md is canonical for Claude Code)

### Skills

- Namespace with `:` in name field, `-` in directory names
- `user-invocable: false` for context/knowledge skills
- User-invocable for action skills with side effects
- Include `description` and `argument-hint` in frontmatter

**Skill template:**

```markdown
---
name: namespace:skill-name
description: One-line description used for discovery
argument-hint: [optional: what arguments look like]
user-invocable: false  # set to false for knowledge-only skills; omit entirely for action skills (defaults to true)
---

# Skill Title

## Arguments

`$ARGUMENTS` — Description of expected input.

## Process

1. Step one
2. Step two
```

### Hooks

- Deterministic rules ("always X", "never Y") become bash scripts in `hooks/enforce/`
- Registered in `settings.json`
- Must be executable

### What gets CUT

- Dev commands discoverable from `package.json`, `Makefile`, `deno.json`, etc.
- Node/runtime version from `.nvmrc`, `.tool-versions`, `package.json#engines`
- Path aliases from `tsconfig.json#paths`, `vite.config.*`
- Auto-generated files inferable from framework
- Architecture already documented in `docs/`
- Linting/formatting config discoverable from config files
- Test setup discoverable from test config and scripts

## Future Direction

- Vendor-agnostic support (Cursor, Copilot, Gemini) — not in v1 scope
