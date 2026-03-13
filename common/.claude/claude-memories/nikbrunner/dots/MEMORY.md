# Dots Project Memory

## Claude Code Config Architecture (2026-03-08)

Restructured from bloated CLAUDE.md + slash commands to skills + hooks.

### Structure

```
common/.claude/
├── CLAUDE.md              # Lean (~28 lines) — communication, blind spot rule, no skill refs
├── settings.json          # Hooks config, permissions, plugins
├── agents/                # 12 custom agent files (added 2026-01-12, NOT from a plugin — needs overhaul)
├── hooks/
│   ├── peon-ping/         # Sound notifications
│   └── enforce/           # Deterministic enforcement
│       ├── semantic-commits.sh   # PreToolUse: blocks non-semantic commits
│       └── warn-any-type.sh      # PostToolUse: warns on `: any` in TypeScript
└── skills/
    ├── README.md              # TODOs and status tracking for skills work
    ├── about-*/               # 8 knowledge skills (about:nik, about:bai, about:awdcs, etc.)
    ├── dev-*/                 # 8 dev skills (react, typescript, tanstack-query, testing, planning, bugs, arch-review, ui-review)
    ├── bai-*/                 # 8 BAI workflow skills (bai:status, bai:commit, etc.)
    ├── dots-*/                # 4 dotfiles skills (dots:add, dots:remove, etc.)
    ├── penny-*/               # 5 penny skills + penny base
    ├── browser-automation/    # agent-browser CLI usage
    └── (others)               # are-we-done, docs, gh-pr-review, migrate-to-skills, research, mcp-guide, obsidian-guide, setup-dep-upgrade-skill
```

### Naming Conventions

- **Namespace separator**: `:` in `name` field (e.g., `about:nik`, `bai:status`, `dev:react`)
- **Directory names**: `-` hyphen (e.g., `about-nik/`, `bai-status/`, `dev-react/`)
- **All namespaced prefixes**: `about:`, `bai:`, `dev:`, `dev-tanstack-`, `dots:`, `penny:`
- **TanStack skills**: use `dev-tanstack-*` directory, `dev:tanstack-*` name (avoids ts ambiguity)

### Key Decisions

- **"Spinach Rule" → "Blind Spot Rule"** — Nik hated the spinach terminology
- **Sonder** — future project, anonymous storytelling platform, domain: sonder.house
- **Agents directory** — manually added 2026-01-12 (not plugin-managed), needs overhaul/cleanup
- **Colon namespace works** in skill name fields
- **Skills have Sources of Truth sections** — link to official docs, Claude must verify before implementation
- **browser-automation** — replaces Chrome DevTools MCP; uses agent-browser CLI via Bash
- **Matt Pocock / AI Hero** — useful resource for Claude Code patterns: https://www.aihero.dev/posts
- **Livery** — BAI desktop theme manager (Tauri v2 + React), GUI evolution of pick-theme → [project_livery.md](project_livery.md)

### Feedback

- **Skill discovery discipline** — always check skills before using MCP tools directly → [feedback_skill_discovery.md](feedback_skill_discovery.md)

### Symlinks (symlinks.yml)

- `common/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `common/.claude/agents` → `~/.claude/agents`
- `common/.claude/settings.json` → `~/.claude/settings.json`
- `common/.claude/skills` → `~/.claude/skills`
- `common/.claude/hooks/peon-ping/config.json` → peon-ping config
- `"common/.claude/hooks/enforce/*"` → `~/.claude/hooks/enforce`
