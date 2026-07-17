# Dots Project Memory

## Claude Code Config Architecture (updated 2026-04-03)

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
    ├── dev-util-*/            # 2 standalone tools (browser, visual-companion)
    ├── dev-setup-*/           # 7 bootstrapping (claude, project, skill, pre-commit, dep-upgrade, release-please, glossary)
    ├── about-*/               # 8 knowledge skills
    ├── bai-*/                 # 6 BAI GitHub issue tools + bai-create-project
    ├── dots-*/                # 2 dotfiles skills (git-status-cleanup, manage)
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
- **Mise evaluated and dismissed (2026-04-02)** — not worth adopting for dots; only handles runtimes, not native packages (brew/pacman)
- **Pre-commit skill rewritten (2026-04-03)** — Husky dropped in favor of `.githooks/` + native `git core.hooksPath`. No wrapper deps needed.

### Plugins (settings.json)

- `impeccable@impeccable` — design quality skills (pbakaus/impeccable)
- `readwise@readwise-skills` — reading library access (readwiseio/readwise-skills, added 2026-04-01)
- `claude-deno-lsp@local-plugins` — Deno LSP
- `lua-lsp@claude-plugins-official` — Lua LSP (for Neovim config)
- `frontend-design@claude-plugins-official` — frontend design skills
- Linear MCP — auto-allowed (`mcp__linear__*`), used by BAI issue skills

### Active Projects

- [ProtonPass migration](project_protonpass_migration.md) — SSH/signing done, env sync in progress
- [Nvim picker migration](project_nvim_picker_migration.md) — Snacks sole picker, committed 6cef1af, not yet merged
- [Neovim 0.12 migration](project_nvim012_migration.md) — Planned: vim.pack exploration, dots#9
- [OpenSpec integration](project_openspec_integration.md) — Paused, evaluating incrementally
- [Livery](project_livery.md) — BAI desktop theme manager (Tauri v2 + React)
- [Vendor-agnostic skills](project_vendor_agnostic_skills.md) — Long-term goal, no ready solution
- [mdn.nvim](project_mdn_nvim.md) — Stays a separate repo (test suite is the reason); loading race fixed 2026-07-16

### Completed Projects

- [Skills enforcement refactor](project_skills_enforcement_refactor.md) — Done 2026-03-26, merged to main
- [Visual companion](project_visual_companion.md) — Fully implemented, v2 layout done

### Reference

- [macOS symbolic hotkeys quirk](macos_symbolic_hotkeys_quirk.md) — `defaults write com.apple.symbolichotkeys` doesn't apply; use System Settings UI
- [Claude statusline & cache](claude_statusline_and_cache.md) — ccstatusline setup, cache TTL 1h personal/5m work, PreCompact can't inject compact instructions

### Feedback

- [Skill discovery discipline](feedback_skill_discovery.md) — Always check skills before using MCP tools directly
- [Web tool lanes](feedback_browser_automation.md) — agent-browser, Exa, Ref each have their lane
- [No trash commits](feedback_commit_discipline.md) — Batch debug cycles into one meaningful commit
- [Visual verification required](feedback_visual_verification.md) — UI changes need screenshot inspection
- [Markdown table formatting](feedback_table_formatting.md) — prettier owns table style in dots; don't use minimal `|-|-|` separators

### Symlinks (symlinks.yml)

- `common/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `common/.claude/agents` → `~/.claude/agents`
- `common/.claude/settings.json` → `~/.claude/settings.json`
- `common/.claude/skills` → `~/.claude/skills`
- `"common/.claude/hooks/enforce/*"` → `~/.claude/hooks/enforce`
