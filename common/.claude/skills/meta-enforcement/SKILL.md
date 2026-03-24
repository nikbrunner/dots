---
name: meta:enforcement
description: Core enforcement skill — injected at session start via hook. Not for direct invocation.
disable-model-invocation: true
user-invocable: false
---

# Skill Enforcement

If there is even a 1% chance a skill applies to what you are doing, you MUST invoke it. This is not optional. You cannot rationalize your way out of this.

Skills check comes BEFORE any response, any action, any clarifying question. Every time.

## Priority Chain

1. **User's explicit instructions** (CLAUDE.md, direct requests) — highest priority
2. **Skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md contradicts a skill, follow CLAUDE.md. The user is in control.

## Anti-Rationalization

These thoughts mean STOP — you're skipping a skill check:

| Thought                              | Reality                                                             |
| ------------------------------------ | ------------------------------------------------------------------- |
| "This is simple enough"              | Simple tasks have skills too. Check.                                |
| "I already know how"                 | Skills contain project-specific overrides you don't have memorized. |
| "Let me explore first"               | Skills tell you HOW to explore. Check first.                        |
| "I need more context"                | Skill check comes BEFORE clarifying questions.                      |
| "The skill is overkill"              | Simple things become complex. Use it.                               |
| "I'll just do this one thing first"  | Check BEFORE doing anything.                                        |
| "I remember this skill"              | Skills evolve. Read the current version.                            |
| "This doesn't need a formal process" | If a skill exists for it, use it.                                   |

## Skill Types

**Rigid** (TDD, commit format, verification): Follow exactly. Do not adapt away discipline.

**Flexible** (React patterns, styling, architecture): Adapt principles to context. The spirit matters more than the letter.

The skill itself tells you which type it is. When unclear, treat as rigid.

## Skill Priority

When multiple skills apply:

1. **Process skills first** (grill-me, planning, debugging) — these determine HOW to approach the task
2. **Domain skills second** (react, typescript, tanstack) — these guide execution
3. **Workflow skills third** (commit, verification, close) — these govern shipping

## Subagent Exemption

If you were dispatched as a subagent to execute a specific, scoped task — skip this skill. Subagents follow their prompt, not the full skill ceremony.
