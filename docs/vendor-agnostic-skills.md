# Vendor-Agnostic Skills Architecture

Status: **Thinking** — not actionable yet, capturing the direction.

## The Problem

I'm investing significant effort into curating skills, conventions, and preferences that personalize my LLM coding experience. This knowledge is genuinely mine — React component patterns, TypeScript rules, planning processes — but it's currently stored in `.claude/skills/` with Claude-specific wiring (frontmatter, tool names, hooks).

If I switch tools or want to use multiple LLM assistants, the knowledge is effectively locked in.

## Current State (2026-03)

The existing skill structure already separates reasonably well:

```
skills/dev-react/
├── SKILL.md                  # Vendor wiring (Claude-specific)
├── component-patterns.md     # Knowledge (portable)
├── folder-structure.md       # Knowledge (portable)
├── hooks-as-logic-layer.md   # Knowledge (portable)
└── component-libraries.md    # Knowledge (portable)
```

The `.md` knowledge files are already vendor-agnostic. Only `SKILL.md` contains Claude-specific frontmatter, tool references, and argument interpolation.

## Idea: `llm/` Directory

A general `llm/` folder in dots that symlinks to vendor-specific locations:

```
dots/common/llm/
├── skills/           # Knowledge files
├── preferences/      # Communication style, coding conventions
└── vendors/
    ├── claude/       # SKILL.md wiring, hooks, settings
    ├── gemini/       # Equivalent wiring
    └── opencode/     # Equivalent wiring
```

Symlinks would map `llm/skills/` content into each vendor's expected directory.

## Research (2026-03)

Existing solutions — all too immature for adoption:

- **luisrudge/dot-ai** — CLI to generate vendor configs from a single `.ai/` source folder
- **dot-agents.com** — "One config. Every AI agent." (early stage)
- **fgrehm/dot-ai** — Symlink-based AI dotfiles, currently Claude-focused
- **AGENTS.md** — Converging as a cross-vendor standard (OpenCode, Codex, others). Most organic path to portability.
- **OpenSpec** — Spec-driven dev framework for 30+ assistants. Focused on project specs, not personal conventions.

## Decision

**Wait.** The landscape is too unstable. Current structure already separates knowledge from wiring well enough. Revisit when:

- Actively using 2+ LLM tools daily
- AGENTS.md or another standard matures enough to be a clear target
- A tool like `dot-ai` reaches sufficient maturity

## Principle to Maintain Now

When creating or editing skills, keep knowledge in supporting `.md` files separate from vendor-specific `SKILL.md` wiring. This makes future migration straightforward regardless of what the ecosystem settles on.
