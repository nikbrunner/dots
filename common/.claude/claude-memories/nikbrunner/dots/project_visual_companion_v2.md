---
name: Visual Companion v2 — Vertical stacking + sidebar
description: Next iteration of visual companion layout — full-width stacked mockups with fixed description sidebar, enabling viewport-width designs and mobile simulation.
type: project
---

Redesign the visual companion's option layout for better mockup fidelity.

**Current problem:** Side-by-side options cramp each mockup. Previews are too small to evaluate at real scale.

**Proposed layout:**

- Stack options vertically, each taking full available screen width
- User scrolls up/down to compare
- Fixed sidebar on the right with: option letter, title, description, pros/cons
- Sidebar anchors while scrolling — context stays visible
- Browser resize naturally simulates different viewport sizes (terminal widths, mobile, etc.)

**Why:** Each mockup should render at the scale it will actually be used. A tmux popup mockup should look like a tmux popup. A web dashboard should fill the screen. Side-by-side forces artificial compression.

**How to apply:** Modify frame-template.html CSS for `.options` layout. May need JS for scroll-spy to highlight which option is currently visible in the sidebar. The selection mechanism (click to pick) stays the same.

**Depends on:** Current visual companion flow working (verified 2026-03-25).
