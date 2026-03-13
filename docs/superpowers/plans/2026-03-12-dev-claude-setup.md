# dev:claude-setup Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a skill that sets up and maintains Claude Code configuration for any project repo, replacing `migrate-to-skills`.

**Architecture:** Single SKILL.md file implementing a three-phase pipeline (Scan → Plan → Execute). The skill is a prompt/instruction set — no application code, no tests. All logic is expressed as instructions Claude follows at runtime.

**Tech Stack:** Markdown (SKILL.md frontmatter format)

---

## Chunk 1: Create the new skill

### Task 1: Write dev-claude-setup/SKILL.md

**Files:**
- Create: `common/.claude/skills/dev-claude-setup/SKILL.md`

**Reference:**
- Spec: `docs/superpowers/specs/2026-03-12-dev-claude-setup-design.md`
- Old skill (for content to subsume): `common/.claude/skills/migrate-to-skills/SKILL.md`

- [ ] **Step 1: Create skill directory**

```bash
mkdir -p common/.claude/skills/dev-claude-setup
```

- [ ] **Step 2: Write SKILL.md**

Write `common/.claude/skills/dev-claude-setup/SKILL.md` with:

**Frontmatter:**
```yaml
---
name: dev:claude-setup
description: Set up or maintain Claude Code configuration for a project repo — handles fresh, legacy, and modern setups
argument-hint: [optional: path to project root]
---
```

**Body structure — follow the spec precisely:**

1. Title and one-line description
2. `## Arguments` — `$ARGUMENTS` with default-to-cwd behavior
3. `## Phase 1: Scan` — Autonomous exploration instructions
   - Scan targets table (language/framework, existing .claude/, other AI config, project docs, CI/CD)
   - Classification output (Fresh / Legacy / Modern)
   - Instruction to present structured report before proceeding
4. `## Phase 2: Plan` — Plan generation per repo state
   - ### Fresh — scaffold CLAUDE.md, settings.json, suggest skills/hooks
   - ### Legacy — subsume ALL migrate-to-skills categorization logic (Skill/Hook/Keep/Cut) including the aggressive "discoverable from codebase" cut list and the decision test
   - ### Modern — audit for bloat, staleness, orphaned config
   - ### Plan format — table with source, action, target path, rationale
   - **Wait for user approval before proceeding**
5. `## Phase 3: Execute` — Execute approved plan
   - Actions table (Create/Migrate/Update/Delete/Symlink)
   - Symlink: CLAUDE.md is canonical, symlink to AGENTS.md if it exists
   - Guardrails (normal tool approval, git handles backups)
6. `## Verification` — checklist (list skills, check hooks executable, CLAUDE.md line count, suggest testing)
7. `## Conventions` — All baked-in conventions from spec
   - CLAUDE.md philosophy (max ~50 lines, decision test, symlink direction)
   - Skill conventions (namespace, invocability, frontmatter template)
   - Hook conventions (enforcement scripts, settings.json registration, executable)
   - What gets CUT (full aggressive list from spec)

Key content to carry forward from `migrate-to-skills`:
- The categorization table (→ Skill / → Hook / → Keep / → Cut)
- The "discoverable from codebase" examples list
- The decision test: "Would Claude make a costly mistake without this line?"
- Naming conventions section (`:` in names, `-` in dirs, namespace prefixes)
- The plan presentation format with table columns

- [ ] **Step 3: Review the written skill**

Read back the file and verify:
- Frontmatter is valid (name, description, argument-hint)
- All three phases are present and complete
- Legacy mode fully subsumes migrate-to-skills (no logic lost)
- Fresh mode has clear scaffolding instructions
- Modern mode has audit instructions
- Conventions section includes all baked-in rules from spec

### Task 2: Delete migrate-to-skills

**Files:**
- Delete: `common/.claude/skills/migrate-to-skills/SKILL.md`
- Delete: `common/.claude/skills/migrate-to-skills/` (directory)

- [ ] **Step 1: Remove the old skill directory**

```bash
rm -rf common/.claude/skills/migrate-to-skills
```

- [ ] **Step 2: Verify removal**

```bash
ls common/.claude/skills/migrate-to-skills 2>&1  # should show "No such file or directory"
```

### Task 3: Verify the new skill is discoverable

- [ ] **Step 1: List skills to confirm new skill appears**

```bash
ls -la common/.claude/skills/dev-claude-setup/SKILL.md
```

- [ ] **Step 2: Verify old skill is gone**

```bash
ls common/.claude/skills/ | grep migrate  # should return nothing
```

- [ ] **Step 3: Commit**

```bash
git add common/.claude/skills/dev-claude-setup/SKILL.md
git add -u common/.claude/skills/migrate-to-skills/
git commit -m "feat(skills): replace migrate-to-skills with dev:claude-setup

Broader skill that handles fresh repo setup, legacy migration, and
modern config auditing. Subsumes all migrate-to-skills functionality."
```
