---
name: Visual Companion for Design Brainstorming
description: Browser-based visual companion skill (dev-visual-companion) — capture existing UI, iterate on mockups, export clean references. Fully implemented.
type: project
---

Browser-based visual companion that lets Claude show mockups during design discussions.

**Why:** Claude can't see what it generates. During dev:brainstorm design discussions, visual questions need visual answers. The companion uses a file-watcher HTTP server + HTML fragments + click-to-select for interactive feedback.

**Status (2026-03-26):** Fully implemented as `dev-visual-companion` skill. V2 layout (vertical stacking + sidebar) also implemented and archived.

**Key features:**

- Capture existing UI state before iterating (web via agent-browser, desktop via screencapture)
- HTML fragment server with CSS classes for options, cards, mockups, split views
- Click-to-select events captured to `.events` file
- Export phase: full-document HTML → screenshot → `design/` directory
- Stitch MCP offered when available (OFFER not REQUIRE — Google might kill it)
- Impeccable critique/polish integrated into visual verification

**V2 layout (2026-03-25):** Vertical stacking + fixed sidebar. Each option takes full width, user scrolls to compare. Archived at `openspec/changes/archive/2026-03-25-visual-companion-v2-layout/`.

**Source:** Extracted from `obra/superpowers/skills/brainstorming/scripts/`.

**Future:** Extract to standalone bundled plugin (server + templates + skills, zero external deps).
