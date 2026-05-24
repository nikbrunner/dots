---
name: Markdown tables follow prettier defaults in dots
description: In the dots repo, prettier owns markdown table formatting — don't author with minimal separators
type: feedback
originSessionId: 79515f6f-2d56-468e-84dd-0de78a4fc7a3
---

When writing markdown in the dots repo, let prettier handle table formatting (padded separators with repeated hyphens, column alignment via spaces). Do NOT use minimal `|-|-|` separators.

**Why:** The pre-commit hook runs `npx prettier --check "**/*.md"` with default prettier config. Default prettier pads tables. A prior global rule said "use minimum separator, never pad" — that rule conflicted with the hook and blocked commits, so it was dropped on 2026-05-24.

**How to apply:** When editing or adding markdown in `~/repos/nikbrunner/dots`, format tables the way prettier would. Equivalently: run `prettier --write <file>` before staging. Doesn't apply to other repos unless they have the same prettier-check hook.
