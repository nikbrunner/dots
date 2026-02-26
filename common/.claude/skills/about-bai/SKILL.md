---
name: about-bai
description: Black Atom Industries theme ecosystem context. Load when BAI, themes, adapters, or colorschemes come up.
user-invocable: false
---

# About Black Atom Industries

Nik's theme/colorscheme ecosystem — a modular system for consistent styling across editors, terminals, and tools.

A central `core` repo (Deno/TypeScript, published on JSR as `@black-atom/core`) defines all theme colors. Platform-specific adapter repos use Eta templates to generate theme files from core definitions. Changing a color in core propagates to every supported platform.

The org contains adapters for various platforms, plus supporting tools like `livery` (theme switcher), `radar.nvim` (file picker plugin), `helm` (multi-repo management CLI), and shared `claude` configuration.

Issues tracked in Linear under "Black Atom Industries" workspace.

## Local Paths

- Org repos: `~/repos/black-atom-industries/`
- Theme files in dots are symlinks to adapter repos
