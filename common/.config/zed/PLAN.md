# Implementation Plan: Zed Keymap Cleanup

## Goal

Clean up and improve `keymap.json` to fix bugs, remove redundancies, align Zed leader mappings with the nvim AWDCS scheme, and drop the leader prefix from the Symbol namespace (mirrored in nvim). All changes land in a single sweep — Nik reviews the Zed diff once and the nvim diff once.

## Context

Nik uses nvim as primary editor with an AWDCS leader scheme (`<leader>` = comma): **A**pp, **W**orkspace, **D**ocument, **C**hange, **S**ymbol. Zed is secondary (`base_keymap: "VSCode"`, `vim_mode: true`). The keymap uses `,` as leader, nulled scoped in vim normal/visual to win precedence over default `vim::RepeatFindReversed`.

**New direction (Nik's feedback):** Drop the leader prefix from the **Symbol** namespace only — `sn`, `sr`, `si` instead of `,sn`, `,sr`, `,si`. This aligns Zed with a parallel change in the `nvim-edit` config. The other namespaces (App/Workspace/Document/Change) keep the leader. **Mechanical requirement:** `s` is a non-waiting vim operator (substitute = `cl`), so it must be neutralized (`s` → `<Nop>` / made to wait) before any two-key `s<key>` binding can resolve. This is the cost Nik has accepted.

Zed `keymap.json` is JSONC (comments + trailing commas). Preserve that style throughout.

## Files

| File                                        | Role                                                                                          |
| ------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `common/.config/zed/keymap.json`            | Zed keymap — edited.                                                                          |
| `common/.config/nvim/lua/keymaps.lua`       | nvim AWDCS — edited (add `s` neutralization).                                                 |
| `common/.config/nvim/lua/specs/mini.lua`    | nvim `mini.clue` group — edited (re-register Symbol group under `s`).                         |
| `common/.config/nvim/lua/lsp-config.lua`    | nvim LSP symbol mappings — edited (drop `<leader>` prefix).                                   |
| `common/.config/nvim/lua/specs/trouble.lua` | nvim Trouble symbol mappings — edited (drop `<leader>` prefix).                               |
| `common/.config/zed/settings.json`          | Reference only — confirms `base_keymap: "VSCode"`, `vim_mode: true`, both panels docked left. |

---

## Decisions (resolved via ask_user)

| #   | Decision                                                                                                                                                                          |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S0  | **Symbol namespace leaderless: yes.** Drop `,` from Symbol bindings → `sd`/`sr`/`si`/…. Requires `s` → `<Nop>` (loses substitute, use `cl`). Mirror in nvim-edit.                 |
| 1   | **`] c` / `[ c`:** revert to git hunk nav (`GoToHunk`/`GoToPreviousHunk`).                                                                                                        |
| 2   | **`si`:** swap — `si` = GoToImplementation, `sh` = Hover.                                                                                                                         |
| 3   | **rename:** keep `sn` (drop leader only). Mnemonic clash with `sr` accepted.                                                                                                      |
| 4   | **`, d p`:** switch to `diagnostics::DeployCurrentFile` (picker).                                                                                                                 |
| 5   | **panel close:** `q` closes panel when focus is inside it (netrw-style, context-scoped). Keep `, w e` / `, a g` as `ToggleFocus`. ⚠️ Close action name needs in-app verification. |

---

## Changes

One table, both editors. Review the Zed diff once and the nvim diff once.

| #   | Editor | File                    | Change                                                                                                                                                                                                                                                                                                                                                                                                                   | Kind      | Decision |
| --- | ------ | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------- | -------- |
| 1   | Zed    | `keymap.json`           | Delete `, c g` (duplicate of `, c d` → `ToggleSelectedDiffHunks`)                                                                                                                                                                                                                                                                                                                                                        | Cleanup   | —        |
| 2   | Zed    | `keymap.json`           | Delete `, w f` (redundant with `, w t` → `DeploySearch`)                                                                                                                                                                                                                                                                                                                                                                 | Cleanup   | —        |
| 3   | Zed    | `keymap.json`           | Delete empty insert-mode block (`bindings: {}`)                                                                                                                                                                                                                                                                                                                                                                          | Cleanup   | —        |
| 4   | Zed    | `keymap.json`           | Add `"s": null` in vim normal block (neutralize substitute)                                                                                                                                                                                                                                                                                                                                                              | S0 prep   | S0       |
| 5   | Zed    | `keymap.json`           | `, s d` → `sd` (drop leader, Symbol namespace)                                                                                                                                                                                                                                                                                                                                                                           | S0        | S0       |
| 6   | Zed    | `keymap.json`           | `, s a` → `sa`, `, s t` → `st`, `, s g b` → `sgb` (drop leader)                                                                                                                                                                                                                                                                                                                                                          | S0        | S0       |
| 7   | Zed    | `keymap.json`           | `, s r` → `sr` (references, drop leader)                                                                                                                                                                                                                                                                                                                                                                                 | S0        | S0       |
| 8   | Zed    | `keymap.json`           | `, s i` → `si` = `editor::GoToImplementation`; `, s shift-i` removed; Hover → `sh` (new)                                                                                                                                                                                                                                                                                                                                 | Swap      | #2       |
| 9   | Zed    | `keymap.json`           | `, s n` → `sn` = `editor::Rename` (keep, drop leader only)                                                                                                                                                                                                                                                                                                                                                               | Keep      | #3       |
| 10  | Zed    | `keymap.json`           | `] c` → `editor::GoToHunk`, `[ c` → `editor::GoToPreviousHunk`                                                                                                                                                                                                                                                                                                                                                           | Revert    | #1       |
| 11  | Zed    | `keymap.json`           | `, d p` → `diagnostics::DeployCurrentFile`                                                                                                                                                                                                                                                                                                                                                                               | Swap      | #4       |
| 12  | Zed    | `keymap.json`           | `ProjectPanel` + `GitPanel` context blocks: add `q` → panel close action                                                                                                                                                                                                                                                                                                                                                 | Add       | #5 ⚠️    |
| 13  | Zed    | `keymap.json`           | Add `sD` → `editor::GoToDeclaration` (optional). **Distinct from `sd` (GoToDefinition):** declaration = the type/interface signature (e.g. C/C++ header, TS `.d.ts`); definition = the implementation. You already have `sd` (def), `st` (type def), and nvim `sV`/`sT` (def in split/tab) — but **no declaration binding**. Useful mainly for C/C++/Rust/TS; overlaps with definition in Python/JS. Offer, don't force. | Optional  | —        |
| 13a | Zed    | `keymap.json`           | Add `sV` → `editor::GoToDefinitionSplit` — **fills the real gap.** Mirrors nvim `sV` (open definition to the side). You have `sd` (same-pane def) but no split variant in Zed. Action `editor::GoToDefinitionSplit` is a standard Zed built-in (verify in all-actions page). Optional companion: `sT` → `editor::GoToTypeDefinitionSplit`.                                                                               | Add       | —        |
| 14  | Zed    | `keymap.json`           | Add `, d y n` → `editor::CopyFileName` (optional; skip `, d y h` — no action)                                                                                                                                                                                                                                                                                                                                            | Optional  | —        |
| 15  | Zed    | `keymap.json`           | Inline comments: H/L, v/V, A/g a tradeoffs + `, ,`/`, w d` redundancy                                                                                                                                                                                                                                                                                                                                                    | Docs      | —        |
| 16  | nvim   | `lua/keymaps.lua`       | Add `vim.keymap.set("n", "s", "<Nop>")` (neutralize `s`)                                                                                                                                                                                                                                                                                                                                                                 | S0 prep   | S0       |
| 17  | nvim   | `lua/specs/mini.lua`    | `mini.clue` Symbol group: `keys = "<leader>s"` → `"s"` (lines ~743-745)                                                                                                                                                                                                                                                                                                                                                  | S0 mirror | S0       |
| 18  | nvim   | `lua/lsp-config.lua`    | `<leader>sp/sh/sa/sn/sV/sT` → `sp/sh/sa/sn/sV/sT` (lines ~67-87)                                                                                                                                                                                                                                                                                                                                                         | S0 mirror | S0       |
| 19  | nvim   | `lua/specs/trouble.lua` | `<leader>sd/st/sR/sI/sci/sco` → `sd/st/sR/sI/sci/sco` (lines ~69-75)                                                                                                                                                                                                                                                                                                                                                     | S0 mirror | S0       |

**⚠️ Item #12 panel close action name unverified** — Zed not at standard path on this machine. Verify in Zed all-actions page (cmd-shift-p → "project panel close") before implementing. Fallback: `workspace::ToggleLeftDock` scoped to panel context.

---

## Verification

### JSONC (Zed `keymap.json`)

Standard JSON validators fail on JSONC. Options:

1. **Best:** Open Zed → `zed::OpenKeymap` → Zed reports parse errors natively.
2. **CLI:** `npx -y jsonc-parser --parse common/.config/zed/keymap.json`

### nvim

- `NVIM_APPNAME=nvim-edit nvim --headless "+qa!"` — startup errors print to stderr.
- `:nmap s` / `:verbose nmap s` — confirm `s` is neutralized, no conflicting substitute mapping.
- Grep for leftover `<leader>s` across the four files — should return zero matches.

### Unverified action names (must confirm in-app)

| Item                                    | Action to verify                                      | How                                     |
| --------------------------------------- | ----------------------------------------------------- | --------------------------------------- |
| Panel close (`q`)                       | `project_panel::Close` vs `workspace::ToggleLeftDock` | Zed cmd-shift-p → "project panel close" |
| `editor::GoToHunk` / `GoToPreviousHunk` | exists in current Zed build                           | Zed key-binding inspector               |

---

## Risks

| Risk                                                                                                                                                   | Impact                                                     | Mitigation                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Panel close action unverified:** The exact Zed action to close a panel from within its context could not be introspected (Zed not at standard path). | Low — additive, context-scoped.                            | Verify in Zed all-actions page before implementing. Fallback: `workspace::ToggleLeftDock` scoped to panel context. |
| **`s` neutralization scope (nvim):** Affects all nvim usage, not just Symbol namespace.                                                                | Medium — could break plugins relying on `s` as substitute. | Check `:nmap s` after applying. Nik accepted losing `s` as substitute (use `cl`).                                  |
| **Swap breaks `, s shift-i` muscle memory:** Decision #2 removes `s shift-i` for GoToImplementation.                                                   | Low — `si` is the natural replacement.                     | Document removal in commit.                                                                                        |
| **Visual `v`/`V` override:** Loses vim visual-mode toggle.                                                                                             | Medium — deliberate tradeoff.                              | Documented. Nik accepted.                                                                                          |
