---
name: Visual Companion for Design Brainstorming (retired)
description: Custom browser-based visual companion skill (dev-visual-companion), retired 2026-07-22 in favor of the sideshow-based dev-illustrator skill.
type: project
---

Custom browser-based visual companion that let Claude show mockups during design discussions — a file-watcher HTTP server + HTML fragments + click-to-select for interactive feedback, extracted from `obra/superpowers/skills/brainstorming/scripts/`.

**Retired 2026-07-22** in favor of `[dev-illustrator](feedback_visual_verification.md)`, which uses the `sideshow` plugin (MCP publish/update + typed browser feedback) and covers the same need — showing mockups and iterating on user comments — without a custom server to maintain. Validated end-to-end including on a clean subagent with no session context.
