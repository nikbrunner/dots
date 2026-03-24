---
name: Skills enforcement refactor (2026-03-24)
description: Major refactor adopting superpowers enforcement patterns — meta-skill injection, skill consolidation, pipeline wiring. PR #6.
type: project
---

On 2026-03-24, refactored the Claude Code skills/hooks architecture to improve reliability. Adopted enforcement patterns from obra/superpowers and design principles from mattpocock/skills while maintaining full ownership.

**Why:** Claude wasn't reliably following skills because enforcement was soft (text reminder via UserPromptSubmit hook). Superpowers' reliability comes from SessionStart content injection, not hooks.

**How to apply:** The meta-enforcement skill at `skills/meta-enforcement/SKILL.md` is injected via `hooks/enforce/session-start.sh` on every SessionStart event (startup, resume, clear, compact). It contains the 1% rule, anti-rationalization table, priority chain, and skill type classification.

## What changed

- **Added**: `meta-enforcement/SKILL.md` + `session-start.sh` hook (SessionStart injection)
- **Removed**: peon-ping hooks from settings.json, `hooks/peon-ping/` dir, deps from Brewfile/arch.sh/symlinks.yml
- **Disabled**: `skills-check.sh` UserPromptSubmit hook (unwired from settings.json, script file kept as fallback)
- **Merged**: `are-we-done` → `dev:verification` (structural review absorbed), `dev:testing` → `dev:tdd` (red-green-refactor internalized, testing layers moved to reference file)
- **Updated**: CLAUDE.md threshold from 0.01% to 1%, all cross-references (10 files), `dev:start` pipeline to include grill-me for small/medium scopes
- **New namespace**: `meta:` for cross-cutting meta-level concerns

## Incomplete cleanup (needs next session)

- **4 peon-ping skill directories still exist** in `common/.claude/skills/` (peon-ping-config, peon-ping-log, peon-ping-toggle, peon-ping-use). The PRD assumed these were plugin-provided, but they're repo-owned. Need to delete them and commit.
- **PR #6** (`refactor/skills-enforcement`) is open — merge after testing enforcement in a fresh session.

## Key learnings

- Superpowers uses ZERO deterministic hooks for enforcement — all prompt-level via SessionStart injection
- Skill description budget: 59% used (9,468 / 16,000 chars) — not a constraint
- Only SKILL.md loads when invoked; supporting files load on-demand via relative links (progressive disclosure)
- `disable-model-invocation: true` + `user-invocable: false` = completely hidden skill (only hook-injected)

## Plans location

PRD and plan at `docs/plans/prd-skills-enforcement-refactor.md` and `docs/plans/plan-skills-enforcement-refactor.md`.
