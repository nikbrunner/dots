# Migrate from oil.nvim to canola.nvim

## Context

oil.nvim is effectively unmaintained — upstream PRs go unmerged. canola.nvim (v2.15.0, `canola` branch) is an actively maintained fork by barrettruth with:

- **Git integration** (`canola-git`): git_status column + git-aware hidden file filtering
- **Serializable config**: `vim.g.canola` is a plain table, functions replaced by User autocmd events
- **Cherry-picked upstream PRs**: ~15 unmerged oil.nvim PRs pulled into canola
- **New features**: extglob brace expansion, custom column API, eza-like column highlighting, `CanolaFileCreated` event, move-into-dir by renaming
- **Neovim 0.11+** required (we're on 0.13.0-dev, so fine)

## Files to create

- `common/.config/nvim/lua/specs/canola.lua` — single lazy.nvim spec returning both canola.nvim and canola-collection plugins

## Files to modify

- `common/.config/nvim/lua/specs/oil.lua` — **delete**
- `common/.config/nvim/plugin/winbar.lua` line 120 — add `canola` to oil skip: `if ft ~= "oil" and ft ~= "canola" then`
- `common/.config/nvim/lazy-lock.json` — auto-updated by lazy.nvim on next sync

## Config migration map

| oil.nvim                                                | canola.nvim                                                   |
| ------------------------------------------------------- | ------------------------------------------------------------- |
| `"stevearc/oil.nvim"`                                   | `"barrettruth/canola.nvim"`, branch `"canola"`                |
| `default_file_explorer = false`                         | Removed (always true in canola)                               |
| `view_options.show_hidden = true`                       | `hidden.enabled = false` (inverted logic)                     |
| `view_options.skip_confirm_for_simple_edits = true`     | `confirm = false`                                             |
| `view_options.prompt_save_on_select_new_entry = false`  | `save = false`                                                |
| `watch_for_changes = true`                              | `watch = true`                                                |
| `lsp_file_methods.*`                                    | `lsp.*`                                                       |
| `win_options.winbar = "..."`                            | `win.winbar = "%{v:lua.require('canola').get_current_dir()}"` |
| `float.*`                                               | `float.*` (same keys, `win_options` → `win`)                  |
| `confirmation.*`                                        | `confirmation.*` (same, `win_options` → `win`)                |
| `keymaps_help { border = "solid" }`                     | Removed (help uses vimdoc)                                    |
| `keymaps` positional: `{ "actions.select", opts = {} }` | Explicit: `{ callback = "actions.select", opts = {} }`        |
| `require("oil")`                                        | `require("canola")` everywhere in keymaps                     |
| `require("oil.actions").cd`                             | `require("canola.actions").cd`                                |
| `OilActionsPost` event                                  | `CanolaMutationComplete` event                                |
| `event.data.actions.type == "move"`                     | Iterate `args.data.actions` for move-type actions             |

## Steps

- [ ] 1. Create single `canola.lua` spec returning both `barrettruth/canola.nvim` (branch `canola`) and `barrettruth/canola-collection` — port all oil config, keymaps, Snacks rename autocmd, and enable `canola-git` with `git_status` column
- [ ] 2. Update `winbar.lua` — add `canola` filetype alongside `oil` in the skip check
- [ ] 3. Delete `oil.lua` spec
- [ ] 4. Run `:Lazy sync` to install canola.nvim + canola-collection and remove oil.nvim
- [ ] 5. Restart Neovim and verify `-` opens canola, editing + `:w` works, keymaps work, git_status column appears, winbar shows path

## Verification

1. Open Neovim, press `-` → canola buffer opens for parent directory
2. `_` → opens canola for cwd
3. `<localleader>h` / `<localleader>c` / `<localleader>0-9` → all quick-jump keymaps work
4. `q` closes canola buffer
5. `<leader>yn/yr/yh/ya` yank keymaps work
6. `<leader><leader>` opens Snacks file picker in canola directory
7. Rename a file → `:w` → file moves, Snacks rename integration fires (`CanolaMutationComplete`)
8. `git_status` column shows M/A/? indicators in git repos
9. Winbar shows directory path
10. Verify canola-git hides gitignored files (e.g. `node_modules/`, `dist/`)
