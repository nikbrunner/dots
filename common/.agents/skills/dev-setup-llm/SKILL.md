---
name: dev-setup-llm
description: Set up or maintain LLM agent configuration for a project repo — handles fresh, legacy, and modern setups for any agent (Pi, Claude Code, etc.)
argument-hint: [optional: path to project root]
---

# LLM Agent Setup

Set up or maintain LLM agent configuration for any project repo. Tool-agnostic: covers the shared `AGENTS.md` + skills structure, with tool-specific guidance in `guides/pi.md` and `guides/claude-code.md`. Handles three states: fresh (no agent config), legacy (commands/agents), and modern (skills-based).

## Tool-Specific Guides

See guide files for tool-specific details:

- [Pi](guides/pi.md) — `AGENTS.md` location, extensions, `~/.pi/agent/` structure, `pi install`
- [Claude Code](guides/claude-code.md) — hooks, `settings.json`, plugins

## Arguments

`$ARGUMENTS` — Optional path to project root. Defaults to current working directory.

## Phase 1: Scan

Autonomous exploration — no user questions yet.

### Scan targets

| Target             | How                                                                        |
| ------------------ | -------------------------------------------------------------------------- |
| Language/framework | `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `Makefile`, etc. |
| Existing AI config | `AGENTS.md`, `CLAUDE.md`, `.pi/`, `.claude/`, `.cursorrules`, `GEMINI.md`  |
| Skills             | `.agents/skills/`, `.pi/skills/`, `.claude/skills/`                        |
| Project docs       | `README.md`, `docs/`, `CONTRIBUTING.md`                                    |
| CI/CD              | `.github/workflows/`, scripts for test/lint/build commands                 |

### Classification

Based on scan results, classify the repo:

| State      | Condition                                                     |
| ---------- | ------------------------------------------------------------- |
| **Fresh**  | No agent config (`AGENTS.md`, `.agents/`, `.pi/`, `.claude/`) |
| **Legacy** | Has `.claude/commands/` or `.claude/agents/` but no `skills/` |
| **Modern** | Has `.agents/skills/` or `.pi/skills/` or `.claude/skills/`   |

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

No existing agent config. Scaffold from scratch based on what the scan found.

| Item        | Description                                                                                                                                                                             |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md` | Lean project context derived from scanned README/docs/package.json. Max ~50 lines. Only include what the agent would get wrong without.                                                 |
| `skills/`   | Suggest skills based on detected stack and available global skills. E.g., TS project with tests may benefit from project-specific testing conventions. No fixed mapping — use judgment. |
| Enforcement | Suggest enforcement mechanisms based on ecosystem. See tool-specific guides for implementation details (Pi: extension; Claude Code: hooks).                                             |

### Legacy

Has commands/agents but no skills. Subsumes all migration logic from the old `migrate-to-skills` skill.

#### Categorize each item

For every discovered item (AGENTS.md/CLAUDE.md lines, commands, agents), classify it:

| Category              | Criteria                                                        | Action                                                                    |
| --------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Skill**             | Task instructions, domain knowledge, workflows                  | Convert to `.agents/skills/<name>/SKILL.md`                               |
| **Enforcement**       | Deterministic rules ("don't do X", "always use Y")              | Pi: extension event handler; Claude Code: bash script in `hooks/enforce/` |
| **Keep in AGENTS.md** | Always-on project context, communication style, core principles | Retain in lean AGENTS.md                                                  |
| **Cut**               | Redundant, outdated, discoverable from codebase                 | Remove entirely                                                           |

#### What gets CUT — be aggressive

"Discoverable from codebase" means CUT it. Common examples:

- Dev commands — discoverable from `package.json`, `Makefile`, `deno.json`, etc.
- Node/runtime version — `.nvmrc`, `.tool-versions`, `package.json#engines`
- Path aliases — `tsconfig.json#paths`, `vite.config.*`
- Auto-generated files — inferable from framework (e.g., TanStack Start generates route trees)
- Architecture details — if they exist in `docs/`, don't duplicate in CLAUDE.md
- Linting/formatting config — discoverable from config files
- Test setup — discoverable from test config and `package.json` scripts

**The decision test:** "Would the agent make a costly mistake without this line? If the answer is 'no, it would just need to read a file first,' cut it."

#### Skill classification

For each item categorized as a skill, also determine:

- `user-invocable: false` — contextual/knowledge skills the agent discovers automatically
- User-invocable (default, omit the key) — action skills with side effects or that users trigger manually

### Modern

Has skills already. Audit for improvements.

- **Bloat audit** — Flag anything in AGENTS.md that's discoverable from code. Apply the decision test.
- **Staleness check** — Skills that reference outdated APIs, removed files, or deprecated patterns.
- **Missing coverage** — Suggest new skills based on codebase evolution since last setup.
- **Orphaned config** — Skills with no matching codebase context, enforcement rules for removed tools.
- **Redundancy** — Skills that overlap significantly, AGENTS.md lines that duplicate skill content.

### Plan format

Present the plan as a table:

| Source                       | Action  | Target path                          | Rationale                                   |
| ---------------------------- | ------- | ------------------------------------ | ------------------------------------------- |
| `.claude/commands/review.md` | Migrate | `.agents/skills/dev-review/SKILL.md` | Workflow belongs in a skill                 |
| `AGENTS.md` lines 12-18      | Cut     | —                                    | Dev commands discoverable from package.json |
| (new)                        | Create  | enforcement logic                    | Enforce commit convention                   |

**Wait for user approval before proceeding to Phase 3.**

## Phase 3: Execute

Execute the approved plan. Each file write goes through normal tool approval — no silent changes.

### Actions

| Action  | What happens                                                                           |
| ------- | -------------------------------------------------------------------------------------- |
| Create  | Write `AGENTS.md`, skill files, enforcement logic from scratch                         |
| Migrate | Convert command/agent to skill format; port enforcement rules to appropriate mechanism |
| Update  | Edit existing files to trim bloat, update content, fix staleness                       |
| Delete  | Remove old `commands/`, `agents/` dirs after migration is verified                     |

### Execution steps

1. Create `.agents/skills/` directory and write `SKILL.md` files
2. Write or rewrite `AGENTS.md` (lean version, ~50 lines max)
3. Set up enforcement (see `guides/pi.md` or `guides/claude-code.md`)
4. Remove old files (commands/, agents/) only after verifying new config works

### Guardrails

- No backup logic needed — git handles this
- Each file operation goes through normal tool approval
- Deletions happen last, after new config is verified

## Verification

After execution, run this checklist:

- `ls -la .agents/skills/*/SKILL.md` — list all skills created
- `wc -l AGENTS.md` — confirm lean line count (~50 lines for project-level)
- Test a skill invocation (e.g., `/skill:name` in Claude Code, or let Pi auto-discover)
- Verify enforcement is active (see tool-specific guides for how to test)

## Conventions

All conventions baked into this skill's decisions.

### AGENTS.md philosophy

- `AGENTS.md` is the canonical source of truth — tool-specific config files (`CLAUDE.md`, etc.) symlink to it
- Max ~50 lines for project-level files; global `~/.agents/AGENTS.md` can be longer
- Only content the agent would get wrong without — nothing discoverable from codebase
- **Decision test:** "Would the agent make a costly mistake without this line? If no, cut it."
- No workflows, no task instructions, no domain deep-dives — those belong in skills

### Skill conventions

- Directory names use `-` (hyphen), e.g., `dev-testing/`
- Common namespace prefixes: `bai-`, `dots-`, `dev-`, `penny-`
- No prefix for general-purpose skills (e.g., `research`, `bugs`)
- `user-invocable: false` for context/knowledge skills — omit entirely for action skills (defaults to true)
- Include `description` and `argument-hint` in frontmatter
- Skills live in `.agents/skills/` (shared across all tools)

**Skill frontmatter template:**

```yaml
---
name: dev-setup-llm
description: One-line description used for discovery
argument-hint: [optional: what arguments look like]
user-invocable: false # only for knowledge skills; omit for action skills
---
```

### Enforcement conventions

- Deterministic rules ("always X", "never Y") belong in enforcement, not AGENTS.md
- See `guides/pi.md` for Pi extension events; see `guides/claude-code.md` for Claude Code hooks

### What gets CUT — full list

- Dev commands discoverable from `package.json`, `Makefile`, `deno.json`, etc.
- Node/runtime version from `.nvmrc`, `.tool-versions`, `package.json#engines`
- Path aliases from `tsconfig.json#paths`, `vite.config.*`
- Auto-generated files inferable from framework
- Architecture already documented in `docs/`
- Linting/formatting config discoverable from config files
- Test setup discoverable from test config and scripts
- Any line that fails the decision test

## Cross-References

- `dev-setup-project` — may invoke this skill as Phase 6 of project bootstrapping
