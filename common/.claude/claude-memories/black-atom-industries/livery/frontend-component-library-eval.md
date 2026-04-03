---
name: frontend-component-library-eval
description: Component library evaluation for issue #29 — BaseUI (headless) vs Mantine, trade-offs discussed 2026-03-31
type: project
---

## Component Library Decision (open as of 2026-03-31)

Issue #29 currently plans **BaseUI (headless) + CSS Modules**. Nik raised Mantine as an alternative after its v8 release, citing CSS Modules first-class support and AI integration (llms.txt, MCP server).

**Key tension:** Mantine is a full opinionated component library, not headless. The "Vault Terminal" aesthetic (no rounded corners, monospace, 1px borders, monochrome chrome) would require extensive override of Mantine defaults. Headless gives full control without fighting a design system.

**Mantine pros:** rich component set out-of-box, CSS Modules native, llms.txt + MCP server for AI-assisted dev.
**Mantine cons:** must override defaults heavily for custom aesthetic, larger bundle, adds a design system layer on top of Black Atom tokens.

**Why:** Nik is interested in DX improvements (AI docs) and CSS Modules alignment, but hasn't committed to switching.

**How to apply:** Decision is still open. Don't assume either library. If frontend work starts, check which direction was chosen on #29 first.
