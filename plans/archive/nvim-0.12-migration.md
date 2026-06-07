# Neovim 0.12 Migration — What We Can Take Advantage Of

## Context

Neovim 0.12.1 is installed. Issue #9 tracks the migration. No breaking changes were found in the current config. This plan covers the actionable improvements we decided on, excluding the `vim.pack` migration (deferred to a separate project).

## Approach

Incremental adoption of 0.12 and nightly features, one change at a time, from lowest to highest risk. Each change is verifiable independently.

## Decisions Summary

| # | Feature | Action |
|---|---|---|
| 1 | vim.pack | **Deferred** — separate future project |
| 2 | GH PR detection via `vim.net.request()` | **Adopt** — replace `gh` CLI calls in `detect_gh_pr_context()` |
| 3 | `vim.diagnostic.status()` in winbar | **Adopt** — simplify `build_right()` |
| 4 | `inlineCompletion` | **Skip** |
| 5 | `'pumborder'` / `'pummaxwidth'` | **Adopt** — set in options.lua |
| 6 | `'shortmess' += u` | **Adopt** — silence undo/redo messages |
| 7 | `ui2` | **Adopt** — enable in init.lua |
| 8 | `'scrolloffpad'` | **Adopt** — set in options.lua |
| 9 | `'switchbuf'` for LSP jumps | **Adopt** — simplify `goto_split/tab_definition()` helpers |
| 10 | Treesitter built-in selection (`v_an`/`v_in`/`v_al`/`v_il`) | **Keep current plugin** — built-in is additional, zero config |
| 11 | `:log`, `ZR` → `:restart`, `'messagesopt'` `progress:c` | **Adopt** |

## Files to Modify

| File | Changes |
|---|---|
| `common/.config/nvim/lua/options.lua` | `pumborder`, `pummaxwidth`, `shortmess`, `scrolloffpad`, `messagesopt`, `switchbuf` |
| `common/.config/nvim/init.lua` | Enable `ui2` |
| `common/.config/nvim/lua/specs/snacks.lua` | Rewrite `detect_gh_pr_context()` to use `vim.net.request()` |
| `common/.config/nvim/plugin/winbar.lua` | Replace manual diagnostic counts with `vim.diagnostic.status()` |
| `common/.config/nvim/lua/lsp-config.lua` | Update jump keymaps to use `switchbuf` instead of custom helpers |
| `common/.config/nvim/lua/lib/lsp.lua` | Remove `goto_split_definition()` and `goto_tab_definition()` |

## Reuse

- `vim.net.request()` — built-in HTTP client (0.12)
- `vim.diagnostic.status()` — built-in diagnostic status string (0.12, improved in nightly)
- `vim.o.switchbuf` — controls single-result LSP jump behavior (nightly)
- `vim._core.ui2.enable()` — experimental core UI redesign (0.12)
- `ZR` maps to `:restart` (nightly), `:log` opens log files (nightly)

## Steps

### Step 1: Add new options

- [ ] In `options.lua`, add:
  - `vim.opt.pumborder = "single"` — global popup menu border
  - `vim.opt.pummaxwidth = 60` — max popup width
  - `vim.opt.shortmess:append("u")` — silence undo/redo messages
  - `vim.opt.scrolloffpad = true` — allow centering at EOF
  - `vim.opt.messagesopt = "progress:c"` — keep progress messages in cmdline
  - `vim.opt.switchbuf = "useopen"` — safe default for LSP jumps

### Step 2: Enable ui2

- [ ] In `init.lua`, add `require('vim._core.ui2').enable()` after options are loaded

### Step 3: Migrate GH PR detection to vim.net.request()

- [ ] Rewrite `detect_gh_pr_context()` in `snacks.lua`:
  - Get git remote URL from `git config --get remote.origin.url` (one call)
  - Extract owner/repo from the remote URL
  - Get current branch from `git rev-parse --abbrev-ref HEAD` (one call)
  - Call `https://api.github.com/repos/{owner}/{repo}/pulls?head={owner}:{branch}&state=open` via `vim.net.request()`
  - Set `state:set("gh_current_pr", pr_number)` and `state:set("gh_current_repo", repo)` from response
  - Remove `Snacks.notify` call (silent detection) or keep it
- [ ] Remove `gh` CLI dependency for this feature

### Step 4: Simplify winbar diagnostic counts

- [ ] In `plugin/winbar.lua`, replace the `build_right()` LSP section:
  - Remove the manual `diagnostic_signs` loop and `diag_tokens`
  - Use `vim.diagnostic.status(bufnr)` — returns string like `"4E 2W 1I"`
  - Append it if non-empty: `"[LSP: " .. status_str .. "]"` with existing highlight group
  - Remove the `diagnostic_signs` table if no longer referenced elsewhere

### Step 5: Switchbuf LSP jumps

- [ ] In `lsp-config.lua`, update `<leader>sV` and `<leader>sT` keymaps:
  - `<leader>sV`: set `switchbuf=useopen,split` temporarily, call `vim.lsp.buf.definition()`, restore
  - `<leader>sT`: set `switchbuf=useopen,usetab` temporarily, call `vim.lsp.buf.definition()`, restore
- [ ] In `lib/lsp.lua`, remove `goto_split_definition()` and `goto_tab_definition()`
- [ ] Update `lsp-config.lua` to remove the `require("lib.lsp")` calls for those functions, replace with local `switchbuf` wrapper

### Step 6: Log/restart awareness (note only)

- [ ] Note: `:log` works natively now — no config change
- [ ] Note: `ZR` maps to `:restart` — no config change, `vim.bo` help
- [ ] Note: Treesitter `v_an`/`v_in`/`v_al`/`v_il` work natively alongside existing treewalker plugin — no config change

## Nightly Fixup Note

Running nightly via bob may produce a corrupted install (partial runtime extraction). If you see `module 'vim.uri' not found` or `syntax/syntax.vim` missing, delete the nightly directory and reinstall:

```bash
rm -rf ~/.local/share/bob/nightly
bob install nightly
```

Also note: `vim.uri` is removed in Neovim 0.13-dev. Plugins that use `vim.uri` (currently: snacks.nvim, kulala.nvim) will need updates. The config itself does not reference `vim.uri`.

## Verification

1. **Nightly install health**: `nvim --headless -c 'checkhealth' -c 'quit'` — no runtime errors.
2. **Options**: Visual: popup borders, no undo/redo messages, centered cursor at EOF.
3. **ui2**: Pager is a real buffer (no "Press ENTER"). Cmdline highlights as you type.
4. **GH PR detection**: In a repo with an open PR branch → `:lua =require("state"):get_gh_context()` returns `{pr = N, repo = "org/name"}`. No PR → null. Non-git dir → no-op.
5. **Winbar diagnostics**: File with LSP errors → winbar shows diagnostic counts. Diagnostic change → winbar updates.
6. **Switchbuf jumps**: Single definition: `<leader>sV` opens in split, `<leader>sT` in tab. Multiple: quickfix opens, navigation respects `switchbuf`.
