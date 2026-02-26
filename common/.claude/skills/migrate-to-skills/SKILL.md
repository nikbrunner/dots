---
name: migrate-to-skills
description: Audit a project's Claude Code setup and plan migration from commands/agents to skills/hooks
disable-model-invocation: true
argument-hint: [optional: path to project root]
---

# Migrate to Skills

Audit a project's Claude Code configuration and generate a migration plan.

## Arguments

`$ARGUMENTS` — Optional path to project root. Defaults to current working directory.

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
| **→ Keep in CLAUDE.md** | Always-on personality, communication style, core principles | Leave in CLAUDE.md |
| **→ Cut** | Redundant, outdated, discoverable from codebase | Remove |

For skills, additionally determine:
- `disable-model-invocation: true` — action skills the user triggers manually
- `user-invocable: false` — background knowledge Claude loads automatically

### 3. Present the plan

Show the categorized plan as a table. Include:
- Source file path
- Category (skill/hook/keep/cut)
- New destination path (if applicable)
- Frontmatter flags

**Wait for user approval before proceeding.**

### 4. Execute the migration

Only after approval:
1. Create skill directories and SKILL.md files
2. Create hook scripts and register in settings.json
3. Rewrite CLAUDE.md (lean version)
4. Update symlinks if applicable
5. Remove old command/agent files

### 5. Verify

- List all new skills: `ls -la .claude/skills/*/SKILL.md`
- Check hooks are executable: `ls -la .claude/hooks/enforce/`
- Verify CLAUDE.md line count: `wc -l .claude/CLAUDE.md`
- Test a skill invocation: suggest user try `/skill-name`
