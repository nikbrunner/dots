# Claude Code Config — Status & TODOs

## Skill Namespace Conventions

| Prefix | Purpose | Invocable |
|--------|---------|-----------|
| `about:*` | Project/domain context | Claude only |
| `bai:*` | Black Atom Industries workflows | Claude only (except `bai:setup-release`) |
| `dev:*` | Development patterns & tools | Claude only |
| `dev-tanstack-*` | TanStack library skills | Claude only |
| `dots:*` | Dotfiles management | User |
| `penny:*` | Personal assistant rituals | User |
| No prefix | Standalone tools/workflows | Varies |

## TODOs

### Cross-Tool Sync
- [ ] Symlink `CLAUDE.md` for use with other tools (e.g., OpenCode)
  - Claude Code: `~/.claude/CLAUDE.md` (managed via dots symlinks)
  - OpenCode: `~/.config/opencode/AGENTS.md` → symlink to the same source
  - Note: Skills and hooks are Claude Code-specific and have no equivalent in other tools

### Skills to create
- [x] **dev-styling** — CSS / Styling approaches, design tokens
- [x] **dev-tanstack-router** — File-based routing, search params, data loading patterns
- [x] **dev-tanstack-start** — Server functions, middleware, SSR patterns
- [ ] **dev-tanstack-(form|store)** — With personal preferences and examples and documentation links
- [x] **dev-state-management** — State categorization, separation principle, URL state patterns

### Skills to improve
- [ ] **dev-react** — Improve component file examples
- [ ] **dev-tanstack-query** — Replace pseudocode with real examples when BikeCenter code available
- [ ] **dev-testing** — Expand with Storybook interaction test examples, hook testing patterns

### Agents directory overhaul
- [ ] Audit `agents/` — currently 12 agent files, never actively used
- [ ] Decide: keep as reusable subagent definitions, or inline into skills via `context: fork`
- [ ] If keeping: trim to only agents that are actually referenced from skills
- [ ] If inlining: migrate agent personas into skill files, delete `agents/`

### Sources of Truth pattern
- [ ] Add to remaining dev skills (dev-typescript, dev-testing, dev-planning)
- [ ] Consider: should skills auto-verify against docs before implementation?

### Research & Inspiration
- [ ] Matt Pocock's AI Hero: https://www.aihero.dev/posts
  - "How To Make Codebases AI Agents Love" — deep modules, codebase architecture
  - "A Complete Guide To AGENTS.md" — progressive disclosure, focused instructions
  - "Essential AI Coding Feedback Loops For TypeScript" — type checking, testing, hooks
  - "My Skill Makes Claude Code GREAT At TDD" — TDD skill patterns
  - Claude Code Hooks articles — enforcement patterns
- [ ] Anthropic docs on skills: https://code.claude.com/docs/en/skills
- [ ] Anthropic docs on subagents: https://code.claude.com/docs/en/sub-agents

### Future ideas
- [ ] Atomic concept skills inspired by react.dev/reference (per-hook skills etc.)
- [ ] `context: fork` + `agent` pattern for expensive review skills
- [ ] Skill that generates project-specific skills from codebase analysis (llm-setup)
