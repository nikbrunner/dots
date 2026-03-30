---
name: Neovim 0.12 Migration
description: Planned migration to Neovim 0.12 — review breaking changes, explore vim.pack as lazy.nvim replacement. Tracked in dots#9.
type: project
---

Nik created GitHub issue nikbrunner/dots#9 on 2026-03-30 to track a proper migration to Neovim 0.12.

**Why:** Neovim 0.12 shipped with significant changes. `vim.pack` is a new built-in package manager that could replace lazy.nvim, simplifying the plugin setup.

**How to apply:** When working on Neovim plugin configuration, be aware this migration is planned. Don't invest heavily in lazy.nvim-specific patterns that would need rewriting.

## References

- Neovim 0.12 news: https://github.com/neovim/neovim/blob/v0.12.0/runtime/doc/news.txt
- Guide to vim.pack (echasnovski): https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack.html
