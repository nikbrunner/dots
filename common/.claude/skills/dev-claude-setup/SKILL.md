---
name: dev:claude-setup
description: Set up or maintain Claude Code configuration for a project repo — handles fresh, legacy, and modern setups
argument-hint: [optional: path to project root]
---

# Claude Code Setup

Set up or maintain Claude Code configuration for any project repo. Handles three states: fresh (no `.claude/`), legacy (commands/agents), and modern (skills/hooks).

## Arguments

`$ARGUMENTS` — Optional path to project root. Defaults to current working directory.

## Phase 1: Scan

Autonomous exploration — no user questions yet.

### Scan targets

| Target | How |
|-|-|
| Language/framework | `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `Makefile`, etc. |
| Existing `.claude/` | `CLAUDE.md`, `settings.json`, `skills/`, `hooks/`, `commands/`, `agents/` |
| Other AI config | `.cursorrules`, `.github/copilot-instructions.md`, `AGENTS.md`, `GEMINI.md` |
| Project docs | `README.md`, `docs/`, `CONTRIBUTING.md` |
| CI/CD | `.github/workflows/`, scripts for test/lint/build commands |

### Classification

Based on scan results, classify the repo:

| State | Condition |
|-|-|
| **Fresh** | No `.claude/` directory |
| **Legacy** | Has `.claude/commands/` or `.claude/agents/` but no `skills/` |
| **Modern** | Has `.claude/skills/` |

### Report

Present a structured report before proceeding:

- State classification (Fresh / Legacy / Modern)
- Language, framework, and tooling detected
- Existing AI configuration found (with file counts and sizes)
- Project documentation found
- CI/CD and dev scripts found

Do not propose any changes yet — just report what exists.

## Phase 2: Plan

Generate a plan tailored to the repo state. Present for user approval before executing.

### Fresh

No existing Claude Code config. Scaffold from scratch based on what the scan found.

| Item | Description |
|-|-|
| `CLAUDE.md` | Lean project context derived from scanned README/docs/package.json. Max ~50 lines. Only include what Claude would get wrong without. |
| `settings.json` | Base structure with `allowedTools`, `hooks` keys. |
| `skills/` | Suggest skills based on detected stack and available global skills. E.g., TS project with tests may benefit from project-specific testing conventions. No fixed mapping — use judgment. |
| `hooks/enforce/` | Suggest enforcement hooks based on ecosystem (e.g., semantic commits, type safety). |

### Legacy

Has commands/agents but no skills. Subsumes all migration logic from the old `migrate-to-skills` skill.

#### Categorize each item

For every discovered item (CLAUDE.md lines, commands, agents), classify it:

| Category | Criteria | Action |
|-|-|-|
| **Skill** | Task instructions, domain knowledge, workflows | Convert to `.claude/skills/<name>/SKILL.md` |
| **Hook** | Deterministic enforcement ("don't do X", "always use Y") | Create bash script in `.claude/hooks/enforce/`, register in `settings.json` |
| **Keep in CLAUDE.md** | Always-on project context, communication style, core principles | Retain in lean CLAUDE.md |
| **Cut** | Redundant, outdated, discoverable from codebase | Remove entirely |

#### What gets CUT — be aggressive

"Discoverable from codebase" means CUT it. Common examples:

- Dev commands — discoverable from `package.json`, `Makefile`, `deno.json`, etc.
- Node/runtime version — `.nvmrc`, `.tool-versions`, `package.json#engines`
- Path aliases — `tsconfig.json#paths`, `vite.config.*`
- Auto-generated files — inferable from framework (e.g., TanStack Start generates route trees)
- Architecture details — if they exist in `docs/`, don't duplicate in CLAUDE.md
- Linting/formatting config — discoverable from config files
- Test setup — discoverable from test config and `package.json` scripts

**The decision test:** "Would Claude make a costly mistake without this line? If the answer is 'no, it would just need to read a file first,' cut it."

#### Skill classification

For each item categorized as a skill, also determine:

- `user-invocable: false` — contextual/knowledge skills Claude discovers and invokes automatically
- User-invocable (default, omit the key) — action skills with side effects or that users trigger manually

### Modern

Has skills/hooks already. Audit for improvements.

- **Bloat audit** — Flag anything in CLAUDE.md that's discoverable from code. Apply the decision test.
- **Staleness check** — Skills that reference outdated APIs, removed files, or deprecated patterns.
- **Missing coverage** — Suggest new skills/hooks based on codebase evolution since last setup.
- **Orphaned config** — Skills with no matching codebase context, hooks that enforce rules for removed tools.
- **Redundancy** — Skills that overlap significantly, CLAUDE.md lines that duplicate skill content.

### Plan format

Present the plan as a table:

| Source | Action | Target path | Rationale |
|-|-|-|-|
| `.claude/commands/review.md` | Migrate | `.claude/skills/dev-review/SKILL.md` | Workflow belongs in a skill |
| `CLAUDE.md` lines 12-18 | Cut | — | Dev commands discoverable from package.json |
| (new) | Create | `.claude/hooks/enforce/semantic-commits.sh` | Enforce commit convention |

**Wait for user approval before proceeding to Phase 3.**

## Phase 3: Execute

Execute the approved plan. Each file write goes through normal tool approval — no silent changes.

### Actions

| Action | What happens |
|-|-|
| Create | Write `CLAUDE.md`, `settings.json`, skill/hook files from scratch |
| Migrate | Convert command/agent to skill format, register hooks in `settings.json` |
| Update | Edit existing files to trim bloat, update content, fix staleness |
| Delete | Remove old `commands/`, `agents/` dirs after migration is verified |
| Symlink | If `AGENTS.md` exists, symlink `CLAUDE.md` to `AGENTS.md` (CLAUDE.md is canonical for Claude Code) |

### Execution steps

1. Create skill directories and write `SKILL.md` files
2. Create hook scripts, make them executable (`chmod +x`)
3. Register hooks in `settings.json`
4. Write or rewrite `CLAUDE.md` (lean version, ~50 lines max)
5. Set up symlinks (CLAUDE.md is canonical; symlink to AGENTS.md if it exists)
6. Update or create `settings.json` with hook registrations and permissions
7. Remove old files (commands/, agents/) only after verifying new config works

### Guardrails

- No backup logic needed — git handles this
- Each file operation goes through normal tool approval
- Deletions happen last, after new config is verified

## Verification

After execution, run this checklist:

- `ls -la .claude/skills/*/SKILL.md` — list all skills created
- `ls -la .claude/hooks/enforce/` — check hooks exist and are executable
- `wc -l .claude/CLAUDE.md` (or root `CLAUDE.md`) — confirm lean line count
- Verify `settings.json` has hook registrations for all enforce scripts
- Suggest user test a skill invocation (e.g., `/skill-name`)

## Conventions

All conventions baked into this skill's decisions.

### CLAUDE.md philosophy

- Max ~50 lines for most projects
- Only content Claude would get wrong without — nothing discoverable from codebase
- **Decision test:** "Would Claude make a costly mistake without this line? If no, cut it."
- `CLAUDE.md` is canonical for Claude Code. If `AGENTS.md` exists, symlink `CLAUDE.md` to it.
- No workflows, no task instructions, no domain deep-dives — those belong in skills

### Skill conventions

- Namespace with `:` in the `name` field (e.g., `dev:testing`, `bai:status`)
- Directory names use `-` (hyphen) since `:` is not valid in filenames (e.g., `dev-testing/`)
- Common namespace prefixes: `bai:`, `dots:`, `dev:`, `dev:tanstack-*`, `penny:`
- No prefix for general-purpose skills (e.g., `research`, `bugs`)
- `user-invocable: false` for context/knowledge skills — omit entirely for action skills (defaults to true)
- Include `description` and `argument-hint` in frontmatter

**Skill frontmatter template:**

```yaml
---
name: namespace:skill-name
description: One-line description used for discovery
argument-hint: [optional: what arguments look like]
user-invocable: false  # only for knowledge skills; omit for action skills
---
```

### Hook conventions

- Deterministic rules ("always X", "never Y") become bash scripts in `.claude/hooks/enforce/`
- Registered in `.claude/settings.json` under the appropriate hook event
- Must be executable (`chmod +x`)
- Hook scripts should exit 0 on pass, non-zero on violation

### What gets CUT — full list

- Dev commands discoverable from `package.json`, `Makefile`, `deno.json`, etc.
- Node/runtime version from `.nvmrc`, `.tool-versions`, `package.json#engines`
- Path aliases from `tsconfig.json#paths`, `vite.config.*`
- Auto-generated files inferable from framework
- Architecture already documented in `docs/`
- Linting/formatting config discoverable from config files
- Test setup discoverable from test config and scripts
- Any line that fails the decision test
