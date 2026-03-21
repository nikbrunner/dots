# Claude Code Config — Status & TODOs

## Terminology

Key concepts used across skills. Many originate from Matt Pocock's [skills collection](https://github.com/mattpocock/skills) and John Ousterhout's *A Philosophy of Software Design*.

| Term | Definition | Source |
|-|-|-|
| **Skill** | Reusable instruction set that tells Claude *how* to do a type of task. Lives permanently in `skills/`. Loaded when relevant. | [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code/skills) |
| **Spec** | One-off design document — the *output* of brainstorming for a specific feature. Consumed once, then historical. Skills produce specs. | superpowers plugin |
| **PRD** | Product Requirements Document. Structured description of *what* to build and *why* before code is written. Covers problem, solution, user stories, decisions. | [Matt Pocock](https://github.com/mattpocock/skills) |
| **Deep Module** | A module with a small interface hiding a large implementation. Easier to test, navigate, and maintain than shallow modules where interface complexity matches implementation. | [Ousterhout, Ch. 4](https://web.stanford.edu/~ouster/cgi-bin/book.php) |
| **Vertical Slice / Tracer Bullet** | An implementation phase that cuts through ALL layers (DB, API, UI, tests) end-to-end, delivering a working increment. Opposite of horizontal slicing (one layer at a time). | [Andy Hunt & Dave Thomas, *The Pragmatic Programmer*](https://pragprog.com/titles/tpp20/) |
| **HITL / AFK** | Issue classification. HITL (Human-in-the-loop) requires human decisions during implementation. AFK (Away from keyboard) can be completed autonomously by an AI agent. | [Matt Pocock](https://github.com/mattpocock/skills) |
| **Ubiquitous Language** | A shared glossary of canonical domain terms used consistently across code, docs, and conversation. Eliminates ambiguity from overloaded or synonym terms. | [Eric Evans, *Domain-Driven Design*](https://www.domainlanguage.com/ddd/) |
| **Dependency Categories** | Classification of code dependencies by test strategy: In-process (pure), Local-substitutable (has test stand-ins), Ports & Adapters (owned remote), True External (third-party). | [Matt Pocock](https://github.com/mattpocock/skills), adapted from [Alistair Cockburn](https://alistair.cockburn.us/hexagonal-architecture/) |

## Skill Namespace Conventions

| Prefix | Purpose | Invocable |
|-|-|-|
| `about:*` | Project/domain context | Claude only |
| `bai:*` | Black Atom Industries workflows | Claude only (except `bai:setup-release`) |
| `dev:*` | Development patterns & tools | Claude only |
| `dev-tanstack-*` | TanStack library skills | Claude only |
| `dots:*` | Dotfiles management | User |
| `penny:*` | Personal assistant rituals | User |
| No prefix | Standalone tools/workflows | Varies |

## Skill Pipeline

Several `dev:*` skills form a sequential pipeline for feature development:

```
dev:write-prd → dev:prd-to-plan → dev:prd-to-issues → implementation
                                                         ↑
dev:grill-me (pressure-test at any stage)    dev:tdd (test discipline)
dev:design-interface (API design)            dev:refactor-plan (refactoring)
dev:ubiquitous-language (terminology)        dev:edit-article (writing)
```

These complement the superpowers plugin workflow (`brainstorming → writing-plans → executing-plans`). The `dev:*` pipeline is more structured and opinionated; superpowers is more flexible. Use whichever fits the situation.

## TODOs

### Cross-Tool Sync
- [ ] Symlink `CLAUDE.md` for use with other tools (e.g., OpenCode)
  - Claude Code: `~/.claude/CLAUDE.md` (managed via dots symlinks)
  - OpenCode: `~/.config/opencode/AGENTS.md` → symlink to the same source
  - Note: Skills and hooks are Claude Code-specific and have no equivalent in other tools

### Agents directory overhaul
- [ ] Audit `agents/` — currently 12 agent files, never actively used
- [ ] Decide: keep as reusable subagent definitions, or inline into skills via `context: fork`
- [ ] If keeping: trim to only agents that are actually referenced from skills
- [ ] If inlining: migrate agent personas into skill files, delete `agents/`

### Known Issues / Upstream Bugs

- [ ] **Skill auto-discovery unreliable** — [#30387](https://github.com/anthropics/claude-code/issues/30387)
  - Skills overlapping with built-in behaviors (git, styling, testing) are skipped ~50% of the time
  - Workaround: "Skill Check (mandatory)" section in CLAUDE.md & `common/.claude/hooks/enforce/skills-check.sh` 
- [ ] **CLAUDE.md instructions ignored** — [#32161](https://github.com/anthropics/claude-code/issues/32161)
  - Knowledge retrieval rules in CLAUDE.md systematically ignored
  - Related: context file dispatch feature request [#31575](https://github.com/anthropics/claude-code/issues/31575)
- [ ] **Skill hot-reload misses new directories** — [#31559](https://github.com/anthropics/claude-code/issues/31559)
  - New skill dirs added mid-session are not detected

### Research & Inspiration
- [x] Matt Pocock's skills — imported and adapted (2026-03-21), see `dev:grill-me`, `dev:write-prd`, `dev:prd-to-plan`, `dev:prd-to-issues`, `dev:ubiquitous-language`, `dev:design-interface`, `dev:refactor-plan`, `dev:edit-article`, `dev:tdd`
- [x] Matt Pocock's AI Hero articles — concepts integrated into skills (deep modules, vertical slices, TDD patterns)
- [ ] Anthropic docs on skills: https://code.claude.com/docs/en/skills
- [ ] Anthropic docs on subagents: https://code.claude.com/docs/en/sub-agents

### Future ideas
- [ ] Atomic concept skills inspired by react.dev/reference (per-hook skills etc.)
- [ ] `context: fork` + `agent` pattern for expensive review skills
- [ ] Skill that generates project-specific skills from codebase analysis (llm-setup)
