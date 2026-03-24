---
name: meta:enforcement
description: Core enforcement skill — injected at session start via hook. Not for direct invocation.
disable-model-invocation: true
user-invocable: false
---

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.

If you think there is even a 1% chance a skill might apply, you ABSOLUTELY MUST invoke the skill using the Skill tool BEFORE any response, any action, any clarifying question.

User instructions say WHAT, not HOW. "Add X" or "Fix Y" does not mean skip workflows. Check for skills FIRST.

## Priority Chain

1. **User's explicit instructions** (CLAUDE.md, direct requests) — highest priority
2. **Skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md contradicts a skill, follow CLAUDE.md. The user is in control.

## Anti-Rationalization

These thoughts mean STOP — you are rationalizing skipping a skill check:

| Thought                              | Reality                                                                        |
| ------------------------------------ | ------------------------------------------------------------------------------ |
| "This is simple enough"              | Simple tasks have skills too. Check.                                           |
| "I already know how"                 | Skills contain project-specific overrides you don't have memorized. Invoke it. |
| "Let me explore first"               | Skills tell you HOW to explore. Check first.                                   |
| "I need more context"                | Skill check comes BEFORE clarifying questions. Always.                         |
| "The skill is overkill"              | Simple things become complex. Use it.                                          |
| "I'll just do this one thing first"  | Check BEFORE doing anything. No exceptions.                                    |
| "I remember this skill"              | Skills evolve. Read the current version via the Skill tool.                    |
| "This doesn't need a formal process" | If a skill exists for it, use it. Period.                                      |
| "Let me look at the code quickly"    | Files lack conversation context. Check for skills.                             |
| "This feels productive"              | Undisciplined action wastes time. Skills prevent this.                         |
| "This is just a discussion"          | Questions about features, bugs, or architecture ARE development tasks. Check.  |

## Skill Types

**Rigid** (TDD, commit format, verification): Follow exactly. Do not adapt away discipline.

**Flexible** (React patterns, styling, architecture): Adapt principles to context. The spirit matters more than the letter.

The skill itself tells you which type it is. When unclear, treat as rigid.

## Skill Priority

When multiple skills apply:

1. **Process skills first** (brainstorm, start, planning, debugging) — these determine HOW to approach the task
2. **Domain skills second** (react, typescript, tanstack) — these guide execution
3. **Workflow skills third** (commit, verification, close) — these govern shipping

## Subagent Exemption

If you were dispatched as a subagent to execute a specific, scoped task — skip this enforcement. Subagents follow their prompt, not the full skill ceremony.
