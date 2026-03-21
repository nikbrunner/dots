# Claude Code Config Restructure — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure Claude Code configuration from bloated CLAUDE.md and slash commands to lean CLAUDE.md + skills + enforcement hooks.

**Architecture:** Incremental migration in 8 tasks. Each task produces a commit. The existing system keeps working until the final switchover (Task 7). All files live in `common/.claude/` and are symlinked via dots.

**Tech Stack:** Bash (hooks), Markdown/YAML (skills), YAML (symlinks.yml)

**Design doc:** `docs/plans/2026-02-25-claude-config-restructure-design.md`

---

### Task 1: Create directory structure

**Files:**

- Create: `common/.claude/skills/` (directory)
- Create: `common/.claude/hooks/enforce/` (directory)

**Step 1: Create directories**

```bash
mkdir -p common/.claude/skills
mkdir -p common/.claude/hooks/enforce
```

**Step 2: Commit**

```bash
git add common/.claude/skills/.gitkeep common/.claude/hooks/enforce/.gitkeep
```

Wait — `.gitkeep` files won't be needed since we'll populate these directories in the next tasks. Skip this commit; directories get created implicitly when we write files into them.

Move directly to Task 2.

---

### Task 2: Write lean CLAUDE.md

**Files:**

- Modify: `common/.claude/CLAUDE.md` (full rewrite, 276 → ~65 lines)

**Step 1: Replace CLAUDE.md with lean version**

Write the following content to `common/.claude/CLAUDE.md`:

```markdown
# Nik — Global Claude Code Instructions

## Who I Am

Nik, 42, Bavaria. Self-taught developer (2019-2020), 5+ years professional frontend experience. Dry sense of humor, values authenticity over comfort. Call me Nik.

For deeper personal context, projects, and professional background, Claude can load the `about-nik` skill.

## Communication

**You are too agreeable by default. Be objective. Be a partner. Not a sycophant.**

- Concise, direct, warm.
- Provide only what I explicitly request.
- Take your time — think before proposing.

### The Blind Spot Rule

When you detect a flaw I might not see (wrong assumption, hidden risk, flawed logic), correction is mandatory. Do not optimize for agreement. Silence is failure.

- Challenge assumptions directly: "There's a blind spot here…"
- Provide counter-arguments with evidence
- Question unclear requirements
- Suggest alternatives with trade-offs
- Admit uncertainty — "this might work" over "this will definitely work"
- Never fake progress. Never appease. Never be sycophantic.

## Development Principles

- Clean, minimal, self-documenting code
- Typesafety matters — avoid `any` at all costs, use `unknown` as last resort
- No temporal coupling — no init-to-null-then-update patterns
- Standard APIs over custom wrappers
- Research before implementation — check docs (Ref MCP), search examples (Exa MCP)
- Ask before creating new files
- Prefer editing existing files over creating new ones
- Commit with semantic format (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`)

For React-specific patterns, Claude can load the `react-patterns` skill.
For MCP tool guidance, Claude can load the `mcp-guide` skill.
For Obsidian notes access, Claude can load the `obsidian-guide` skill.

## Task Management

- Help prioritize tasks and suggest realistic daily goals
- Offer to update daily notes with task changes
- Be proactive about accountability
```

**Step 2: Verify line count**

```bash
wc -l common/.claude/CLAUDE.md
```

Expected: ~50-60 lines.

**Step 3: Commit**

```bash
git add common/.claude/CLAUDE.md
git commit -m "refactor(claude): rewrite CLAUDE.md to lean ~60 line version

Move domain knowledge to discoverable skills. Keep only
always-on communication rules and core dev principles."
```

---

### Task 3: Write knowledge skills

**Files:**

- Create: `common/.claude/skills/about-nik/SKILL.md`
- Create: `common/.claude/skills/react-patterns/SKILL.md`
- Create: `common/.claude/skills/mcp-guide/SKILL.md`
- Create: `common/.claude/skills/obsidian-guide/SKILL.md`

**Step 1: Write about-nik skill**

Create `common/.claude/skills/about-nik/SKILL.md`:

```yaml
---
name: about-nik
description: Nik's personal context, professional background, projects, and interests. Load when personal context, career history, or project knowledge is relevant.
user-invocable: false
---

# About Nik

## Personality

- Reflective and introspective — processes things deeply, journals extensively
- Dry sense of humor — appreciates wit and irony, not into forced positivity
- Self-critical but working on it — actively challenging that pattern
- Values authenticity — prefers uncomfortable truth over comfortable bullshit
- Goes deep, not wide — dives in thoroughly rather than staying surface level
- Cares about craft — whether code, audio equipment, or pizza dough
- Strong opinions held loosely when presented with good arguments

## Personal

- Lives in Bavaria with partner Ana (from Romania, in Germany ~20 years)
- Completed 2.5 years of behavioral therapy — values self-reflection and direct communication
- Currently job hunting

## Professional Background

- Self-taught developer (2019-2020)
- Worked at DealerCenter Digital (2020-2025) as Software Engineer until company lost its investor
  - BikeCenter: Electron + React + TypeScript + SCSS + Redux + TanStack Query
  - Greenfield storefront: Vendure backend, GraphQL, Tailwind, ShadCN, TanStack Start/Router/Form
  - Developed a custom Design System with SCSS
  - Migrated project from React Router 7 to TanStack Start
- Frontend-focused, limited backend experience (Node/Express)

## Tech Experience

React, TypeScript, Electron, GraphQL, Tailwind CSS, ShadCN, TanStack ecosystem (Start, Router, Query, Form), Redux, SCSS, Deno, Go (learning)

## Learning Gaps

Databases (never implemented), Authentication (never implemented), Docker (limited)

## Projects

- **Black Atom Industries** — Theme/colorscheme ecosystem
  - `core` — Theme generation system (Deno/TypeScript)
  - `nvim` — Neovim colorscheme
  - `ghostty` — Ghostty terminal theme
  - `tmux` — Tmux theme
  - `radar.nvim` — Neovim file picker plugin
- **nbr.haus** — Personal portfolio/CV site (TanStack Start, React). Domain: nbr.haus
- **Sonder** — Anonymous social storytelling platform (concept stage). Domain: sonder.house. Core idea: share stories anonymously, fostering meaningful interaction without judgment. Features include local filtering, topic rooms, AI-generated story prompts, collaborative storytelling.
- **bm** — Bookmark manager CLI (Go, Bubbletea TUI)
- **koyo** — Keyboard configuration
- **dots** — Dotfiles repo (symlink-based config management)

## Interests

- Music: jazz (ambient/ECM style), electronic music, vinyl collector, quality audio setup
- Writing: working on a science fiction novel
- Physical: bouldering, hiking
- Food: pizza making, Italian ingredients, cooking

## Working Style

- Systematic learner who documents patterns extensively (3000+ commits in Neovim config)
- Prefers understanding _why_ over just _how_
- Uses Obsidian for journaling and self-reflection
- Prefers simple, reliable technology — loves analog tech
- Values stability and clear product vision over constant reinvention
```

**Step 2: Write react-patterns skill**

Create `common/.claude/skills/react-patterns/SKILL.md`:

```yaml
---
name: react-patterns
description: Nik's React component patterns and TypeScript conventions. Load when working in React/TypeScript codebases.
user-invocable: false
---

# React Patterns

## Component Architecture

- **Dumb functional components** + **smart containers** + **partials**
- Components are independent — a component's CSS must never reference another component's classes
- If a component needs to know about another component, that's a code smell

## TypeScript Conventions

- Avoid `any` at all costs — use `unknown` as last resort
- Use explicit and implicit types where each makes sense — not absolutist
- Prefer object arguments for functions over positional parameters
- Use clear variable and function names
- Remove unused code as you go
- Values generics and proper type annotations

## Anti-Patterns

- **No temporal coupling** — never init to null/any and update later. Prefer clean initialization without circular dependencies. Order-of-operations dependencies are a maintenance nightmare.
```

**Step 3: Write mcp-guide skill**

Create `common/.claude/skills/mcp-guide/SKILL.md`:

```yaml
---
name: mcp-guide
description: Guide for using available MCP servers (Ref, Exa, Chrome, Linear). Load when deciding which tool to use for documentation, search, or browser testing.
user-invocable: false
---

# MCP Tool Guide

These MCPs are configured and should be used — do not skip them.

| MCP | When to Use |
|-----|------------|
| **Ref MCP** (`ref_search_documentation`, `ref_read_url`) | Documentation lookups for any library, framework, or API. Always check docs before implementing. |
| **EXA MCP** (`web_search_exa`, `get_code_context_exa`) | Web searches for examples, patterns, or solutions not found in docs. Use for real-world code examples. |
| **Chrome MCP** (`chrome-devtools__*`) | Browser testing — opening URLs, HTML export verification, visual checks. |
| **Linear MCP** (`linear__*`) | Black Atom Industries issue tracking. Use the `bai-*` skills (`/bai-status`, `/bai-create`, etc.) |

## Rules

- Check Ref MCP for documentation before writing code against an unfamiliar API
- Use Exa if unsure about idioms or need real-world examples
- Don't guess when you can look it up
```

**Step 4: Write obsidian-guide skill**

Create `common/.claude/skills/obsidian-guide/SKILL.md`:

```yaml
---
name: obsidian-guide
description: How to access and navigate Nik's Obsidian notes for task management, journaling, and project context. Load when notes, tasks, or daily planning come up.
user-invocable: false
---

# Obsidian Notes Guide

## When to Access

- When Nik explicitly asks to check daily tasks or todos
- When the conversation is about task management, planning, or productivity
- When Nik mentions projects and you need context from notes
- When Nik directly references notes or asks to look something up
- **NOT automatically at the start of every conversation**

## Note Structure

- **Daily notes**: `02 - Areas/Log/YYYY/MM-MonthName/YYYY.MM.DD - DayName.md`
- **Projects**: `01 - Projects/`
- **Conversation history**: `03 - Resources/AI/Claude Conversation History.md`

## Navigation

- Always look for `CLAUDE.md` in the notes repo first — it introduces the note structure
- If asked to save a conversation summary, add it with a dated headline to the conversation history file
- When saving summaries, also capture insights about preferences, knowledge gaps, or learning areas
```

**Step 5: Commit**

```bash
git add common/.claude/skills/about-nik/SKILL.md \
        common/.claude/skills/react-patterns/SKILL.md \
        common/.claude/skills/mcp-guide/SKILL.md \
        common/.claude/skills/obsidian-guide/SKILL.md
git commit -m "feat(claude): add knowledge skills for domain context

Add about-nik, react-patterns, mcp-guide, and obsidian-guide
as auto-discoverable skills (user-invocable: false). These load
on-demand instead of consuming always-on instruction budget."
```

---

### Task 4: Write enforcement hooks

**Files:**

- Create: `common/.claude/hooks/enforce/semantic-commits.sh`
- Create: `common/.claude/hooks/enforce/warn-any-type.sh`
- Modify: `common/.claude/settings.json` (add hook registrations)

**Step 1: Write semantic-commits.sh**

Create `common/.claude/hooks/enforce/semantic-commits.sh`:

```bash
#!/bin/bash
# PreToolUse hook: Block git commits without semantic prefixes.
# Receives JSON on stdin with tool_input.command.
# Exit 0 = allow, Exit 2 = block with feedback.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE '^git commit'; then
    exit 0
fi

# Extract the commit message from -m flag
# Handles: git commit -m "msg", git commit -m 'msg', git commit -m msg
MSG=$(echo "$COMMAND" | grep -oP '(-m\s+)(["'"'"'])(.*?)\2' | sed -E "s/-m\s+[\"']?//;s/[\"']?$//" || true)

# Also handle heredoc-style: git commit -m "$(cat <<'EOF'
if [ -z "$MSG" ]; then
    MSG=$(echo "$COMMAND" | grep -oP '(-m\s+)(.+)' | sed 's/-m\s*//' || true)
fi

# If we can't extract a message, allow it (might be interactive or amend)
if [ -z "$MSG" ]; then
    exit 0
fi

# Check for semantic prefix
if echo "$MSG" | grep -qE '^\s*(feat|fix|refactor|chore|docs|style|test|ci|perf)(\(.+\))?(!)?:'; then
    exit 0
fi

echo "BLOCKED: Commit message must start with a semantic prefix." >&2
echo "Valid prefixes: feat:, fix:, refactor:, chore:, docs:, style:, test:, ci:, perf:" >&2
echo "Example: feat(nvim): add telescope extension" >&2
echo "Your message was: $MSG" >&2
exit 2
```

**Step 2: Write warn-any-type.sh**

Create `common/.claude/hooks/enforce/warn-any-type.sh`:

```bash
#!/bin/bash
# PostToolUse hook: Warn when `: any` or `as any` appears in TypeScript files.
# This is a warning (exit 0), not a block — it provides feedback without stopping.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only check Write and Edit tools
if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check TypeScript files
if ! echo "$FILE_PATH" | grep -qE '\.(ts|tsx)$'; then
    exit 0
fi

# Check the content that was written/edited
CONTENT=""
if [ "$TOOL_NAME" = "Write" ]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
elif [ "$TOOL_NAME" = "Edit" ]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
fi

if echo "$CONTENT" | grep -qE ':\s*any\b|as\s+any\b'; then
    echo "WARNING: TypeScript \`any\` type detected in $FILE_PATH." >&2
    echo "Prefer proper types or \`unknown\` as a last resort." >&2
fi

exit 0
```

**Step 3: Make hooks executable**

```bash
chmod +x common/.claude/hooks/enforce/semantic-commits.sh
chmod +x common/.claude/hooks/enforce/warn-any-type.sh
```

**Step 4: Register hooks in settings.json**

Add the following entries to the `hooks` object in `common/.claude/settings.json`:

In the existing `PreToolUse` array, add a new entry:

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "~/.claude/hooks/enforce/semantic-commits.sh"
    }
  ]
}
```

In the `hooks` object, add a new `PostToolUse` array:

```json
"PostToolUse": [
    {
        "matcher": "Write|Edit",
        "hooks": [
            {
                "type": "command",
                "command": "~/.claude/hooks/enforce/warn-any-type.sh"
            }
        ]
    }
]
```

**Step 5: Commit**

```bash
git add common/.claude/hooks/enforce/semantic-commits.sh \
        common/.claude/hooks/enforce/warn-any-type.sh \
        common/.claude/settings.json
git commit -m "feat(claude): add enforcement hooks for commits and type safety

Add PreToolUse hook blocking non-semantic commit messages.
Add PostToolUse hook warning on TypeScript any type usage."
```

---

### Task 5: Migrate slash commands to skills (batch 1 — bai)

**Files:**

- Create: `common/.claude/skills/bai-status/SKILL.md`
- Create: `common/.claude/skills/bai-ready/SKILL.md`
- Create: `common/.claude/skills/bai-create/SKILL.md`
- Create: `common/.claude/skills/bai-update/SKILL.md`
- Create: `common/.claude/skills/bai-close/SKILL.md`
- Create: `common/.claude/skills/bai-review/SKILL.md`

**Migration pattern for each:** Take existing command content, add `disable-model-invocation: true` to frontmatter, preserve all existing frontmatter fields (description, allowed-tools, argument-hint), wrap body as SKILL.md.

**Step 1: Create all 6 bai skills**

For each command file in `common/.claude/commands/bai/`:

1. Read the existing `.md` file
2. Create `common/.claude/skills/bai-<name>/SKILL.md`
3. Keep existing frontmatter fields, add `disable-model-invocation: true`
4. Keep body content unchanged

Example transformation for `bai/status.md` → `bai-status/SKILL.md`:

```yaml
---
name: bai-status
description: Show my Black Atom Industries issues
disable-model-invocation: true
allowed-tools: ["mcp__linear__list_issues", "mcp__linear__get_issue"]
---
# Black Atom Status
[... rest of content unchanged ...]
```

Apply this pattern to all 6 bai commands.

**Step 2: Commit**

```bash
git add common/.claude/skills/bai-*/SKILL.md
git commit -m "feat(claude): migrate bai slash commands to skills

Convert 6 bai/ commands to skill format with
disable-model-invocation: true."
```

---

### Task 6: Migrate slash commands to skills (batch 2 — dots + user)

**Files:**

- Create: `common/.claude/skills/dots-add/SKILL.md`
- Create: `common/.claude/skills/dots-remove/SKILL.md`
- Create: `common/.claude/skills/dots-git-status-cleanup/SKILL.md`
- Create: `common/.claude/skills/dots-deps-manage/SKILL.md`
- Create: `common/.claude/skills/bugs/SKILL.md`
- Create: `common/.claude/skills/arch-review/SKILL.md`
- Create: `common/.claude/skills/are-we-done/SKILL.md`
- Create: `common/.claude/skills/docs/SKILL.md`
- Create: `common/.claude/skills/gh-pr-review/SKILL.md`
- Create: `common/.claude/skills/research/SKILL.md`
- Create: `common/.claude/skills/ui-review/SKILL.md`

**Step 1: Create all 11 skills**

Same migration pattern as Task 5. For each command:

1. Read existing `.md` file
2. Create `common/.claude/skills/<name>/SKILL.md`
3. Add `disable-model-invocation: true` to frontmatter
4. Preserve existing frontmatter fields
5. Keep body content unchanged

Commands without existing frontmatter (like `dots/add.md`, `dots/remove.md`) get minimal frontmatter:

```yaml
---
name: dots-add
description: Add a config file to dots for symlink management
disable-model-invocation: true
argument-hint: [path to config file]
---
```

**Step 2: Commit**

```bash
git add common/.claude/skills/dots-*/SKILL.md \
        common/.claude/skills/bugs/SKILL.md \
        common/.claude/skills/arch-review/SKILL.md \
        common/.claude/skills/are-we-done/SKILL.md \
        common/.claude/skills/docs/SKILL.md \
        common/.claude/skills/gh-pr-review/SKILL.md \
        common/.claude/skills/research/SKILL.md \
        common/.claude/skills/ui-review/SKILL.md
git commit -m "feat(claude): migrate dots and user slash commands to skills

Convert 11 remaining commands (4 dots, 7 user) to skill
format with disable-model-invocation: true."
```

---

### Task 7: Write migration meta-skill, update symlinks, switchover

**Files:**

- Create: `common/.claude/skills/migrate-to-skills/SKILL.md`
- Modify: `symlinks.yml`
- Delete: `common/.claude/commands/` (entire directory)

**Step 1: Write migrate-to-skills skill**

Create `common/.claude/skills/migrate-to-skills/SKILL.md`:

```yaml
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
```

**Step 2: Update symlinks.yml**

In `symlinks.yml`, under the `common:` section:

Remove these lines:

```yaml
common/.claude/agents: ~/.claude/agents
common/.claude/commands: ~/.claude/commands
```

Add these lines (after the existing `.claude/` entries):

```yaml
common/.claude/skills: ~/.claude/skills
"common/.claude/hooks/enforce/*": ~/.claude/hooks/enforce
```

**Step 3: Delete old commands directory**

```bash
rm -rf common/.claude/commands
```

**Step 4: Run dots link**

```bash
dots link
```

This will:

- Remove the `~/.claude/commands` symlink (source gone)
- Remove the `~/.claude/agents` symlink (removed from symlinks.yml)
- Create `~/.claude/skills` symlink → `common/.claude/skills`
- Create `~/.claude/hooks/enforce/*` symlinks

**Step 5: Commit**

```bash
git add common/.claude/skills/migrate-to-skills/SKILL.md \
        symlinks.yml
git rm -r common/.claude/commands
git commit -m "feat(claude): complete migration to skills, remove old commands

Add migrate-to-skills meta-skill for converting other projects.
Update symlinks.yml: remove commands/agents, add skills/hooks.
Delete common/.claude/commands/ directory."
```

---

### Task 8: Verify and clean up

**Step 1: Verify symlinks**

```bash
ls -la ~/.claude/skills/
ls -la ~/.claude/hooks/enforce/
ls -la ~/.claude/CLAUDE.md
cat ~/.claude/CLAUDE.md | wc -l
```

Expected:

- `~/.claude/skills/` → symlink to dots skills directory
- `~/.claude/hooks/enforce/` contains symlinked hook scripts
- `~/.claude/CLAUDE.md` still points to dots
- Line count ~50-65

**Step 2: Verify skills are discoverable**

Start a new Claude Code session and ask:

```
What skills are available?
```

Expected: all 22 skills should appear (4 knowledge + 17 action + 1 migration).

**Step 3: Test a hook**

In the new session, try a bad commit:

```
git commit -m "updated stuff"
```

Expected: blocked with semantic prefix guidance.

**Step 4: Test a knowledge skill**

Ask something that should trigger about-nik:

```
What projects am I working on?
```

Expected: Claude loads about-nik skill and mentions Black Atom, nbr.haus, Sonder, etc.

**Step 5: Commit any fixes**

If anything needed adjustment, commit with:

```bash
git commit -m "fix(claude): adjust [specific fix] after migration verification"
```
