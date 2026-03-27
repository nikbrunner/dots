# Dots Project Memory

## Claude Code Config Architecture (updated 2026-03-26)

Skills + hooks architecture with SessionStart enforcement injection.

### Structure

```
common/.claude/
├── CLAUDE.md              # Communication, blind spot rule, 1% skill check threshold
├── settings.json          # Hooks config, permissions, plugins
├── agents/                # 12 custom agent files (added 2026-01-12, needs overhaul)
├── hooks/
│   └── enforce/           # Deterministic enforcement
│       ├── session-start.sh      # SessionStart: injects meta-enforcement skill
│       ├── semantic-commits.sh   # PreToolUse: blocks non-semantic commits
│       ├── warn-any-type.sh      # PostToolUse: warns on `: any` in TypeScript
│       ├── current-datetime.sh   # UserPromptSubmit: injects current date/time
│       └── skills-check.sh       # DISABLED — kept as fallback
└── skills/
    ├── meta-enforcement/      # Injected at session start (hidden)
    ├── about-*/               # 8 knowledge skills
    ├── dev-*/                 # ~28 dev skills
    ├── bai-*/                 # 9 BAI workflow skills
    ├── dots-*/                # 4 dotfiles skills
    ├── penny-*/               # 7 penny skills + penny base
    ├── browser-automation/    # agent-browser CLI usage
    └── (others)               # docs, gh-pr-review, research, mcp-guide, etc.
```

### Naming Conventions

- **Namespace separator**: `:` in `name` field (e.g., `about:nik`, `dev:react`, `meta:enforcement`)
- **Directory names**: `-` hyphen (e.g., `about-nik/`, `dev-react/`)
- **All prefixes**: `about:`, `bai:`, `dev:`, `dev-tanstack-`, `dots:`, `meta:`, `penny:`, `opsx:`
- **TanStack skills**: `dev-tanstack-*` directory, `dev:tanstack-*` name
- **OpenSpec per-project**: `opsx:` prefix (opsx:explore, opsx:propose, opsx:apply, opsx:archive)

### Recent Skill Renames (2026-03-25, feat/openspec-integration branch)

- `dev-grill-me` → `dev-brainstorm`
- `dev-write-prd` → `dev-propose`
- `dev-prd-to-plan` → `dev-plan-tasks`

### Key Decisions

- **"Blind Spot Rule"** — correction is mandatory when flaws detected
- **Sonder** — future project, anonymous storytelling platform, domain: sonder.house
- **Agents directory** — manually added 2026-01-12 (not plugin-managed), needs overhaul
- **Skills have Sources of Truth sections** — link to official docs, verify before implementation
- **browser-automation** — replaces Chrome DevTools MCP; uses agent-browser CLI via Bash
- **Matt Pocock / AI Hero** — useful resource for Claude Code patterns: https://www.aihero.dev/posts

### Active Projects

- [OpenSpec integration](project_openspec_integration.md) — Active branch, skill renames done, remaining tasks
- [Visual companion](project_visual_companion.md) — Fully implemented, v2 archived
- [Livery](project_livery.md) — BAI desktop theme manager (Tauri v2 + React)
- [Vendor-agnostic skills](project_vendor_agnostic_skills.md) — Long-term goal, no ready solution
- [Skills enforcement refactor](project_skills_enforcement_refactor.md) — Merged to main, peon-ping cleanup pending

### Feedback

- [Skill discovery discipline](feedback_skill_discovery.md) — Always check skills before using MCP tools directly
- [Web tool lanes](feedback_browser_automation.md) — agent-browser, Exa, Ref each have their lane
- [No trash commits](feedback_commit_discipline.md) — Batch debug cycles into one meaningful commit
- [Visual verification required](feedback_visual_verification.md) — UI changes need screenshot inspection

### Symlinks (symlinks.yml)

- `common/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `common/.claude/agents` → `~/.claude/agents`
- `common/.claude/settings.json` → `~/.claude/settings.json`
- `common/.claude/skills` → `~/.claude/skills`
- `"common/.claude/hooks/enforce/*"` → `~/.claude/hooks/enforce`
