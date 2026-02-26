---
name: migrate-to-skills
description: Audit a project's Claude Code setup and plan migration from commands/agents to skills/hooks
argument-hint: [optional: path to project root]
---

# Migrate to Skills

Audit a project's Claude Code configuration and generate a migration plan.

## Arguments

`$ARGUMENTS` — Optional path to project root. Defaults to current working directory.

## Goals

The migration targets these outcomes:

1. **Lean AGENTS.md** — Only essential project-level context needed on every interaction. No workflows, no task instructions, no domain deep-dives. Think 3-50 lines depending on project complexity. CLAUDE.md symlinks to AGENTS.md for Claude Code compatibility.
2. **No commands/ directory** — All `.claude/commands/` slash commands are converted to `.claude/skills/` format.
3. **Enforcement via hooks** — Deterministic rules ("always X", "never Y") become bash scripts in `.claude/hooks/enforce/`, not CLAUDE.md instructions.
4. **Domain knowledge as discoverable skills** — Context that Claude needs occasionally (architecture, workflows, project-specific knowledge) becomes `user-invocable: false` skills that Claude discovers automatically.
5. **Clean skill namespace** — Skills use `:` namespace prefixes in names and `-` in directory names. Only action skills with side effects stay user-invocable.

## Process

### 1. Scan for existing configuration

Search the project for:
- `.claude/commands/` — slash commands to convert to skills
- `.claude/agents/` or `AGENTS.md` — agent definitions to evaluate
- `CLAUDE.md` — instructions to categorize
- `.claude/settings.json` — existing hooks and permissions

Report what was found with file counts and sizes.

### 2. Categorize each item

For each discovered item, classify it:

| Category | Criteria | Action |
|----------|----------|--------|
| **→ Skill** | Task instructions, domain knowledge, workflows | Convert to `.claude/skills/<name>/SKILL.md` |
| **→ Hook** | Deterministic enforcement ("don't do X", "always use Y") | Create bash script in `.claude/hooks/enforce/` |
| **→ Keep in AGENTS.md** | Always-on project context, communication style, core principles | Leave in AGENTS.md |
| **→ Cut** | Redundant, outdated, discoverable from codebase | Remove |

For skills, additionally determine:
- `user-invocable: false` — contextual skills Claude discovers and invokes automatically
- Keep user-invocable (default) — action skills with side effects or that users trigger manually

### 3. Naming conventions

**Namespace separator**: Use `:` in the `name` field for grouped skills.
**Directory names**: Use `-` (hyphen) as separator since `:` is not valid in filenames.

Examples:
- Directory: `bai-status/SKILL.md` → Frontmatter: `name: bai:status`
- Directory: `dots-add/SKILL.md` → Frontmatter: `name: dots:add`
- Directory: `research/SKILL.md` → Frontmatter: `name: research` (no namespace needed)

Common namespace prefixes:
- `bai:` — Black Atom Industries issue tracking
- `dots:` — Dotfiles management
- No prefix — general-purpose skills (bugs, research, arch-review, etc.)

### 4. Present the plan

Show the categorized plan as a table. Include:
- Source file path
- Category (skill/hook/keep/cut)
- New skill name (with `:` namespace if applicable)
- New directory path (with `-` separator)
- Frontmatter flags (`user-invocable: false`, `allowed-tools`, etc.)

**Wait for user approval before proceeding.**

### 5. Execute the migration

Only after approval:
1. Create skill directories and SKILL.md files
2. Create hook scripts and register in settings.json
3. Rewrite AGENTS.md (lean version)
4. Update symlinks if applicable
5. Remove old command/agent files
6. Symlink AGENTS.md to CLAUDE.md so claude can discover it

### 6. Verify

- List all new skills: `ls -la .claude/skills/*/SKILL.md`
- Check hooks are executable: `ls -la .claude/hooks/enforce/`
- Verify AGENTS.md line count: `wc -l AGENTS.md`
- Test a skill invocation: suggest user try `/skill-name`
