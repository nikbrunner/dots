# Claude Code Config Restructure: Skills & Hooks Over CLAUDE.md Bloat

**Date**: 2026-02-25
**Status**: Approved
**Approach**: Incremental Migration (Approach A)

## Motivation

The global CLAUDE.md (276 lines) wastes instruction budget on domain-specific context that's irrelevant to most sessions. Rules like "don't use `any`" are suggestions, not guarantees. Slash commands in `.claude/commands/` work but lack skill features (auto-invocation, supporting files, tool restrictions).

Inspired by:

- [Claude Code Hooks: Enforce the Right CLI](https://www.aihero.dev/how-to-use-claude-code-hooks-to-enforce-the-right-cli)
- [Never Run Claude Init](https://www.aihero.dev/never-run-claude-init)

## Goals

1. Lean CLAUDE.md (~60 lines) with only always-on personality/communication rules
2. Enforcement hooks for deterministic rules
3. Domain knowledge as auto-discoverable skills (`user-invocable: false`)
4. Slash commands upgraded to skill format
5. Migration meta-skill for converting other projects
6. Everything managed through dots symlink system

## Phase 1: Rewrite CLAUDE.md

Trim from 276 to ~60 lines. Keep only what must be always-on.

**Stays:**

- Communication style + Blind Spot Rule (renamed from "Spinach Rule", condensed to ~30 lines)
- Identity: 3 lines (Nik, Bavaria, self-taught dev, dry humor, values authenticity)
- Core dev principles: 5 lines (clean code, typesafety, no temporal coupling, standard APIs)
- Workflow basics: 5 lines (research first, ask before creating files, semantic commits)
- Task management: 3 lines

**Moves to skills:**

- MCP usage guide -> `mcp-guide` skill
- Personal context deep dive + projects -> `about-nik` skill
- Professional background -> `about-nik` skill
- React patterns -> `react-patterns` skill
- Obsidian/notes integration -> `obsidian-guide` skill

**Cut entirely:**

- DCD commands and references (no longer employed there)
- BAI workflow details (covered by bai-\* skills)
- Tools & Environment section (Claude detects from environment)
- Technologies & Learning section (discoverable from codebase)
- Product Philosophy section (fold one line into about-nik)

## Phase 2: Enforcement Hooks

Scripts in `common/.claude/hooks/enforce/`, registered in `settings.json`.

### semantic-commits.sh (PreToolUse on Bash)

Block `git commit` commands where the message doesn't start with a semantic prefix (`feat:|fix:|refactor:|chore:|docs:|style:|test:|ci:|perf:`). Exit 2 with guidance.

### warn-any-type.sh (PostToolUse on Write/Edit)

Warn (not block) when `: any` or `as any` appears in written/edited TypeScript files. Feedback message reminds to use proper types or `unknown`.

**Not hooks (stay as CLAUDE.md instructions):**

- "Research before implementation" — behavioral, not enforceable
- "Ask before creating files" — handled by permission settings
- "Prefer editing over creating" — judgment call

**Not hooks (handled by settings):**

- Co-author in commits — `"includeCoAuthoredBy": false` in settings.json
- Claude Code references in commits — same setting covers this

## Phase 3: Knowledge Skills

Auto-discoverable skills that load when Claude detects relevance.

### about-nik (user-invocable: false)

- Personality: reflective, dry humor, values authenticity, goes deep not wide, cares about craft
- Partner Ana (Romanian, in Germany ~20 years)
- Professional: self-taught (2019-2020), 5+ years frontend experience, previously at DealerCenter Digital (2020-2025), currently job hunting
- Tech experience: React, TypeScript, Electron, GraphQL, Tailwind, TanStack ecosystem, ShadCN
- Projects: Black Atom Industries (theme ecosystem), nbr.haus (portfolio), Sonder (anonymous storytelling platform, domain: sonder.house), bm (Go CLI), koyo (keyboard config)
- Interests: jazz/electronic music, vinyl, sci-fi writing, bouldering, pizza making
- Working style: systematic documenter, prefers understanding why, strong opinions held loosely
- Learning gaps: databases, authentication, Docker

### react-patterns (user-invocable: false)

- Dumb functional components + smart containers/partials
- Component CSS isolation (never reference another component's classes)
- Avoid `any` — use `unknown` as last resort
- Object arguments for functions
- Clear variable/function names, remove unused code
- Explicit and implicit types where each makes sense

### mcp-guide (user-invocable: false)

- Ref MCP: documentation lookups (bubbletea, lipgloss, Go stdlib, etc.)
- EXA MCP: web searches for examples, patterns, solutions
- Chrome MCP: browser testing (opening URLs, HTML verification)
- Linear MCP: Black Atom issue tracking (use bai-\* skills)
- Don't skip these — check docs before implementing

### obsidian-guide (user-invocable: false)

- Daily notes: `02 - Areas/Log/YYYY/MM-MonthName/YYYY.MM.DD - DayName.md`
- Look for `CLAUDE.md` in notes repo first
- Conversation history: `03 - Resources/AI/Claude Conversation History.md`
- Projects context: `01 - Projects/`
- Only access when explicitly asked or when conversation is about tasks/planning
- NOT automatically at session start

## Phase 4: Slash Commands -> Skills

17 commands (DCD removed) migrate to skill format. All get `disable-model-invocation: true`.

| Old path                              | New skill name            |
| ------------------------------------- | ------------------------- |
| `commands/bai/status.md`              | `bai-status`              |
| `commands/bai/ready.md`               | `bai-ready`               |
| `commands/bai/create.md`              | `bai-create`              |
| `commands/bai/update.md`              | `bai-update`              |
| `commands/bai/close.md`               | `bai-close`               |
| `commands/bai/review.md`              | `bai-review`              |
| `commands/dots/add.md`                | `dots-add`                |
| `commands/dots/remove.md`             | `dots-remove`             |
| `commands/dots/git-status-cleanup.md` | `dots-git-status-cleanup` |
| `commands/dots/deps-manage.md`        | `dots-deps-manage`        |
| `commands/user/bugs.md`               | `bugs`                    |
| `commands/user/arch-review.md`        | `arch-review`             |
| `commands/user/are-we-done.md`        | `are-we-done`             |
| `commands/user/docs.md`               | `docs`                    |
| `commands/user/gh-pr-review.md`       | `gh-pr-review`            |
| `commands/user/research.md`           | `research`                |
| `commands/user/ui-review.md`          | `ui-review`               |

Migration format: preserve existing content, wrap in SKILL.md frontmatter, move existing frontmatter fields (description, allowed-tools, argument-hint) to YAML block.

## Phase 5: Migration Meta-Skill

Skill: `migrate-to-skills` (`disable-model-invocation: true`)

Workflow:

1. Scan project for `.claude/commands/`, `.claude/agents/`, `CLAUDE.md`, `AGENTS.md`
2. Categorize each item: -> skill, -> hook, -> keep in CLAUDE.md, -> cut
3. Present conversion plan for approval
4. Execute only after confirmation

## Phase 6: Symlinks

### symlinks.yml changes

**Remove:**

- `common/.claude/commands: ~/.claude/commands`
- `common/.claude/agents: ~/.claude/agents`

**Add:**

- `common/.claude/skills: ~/.claude/skills`
- `"common/.claude/hooks/enforce/*": ~/.claude/hooks/enforce`

**Keep:**

- `common/.claude/CLAUDE.md: ~/.claude/CLAUDE.md`
- `common/.claude/settings.json: ~/.claude/settings.json`
- `common/.claude/hooks/peon-ping/config.json: ~/.claude/hooks/peon-ping/config.json`

### Final structure

```
common/.claude/
├── CLAUDE.md                              # Lean (~60 lines)
├── settings.json                          # Hooks config + permissions
├── hooks/
│   ├── peon-ping/                         # Existing
│   └── enforce/
│       ├── semantic-commits.sh
│       └── warn-any-type.sh
└── skills/
    ├── about-nik/SKILL.md
    ├── react-patterns/SKILL.md
    ├── mcp-guide/SKILL.md
    ├── obsidian-guide/SKILL.md
    ├── bai-status/SKILL.md
    ├── bai-ready/SKILL.md
    ├── bai-create/SKILL.md
    ├── bai-update/SKILL.md
    ├── bai-close/SKILL.md
    ├── bai-review/SKILL.md
    ├── dots-add/SKILL.md
    ├── dots-remove/SKILL.md
    ├── dots-git-status-cleanup/SKILL.md
    ├── dots-deps-manage/SKILL.md
    ├── bugs/SKILL.md
    ├── arch-review/SKILL.md
    ├── are-we-done/SKILL.md
    ├── docs/SKILL.md
    ├── gh-pr-review/SKILL.md
    ├── research/SKILL.md
    ├── ui-review/SKILL.md
    └── migrate-to-skills/SKILL.md
```

## Implementation Order

1. Create `common/.claude/skills/` directory
2. Create `common/.claude/hooks/enforce/` directory
3. Write lean CLAUDE.md
4. Write 4 knowledge skills
5. Write 2 enforcement hooks + register in settings.json
6. Migrate 17 slash commands to skills
7. Write migration meta-skill
8. Update symlinks.yml (remove commands/agents, add skills/hooks)
9. Run `dots link`
10. Delete `common/.claude/commands/` directory
11. Verify everything works
