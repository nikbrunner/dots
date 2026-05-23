# `nbr.nvim`

<a href="https://dotfyle.com/nikbrunner/nbrnvim"><img src="https://dotfyle.com/nikbrunner/nbrnvim/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/nikbrunner/nbrnvim"><img src="https://dotfyle.com/nikbrunner/nbrnvim/badges/leaderkey?style=flat" /></a>
<a href="https://dotfyle.com/nikbrunner/nbrnvim"><img src="https://dotfyle.com/nikbrunner/nbrnvim/badges/plugin-manager?style=flat" /></a>

My personal Neovim configuration, tailored for frontend web engineering.

This config is managed as part of my [dots](https://github.com/nikbrunner/dots) repo and symlinked to `~/.config/nvim` via `dots link`.

## Keymap

This config uses [`AWDCS`](https://github.com/nikbrunner/awdcs) keymap principles.

Leader: `,` — Local leader: `.`

| Prefix | Group | | Prefix | Group |
| |-|-|-|-|-|
| `<leader>a` | [A]pp | | `<leader>s` | [S]ymbol |
| `<leader>d` | [D]ocument | | `<leader>w` | [W]orkspace |
| `<leader>c` | [C]hange | | `<leader>n` | [N]otes |
| `<leader>h` | [H]ttp (Kulala) | | `<leader>x` | Trouble/Quickfix |

## Install

### Prerequisites

- Neovim 0.10+
- A [Nerd Font](https://github.com/ryanoasis/nerd-fonts) (JetBrainsMono Nerd Font recommended)
- [mise](https://mise.jdx.dev/) or system packages for LSP servers, formatters, and linters

### Setup (via dots)

This is how I manage it — the config lives inside my dotfiles and is symlinked to `~/.config/nvim`:

```sh
git clone git@github.com:nikbrunner/dots ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
dots link
```

Then open Neovim — `lazy.nvim` will bootstrap and install all plugins on first run.

### Setup (NVIM_APPNAME)

Use this method to install alongside an existing Neovim config without conflicts:

```sh
# Clone the repo
git clone git@github.com:nikbrunner/nbr.nvim ~/.config/nbr

# Install plugins
NVIM_APPNAME=nbr nvim --headless +"Lazy! sync" +qa
```

Open with:

```sh
NVIM_APPNAME=nbr nvim
```

Or set up a shell alias in `.zshrc` / `.bashrc`:

```sh
alias nbr="NVIM_APPNAME=nbr nvim"
```

Plugin data lives in `~/.local/share/nbr` and state in `~/.local/state/nbr`, keeping it fully isolated from your default `nvim` config.

### Setup (standalone — replaces default config)

```sh
git clone git@github.com:nikbrunner/nbr.nvim ~/.config/nvim
nvim --headless +"Lazy! sync" +qa
```

## Project Structure

```
nvim/
├── init.lua                  # Bootstrap — lazy.nvim + module loading
├── lua/
│   ├── config.lua            # Colorscheme, paths, dev mode
│   ├── options.lua           # Vim options & settings
│   ├── keymaps.lua           # General keymaps
│   ├── autocmd.lua           # Autocommands
│   ├── state.lua             # Global runtime state (gh PR context, etc.)
│   ├── hotreload.lua         # Dev hot-reload support
│   ├── directory-watcher.lua # Auto-cd to git root
│   ├── specs/                # Plugin specs (lazy.nvim)
│   └── lib/                  # Shared utilities (tabline, sessions, git, lsp, …)
├── lsp/                      # Per-server LSP configs (auto-discovered)
├── plugin/                   # Immediate-load scripts (claude-edit, tmux, …)
├── colors/                   # Custom colorscheme overrides
├── after/queries/            # Treesitter query overrides (markdown)
├── snippets/                 # Custom snippets (Lua + JSON)
├── ftplugin/                 # Filetype-specific settings
├── spell/                   # Spell files (en, de)
└── sessions/                 # Mini.sessions auto-saved session files
```

## Plugins

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim). All plugins load lazily unless marked `lazy = false`.

| Plugin                                                                                     | Purpose                                                            |
| ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------ |
| [snacks.nvim](https://github.com/folke/snacks.nvim)                                        | Picker, explorer, lazygit, notifier, terminal, git, words, bigfile |
| [blink.cmp](https://github.com/saghen/blink.cmp)                                           | Autocompletion + signature help                                    |
| [mini.nvim](https://github.com/echasnovski/mini.nvim)                                      | Sessions, icons, clue, ai, surround, pairs, …                      |
| [black-atom](https://github.com/black-atom-industries/nvim)                                | Colorscheme (Terra Fall Night default)                             |
| [radar.nvim](https://github.com/black-atom-industries/radar.nvim)                          | Tab-style buffer bar                                               |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                      | Syntax highlighting & textobjects                                  |
| [trouble.nvim](https://github.com/folke/trouble.nvim)                                      | Diagnostics list                                                   |
| [oil.nvim](https://github.com/stevearc/oil.nvim)                                           | File editing (buffer-based)                                        |
| [conform.nvim](https://github.com/stevearc/conform.nvim)                                   | Formatting                                                         |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint)                                     | Linting                                                            |
| [mason.nvim](https://github.com/williamboman/mason.nvim)                                   | LSP server installer                                               |
| [supermaven-nvim](https://github.com/supermaveninc/supermaven-nvim)                        | AI inline completions                                              |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip)                                             | Snippet engine                                                     |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim)                                      | Lua dev setup for Neovim runtime                                   |
| [which-key.nvim](https://github.com/folke/which-key.nvim)                                  | Keymap discovery (disabled — using MiniClue)                       |
| [kulala.nvim](https://github.com/mistweaverco/kulala.nvim)                                 | HTTP client (REST)                                                 |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)       | Markdown rendering                                                 |
| [helpview.nvim](https://github.com/OXY2DEV/helpview.nvim)                                  | Help doc rendering                                                 |
| [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)                                | Find & replace                                                     |
| [gitlinker.nvim](https://github.com/linrongbin16/gitlinker.nvim)                           | GitHub permalink                                                   |
| [gitpad.nvim](https://github.com/yujinyuz/gitpad.nvim)                                     | Git scratch buffer                                                 |
| [flux.nvim](https://github.com/nikbrunner/flux.nvim)                                       | Git blame viewer (renamed from fugit)                              |
| [oklch-color-picker.nvim](https://github.com/eero-lehtinen/oklch-color-picker.nvim)        | OKLCH color picker                                                 |
| [spider.nvim](https://github.com/chrisgrieser/nvim-spider)                                 | Motion by sub-word                                                 |
| [annotator.nvim](https://github.com/chpeters/annotator.nvim)                               | Annotation rendering                                               |
| [codediff.nvim](https://github.com/esmuellert/codediff.nvim)                               | Code diff viewer                                                   |
| [fff.nvim](https://github.com/dmtrKovalenko/fff.nvim)                                      | File finding                                                       |
| [fff-snacks.nvim](https://github.com/nikbrunner/fff-snacks.nvim)                           | Snacks integration for fff                                         |
| [qmk.nvim](https://github.com/codethread/qmk.nvim)                                         | QMK keyboard layout visualization                                  |
| [navigator.nvim](https://github.com/numToStr/Navigator.nvim)                               | Window navigation (tmux integration)                               |
| [mdn.nvim](https://github.com/nikbrunner/mdn.nvim)                                         | MDN docs                                                           |
| [review.nvim](https://github.com/nikbrunner/review.nvim)                                   | Code review (codediff dependency)                                  |
| [treesitter-modules.nvim](https://github.com/MeanderingProgrammer/treesitter-modules.nvim) | Treesitter module management                                       |
| [treewalker.nvim](https://github.com/aaronik/treewalker.nvim)                              | Treesitter-based navigation                                        |
| [ts-comments.nvim](https://github.com/folke/ts-comments.nvim)                              | Comment strings per filetype                                       |
| [ts-error-translator.nvim](https://github.com/dmmulroy/ts-error-translator.nvim)           | TypeScript error translation                                       |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)                               | Auto-close/rename HTML tags                                        |
| [whatthejump.nvim](https://github.com/lewis6991/whatthejump.nvim)                          | Jump list visualization                                            |
| [tsc.nvim](https://github.com/dmmulroy/tsc.nvim)                                           | Type-check project                                                 |
| [vim-sleuth](https://github.com/tpope/vim-sleuth)                                          | Auto-detect indentation                                            |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim)                                        | UI component library (codediff dependency)                         |
| [markdown-table-wrap.nvim](https://github.com/vasilispher/markdown-table-wrap.nvim)        | Markdown table formatting                                          |
| [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)                                | JSON schema catalog                                                |

## LSP Servers

Auto-discovered from `lsp/*.lua`. Enabled servers:

`astro` · `bashls` · `biome` · `cssls` · `cssvariables` · `denols` · `eslint` · `gopls` · `jsonls` · `lua_ls` · `marksman` · `md-oxide` · `rust_analyzer` · `tailwindcss` · `taplo` · `tsgo` · `vtsls` · `yamlls`

## Formatting & Linting

- **Formatting**: [conform.nvim](https://github.com/stevearc/conform.nvim) — see `lua/specs/conform.lua`
- **Linting**: [nvim-lint](https://github.com/mfussenegger/nvim-lint) — see `lua/specs/lint.lua`
- **Markdown**: `markdown-table-wrap.nvim` for table formatting, `render-markdown.nvim` for rendering

## Development

### Lua Diagnostics

```sh
lua-language-server --check ./lua --logpath=. --configpath="$(pwd)/.luarc.json"
```

### Formatting

```sh
stylua .
```

Uses the settings in `stylua.toml` (4-space indent, 125 col width, auto-prefer-double quotes).

## Dev Mode

`config.lua` has a `dev_mode` flag. When enabled, plugins from `black-atom-industries` and `nikbrunner` load from local repos under `~/repos/` instead of downloading from GitHub — enabling hot-reload during development.

## Links

- [Neovim docs](https://neovim.io/doc/user/index.html)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [blink.cmp](https://cmp.saghen.dev/)
- [AWDCS keymap](https://github.com/nikbrunner/awdcs)
