# vim.pack Migration PRD

## Status

**Draft** — implementation deferred. This document captures the full design so it can be picked up later without re-researching.

## Goal

Replace `lazy.nvim` with Neovim's built-in `vim.pack` plugin manager (nightly, 0.13-dev). All 40 plugins load at startup — no lazy loading. Plugin configuration moves from `lua/specs/*.lua` to `plugin/*.lua`, where Neovim auto-sources every file.

## Motivation

- `vim.pack` is now stable enough for daily use (nightly 0.13-dev)
- `:packupdate` / `:packdel` commands provide proper CLI
- `nvim-pack-lock.json` provides version-pinned, syncable plugin state
- Dropping lazy.nvim removes a C dependency (git clone) from `init.lua`
- `plugin/` auto-sourcing is simpler than lazy.nvim's spec→config pipeline
- Startup time impact is negligible on modern hardware — we accept all-at-once loading

## Design

### Loading model

```
init.lua
  ├── PackChanged autocmd (hooks, before vim.pack.add)
  ├── require("config")
  ├── require("options")
  ├── require("lib")
  ├── require("keymaps")
  ├── require("autocmd")
  ├── require("lsp-config")
  ├── vim.pack.add({...}, { load = true })   ← install + load all plugins
  └── (nothing else — plugin/*.lua handles config)

plugin/*.lua                                  ← auto-sourced by Neovim
  ├── mini.lua        (was specs/mini.lua)
  ├── snacks.lua      (was specs/snacks.lua)
  ├── blink.lua       (was specs/blink.lua)
  ├── treesitter.lua  (was specs/treesitter.lua)
  ├── conform.lua     (was specs/conform.lua)
  ├── ...all other specs...
  ├── winbar.lua      (existing custom plugin)
  ├── claude-edit.lua (existing custom plugin)
  ├── component.lua   (existing custom plugin)
  ├── logger.lua      (existing custom plugin)
  └── tmux.lua        (existing custom plugin)
```

### Plugin directory convention

Third-party plugin configs and custom plugins live in `plugin/` side-by-side with **no naming distinction**. The origin is clear from content: custom plugins define their own functionality, third-party configs call `require("plugin-name").setup(...)`.

### Granularity

One `plugin/*.lua` file per current `specs/*.lua` file. Multi-spec bundles (e.g., `treesitter.lua` has 4 sub-specs) stay in one file — same structure as today.

### Hooks

`PackChanged` autocmd (defined before `vim.pack.add` in `init.lua`):

```lua
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})
```

### Update workflow

| Action | Command |
|---|---|
| Review available updates | `:packupdate` (interactive, LSP-powered confirmation buffer) |
| Review without downloading | `:packupdate ++offline` |
| Apply all immediately | `:packupdate!` |
| Delete inactive plugins | `:packdel ++all` |
| Revert to lockfile | `:packupdate ++offline ++lockfile` |
| Check for pending updates | `:lua =vim.pack.get(nil, { offline = false })` |

## Plugin Inventory

Complete mapping of every current `specs/*.lua` → `plugin/*.lua` with vim.pack spec:

### Always-loaded (currently `lazy = false`)

| plugin/*.lua | vim.pack spec |
|---|---|
| `mini.lua` | `{ src = "https://github.com/nvim-mini/mini.nvim", name = "mini.nvim", version = "stable" }` |
| `snacks.lua` | `{ src = "https://github.com/folke/snacks.nvim", name = "snacks.nvim" }` |
| `treesitter.lua` | `{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter", version = "main" }` |
| `treesitter.lua` | `{ src = "https://github.com/MeanderingProgrammer/treesitter-modules.nvim", name = "treesitter-modules.nvim" }` |
| `treesitter.lua` | `{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", name = "nvim-treesitter-textobjects", version = "main" }` |
| `fff.lua` | `{ src = "https://github.com/dmtrKovalenko/fff.nvim", name = "fff.nvim" }` |
| `black-atom.lua` | `{ src = "https://github.com/black-atom-industries/nvim", name = "black-atom.nvim" }` |

### Currently lazy via event/keys/cmd

| plugin/*.lua | vim.pack spec |
|---|---|
| `blink.lua` | `{ src = "https://github.com/Saghen/blink.cmp", name = "blink.cmp", version = vim.version.range("1.*") }` |
| `blink.lua` | LuaSnip + friendly-snippets (deps in same file) |
| `conform.lua` | `{ src = "https://github.com/stevearc/conform.nvim", name = "conform.nvim" }` |
| `lint.lua` | `{ src = "https://github.com/mfussenegger/nvim-lint", name = "nvim-lint" }` |
| `oil.lua` | `{ src = "https://github.com/stevearc/oil.nvim", name = "oil.nvim" }` |
| `supermaven.lua` | `{ src = "https://github.com/supermaven-inc/supermaven-nvim", name = "supermaven-nvim" }` |
| `trouble.lua` | `{ src = "https://github.com/folke/trouble.nvim", name = "trouble.nvim" }` |
| `typescript.lua` | `{ src = "https://github.com/dmmulroy/tsc.nvim", name = "tsc.nvim" }` |
| `codediff.lua` | `{ src = "https://github.com/esmuellert/codediff.nvim", name = "codediff.nvim" }` |
| `gitlinker.lua` | `{ src = "https://github.com/linrongbin16/gitlinker.nvim", name = "gitlinker.nvim" }` |
| `whatthejump.lua` | `{ src = "https://github.com/lewis6991/whatthejump.nvim", name = "whatthejump.nvim" }` |
| `ts-autotag.lua` | `{ src = "https://github.com/windwp/nvim-ts-autotag", name = "nvim-ts-autotag" }` |
| `ts-comments.lua` | `{ src = "https://github.com/folke/ts-comments.nvim", name = "ts-comments.nvim" }` |
| `treewalker.lua` | `{ src = "https://github.com/aaronik/treewalker.nvim", name = "treewalker.nvim" }` |
| `render-markdown.lua` | `{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown.nvim" }` |
| `annotator.lua` | `{ src = "https://github.com/chpeters/annotator.nvim", name = "annotator.nvim" }` |
| `spider.lua` | `{ src = "https://github.com/chrisgrieser/nvim-spider", name = "nvim-spider" }` |
| `schemastore.lua` | `{ src = "https://github.com/b0o/SchemaStore.nvim", name = "SchemaStore.nvim" }` |
| `vim-sleuth.lua` | `{ src = "https://github.com/tpope/vim-sleuth", name = "vim-sleuth" }` |

### Other

| plugin/*.lua | vim.pack spec |
|---|---|
| `flux.lua` | `{ src = "https://github.com/nikbrunner/flux.nvim", name = "flux.nvim" }` |
| `grug.lua` | `{ src = "https://github.com/MagicDuck/grug-far.nvim", name = "grug-far.nvim" }` |
| `helpview.lua` | `{ src = "https://github.com/OXY2DEV/helpview.nvim", name = "helpview.nvim" }` |
| `kulala.lua` | `{ src = "https://github.com/mistweaverco/kulala.nvim", name = "kulala.nvim" }` |
| `mdn.lua` | `{ src = "https://github.com/nikbrunner/mdn.nvim", name = "mdn.nvim" }` |
| `navigator.lua` | `{ src = "https://github.com/numToStr/Navigator.nvim", name = "Navigator.nvim" }` |
| `oklch.lua` | (bundled in mini.nvim, handled by mini config) |
| `qmk.lua` | `{ src = "https://github.com/codethread/qmk.nvim", name = "qmk.nvim" }` |
| `lazydev.lua` | `{ src = "https://github.com/folke/lazydev.nvim", name = "lazydev.nvim" }` |

### Removed

| Reason | Plugin |
|---|---|
| Deleted (Mason→mise) | `mason.lua` |
| Deleted (gitpad) | `gitpad.lua` |
| Deleted (fugit→flux) | `fugit.lua` |
| Disabled (MiniClue) | `which-key.lua` — not in vim.pack list |

## Files Changed

| File | Action |
|---|---|
| `init.lua` | Replace lazy.nvim bootstrap + `lazy.setup()` with `PackChanged` autocmd + `vim.pack.add()` |
| `lua/specs/*.lua` | **Delete all** |
| `plugin/*.lua` | **Create** one per spec with config code |
| `lazy-lock.json` | **Delete** |
| `nvim-pack-lock.json` | **Add** to VCS (auto-generated by vim.pack) |

### Files NOT changed

`lua/config.lua`, `lua/options.lua`, `lua/keymaps.lua`, `lua/autocmd.lua`, `lua/lsp-config.lua`, `lua/lib/*.lua`, `lua/state.lua`, `lsp/*.lua`, `colors/*.lua`, `snippets/*.lua`, `ftplugin/*.lua` — all unchanged.

## init.lua Target State

```lua
-- Hooks (before vim.pack.add for install events)
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

require("config")
require("options")
require("lib")
require("keymaps")
require("autocmd")
require("lsp-config")

vim.pack.add({
  -- Core
  { src = "https://github.com/nvim-mini/mini.nvim", name = "mini.nvim", version = "stable" },
  -- UI
  { src = "https://github.com/folke/snacks.nvim", name = "snacks.nvim" },
  { src = "https://github.com/folke/trouble.nvim", name = "trouble.nvim" },
  -- Completion
  { src = "https://github.com/Saghen/blink.cmp", name = "blink.cmp", version = vim.version.range("1.*") },
  { src = "https://github.com/L3MON4D3/LuaSnip", name = "LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets", name = "friendly-snippets" },
  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter", version = "main" },
  { src = "https://github.com/MeanderingProgrammer/treesitter-modules.nvim", name = "treesitter-modules.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", name = "nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/windwp/nvim-ts-autotag", name = "nvim-ts-autotag" },
  { src = "https://github.com/folke/ts-comments.nvim", name = "ts-comments.nvim" },
  { src = "https://github.com/aaronik/treewalker.nvim", name = "treewalker.nvim" },
  -- LSP & Formatting
  { src = "https://github.com/stevearc/conform.nvim", name = "conform.nvim" },
  { src = "https://github.com/mfussenegger/nvim-lint", name = "nvim-lint" },
  { src = "https://github.com/dmmulroy/tsc.nvim", name = "tsc.nvim" },
  { src = "https://github.com/folke/lazydev.nvim", name = "lazydev.nvim" },
  -- Git
  { src = "https://github.com/linrongbin16/gitlinker.nvim", name = "gitlinker.nvim" },
  { src = "https://github.com/nikbrunner/flux.nvim", name = "flux.nvim" },
  { src = "https://github.com/esmuellert/codediff.nvim", name = "codediff.nvim" },
  -- File Navigation
  { src = "https://github.com/stevearc/oil.nvim", name = "oil.nvim" },
  { src = "https://github.com/dmtrKovalenko/fff.nvim", name = "fff.nvim" },
  { src = "https://github.com/numToStr/Navigator.nvim", name = "Navigator.nvim" },
  -- Editing
  { src = "https://github.com/chrisgrieser/nvim-spider", name = "nvim-spider" },
  { src = "https://github.com/tpope/vim-sleuth", name = "vim-sleuth" },
  { src = "https://github.com/lewis6991/whatthejump.nvim", name = "whatthejump.nvim" },
  -- Markdown & Docs
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown.nvim" },
  { src = "https://github.com/OXY2DEV/helpview.nvim", name = "helpview.nvim" },
  { src = "https://github.com/nikbrunner/mdn.nvim", name = "mdn.nvim" },
  -- Search
  { src = "https://github.com/MagicDuck/grug-far.nvim", name = "grug-far.nvim" },
  -- HTTP / API
  { src = "https://github.com/mistweaverco/kulala.nvim", name = "kulala.nvim" },
  -- Annotations
  { src = "https://github.com/chpeters/annotator.nvim", name = "annotator.nvim" },
  -- Themes
  { src = "https://github.com/black-atom-industries/nvim", name = "black-atom.nvim" },
  -- Misc
  { src = "https://github.com/b0o/SchemaStore.nvim", name = "SchemaStore.nvim" },
  { src = "https://github.com/codethread/qmk.nvim", name = "qmk.nvim" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim", name = "supermaven-nvim" },
}, { load = true })
```

## plugin/*.lua Examples

Each file is the config/setup code extracted from the current spec:

```lua
-- plugin/blink.lua
local luasnip = require("luasnip")
luasnip.setup({})
require("luasnip.loaders.from_vscode").lazy_load()
-- ...blink.cmp.setup({...})...
-- ...vim.lsp.config("*", { capabilities = ... })...
```

```lua
-- plugin/treesitter.lua
vim.filetype.add({ extension = { mdx = "mdx" } })
vim.treesitter.language.register("markdown", "mdx")
-- ...stale node fix...
-- ...folds query override...
-- ...treesitter-modules setup...
```

## Rollback

The migration is done on a git worktree (branch `experiment/vim-pack`). To rollback: delete the worktree and branch. Main config is untouched.

## Open Questions

1. **lazydev.nvim** — currently integrates with `lazy.nvim` for LSP library paths (e.g., `{ path = "lazy.nvim", words = { "Snacks" } }`). Without lazy.nvim, we configure it statically: `{ path = "snacks.nvim", words = { "Snacks" } }, { path = "luvit-meta/library", words = { "vim%.uv" } }`. Confirm this works.

2. **Dependency ordering** — `vim.pack.add()` registers all plugins, then `plugin/*.lua` is sourced alphabetically. If plugin B's config calls `require("plugin-A")` and `plugin-a.lua` is alphabetically after `plugin-b.lua`, the require will still work because the plugin is in rtp from `vim.pack.add({ load = true })`. The config order only matters for side effects. Verify no ordering issues.

3. **Disabled plugins** — which-key.nvim is disabled (MiniClue replaces it). Simply not listed in vim.pack.add(). Confirm nothing references it.

## Implementation Steps (when ready)

1. Ensure nightly Neovim is installed (`nvim --version` shows 0.13-dev)
2. Create worktree: `git worktree add ../dots-vim-pack -b experiment/vim-pack`
3. Write new `init.lua` with PackChanged + vim.pack.add()
4. For each `specs/*.lua`: create `plugin/*.lua` with config code
5. Delete all `specs/*.lua`
6. Delete `lazy-lock.json`
7. `:restart` → verify `nvim-pack-lock.json` is created
8. Test: `nvim --headless -c 'checkhealth'`, LSP attach, treesitter highlight, picker, mini.diff
9. Commit `nvim-pack-lock.json`
10. Document `:packupdate` workflow