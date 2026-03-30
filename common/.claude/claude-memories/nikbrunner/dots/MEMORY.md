# Dots Project Memory

## Claude Code Config Architecture (updated 2026-03-30)

Skills + hooks architecture with SessionStart enforcement injection.

### Structure

```
common/.claude/
├── CLAUDE.md              # Communication, blind spot rule, 1% skill check threshold
├── settings.json          # Hooks config, permissions, plugins
├── agents/                # Custom agent files (pruned 2026-03-30)
├── hooks/
│   └── enforce/           # Deterministic enforcement
│       ├── session-start.sh      # SessionStart: injects meta-enforcement skill
│       ├── semantic-commits.sh   # PreToolUse: blocks non-semantic commits
│       ├── warn-any-type.sh      # PostToolUse: warns on `: any` in TypeScript
│       ├── current-datetime.sh   # UserPromptSubmit: injects current date/time
│       └── skills-check.sh       # UserPromptSubmit: smart skill suggestion (tightened 2026-03-30)
└── skills/                # Restructured 2026-03-30
    ├── meta-enforcement/      # Injected at session start (hidden)
    ├── dev-flow/              # 1 skill, 5 sub-docs: assess, plan, implement, review, close
    ├── dev-audit/             # 1 skill, 4 sub-docs: ui, style, arch, docs
    ├── dev-style-*/           # 6 coding convention skills (react, typescript, css, tanstack, tdd, state)
    ├── dev-util-*/            # 5 standalone tools (commit, visual-companion, browser, glossary, design-interface)
    ├── dev-setup-*/           # 4 bootstrapping (claude, project, openspec, skill)
    ├── about-*/               # 8 knowledge skills
    ├── bai-*/                 # 6 BAI Linear tools (wrappers absorbed into dev:flow)
    ├── dots-*/                # 4 dotfiles skills
    └── penny-*/               # 7 penny skills + penny base
```

### Naming Conventions

- **Namespace separator**: `:` in `name` field (e.g., `dev:flow`, `dev:style:react`, `dev:util:commit`)
- **Directory names**: `-` hyphen (e.g., `dev-flow/`, `dev-style-react/`)
- **Prefixes**: `about:`, `bai:`, `dev:flow`, `dev:style:`, `dev:util:`, `dev:setup:`, `dev:audit`, `dots:`, `meta:`, `penny:`
- **argument-hint**: `dev:flow` and `dev:audit` use argument-hint frontmatter for autocomplete

### Key Decisions

- **"Blind Spot Rule"** — correction is mandatory when flaws detected
- **Sonder** — future project, anonymous storytelling platform, domain: sonder.house
- **Skills have Sources of Truth sections** — link to official docs, verify before implementation
- **browser-automation** → `dev:util:browser` — uses agent-browser CLI via Bash
- **Matt Pocock / AI Hero** — useful resource for Claude Code patterns: https://www.aihero.dev/posts
- **Skill restructuring (2026-03-30)** — 34 dev skills → 17, namespaced taxonomy, BAI wrappers absorbed
- **OpenSpec paused** — installed but not wired into flow, Nik wants to try incrementally

### Active Projects

- [Nvim picker migration](project_nvim_picker_migration.md) — Snacks sole picker, committed 6cef1af, not yet merged
- [Neovim 0.12 migration](project_nvim012_migration.md) — Planned: vim.pack exploration, dots#9
- [OpenSpec integration](project_openspec_integration.md) — Paused, evaluating incrementally
- [Visual companion](project_visual_companion.md) — Fully implemented, v2 layout done
- [Livery](project_livery.md) — BAI desktop theme manager (Tauri v2 + React)
- [Vendor-agnostic skills](project_vendor_agnostic_skills.md) — Long-term goal, no ready solution

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
