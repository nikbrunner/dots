# Dots Project Memory

## Claude Code Config Architecture (2026-02-25)

Restructured from bloated CLAUDE.md + slash commands to skills + hooks.

### Structure

```
common/.claude/
├── CLAUDE.md              # Lean (47 lines) — communication, blind spot rule, dev principles
├── settings.json          # Hooks config, permissions, plugins
├── agents/                # Superpowers plugin agents (12 files, leave alone)
├── hooks/
│   ├── peon-ping/         # Sound notifications
│   └── enforce/           # Deterministic enforcement
│       ├── semantic-commits.sh   # PreToolUse: blocks non-semantic commits
│       └── warn-any-type.sh      # PostToolUse: warns on `: any` in TypeScript
└── skills/
    ├── about-nik/         # Knowledge (user-invocable: false)
    ├── react-patterns/    # Knowledge (user-invocable: false)
    ├── mcp-guide/         # Knowledge (user-invocable: false)
    ├── obsidian-guide/    # Knowledge (user-invocable: false)
    ├── bai-*/             # 6 Linear skills (user-invocable: false, Claude discovers)
    ├── dots-*/            # 4 dotfiles skills (user-invocable, /dots:add etc.)
    ├── bugs/              # Bug hunting (user-invocable: false)
    ├── arch-review/       # Architecture review (user-invocable: false)
    ├── are-we-done/       # Structural completeness (user-invocable, /are-we-done)
    ├── docs/              # Documentation workflow (user-invocable, /docs)
    ├── gh-pr-review/      # PR review (user-invocable, /gh-pr-review)
    ├── research/          # Research (user-invocable: false, Claude discovers)
    ├── ui-review/         # UI/UX review (user-invocable: false)
    └── migrate-to-skills/ # Meta-skill (user-invocable, /migrate-to-skills)
```

### Naming Conventions

- **Namespace separator**: `:` in `name` field (e.g., `bai:status`, `dots:add`)
- **Directory names**: `-` hyphen (e.g., `bai-status/`, `dots-add/`)
- **No prefix**: general-purpose skills (bugs, research, arch-review)

### Invocability Rules

- **User-invocable (shows in / menu)**: dots:*, gh-pr-review, docs, are-we-done, migrate-to-skills
- **Claude-only (user-invocable: false)**: bai:*, bugs, arch-review, ui-review, research, plus all 4 knowledge skills
- **All skills are discoverable** by Claude (no disable-model-invocation anywhere)

### Key Decisions

- **"Spinach Rule" → "Blind Spot Rule"** — Nik hated the spinach terminology
- **DCD commands removed** — Nik no longer at DealerCenter Digital (lost investor, 2025)
- **Sonder** — future project, anonymous storytelling platform, domain: sonder.house
- **Agents directory stays** — superpowers plugin manages it, symlinked from dots
- **Colon namespace works** in skill name fields despite docs saying "hyphens only"

### Symlinks (symlinks.yml)

- `common/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `common/.claude/agents` → `~/.claude/agents`
- `common/.claude/settings.json` → `~/.claude/settings.json`
- `common/.claude/skills` → `~/.claude/skills`
- `common/.claude/hooks/peon-ping/config.json` → peon-ping config
- `"common/.claude/hooks/enforce/*"` → `~/.claude/hooks/enforce`
