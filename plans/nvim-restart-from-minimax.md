# Neovim Config Restart — from `nvim-minimax` base

## How to use this plan

This plan is designed to be worked through over **multiple sessions** — each step is a coherent chunk that you can complete, verify, and commit independently. A suggested session breakdown:

| Session | Steps                                              | Goal                                                  |
| ------- | -------------------------------------------------- | ----------------------------------------------------- |
| 1       | Steps 1–3                                          | Bootstrap: empty folder, symlink, alias, minimal init.lua |
| 2       | Steps 4–5                                          | `plugin/20_keymaps.lua` + `plugin/30_autocmds.lua` (global keymaps + autocmds) |
| 3       | Step 6                                             | LSP setup (`after/lsp/`)                              |
| 4       | Step 7.5 (worked example) + Step 7 (mini)         | Port `plugin/50_specs/mini.lua` (the foundational mini.nvim config) |
| 5–8     | Step 7 (remaining 22 plugins)                      | One or two plugins per session, each verified         |
| 9       | Step 8 (personal tools)                            | tmux, logger, component, pi-edit                      |
| 10      | Steps 9–10 (colors, snippets, ftplugin, spell)     | Visual + content files                                |
| 11      | Steps 11–12 (lib helpers, CLAUDE.md)               | Cleanup + docs                                        |
| 12      | Steps 13–14 (first launch + verification)          | Smoke test                                            |
| 13      | Steps 15–16 (cut over + retire)                    | Make `edit`/`vin` the default; remove old config       |

Each step has its own checkboxes (`- [ ]`) for progress tracking. Commit after each step (or each session) to make rollback easy.

## Context

Current personal config (`common/.config/nvim/`, aliased as `vin → nvim_mnml`) has grown organically: lazy.nvim + 24 plugin specs, 14+ LSP server configs, a sprawling `lua/` tree, a hand-rolled `lua/specs/mini.lua` (~900 lines) that re-implements parts of `mini.nvim` on top of lazy, plus personal plugins (winbar, tmux, claude-edit, component, logger).

The MiniMax base config (`common/.config/nvim-minimax/`, aliased as `mini`) is lean: `vim.pack` (built-in), a single `mini.nvim` dependency, four `plugin/*.lua` files, two `after/` examples. It demonstrates a great **toolkit** (`vim.pack` + `mini.*`), but its **file structure conventions** (numbered prefixes, opinionated layout) are not what we want to inherit verbatim.

**Goal**: build a third config from scratch — no MiniMax skeleton, no numbered-prefix convention, no `Config.*` helper API. Just a clean personal config that uses `vim.pack` and `mini.*` as libraries. Old `vin` config stays untouched until the new one is verified.

## Approach

1. **Seed** an empty `nvim-edit/` folder.
2. **Symlink** it as a third `NVIM_APPNAME` entry alongside `mini`, `vin`, `lazyvim`.
3. **Build** the personal config from scratch: minimal `init.lua` (Config helpers + `vim.pack.add('mini.nvim')`). Then `plugin/10_options.lua` + `plugin/20_keymaps.lua` + `plugin/30_autocmds.lua` for personal config, and `plugin/50_specs/*.lua` for plugin specs. No sub-structure beyond what the number prefix on `50_specs/` implies.
4. **Port** all 24 lazy specs from the old config (no filtering in the first pass — keep redundancies, decide later).
5. **Validate** by running with the new `NVIM_APPNAME` and walking the existing test surface.
6. **Cut over** by switching the default `vin` alias.
7. **Retire** the old `nvim_mnml` config in a separate commit.

The migration is **additive**, not subtractive: the goal of the first pass is to get **everything** working, even if there are redundancies (e.g. `spider.lua` + `mini.jump` both being installed). A future pass can prune.

## Naming

The existing aliases are:

| Alias        | App name        | Status                |
| ------------ | --------------- | --------------------- |
| `vin`        | `nvim_mnml`     | Current personal — to retire |
| `mini`       | `nvim-minimax`  | Clean base — keep as reference |
| `lazyvim`    | `lazyvim`       | LazyVim stock         |
| `edit`       | `nvim-edit`     | **NEW** — the merged config |

**App name**: `nvim-edit` · **Alias**: `edit`. (Short, punchy, evokes the "go in and tweak things" intent of the restart.)

## Files to modify

### New files (created by this plan)

- `common/.config/nvim-edit/` — the new config (empty, built from scratch)
- `common/.config/nvim-edit/CLAUDE.md` — port of the current nvim CLAUDE.md, updated for `vim.pack`

### Edited files

- `common/.zshrc` — add `alias edit="NVIM_APPNAME=nvim-edit nvim"` next to the existing `mini` / `vin` / `lazyvim` aliases
- `symlinks.yml` — add `common/.config/nvim-edit: ~/.config/nvim-edit` (and `~` for `vim.pack` data dir if needed)

### Files NOT touched (yet)

- `common/.config/nvim/` (old `vin`) — kept intact for the duration of the migration
- `common/.config/nvim-minimax/` — kept intact as a reference / fallback
- All `lsp/`, `plugin/winbar.lua`, `plugin/tmux.lua`, etc. in the old config — read for porting, not modified (these will be ported to `plugin/50_specs/`)

## Architecture: old → new

`plugin/*.lua` files are sourced in **alphabetical order** by Neovim. **All files in `plugin/` are auto-loaded, including files in subdirectories of `plugin/`.** Load order is alphabetic, even across subdirectories. A number prefix on a subdirectory (e.g. `50_specs/`) makes it sort after all top-level files.

```
init.lua                          (minimal: Config helpers + load mini.nvim)
plugin/
├── 10_options.lua                (auto-loaded first; sets all options)
├── 20_keymaps.lua                (auto-loaded second; global keymaps only)
├── 30_autocmds.lua               (auto-loaded third; all autocmds)
└── 50_specs/                     (subdir sorts after 30_ because 5 > 3 in ASCII)
    ├── mini.lua                  (mini.nvim plugin config: setup() calls for mini.* modules)
    ├── conform.lua
    ├── kulala.lua
    ├── black-atom.lua
    └── ... (all 24+)
```

**Why this works (verified empirically):**

- `init.lua` is minimal (5–10 lines of actual logic)
- Each personal config concern (options, keymaps, autocmds) lives in its own clearly-numbered file in `plugin/`
- `plugin/50_specs/` is the home for all plugin specs (own and third-party, treated the same)
- No loader file needed — Neovim auto-loads everything in `plugin/` recursively
- Number prefixes give explicit control over load order; subdirectory naming follows the same scheme
- Plugin-specific keymaps (e.g. `<leader>lf` for conform) live in the spec file, not in `plugin/20_keymaps.lua`. The keymaps file is **only for global cross-cutting keymaps** (leader, common motions, terminal mode exit, etc.)

| Old (lazy-based)                          | New (vim.pack + mini, fresh)                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------------- |
| `lua/config.lua`                          | `init.lua` (minimal bootstrap)                                                         |
| `lua/options.lua`                         | `plugin/10_options.lua`                                                                |
| `lua/keymaps.lua` + `lib/*.lua` keymaps   | `plugin/20_keymaps.lua` (global only) + plugin-specific keymaps in each spec file       |
| `lua/autocmd.lua`                         | `plugin/30_autocmds.lua`                                                               |
| `lua/lsp-config.lua`                      | `after/lsp/init.lua` (per-buffer attach) + per-LSP server configs in `after/lsp/<name>.lua` |
| `lua/specs/<name>.lua` (24 files)         | **All 24 ported** as `plugin/50_specs/<name>.lua`                                       |
| `lsp/<server>.lua`                        | `after/lsp/<server>.lua` — **copy as-is**, the file format is already `:h vim.lsp.Config` compatible |
| `plugin/winbar.lua`                       | `plugin/50_specs/winbar.lua` — own "plugin" spec, treated the same as third-party     |
| `plugin/tmux.lua`                         | `plugin/50_specs/tmux.lua`                                                             |
| `plugin/component.lua`                    | `plugin/50_specs/component.lua`                                                        |
| `plugin/logger.lua`                       | `plugin/50_specs/logger.lua`                                                           |
| `plugin/claude-edit.lua`                  | `plugin/50_specs/pi-edit.lua` — with `pi -p` backend                                   |
| `colors/*.lua`                            | `colors/*.lua` — **copy as-is**                                                         |
| `ftplugin/markdown.lua`                   | `ftplugin/markdown.lua` — copy as-is                                                   |
| `after/queries/markdown/*`                | `after/queries/markdown/*` — copy as-is                                                 |
| `snippets/*`                              | `snippets/*` — copy, `mini.snippets` expects the same JSON format                       |
| `spell/*`                                 | `spell/*` — copy as-is                                                                 |
| `.luarc.json`, `.luacheckrc`, `stylua.toml` | Personal preferences — `indent_width = 2`, `column_width = 125`                        |
| `lazy-lock.json`                          | **Delete** — replaced by `nvim-pack-lock.json` (auto-generated by `vim.pack`)           |
| `lib/sessions.lua` (custom)               | Port as `lua/sessions.lua` — use alongside `mini.sessions` (it complements rather than replaces) |

### Target file structure

```
nvim-edit/
├── init.lua                          (minimal: defines Config helpers + loads mini.nvim)
├── plugin/
│   ├── 10_options.lua                (auto-loaded first; sets all options)
│   ├── 20_keymaps.lua                (auto-loaded second; global keymaps only)
│   ├── 30_autocmds.lua               (auto-loaded third; all autocmds)
│   └── 50_specs/                     (subdir, sorts after 30_; one file per plugin spec)
│       ├── mini.lua                  (mini.nvim config: setup() calls for mini.* modules)
│       ├── snacks.lua
│       ├── black-atom.lua            (local-repos-friendly, see Local Dev section)
│       ├── blink.lua
│       ├── codediff.lua
│       ├── conform.lua
│       ├── gitlinker.lua
│       ├── grug.lua
│       ├── helpview.lua
│       ├── kulala.lua
│       ├── lazydev.lua
│       ├── lint.lua
│       ├── mdn.lua
│       ├── navigator.lua
│       ├── oklch.lua
│       ├── qmk.lua
│       ├── radar.lua
│       ├── schemastore.lua
│       ├── spider.lua
│       ├── supermaven.lua
│       ├── treesitter.lua
│       ├── trouble.lua
│       ├── typescript.lua
│       ├── whatthejump.lua
│       ├── winbar.lua                (own)
│       ├── tmux.lua                  (own)
│       ├── component.lua             (own)
│       ├── logger.lua                (own)
│       └── pi-edit.lua               (own, port of claude-edit, using `pi -p`)
├── after/
│   ├── lsp/                          (LSP server configs — copy from old `lsp/`)
│   │   ├── init.lua                  (enable + per-buffer attach)
│   │   ├── lua_ls.lua
│   │   ├── tsgo.lua
│   │   ├── vtsls.lua
│   │   └── ... (all 14 from old config)
│   ├── ftplugin/
│   │   └── markdown.lua
│   ├── queries/
│   │   └── markdown/
│   │       ├── highlights.scm
│   │       └── injections.scm
│   ├── snippets/
│   │   └── lua.json
│   └── plugin/                       (canonical Neovim override tier)
│       └── (last-look overrides go here)
├── colors/                           (copy of old `colors/*.lua`)
│   ├── default.lua
│   ├── habamax.lua
│   ├── minigreen.lua
│   └── (black-atom comes from the black-atom plugin's own `colors/`)
├── snippets/
│   ├── global.json
│   └── markdown.json
├── ftplugin/
│   └── markdown.lua
├── spell/                            (de.utf-8 + en.utf-8)
├── lua/                              (shared Lua modules, only if needed)
│   ├── copy.lua                      (port of `lib/copy.lua` helpers)
│   └── sessions.lua                  (port of `lib/sessions.lua` — pairs with mini.sessions)
├── .gitignore                        (ignores `sessions/`, `*.swp`, etc.)
├── .luacheckrc
├── .luarc.json
├── stylua.toml
├── CLAUDE.md
└── nvim-pack-lock.json               (auto-generated, committed)
```

### Local development pattern

Per [neovim/neovim#35173](https://github.com/neovim/neovim/discussions/35173), the cleanest local-dev approach with `vim.pack` is to **prepend the local path to `runtimepath`** instead of using `vim.pack.add` at all:

```lua
-- plugin/50_specs/black-atom.lua
later(function()
  -- Production (committed):
  vim.pack.add({ 'https://github.com/black-atom-industries/nvim' })

  -- Development: comment line above, uncomment below — no other setup needed:
  -- vim.opt.rtp:prepend(vim.fn.expand('~/repos/black-atom-industries/nvim'))

  require('black-atom').setup({ ... })
end)
```

Why this is better than the `pack/mine/` symlink approach:
- Local file edits are picked up on **next `nvim` launch** — no commit, no `:packupdate`
- No symlink script, no separate `pack/mine/` directory
- The toggle is a single comment flip
- Falls through to the same `require('black-atom').setup()` call regardless of source

To switch back: comment the rtp line, uncomment the `vim.pack.add` line.

## Steps

### Step 1 — Seed an empty new config folder

```bash
mkdir -p common/.config/nvim-edit
```

Add to `symlinks.yml` (alphabetical position next to `nvim-minimax`):

```yaml
  common/.config/nvim-edit: ~/.config/nvim-edit
```

Then `dots link`.

### Step 2 — Add the zshrc alias

In `common/.zshrc`, next to the existing `vin` / `mini` / `lazyvim` aliases:

```bash
alias edit="NVIM_APPNAME=nvim-edit nvim"
```

Open a new shell and verify: `edit` opens an empty Neovim (no plugins yet — that's step 3+).

### Step 3 — Set up minimal `init.lua` (bootstrap only)

`init.lua` is **minimal** — it only defines the `Config` helpers and loads `mini.nvim`. Everything else (options, keymaps, autocmds, mini setup, plugin specs) lives in `plugin/` files.

```lua
-- ┌────────────────────────────────────────┐
-- │ nvim-edit — init.lua (minimal bootstrap)│
-- └────────────────────────────────────────┘
-- Defines the Config table, helpers, and loads mini.nvim.
-- Options, keymaps, autocmds live in plugin/10_*.lua (auto-loaded).
-- Plugin specs live in plugin/50_specs/*.lua (auto-loaded).

-- ┌────────────────┐
-- │ Config helpers │
-- └────────────────┘

_G.Config = {}

local gr = vim.api.nvim_create_augroup('nvim-edit', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = gr, pattern = pattern, callback = callback, desc = desc })
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

-- ┌────────────────┐
-- │ Load mini.nvim │
-- └────────────────┘
-- (must come before defining Config.now/later so they can use mini.misc.safely)

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end
```

**Verification (per-session checklist):**

- [ ] `edit` launches without errors
- [ ] `:lua print(vim.inspect(Config))` shows the Config table with all helpers
- [ ] `require('mini.misc')` works (mini.nvim is loaded)
- [ ] `:lua print(MiniMisc and 'yes' or 'no')` returns `'yes'`
- [ ] `:messages` is clean (no errors)

After this step, all the plugin files (10/20/30/50_specs) don't exist yet, so the config will be bare. That's expected — they come in the next steps.

### Step 4 — Create `plugin/20_keymaps.lua` (global keymaps only)

`plugin/20_keymaps.lua` contains **only global keymaps** — mappings that apply everywhere. Plugin-specific keymaps (e.g. `<leader>lf` for conform format) live in the respective spec file in `plugin/50_specs/<name>.lua`.

Port from `common/.config/nvim/lua/keymaps.lua` to `plugin/20_keymaps.lua`. Mapping of original → new:

| Original keymap | New home                                                  |
| --------------- | --------------------------------------------------------- |
| `<Esc>` (clear hlsearch, save, hide notifier) | Append to "General mappings" — replace `require('snacks.notifier').hide()` with `MiniNotify.hide()` |
| `<S-Esc>` (close floats) | `vim.cmd('silent! close')` via `lua`                       |
| `<C-o>` / `<C-i>` (center on jump) | Manual `zz` centering — keep                                    |
| `N` / `n` with `zzzv` | `vim.keymap.set('n', 'N', 'Nzzzv', { desc = '...' })`     |
| `j` / `k` → `gj` / `gk` (visual-line aware) | Add to General mappings                                  |
| `<C-e>` (toggle buffer in tab) | Add to General mappings                                  |
| `J` / `K` (move lines in visual) | Add to `xmap`                                              |
| `<` / `>` (indent in visual, keep selection) | Add to `xmap`                                              |
| `,` / `.` / `;` (undo points) | Add to `imap`                                              |
| `x` → `"_x` | Add to `nmap`                                              |
| `yp` / `yc` (duplicate line) | Add to `nmap`                                              |
| `yA` (yank all) / `vA` (select all) | Add to `nmap`                                              |
| `<leader>dya/h/r/R/n` (copy helpers) | Add to `nmap`/`xmap` — port `lib/copy.lua` logic to a local helper or `lua/copy.lua` file |
| `H` / `L` (tab nav) | Add to `nmap`                                              |
| `<S-Arrow>` (resize) | Add to `nmap`/`xmap`                                       |
| `<C-s>` / `<C-q>` | Add to `nmap`                                              |
| `<leader>dl` (last doc) | Add to `nmap`                                              |
| `<leader>z` (open in Zed) | Add to `nmap`                                              |
| `<leader>w.` (cd to git root) | Add to `nmap` — use `vim.fs.root(0, { '.git' })`         |
| `<leader>ap/ali/all/am` (lazy UI) | **Drop** — no lazy.nvim. Replace with `<leader>ap = :lua print(vim.pack.update and 'vim.pack is the plugin manager')` or similar one-time hint, or just remove |
| `<leader>i` (show pos) | Add to `nmap`                                              |
| `<M-t>` (insert date) | Add to `imap`                                              |
| `<A-u/o/a/U/O/A>` (German umlauts) | Add to `imap`                                              |

`lib/copy.lua` helpers (`file_name`, `get_current_relative_path`, `full_path_from_home`, `full_path`) need to be ported. **Decision**: drop them in the initial pass, then add back as a `lua/copy.lua` file in the new config if you actually use them. Most users don't.

### Step 5 — Create `plugin/30_autocmds.lua` (all autocmds)

Port from `common/.config/nvim/lua/autocmd.lua` to `plugin/30_autocmds.lua`. All autocmds are mechanical translations:

- `VimEnter` — shada tmp cleanup (no change)
- `FileType` — closeable buffer types (the union of MiniMax's defaults + your old list)
- `BufReadPost` — restore last cursor (use `MiniMisc.setup_restore_cursor()` from the old custom logic, or keep the existing one)
- `TextYankPost` — `vim.hl.hl_op()` (or a simple 200ms flash)
- `VimResized` — equalize splits
- `BufEnter` (gitcommit) — 72-col wrap
- `FocusGained` — close stale buffers
- `LspProgress` — spinner notification (use `MiniNotify` for consistency)
- `FocusGained/TermLeave/BufEnter/WinEnter/CursorHold/CursorHoldI` — `:checktime`

### Step 6 — Port LSP setup

The `lsp/*.lua` files in the old config are **already in `:h vim.lsp.Config` format** — they should work as-is in `after/lsp/`. Copy the entire `lsp/` folder:

```bash
cp -r common/.config/nvim/lsp common/.config/nvim-edit/after/lsp
```

The `lua/lsp-config.lua` file from the old config is the glue. Port it to `after/lsp/init.lua`:

```lua
-- In after/lsp/init.lua
local function enable_lsp()
  local server_configs = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
    :map(function(file) return vim.fn.fnamemodify(file, ":t:r") end)
    :totable()
  vim.lsp.enable(server_configs)
end

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    if vim.g.SessionLoad == 1 then return end
    enable_lsp()
  end,
})

vim.api.nvim_create_autocmd("SessionLoadPost", { once = true, callback = enable_lsp })

vim.api.nvim_create_autocmd("LspAttach", {
  nested = true,
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Port <leader>sp, <leader>sh, <leader>sa, <leader>sn, <leader>sV, <leader>sT keymaps
    -- (see `lib/lsp.lua` in the old config for helpers)
  end,
})
```

LSP keymaps port:

- `<leader>sh` (hover) → keep (or rename to `<leader>lh` if you prefer a unified `l` group)
- `<leader>sa` (code action) → keep
- `<leader>sn` (rename) → keep
- `<leader>sp` (toggle inline diagnostics) → port as a buffer-local mapping; conflict-free at `<leader>up`
- `<leader>sV` (split definition) → drop, use `<C-w>v` after `<leader>ls`
- `<leader>sT` (tab definition) → drop, use `<C-w>t` after `<leader>ls`

**Significant cleanup opportunity**: the old config has a `lib/lsp.lua` with `goto_split_definition` / `goto_tab_definition` helpers. With `vim.o.switchbuf = 'usetab,vsplit'` you get the same behavior natively (this is already in the `nvim-0.12-migration.md` plan). Don't port those helpers.

### Step 7 — Port **all 24** plugin specs (no drops in the first pass)

**Decision**: port every single `lua/specs/<name>.lua` from the old config. Don't filter. Some will overlap with `mini.*` (e.g. `spider.lua` vs `mini.jump`) — that's fine. Future passes can prune.

| Old spec file         | Plugin                                    | Local dev | New file                             |
| --------------------- | ----------------------------------------- | --------- | ------------------------------------ |
| `annotator.lua`       | `nvim-lua/annotator.nvim`                 | —         | `plugin/annotator.lua`               |
| `black-atom.lua`      | `black-atom-industries/nvim` (×3 plugins) | ✓         | `plugin/50_specs/black-atom.lua`      |
| `blink.lua`           | `saghen/blink.cmp`                        | —         | `plugin/blink.lua`                   |
| `codediff.lua`        | `esmuellert/codediff.nvim`                | —         | `plugin/codediff.lua`                |
| `conform.lua`         | `stevearc/conform.nvim`                   | —         | `plugin/50_specs/conform.lua`         |
| `gitlinker.lua`       | `lewis6991/gitsigns.nvim` + others        | —         | `plugin/gitlinker.lua`               |
| `grug.lua`            | `grug-far` (or similar)                   | —         | `plugin/grug.lua`                    |
| `helpview.lua`        | `Helpview` plugin                         | —         | `plugin/helpview.lua`                |
| `kulala.lua`          | `mistweaverco/kulala.nvim`                | —         | `plugin/kulala.lua`                  |
| `lazydev.lua`         | `folke/lazydev.nvim`                      | —         | `plugin/lazydev.lua`                 |
| `lint.lua`            | `mfussenegger/nvim-lint`                  | —         | `plugin/lint.lua`                    |
| `mdn.lua`             | `EdenEast/mdn.nvim` (or similar)          | —         | `plugin/mdn.lua`                     |
| `mini.lua`            | `mini.nvim` (custom `setup`s)             | —         | `plugin/mini.lua` (full setup)        |
| `navigator.lua`       | `navigator.lua`                            | —         | `plugin/navigator.lua`               |
| `oklch.lua`           | `oklch` (color helper)                    | —         | `plugin/oklch.lua`                   |
| `qmk.lua`             | `qmk` plugin                              | ✓         | `plugin/qmk.lua`                     |
| `radar.lua` (in black-atom) | `black-atom-industries/radar.nvim` | ✓         | `plugin/radar.lua`                   |
| `schemastore.lua`     | `schemastore` (JSON schemas)              | —         | `plugin/schemestore.lua`             |
| `snacks.lua`          | `folke/snacks.nvim` (subset)              | —         | `plugin/snacks.lua`                  |
| `spider.lua`          | `spider` (motion plugin)                  | —         | `plugin/spider.lua`                  |
| `supermaven.lua`      | `supermaven.nvim`                         | —         | `plugin/supermaven.lua`              |
| `treesitter.lua`      | `nvim-treesitter` (race-fix + MDX)        | —         | `plugin/treesitter.lua`              |
| `trouble.lua`         | `folke/trouble.nvim`                      | —         | `plugin/trouble.lua`                 |
| `typescript.lua`     | `typescript` (wrappers)                   | —         | `plugin/typescript.lua`              |
| `whatthejump.lua`     | `whatthejump`                             | —         | `plugin/whatthejump.lua`             |

Each ported spec becomes a file like `plugin/50_specs/conform.lua`:

```lua
-- plugin/50_specs/conform.lua
later(function()
  vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
  require('conform').setup({
    default_format_opts = { lsp_format = 'fallback' },
    formatters_by_ft = {
      -- ... (merge from old `lua/specs/conform.lua`)
    },
    -- ... (keymaps, formatters from old spec)
  })
end)
```

Specs that need the local-dev pattern (black-atom, qmk, radar) get the `vim.opt.rtp:prepend()` swap (see Local Dev section).

### Step 7.5 — Worked example: full migration of `conform.lua`

Before porting the other 23 plugins, work through one end-to-end so the pattern is clear. **Conform** is a good choice — it has formatters-by-filetype, keymaps, options, and is the kind of plugin you set up once and forget.

**Source** (`common/.config/nvim/lua/specs/conform.lua`, ~140 lines): a `LazyPluginSpec` with `init = function() ... end`, `event = { 'BufReadPre', 'BufNewFile' }`, `cmd = { 'ConformInfo' }`, an `opts` table with formatters-by-filetype, keymaps, and a custom `on_init`/`on_attach` flow.

**Target** (`common/.config/nvim-edit/plugin/50_specs/conform.lua`):

```lua
-- plugin/50_specs/conform.lua
-- All-in-one file: install + config + keymaps for conform.nvim.

-- Install the plugin (deferred so it doesn't block startup)
Config.later(function()
  vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })

  -- Per-filetype formatter configuration (copied from old spec)
  require('conform').setup({
    default_format_opts = { lsp_format = 'fallback' },
    formatters_by_ft = {
      -- ... full list from old spec ...
      -- (e.g. stylua for lua, prettier for ts/tsx/js/json, biome for css,
      --  deno_fmt for deno projects, etc.)
    },
    format_on_save = function(bufnr)
      -- Disable in large buffers
      local max_lines = 500
      local lines = vim.api.nvim_buf_line_count(bufnr)
      if lines > max_lines then return nil end
      return { timeout_ms = 1500, lsp_format = 'fallback' }
    end,
  })
end)

-- Plugin-specific keymaps (live here, not in plugin/20_keymaps.lua)
nmap_leader('lf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, '[F]ormat buffer')
xmap_leader('lf', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end, '[F]ormat selection')
nmap('<leader>lF', function() require('conform').format({ async = true, lsp_format = 'fallback', formatters = { 'injected' } }) end, '[F]ormat (injected languages)')
```

**What changed from the old spec:**

| Old (`lua/specs/conform.lua`)        | New (`plugin/50_specs/conform.lua`)                     |
| ----------------------------------- | ------------------------------------------------------ |
| Wrapped in `LazyPluginSpec` table    | Top-level code (no wrapper)                            |
| `init = function() ... end`         | Top-level code (runs once at startup)                  |
| `event = { 'BufReadPre', ... }`      | `Config.later(function() ... end)` (deferred)          |
| `opts = { ... }`                    | `require('conform').setup({ ... })` (inline)            |
| `keys = { { '<leader>lf', ... } }`   | `nmap_leader('lf', ...)` (top-level)                    |
| Managed by `lazy.nvim`               | Managed by `vim.pack`                                  |

**Verification (per plugin)**:

- [ ] Plugin shows up in `vim.pack.get()` with the expected name and rev
- [ ] `:lua print(vim.inspect(vim.pack.get({ 'conform.nvim' }, { info = true })[1]))` shows the plugin as active
- [ ] The plugin's main module can be required: `:lua print(pcall(require, 'conform'))` returns `true`
- [ ] Plugin-specific keymaps work: `<leader>lf` formats the current buffer
- [ ] No errors in `:messages` after the keymap fires

Once the pattern is clear, port the other 23 plugins using the same template. The bulk of each port is **transcription** — copy the `opts` table verbatim, convert `keys = { ... }` to top-level `nmap`/`xmap` calls, replace the `LazyPluginSpec` wrapper with `Config.later(function() ... end)`.

### Step 8 — Port personal plugin files

Copy from `common/.config/nvim/plugin/`, with sub-directory organization:

- `plugin/winbar.lua` (own) → `plugin/50_specs/winbar.lua`
- `plugin/tmux.lua` (own) → `plugin/50_specs/tmux.lua`
- `plugin/component.lua` (own) → `plugin/50_specs/component.lua`
- `plugin/logger.lua` (own) → `plugin/50_specs/logger.lua`
- `plugin/claude-edit.lua` → `plugin/50_specs/pi-edit.lua` (rewritten to use `pi -p` — see below)

**`pi-edit.lua`** (replacement for `claude-edit.lua`): same UX (visual select code, run a command, enter instruction, get refactored code) but the backend calls `pi -p` instead of the Anthropic API or `claude` CLI. Implementation sketch:

```lua
-- plugin/50_specs/pi-edit.lua
local function has_pi()
  return vim.fn.executable("pi") == 1
end

vim.api.nvim_create_user_command("PiEdit", function(args)
  if not has_pi() then
    vim.notify("pi not found on PATH", vim.log.levels.ERROR)
    return
  end

  -- Capture the visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  local selected = table.concat(lines, "\n")

  -- Get the instruction from the user
  vim.ui.input({ prompt = "Refactor instruction: " }, function(instruction)
    if not instruction or instruction == "" then return end

    -- Build the prompt and call pi -p
    local prompt = string.format(
      "Refactor the following code:\n\n```\n%s\n```\n\nInstruction: %s\n\nOutput ONLY the refactored code block, no prose.",
      selected, instruction
    )

    local result = vim.fn.system({ "pi", "-p", "--no-tools", prompt })
    if vim.v.shell_error ~= 0 then
      vim.notify("pi failed: " .. result, vim.log.levels.ERROR)
      return
    end

    -- Extract code from ``` fences
    local code = result:match("```[%w]*\n(.-)\n```") or result

    -- Replace the selection
    vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, end_pos[2], false, vim.split(code, "\n"))
  end)
end, { range = true, desc = "Pi Edit: refactor selection" })

vim.keymap.set("x", "<leader>pe", ":<C-u>'<,'>PiEdit<CR>", { desc = "[P]i [E]dit" })
```

Notes:
- `--no-tools` keeps `pi` focused on a single text response (no file editing from the model's side).
- Adjust the prompt template to taste; this is a starting point.

### Step 9 — Colors and colorscheme

Decision: **use `miniwinter`** (a `mini.hues` scheme, comes with `mini.nvim` — no extra plugin needed).

The black-atom plugin is still ported (for the rare cases you want to switch back), so copy the colorscheme files:

```bash
cp common/.config/nvim/colors/*.lua common/.config/nvim-edit/colors/
# The black-atom colorscheme lives inside the black-atom plugin's own colors/ dir
# and is registered automatically when the plugin loads.
```

Activate `miniwinter` in `plugin/mini.lua`:

```lua
-- plugin/mini.lua (the first module to set up)
Config.now(function() vim.cmd('colorscheme miniwinter') end)
```

If you ever want to switch interactively:

```lua
nmap('<Leader>uc', '<Cmd>lua MiniColors.interactive()<CR>', 'Change colorscheme interactively')
```

### Step 10 — Port snippets, ftplugin, after/queries, spell

```bash
# Snippets — copy but rename
cp common/.config/nvim/snippets/markdown.json common/.config/nvim-edit/snippets/markdown.json

# ftplugin
cp common/.config/nvim/ftplugin/markdown.lua common/.config/nvim-edit/ftplugin/markdown.lua
# Edit: change vim.opt_local.textwidth source — drop `lib.files` reference, hardcode 80

# after/queries (treesitter)
cp -r common/.config/nvim/after/queries common/.config/nvim-edit/after/queries

# Spell
cp -r common/.config/nvim/spell common/.config/nvim-edit/spell
```

Snippet format: `nvim-minimax` uses `mini.snippets` with `gen_loader.from_file` and the `friendly-snippets` plugin. Both `global.json` and `markdown.json` need to be in the format `mini.snippets` expects (which is the same as VSCode/LSP-snippet format — already what `markdown.json` is in). `global.lua` in the old config needs to be converted to JSON if you want to keep it (or move it to the `mini.snippets` config inline).

### Step 11 — Port lib/ helpers (selectively)

Don't copy all of `lua/lib/`. Keep only what keymaps/autocmds actually need:

| Old file              | Decision   | Reason                                                |
| --------------------- | ---------- | ----------------------------------------------------- |
| `lib/init.lua`        | **DROP**   | lazy-loader for `require('lib.x')` — not needed without lazy. |
| `lib/colors.lua`      | **DROP**   | Only used by the winbar. Inline the color extraction. |
| `lib/copy.lua`        | **PORT** (or drop per step 4) | Helper for `<leader>dy*` keymaps. |
| `lib/files.lua`       | **DROP**   | Only used by `ftplugin/markdown.lua` (for `detect_printwidth`). |
| `lib/git.lua`         | **CHECK**  | Likely drop — `mini.git` covers it. |
| `lib/lsp.lua`         | **DROP**   | Custom goto helpers; covered by `switchbuf` (see `nvim-0.12-migration.md`). |
| `lib/lsp-util.lua`    | **DROP**   | Likely utilities for the dropped `lib/lsp.lua`. |
| `lib/mini_pickers.lua`| **DROP**   | Replaced by `mini.pick`. |
| `lib/sessions.lua`    | **PORT**   | Custom session management. Might be worth keeping if it has features `mini.sessions` lacks. |
| `lib/ui.lua`          | **PORT**   | `close_all_floating_windows` used in `<S-Esc>`. Inline. |
| `lib/config.lua`      | **PORT**   | `get_repo_path` for the black-atom local repos. The new `vim.pack.add` doesn't support local `dir`, so this whole mechanism needs a rethink. |
| `lib/periodic.lua`    | **CHECK**  | If used, port. |

### Step 12 — Update `nvim/CLAUDE.md` and add `nvim-edit/CLAUDE.md`

The current `CLAUDE.md` references lazy.nvim commands (`:Lazy install`, `:Lazy update`). Either:
- Delete `nvim-edit/CLAUDE.md` entirely, or
- Replace with a one-line "see `common/.config/nvim-minimax/` for documentation"

Recommendation: just port the format/style sections, replace plugin-manager commands with `vim.pack.update()`.

### Step 13 — First launch

```bash
edit
```

Expected:
- Pack install prompt (accept to install all listed plugins)
- `checkhealth` shows no red flags for the LSP servers you have installed
- Treesitter parsers install on first file open
- Color scheme is `black-atom-terra-summer-night` (or whatever your default is)

Run `:checkhealth` in each of: `vim.lsp`, `vim.treesitter`, `nvim-treesitter`, and `mini.nvim`.

### Step 14 — Verification checklist

- [ ] `edit` launches without errors (`:messages`)
- [ ] `miniwinter` colorscheme is active (`:colorscheme` shows current)
- [ ] `,` is leader — verify `<leader>e` opens file explorer (mini.files)
- [ ] `<C-hjkl>` window navigation works (mini.basics)
- [ ] `gx` closes/parses around args
- [ ] `<C-s>` saves
- [ ] `<C-q>` force-quits
- [ ] `yp` / `yc` duplicate / dupe-comment
- [ ] `<leader>dy*` copy helpers (if ported)
- [ ] `<leader>sh` / `<leader>la` / `<leader>lr` LSP hover/action/rename
- [ ] `<leader>l*` work for at least one language (e.g. typescript in a project)
- [ ] `<leader>f*` mini.pick works
- [ ] Treesitter highlight works in `.lua` and `.ts` files
- [ ] Fold expression works (`zR`, `zM` on a `.ts` file)
- [ ] Snippets expand via `<C-j>`
- [ ] `gitcommit` filetype sets 72-col wrap
- [ ] `markdown` filetype sets spell + wrap
- [ ] Sessions: `<leader>sn` creates, `<leader>sr` reads, `<leader>sd` deletes
- [ ] Sessions restore LSP correctly (open session, LSP attaches)
- [ ] `<leader>z` opens Zed at cursor (if you ported it)
- [ ] `<leader>w.` cds to git root
- [ ] German umlaut insert-mode bindings work
- [ ] `<M-t>` inserts date
- [ ] Statusline shows VIN/Project/Git/Cursor (custom mini.statusline content from `specs/mini.lua`)
- [ ] Winbar shows git/LSP diagnostic counts
- [ ] `mj` / `mk` swaps function args (mini.operators)
- [ ] `gcip` toggles comment
- [ ] `saiw)` / `sdf` / `srb[` mini.surround
- [ ] `:w` in a git dir updates the diff overlay
- [ ] Spells: `:set spell` in a `.md` file shows de/en highlighting
- [ ] `<leader>pe` (Pi-Edit) refactors a visual selection via `pi -p` — confirm `pi` is on `PATH` (`which pi`)
- [ ] `<leader>ag` (Snacks.lazygit) opens lazygit
- [ ] Bigfile detection: open a >1MB file → treesitter/LSP disabled
- [ ] Local dev: edit a plugin file (e.g. flip the rtp-prepend line in `plugin/50_specs/black-atom.lua`), restart `edit`, and confirm the local repo is loaded (check `:lua print(vim.api.nvim_get_runtime_file('lua/black-atom/init.lua', false)[1])`)

### Step 15 — Cut over

Once verification passes:

1. Remove `alias vin="NVIM_APPNAME=nvim_mnml nvim"` from `common/.zshrc`.
2. Reassign the `vin` alias to point at the new config:
   ```bash
   alias vin="NVIM_APPNAME=nvim-edit nvim"
   ```
3. In a new shell, `vin` opens the new config.

### Step 16 — Retire the old config (later, in a separate commit)

After at least a week of using `edit`/`vin` as primary:

1. Remove `common/.config/nvim/` from the filesystem (or move it to `common/.config/nvim_mnml_DEPRECATED/`).
2. Remove its entry from `symlinks.yml`.
3. Run `dots link` to clean up the symlink.
4. Optional: keep the directory as a frozen reference in a separate branch.

## Reuse

- **`Config` table and helpers** (`Config.new_autocmd` / `Config.now` / `Config.later` / `Config.on_event` / `Config.on_filetype` / `Config.on_packchanged`) — defined in our own `init.lua`. Use these throughout the config to keep things consistent.
- **All `mini.*` modules** — loaded by `plugin/mini.lua` via `require('mini.xxx').setup()`. For per-module overrides, **only specify the fields you want to change** — don't copy-paste the full setup.
- **`vim.pack.add({...})`** — used the same way `lazy.nvim` was. Supports `version =`, `name =`, etc.
- **`vim.pack.update()`** — replaces `:Lazy update`.
- **`:h vim.lsp.config()` + `after/lsp/*.lua`** — the `lsp/*.lua` files in the old config are already in this format. Direct copy.
- **`vim.diagnostic.config()`** — call it in `plugin/30_autocmds.lua` or wherever fits your LSP setup.
- **`vim.o.switchbuf = 'usetab,vsplit'`** — see `plans/nvim-0.12-migration.md` step 5. Replaces `lib/lsp.lua`'s `goto_split_definition` / `goto_tab_definition`.
- **`vim.diagnostic.status()`** — see `plans/nvim-0.12-migration.md` step 4. Replaces manual diagnostic counts in `plugin/50_specs/winbar.lua`.
- **`:h vim.lsp.enable(server_configs)`** — port directly from `lua/lsp-config.lua`.
- **`after/plugin/`** — canonical Neovim override tier (sourced after all `plugin/*.lua`). Use for last-look overrides.
- **`mini.misc.safely(name, f)`** — the building block for `Config.now` / `Config.later`. Runs a function via `vim.schedule()` with a unique name so it only runs once even if called multiple times.

## Resolved decisions

| Question                                  | Decision                                                                            |
| ----------------------------------------- | ----------------------------------------------------------------------------------- |
| Name for the new config                   | `nvim-edit` / alias `edit`                                                          |
| Starting layer                            | **Empty config** — no MiniMax skeleton. Just use `vim.pack` + `mini.*` as libraries. |
| File organization                         | Minimal `init.lua` (bootstrap + Config helpers) + `plugin/10_options.lua` + `plugin/20_keymaps.lua` + `plugin/30_autocmds.lua` + `plugin/50_specs/*.lua` (one file per plugin spec, including `plugin/50_specs/mini.lua` for mini.nvim config) |
| Snacks sub-features to port               | lazygit UI + terminal only (drop statuscolumn, bigfile)                             |
| Bigfile detection                         | Hand-rolled 3-line autocmd in `plugin/30_autocmds.lua` (no `mini.*` equivalent)      |
| `claude-edit.lua`                         | Port as `pi-edit.lua` with `pi -p` backend                                          |
| `lib/sessions.lua`                        | Port as `lua/sessions.lua`, use alongside `mini.sessions`                            |
| Stylua indent                             | 2 spaces                                                                            |
| Local-dev pattern                         | Edit-line toggle: `vim.pack.add(URL)` ↔ `vim.opt.rtp:prepend(local_path)` (per [neovim#35173](https://github.com/neovim/neovim/discussions/35173)) |
| Plugin filter in first pass                | **None** — port all 24 specs; prune in a future pass                                |
| Timeline                                  | Single PR                                                                           |
| Colorscheme default                       | `miniwinter` (no extra plugin needed)                                               |

## Open items (non-blocking)

- **Black-atom plugin** is still ported (for use as a manual switch via `:colorscheme`), but not set as the default. If you ever want to switch back, run `:colorscheme black-atom-terra-summer-night`.
- **The 3 colorscheme files** in old `colors/` (`default.lua`, `habamax.lua`, `minigreen.lua`) look like leftovers — port them anyway for reference, but they won't be auto-loaded.
- **Conflict resolution is a future pass** — once everything is working, run a session and notice which `mini.*` modules shadow which old plugin. Prune the old plugin at that point (e.g. once you confirm `mini.jump` covers you, drop `spider.lua` + `whatthejump.lua`).
