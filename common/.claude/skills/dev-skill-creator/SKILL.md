---
name: dev:skill-creator
description: "Template and checklist for creating new dev-* concept skills. Load when creating a new dev skill."
user-invocable: false
---

# Dev Skill Creator

Template for creating dev-* concept skills consistently. Not for process/review skills (dev:bugs, dev:arch-review, dev:ui-review) — those follow different patterns.

**IMPORTANT**:

- Before creating a new skill, use the Ref MCP, Exa MCP, and agent-browser CLI to research the topic and about its key principles and anti-patterns.
- Also keep track which breaking changes are either happend or are planned. A project could use an older version of a tool.
- Also check if there is overlapping topics with other `dev-*` skills and if cross-references, or even a restructure is needed.

## SKILL.md Template

See `template.md` for the canonical SKILL.md structure with placeholders.

## Supporting Files

| Condition | Action |
|-|-|
| Sub-topic exceeds ~50 lines | Separate `.md` file |
| Distinct concept with its own examples | Separate `.md` file |
| Everything fits in SKILL.md | Keep inline |

**File conventions:**
- Descriptive names: `query-patterns.md`, `url-state-patterns.md`, `alternatives.md`
- For dedicated code example files, use the `*-examples.md` suffix
- No frontmatter — start with `# Title`
- Real-world code examples preferred over pseudocode

## Conventions

| Aspect | Convention |
|-|-|
| Directory | `dev-topic-name/` (hyphen-separated) |
| Skill name | `dev:topic-name` (colon namespace) |
| TanStack skills | `dev-tanstack-*` dir, `dev:tanstack-*` name |
| Description | Starts with "Nik's [topic]", ends with "Load when [trigger]." |
| Cross-refs | Backtick-quoted inline: `` `dev:react` `` |
| Tables | Minimal separators (`\|-\|-\|`) |
| Code examples | Real-world > pseudocode, one good example > many mediocre |

## After Creation

1. Add cross-references from related existing skills back to the new one
2. Update `common/.claude/README.md` if the skill was tracked in TODOs
3. Commit: `feat(skills): add dev:topic-name skill`
