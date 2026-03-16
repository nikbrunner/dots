---
name: Vendor-agnostic skill architecture
description: Long-term goal to keep LLM skills/conventions portable across vendors, separating knowledge from wiring
type: project
---

Nik wants his skills, preferences, and conventions to be a personal archive that isn't locked into Claude Code. The knowledge (React patterns, TypeScript rules, component conventions) is the long-term asset; the vendor wiring (frontmatter, tool names, hooks) is disposable glue.

**Why:** LLM tooling landscape is unstable — big CLAUDE.md files are already outdated, MCPs may evolve, commands became skills. Investing in skill curation is a long-term project and shouldn't be vendor-locked.

**How to apply:** Keep knowledge in supporting .md files (component-patterns.md, folder-structure.md, etc.) separate from SKILL.md wiring. When creating or editing skills, maintain this separation. Don't over-engineer an abstraction layer yet — the current structure already separates well. Revisit when actively using 2+ LLM tools or when a credible open standard emerges.

**Landscape (2026-03):** Researched existing solutions — all too fragile/immature:
- `luisrudge/dot-ai` — CLI to generate vendor configs from single `.ai/` source
- `dot-agents.com` — "one config, every agent" (early stage)
- `fgrehm/dot-ai` — symlink-based AI dotfiles (Claude-focused)
- AGENTS.md converging as cross-vendor standard (OpenCode, Codex fall back to CLAUDE.md)
- OpenSpec — spec-driven dev framework, 30+ assistants, but about project specs not personal conventions

None ready for adoption yet. AGENTS.md convergence is the most organic path.
