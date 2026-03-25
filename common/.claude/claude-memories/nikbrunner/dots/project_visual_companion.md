---
name: Visual Companion for Design Brainstorming
description: Plan to extract superpowers' visual brainstorming companion into standalone tool, integrate with agent-browser for AI visual feedback loop.
type: project
---

Extract superpowers' visual companion (local HTTP server + HTML mockups + click-to-select) into a standalone tool owned by Nik.

**Why:** Claude can't see what it generates. During dev:grill-me design discussions, visual questions need visual answers — not ASCII art. The superpowers companion solves this with a file-watcher server that serves HTML fragments with interactive selection.

**How to apply:**

- Start by copying superpowers' server scripts (`skills/brainstorming/scripts/`, `visual-companion.md`) into dots or a standalone repo
- Key innovation: connect via agent-browser so Claude can actually see the rendered output (screenshot → Read tool), closing the feedback loop
- Integrate as optional step in dev:grill-me when visual questions arise
- Agentic Coding Handbook has a documented visual feedback workflow pattern
- Nik has additional ideas to iterate on — discuss at start of next session

**Current state:** Extracted to `dev-visual-companion` skill in dots. Server works, click events captured, integrated with dev:brainstorm. Enhanced flow: capture existing → iterate → export clean reference to `design/`.

**Future:** Extract to standalone bundled plugin (server + templates + skills, zero external deps). Note: Stitch MCP is OFFER not REQUIRE — Google might kill it.

**Source files:** Originally from `/Users/nbr/repos/obra/superpowers/skills/brainstorming/scripts/`
