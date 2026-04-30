---
name: dev-setup-skill
description: "Template and checklist for creating new dev-* concept skills. Load when creating a new dev skill."
user-invocable: false
metadata:
  user-invocable: false
---

# Dev Skill Creator

Template for creating dev-\* concept skills consistently. Not for process/review skills (dev:audit) — those follow different patterns.

**IMPORTANT**:

- Before creating a new skill, use the Ref MCP, Exa MCP, and agent-browser CLI to research the topic and about its key principles and anti-patterns.
- Also keep track which breaking changes are either happend or are planned. A project could use an older version of a tool.
- Also check if there is overlapping topics with other `dev-*` skills and if cross-references, or even a restructure is needed.

## SKILL.md Template

See `template.md` for the canonical SKILL.md structure with placeholders.

## Supporting Files

| Condition                              | Action              |
| -------------------------------------- | ------------------- |
| Sub-topic exceeds ~50 lines            | Separate `.md` file |
| Distinct concept with its own examples | Separate `.md` file |
| Everything fits in SKILL.md            | Keep inline         |

**File conventions:**

- Descriptive names: `query-patterns.md`, `url-state-patterns.md`, `alternatives.md`
- For dedicated code example files, use the `*-examples.md` suffix
- No frontmatter — start with `# Title`
- Real-world code examples preferred over pseudocode

## Conventions

| Aspect          | Convention                                                 |
| --------------- | ---------------------------------------------------------- |
| Directory       | `dev-topic-name/` (hyphen-separated)                       |
| Skill name      | `dev:topic-name` (colon namespace)                         |
| TanStack skills | `dev-tanstack-*` dir, `dev:tanstack-*` name                |
| Description     | Starts with "My [topic]", ends with "Load when [trigger]." |
| Cross-refs      | Backtick-quoted inline: `` `dev:react` ``                  |
| Tables          | Minimal separators (`\|-\|-\|`)                            |
| Code examples   | Real-world > pseudocode, one good example > many mediocre  |

## Description Requirements

The description is the ONLY thing the agent sees when deciding which skill to load. Max 1024 characters.

- First sentence: what the skill does.
- Second sentence: "Load when [specific triggers]."
- Write in first person ("My React patterns..." not "Your React patterns...").
- Include concrete trigger words the agent will match against (e.g., "component", "hook", "React" not just "frontend").

## When to Add Scripts

Add utility scripts (`*.sh`, `*.ts`) to a skill directory when:

- The operation is deterministic (same input always produces same output)
- The same code would be generated repeatedly across invocations
- Errors need explicit handling that's easy to get wrong inline

Scripts save tokens vs. regenerating code each time. Name them descriptively: `validate-config.sh`, `scaffold-test.sh`.

## Review Checklist

After drafting a new skill, verify:

- [ ] Description includes trigger words for when to load
- [ ] SKILL.md is under 100 lines
- [ ] No time-sensitive info (versions, dates) that will go stale
- [ ] Terminology is consistent with other `dev-*` skills
- [ ] Concrete examples, not abstract principles
- [ ] Cross-references go one level deep (don't chain A -> B -> C)

## After Creation

1. Add cross-references from related existing skills back to the new one
2. Update `common/.claude/README.md` if the skill was tracked in TODOs
3. Commit: `feat(skills): add dev:topic-name skill`
