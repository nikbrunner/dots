---
name: dev-nvim
description: "My Neovim/Lua development workflow — doc lookup via local help files, headless API verification. Load when working on Neovim configs or plugins (lua specs, vim.pack, mini.*, LSP configs, vim.* APIs)."
user-invocable: false
metadata:
  user-invocable: false
---

# Neovim Development

## Core Principle

I run **Neovim nightly** (via `bob`) — APIs move between builds. Never trust memory for `vim.*` APIs, help tags, or plugin module names. Verify against the **locally installed docs** first; they always match the running version. Web docs describe stable and are often behind.

## Doc Lookup (local, always current)

```bash
# Locate the runtime docs for the active nightly
VIMRUNTIME=$(nvim --clean --headless --cmd 'lua io.write(vim.env.VIMRUNTIME)' --cmd 'q')

# Find which help file documents a symbol, then read that section
rg -l 'vim\.pack\.add' "$VIMRUNTIME/doc"
rg -B2 -A20 'vim\.pack\.add' "$VIMRUNTIME/doc/pack.txt"
```

Key help files: `pack.txt` (vim.pack), `lsp.txt` (vim.lsp.config/enable), `lua.txt` (vim.api/vim.fs/vim.hl), `news.txt` (breaking changes on nightly).

Plugin docs live inside the installed plugin's `doc/` directory, e.g. mini.nvim ships one file per module:

```bash
ls "$(NVIM_APPNAME=nvim-edit nvim --clean --headless --cmd 'lua io.write(vim.fn.stdpath("data"))' --cmd 'q')/site/pack/core/opt/mini.nvim/doc/"
```

## Headless Verification

```bash
# Does this API exist in the running build?
nvim --clean --headless "+lua print(vim.inspect(vim.tbl_keys(vim.hl)))" +q

# Smoke test a config — startup errors print to stderr
NVIM_APPNAME=nvim-edit nvim --headless "+qa!"

# Run something inside the full config (deferred/lazy errors only surface at runtime)
NVIM_APPNAME=nvim-edit nvim --headless "+lua print(pcall(require, 'conform'))" +q
```

## Sources of Truth

- **Local help** (primary): `$VIMRUNTIME/doc/` — see lookup commands above
- **Installed plugin docs**: `<stdpath data>/site/pack/*/opt/<plugin>/doc/`
- **Nightly breaking changes**: https://github.com/neovim/neovim/blob/master/runtime/doc/news.txt
- **mini.nvim**: https://github.com/nvim-mini/mini.nvim
