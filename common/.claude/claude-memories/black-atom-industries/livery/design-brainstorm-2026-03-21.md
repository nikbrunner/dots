---
name: design-brainstorm-2026-03-21
description: Livery UI design brainstorm session — Stitch project, brand identity direction, Black Atom color mapping
type: project
---

## Livery UI Design — Brainstorm Status

**Stitch project ID:** 11018168170664527349

**Design direction locked:**

- "Vault terminal" hybrid — technical datasheet chrome, more atmospheric center specimen area
- Setup wizard & settings: fully datasheet/utilitarian
- Main view: hybrid (technical sides, breathing room in center)
- Light AND dark mode both first-class
- Monospace backbone + display sans for theme names only
- No rounded corners. 1px borders. Uppercase mono section headers with horizontal rules.
- Only accent colors: muted green (synced/valid) and purple (selected/active)
- Chrome is monochrome — themes bring the color

**Actual Black Atom colors from core (hex):**

- Light surfaces: #f9fcff, #eceff1, #dbdee1, #d3d6d9
- Light text: #191b1c, #28292a, #313334, #576570, #788288
- Dark surfaces: #080f0f, #111817, #1a2121, #232a2a
- Dark text: #d6e7f4, #c9dae7, #b6c7d3, #91a1ad, #73838e
- Green accents: light #60a259/#2f8728, dark #afdca9/#8fbc8a
- Purple accents: light #8f81d6/#735dc4, dark #ada5e1/#826cd9

**Stitch learnings:**

- DESIGN.md is auto-generated, serves as handoff artifact for coding agents
- Edit API creates new screens alongside originals (no delete via MCP)
- Set Design System (Theme tab + DESIGN.md) BEFORE generating screens for best results
- Workflow: Stitch → Code (via MCP + Claude Code), skip Figma
- Can extract HTML/CSS per screen via get_screen downloadUrl

**Stitch MCP status:** Connected and working as of 2026-04-04.

**Next steps:**

- Nik cleans up Stitch canvas manually (remove old versions)
- Potentially set Theme tab colors to Black Atom values in Stitch UI
- Then regenerate clean screens or continue iterating from v2/v3

**Related issues (migrated to GitHub Issues as of 2026-03-28):** #29 (frontend architecture), logo, banner, setup wizard, settings page

**Design spec written to:** docs/superpowers/specs/2026-03-21-livery-ui-design-language.md
