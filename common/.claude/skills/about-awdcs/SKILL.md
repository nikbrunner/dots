---
name: about:awdcs
description: AWDCS keybinding system context. Load when editor keybindings, keymaps, shortcuts, or key mappings come up (Neovim, Zed, etc.).
user-invocable: false
---

# About AWDCS

Nik's scope-based keymap system for modal editors. Organizes bindings by **scope of operation** rather than tool or function — matching how developers naturally think ("I want to search the workspace" not "I want to use Telescope").

Repo: `~/repos/nikbrunner/awdcs/`

## The Five Scopes

| Scope | Leader | Purpose |
|-|-|-|
| **[A]pp** | `<leader>a` | Application-level: themes, settings, plugins, help, AI |
| **[W]orkspace** | `<leader>w` | Cross-codebase: find files, search text, version control |
| **[D]ocument** | `<leader>d` | Current file: find/replace, diagnostics, undo, yank |
| **[C]hange** | `<leader>c` | Git hunk operations: stage, revert, diff |
| **[S]ymbol** | `s` (or `<leader>s`) | Code symbols: definition, references, rename, actions |

## Key Patterns

- **Format**: `<Scope><?Group?><Operation>` — e.g., `<leader>wvh` = Workspace → Version → History
- **Lowercase/Uppercase variants**: lowercase = transient picker UI, uppercase = persistent panel UI
- **Leader key**: Nik uses `,` — enables two-handed ergonomic typing
- **Symbol scope exception**: `s` prefix without leader (high-frequency operations)
- **Alphabetical order** within each scope for predictable reference
- **Single mapping** per operation — no duplicates across scopes

## Design Principles

- Scope first — every binding belongs to exactly one scope
- Semantic naming — describe meaning, not implementation
- Preserve editor defaults — enhance, don't replace core commands
- Consistent patterns — related operations share scopes

## Source of Truth

The AWDCS spec is a **living document**. The editor configs (Neovim, Zed) are where new mappings get tried out first. When a new mapping or reorganization feels right in practice, the AWDCS repo README should be updated to reflect the change. The flow is:

1. **Try it** in the editor config (dots)
2. **Like it** — update the AWDCS spec (`~/repos/nikbrunner/awdcs/README.md`)
3. **Spec it** — the README becomes the reference for other editor implementations

When working on keybindings, always check the current editor config AND the AWDCS README — they may diverge intentionally during experimentation.

## Implementations

- **Neovim**: `~/repos/nikbrunner/dots/common/.config/nvim/`
- **Zed**: `~/repos/nikbrunner/dots/common/.config/zed/`
