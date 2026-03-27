---
name: feedback-css-modules
description: Nik prefers CSS Modules over Tailwind for component styling in Black Atom projects — intended direction for frontend rebuild
type: feedback
---

Default styling approach going forward is CSS Modules, not Tailwind.

Note: Tailwind is currently installed and used (`@import "tailwindcss"` in `src/index.css`), and `src/AGENTS.md` lists it as the stack. The preference applies to the upcoming frontend/UI rebuild (DEV-318), not to existing code.

**Why:** Explicit preference — Nik corrected when Tailwind was assumed for DEV-318.

**How to apply:** When setting up new styling or suggesting CSS approaches in Black Atom projects, default to CSS Modules + CSS custom properties for design tokens. Don't suggest Tailwind unless Nik brings it up. Existing Tailwind usage is fine until the frontend rebuild.
