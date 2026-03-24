# PRD: Neovim Lang Folder Refactor

## Problem Statement

Neovim config organizes tool concerns separately: treesitter parsers in one file, formatters in another, LSP configs in a third directory, and mason packages in a fourth. Adding or removing a language means touching 4+ files. The monolithic `conform.lua` contains a complex `handle_shared_formatter` function that exists solely because all formatter logic is forced into one file.

This makes the config harder to reason about per-language and impossible to automate ("set up language X" requires knowledge of 4 different files and their conventions).

## Solution

Reorganize config by **language** instead of by **tool**. Each language gets a single file in `specs/lang/` that declares all its concerns: treesitter parsers, LSP configuration, formatters, linters, and mason packages. Shared infrastructure (LspAttach keymaps, diagnostic config, format-on-save behavior) stays centralized.

### Directory Structure After

```
lua/specs/
├── lang/
│   ├── web.lua        # JS/TS/TSX/JSX/CSS/SCSS/HTML/Astro/Svelte/GraphQL/JSON
│   ├── go.lua         # Go
│   ├── lua.lua        # Lua
│   ├── rust.lua       # Rust
│   ├── swift.lua      # Swift
│   ├── bash.lua       # Bash/Shell
│   ├── markdown.lua   # Markdown/MDX
│   ├── yaml.lua       # YAML
│   ├── toml.lua       # TOML
│   └── http.lua       # HTTP (Kulala)
├── treesitter.lua     # Slim: just nvim-treesitter + treesitter-modules base config (no ensure_installed)
├── conform.lua        # Slim: just plugin setup, format_on_save, keymaps (no formatters_by_ft)
├── mason.lua          # Slim: just mason.setup() (no package list)
├── blink.lua          # Unchanged (completion is not language-specific)
├── ...                # Other non-lang specs unchanged
```

### Files Removed

- `lsp/*.lua` (all 18 files) -- LSP config moves into lang files via `vim.lsp.config()` + `vim.lsp.enable()`
- `lua/lsp-config.lua` -- LSP discovery logic removed; LspAttach keymaps + diagnostics move to a new `specs/lsp.lua`
- `lua/specs/sleuth.lua` -- already removed (treesitter migration)
- `lua/specs/lint.lua` -- linter config moves into `lang/web.lua` (only web filetypes use it)
- `lua/lib/lsp-util.lua` -- TypeScript SDK helper inlined into `lang/web.lua`
- `lua/lib/lsp.lua` -- helpers (`goto_split_definition`, `set_diagnostic_virtual_lines`, etc.) move into `specs/lsp.lua` as local functions

### Files Modified

- `treesitter.lua` -- remove `ensure_installed` list (lang files provide parsers)
- `conform.lua` -- remove `formatters_by_ft` (lang files provide formatters)
- `mason.lua` -- remove package list; refactor custom async install to read from `opts.ensure_installed` instead of local variable (see Mason section below)
- `init.lua` -- remove `require("lsp-config")` (replaced by `specs/lsp.lua` plugin spec)

### Files Created

- `specs/lang/*.lua` (10 files) -- one per language/ecosystem
- `specs/lsp.lua` -- virtual plugin spec (no actual plugin, just `init`/`config` functions) containing: LspAttach keymaps, diagnostic config, `vim.lsp.config('*', ...)` global defaults, and LSP helper functions from `lib/lsp.lua`

## User Stories

- As a Neovim user, I want all config for a language in one file so I can understand and modify it in one place.
- As a Neovim user, I want to add a new language by creating one file and having everything work (LSP, formatter, treesitter, mason install).
- As a Neovim user, I want to disable a language by removing/commenting out one file.
- As a Claude Code user, I want a skill that can scaffold a new language config file.

## Implementation Decisions

### Lang file anatomy

Each lang file returns an array of lazy.nvim specs. The LSP configuration uses `vim.lsp.config()` + `vim.lsp.enable()` inside a virtual spec (no actual plugin — just an `init` function that runs at startup). Example for `lang/go.lua`:

```lua
return {
    -- Treesitter
    {
        "MeanderingProgrammer/treesitter-modules.nvim",
        opts = { ensure_installed = { "go", "gomod", "gosum" } },
    },

    -- Mason packages
    {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "gopls" } },
    },

    -- Formatters
    {
        "stevearc/conform.nvim",
        opts = { formatters_by_ft = { go = { "gofmt" } } },
    },

    -- LSP
    {
        "lang-go", -- virtual spec name (no real plugin)
        virtual = true,
        init = function()
            vim.lsp.config("gopls", {
                cmd = { "gopls" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_markers = { "go.mod", "go.work", ".git" },
            })
            vim.lsp.enable("gopls")
        end,
    },
}
```

**Note:** The `virtual = true` pattern avoids attaching LSP config to an unrelated plugin. If lazy.nvim doesn't support virtual specs cleanly, an alternative is using `vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", ... })` inside the lang file's module scope (outside the returned specs table) to run `vim.lsp.config()` + `vim.lsp.enable()` at the right time. This needs prototyping during Phase 1 to determine the best approach.

### Lazy.nvim merging strategy

- **Dict fields** (`formatters_by_ft`, `settings`): merge automatically across specs
- **List fields** (`ensure_installed`): require `opts_extend` on the base plugin spec. Both treesitter-modules and mason need `opts_extend = { "ensure_installed" }` set in their base specs.
- **Function opts**: avoided in lang files. Only the base conform.lua uses function opts (for `format_on_save`). Lang files use plain table opts for `formatters_by_ft`.

### Web ecosystem grouping

`web.lua` handles all web filetypes (including JSON) as a single unit because they share:

- Formatter detection logic (prettier > deno > biome priority)
- Linter detection logic (deno > eslint priority, same config-file-sniffing pattern)
- Treesitter parsers that travel together
- Mason packages that overlap
- Similar LSP complexity (vtsls, eslint, biome, tailwindcss, cssls, cssvariables, jsonls, astro, denols)

The `handle_shared_formatter` function and the `get_linter_for_buffer` function (from current `lint.lua`) both move into `web.lua` as local functions scoped to where they belong. Both follow the same pattern: check for config files upward from the buffer, return the appropriate tool.

### LspAttach keymaps stay centralized

LspAttach keymaps (hover, code action, rename, diagnostics, etc.) are universal across all languages. They stay in a new `specs/lsp.lua` alongside diagnostic config and `vim.lsp.config('*', ...)` global defaults (like blink.cmp capabilities).

### LSP attach point and session restore

The current `lsp-config.lua` defers `vim.lsp.enable()` until first buffer open (BufReadPre) or session restore (SessionLoadPost). This logic exists because calling `vim.lsp.enable()` too early (before buffers exist) is a no-op.

In the new model, `vim.lsp.config()` can run early (it just registers config, doesn't start anything). `vim.lsp.enable()` triggers attachment on matching filetypes — it works whether called before or after buffers exist (Neovim 0.11+ handles this via autocommands internally).

**Session restore**: `vim.lsp.enable()` respects SessionLoadPost because it sets up persistent autocommands. Once enabled, servers attach to any future buffer that matches their filetypes. No special session handling is needed — this is a change from the current manual approach. Verify during Phase 1.

### specs/lsp.lua structure

`specs/lsp.lua` is a lazy.nvim spec file that returns a virtual spec (or uses `init` directly). It contains:

- Diagnostic config (`vim.diagnostic.config(...)`)
- Global LSP defaults (`vim.lsp.config('*', { ... })`) — currently in blink.lua, consolidate here
- LspAttach autocmd with keymaps (hover, code action, rename, etc.)
- Helper functions from current `lib/lsp.lua` (goto_split_definition, diagnostic toggle, etc.)

This runs early via `lazy = false` or `init` function to ensure diagnostics and keymaps are configured before any LSP attaches.

### Mason ensure_installed

Current mason.lua has a custom async install implementation: a local `packages` table, `get_missing_packages()` that checks the registry, and `install_package()` with notification callbacks. This needs refactoring:

1. Move the package list from local variable to `opts.ensure_installed`
2. Add `opts_extend = { "ensure_installed" }` to the mason spec so lang files can extend the list
3. Rewrite `config` function to read `opts.ensure_installed` (passed by lazy.nvim) instead of the captured local
4. Keep the async install logic (registry refresh, missing package detection, per-package notifications) — just change the data source

The `ensure_installed` function, `install_package`, and `get_missing_packages` helpers stay in mason.lua. Only the data flow changes: packages come from merged opts instead of a hardcoded list.

### Linter migration (nvim-lint)

`lint.lua` already exists with dynamic linter detection for web filetypes (deno > eslint priority, config file sniffing). This is scoped entirely to web filetypes (JS/TS/JSON) and follows the same pattern as the shared formatter. It moves into `web.lua` alongside the formatter logic — both share the same config-file-detection pattern and filetype scope.

## Testing Decisions

### Manual verification checklist (per language)

For each lang file, verify:

- [ ] Treesitter parsers install (`:TSInstall` or auto_install)
- [ ] LSP starts and attaches (`:checkhealth lsp` or `:lua vim.print(vim.lsp.get_clients())`)
- [ ] Formatter runs on save (`:ConformInfo` shows correct formatter)
- [ ] Mason packages install (`:Mason` shows installed)
- [ ] LspAttach keymaps work (hover, code action, rename)

### Regression risks

- **Load ordering**: LSP config must be available before first buffer opens. Test with cold start AND session restore.
- **opts_extend merging**: Verify `ensure_installed` lists from multiple lang files actually combine (not replace).
- **Web formatter logic**: The shared formatter detection (prettier/deno/biome) is the most complex piece. Test with projects using each formatter.

### No automated tests

This is dotfiles config -- manual verification in Neovim is the test suite.

## Migration Strategy

Implement one language at a time, verify, commit. Order by complexity:

1. **Phase 1 -- Infrastructure**: Create slim base specs (treesitter, conform, mason, lsp.lua). Verify nothing breaks with existing `lsp/*.lua` files still in place.
2. **Phase 2 -- Simple languages**: go, bash, toml, http (minimal LSP config, straightforward formatters)
3. **Phase 3 -- Medium languages**: lua, rust, swift, yaml, markdown (some custom LSP settings)
4. **Phase 4 -- Web ecosystem**: web.lua (complex -- shared formatters, shared linters, multiple LSPs, framework LSPs). Absorbs conform web formatters, lint.lua linter logic, and all web LSP configs.
5. **Phase 5 -- Cleanup**: Remove empty `lsp/` directory, `lsp-config.lua`, `lib/lsp-util.lua`, `lib/lsp.lua`, `specs/lint.lua`. Update CLAUDE.md.

Each phase is one or more commits. Revert is always possible per-phase.

## Out of Scope

- **dev:add-lang skill**: Future work after the refactor proves stable. Tracked separately.
- **nvim-lspconfig adoption**: Staying fully native. Lang files use `vim.lsp.config()` directly.
- **Linter refactoring beyond web.lua**: nvim-lint is in use for web filetypes and moves into `web.lua`. No new linter integrations are added for other languages as part of this refactor.
- **Completion config (blink.cmp)**: Not language-specific, stays in its own spec.
- **DAP/debugging config**: Not currently set up. Future lang file concern.
