# Dots Project Memory

## Claude Code Config Architecture (updated 2026-03-24)

Skills + hooks architecture with SessionStart enforcement injection.

### Structure

```
common/.claude/
├── CLAUDE.md              # Lean — communication, blind spot rule, 1% skill check threshold
├── settings.json          # Hooks config, permissions, plugins
├── agents/                # 12 custom agent files (added 2026-01-12, NOT from a plugin — needs overhaul)
├── hooks/
│   └── enforce/           # Deterministic enforcement
│       ├── session-start.sh      # SessionStart: injects meta-enforcement skill content
│       ├── semantic-commits.sh   # PreToolUse: blocks non-semantic commits
│       ├── warn-any-type.sh      # PostToolUse: warns on `: any` in TypeScript
│       ├── current-datetime.sh   # UserPromptSubmit: injects current date/time
│       └── skills-check.sh       # DISABLED — kept as fallback, not wired in settings.json
└── skills/
    ├── meta-enforcement/      # Injected at session start (hidden from discovery)
    ├── about-*/               # 8 knowledge skills
    ├── dev-*/                 # ~28 dev skills (react, typescript, tdd, planning, etc.)
    ├── bai-*/                 # 9 BAI workflow skills
    ├── dots-*/                # 4 dotfiles skills
    ├── penny-*/               # 7 penny skills + penny base
    ├── browser-automation/    # agent-browser CLI usage
    └── (others)               # docs, gh-pr-review, research, mcp-guide, obsidian-guide, etc.
```

### Naming Conventions

- **Namespace separator**: `:` in `name` field (e.g., `about:nik`, `bai:status`, `dev:react`, `meta:enforcement`)
- **Directory names**: `-` hyphen (e.g., `about-nik/`, `bai-status/`, `dev-react/`, `meta-enforcement/`)
- **All namespaced prefixes**: `about:`, `bai:`, `dev:`, `dev-tanstack-`, `dots:`, `meta:`, `penny:`
- **TanStack skills**: use `dev-tanstack-*` directory, `dev:tanstack-*` name (avoids ts ambiguity)

### Key Decisions

- **"Blind Spot Rule"** — correction is mandatory when flaws detected
- **Sonder** — future project, anonymous storytelling platform, domain: sonder.house
- **Agents directory** — manually added 2026-01-12 (not plugin-managed), needs overhaul/cleanup
- **Skills have Sources of Truth sections** — link to official docs, Claude must verify before implementation
- **browser-automation** — replaces Chrome DevTools MCP; uses agent-browser CLI via Bash
- **Matt Pocock / AI Hero** — useful resource for Claude Code patterns: https://www.aihero.dev/posts
- **Livery** — BAI desktop theme manager (Tauri v2 + React) → [project_livery.md](project_livery.md)
- **Vendor-agnostic skills** — long-term goal, no ready solution yet → [project_vendor_agnostic_skills.md](project_vendor_agnostic_skills.md)
- **Skills enforcement refactor** (2026-03-24) — SessionStart injection, skill consolidation, pipeline wiring → [project_skills_enforcement_refactor.md](project_skills_enforcement_refactor.md)
- **Visual companion** (2026-03-24) — Extract superpowers' visual brainstorming server, integrate with agent-browser → [project_visual_companion.md](project_visual_companion.md)
- **Visual companion v2** (2026-03-25) — Vertical stacking + fixed sidebar layout → [project_visual_companion_v2.md](project_visual_companion_v2.md)

### Feedback

- **Skill discovery discipline** → [feedback_skill_discovery.md](feedback_skill_discovery.md)
- **Web tool lanes** → [feedback_browser_automation.md](feedback_browser_automation.md)
- **No trash commits during debug cycles** → [feedback_commit_discipline.md](feedback_commit_discipline.md)
- **UI changes require visual verification** → [feedback_visual_verification.md](feedback_visual_verification.md)

### Symlinks (symlinks.yml)

- `common/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `common/.claude/agents` → `~/.claude/agents`
- `common/.claude/settings.json` → `~/.claude/settings.json`
- `common/.claude/skills` → `~/.claude/skills`
- `"common/.claude/hooks/enforce/*"` → `~/.claude/hooks/enforce`
