# `nbr.nvim`

<a href="https://dotfyle.com/nikbrunner/nbrnvim"><img src="https://dotfyle.com/nikbrunner/nbrnvim/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/nikbrunner/nbrnvim"><img src="https://dotfyle.com/nikbrunner/nbrnvim/badges/leaderkey?style=flat" /></a>
<a href="https://dotfyle.com/nikbrunner/nbrnvim"><img src="https://dotfyle.com/nikbrunner/nbrnvim/badges/plugin-manager?style=flat" /></a>

My personal Neovim configuration, tailored for frontend web engineering.

This config is managed as part of my [dots](https://github.com/nikbrunner/dots) repo and symlinked to `~/.config/nvim` via `dots link`.

## 📚 Table of Contents

- [Keymap](#keymap)
- [Install](#install)
  - [Prerequisites](#prerequisites)
  - [Setup (via dots)](#setup-via-dots)
  - [Setup (NVIM_APPNAME)](#setup-nvim_appname)
  - [Setup (standalone)](#setup-standalone--replaces-default-config)
- [Project Structure](#project-structure)
- [Plugins](#plugins)
- [LSP Servers](#lsp-servers)
- [Formatting & Linting](#formatting--linting)
- [Development](#development)
  - [Lua Diagnostics](#lua-diagnostics)
  - [Formatting](#formatting-1)
- [Dev Mode](#dev-mode)
- [Links](#links)

## Keymap

This config uses [`AWDCS`](https://github.com/nikbrunner/awdcs) keymap principles.

Leader: `,` — Local leader: `.`

| Prefix      | Group           |     | Prefix      | Group            |
| ----------- | --------------- | --- | ----------- | ---------------- |
| `<leader>a` | [A]pp           |     | `<leader>s` | [S]ymbol         |
| `<leader>d` | [D]ocument      |     | `<leader>w` | [W]orkspace      |
| `<leader>c` | [C]hange        |     | `<leader>n` | [N]otes          |
| `<leader>h` | [H]ttp (Kulala) |     | `<leader>x` | Trouble/Quickfix |

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

Look at the [`lazy-lock.json` file](common/.config/nvim/lazy-lock.json) to see which plugins are installed.

## LSP Servers

Auto-discovered from `lsp/*.lua`. Enabled servers:

`astro` · `bashls` · `biome` · `cssls` · `cssvariables` · `denols` · `eslint` · `gopls` · `jsonls` · `lua_ls` · `marksman` · `rust_analyzer` · `tailwindcss` · `taplo` · `tsgo` · `vtsls` · `yamlls`

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
