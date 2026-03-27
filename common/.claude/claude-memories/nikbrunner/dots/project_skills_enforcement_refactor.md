---
name: Skills enforcement refactor (2026-03-24)
description: Major refactor adopting superpowers enforcement patterns — meta-skill injection, skill consolidation. Merged to main. Peon-ping cleanup still pending.
type: project
---

On 2026-03-24, refactored the Claude Code skills/hooks architecture to improve reliability. Adopted enforcement patterns from obra/superpowers. **Merged to main** (branch `refactor/skills-enforcement` merged).

**Why:** Claude wasn't reliably following skills because enforcement was soft. Superpowers' reliability comes from SessionStart content injection, not hooks.

**How to apply:** The meta-enforcement skill at `skills/meta-enforcement/SKILL.md` is injected via `hooks/enforce/session-start.sh` on every SessionStart event. Contains the 1% rule, anti-rationalization table, priority chain, and skill type classification.

## What changed

- **Added**: `meta-enforcement/SKILL.md` + `session-start.sh` hook (SessionStart injection)
- **Removed**: peon-ping hooks from settings.json, `hooks/peon-ping/` dir, deps from Brewfile/arch.sh/symlinks.yml
- **Disabled**: `skills-check.sh` UserPromptSubmit hook (unwired, script kept as fallback)
- **Merged skills**: `are-we-done` → `dev:verification`, `dev:testing` → `dev:tdd`
- **Updated**: CLAUDE.md threshold to 1%, cross-references (10 files), `dev:start` pipeline
- **New namespace**: `meta:` for cross-cutting concerns

## Still incomplete (as of 2026-03-26)

- **4 peon-ping skill directories still exist** in `common/.claude/skills/` (peon-ping-config, peon-ping-log, peon-ping-toggle, peon-ping-use). Decision was to remove entirely, but directories weren't deleted yet.

## Key learnings

- Superpowers uses ZERO deterministic hooks for enforcement — all prompt-level via SessionStart
- Skill description budget: 59% used (9,468 / 16,000 chars)
- Only SKILL.md loads when invoked; supporting files load on-demand (progressive disclosure)
- `disable-model-invocation: true` + `user-invocable: false` = completely hidden skill
