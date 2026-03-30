---
name: Skills enforcement refactor (2026-03-24)
description: Major refactor adopting superpowers enforcement patterns — meta-skill injection, skill consolidation. Fully complete.
type: project
---

On 2026-03-24, refactored the Claude Code skills/hooks architecture to improve reliability. Adopted enforcement patterns from obra/superpowers. **Merged to main** (branch `refactor/skills-enforcement` merged). **Fully complete** as of 2026-03-26.

**Why:** Claude wasn't reliably following skills because enforcement was soft. Superpowers' reliability comes from SessionStart content injection, not hooks.

**How to apply:** The meta-enforcement skill at `skills/meta-enforcement/SKILL.md` is injected via `hooks/enforce/session-start.sh` on every SessionStart event. Contains the 1% rule, anti-rationalization table, priority chain, and skill type classification.

## What changed

- **Added**: `meta-enforcement/SKILL.md` + `session-start.sh` hook (SessionStart injection)
- **Removed**: peon-ping hooks, dirs, deps (fully cleaned up in ea9720c on 2026-03-26)
- **Disabled**: `skills-check.sh` UserPromptSubmit hook (unwired, script kept as fallback)
- **Merged skills**: `are-we-done` → `dev:verification`, `dev:testing` → `dev:tdd`
- **Updated**: CLAUDE.md threshold to 1%, cross-references (10 files), `dev:start` pipeline
- **New namespace**: `meta:` for cross-cutting concerns

## Key learnings

- Superpowers uses ZERO deterministic hooks for enforcement — all prompt-level via SessionStart
- Skill description budget: 59% used (9,468 / 16,000 chars)
- Only SKILL.md loads when invoked; supporting files load on-demand (progressive disclosure)
- `disable-model-invocation: true` + `user-invocable: false` = completely hidden skill
