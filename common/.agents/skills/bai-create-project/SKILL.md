---
name: bai-create-project
description: Bootstrap a Black Atom Industries project — loads org context from about:bai and bai:* skills, then invokes dev:create-project with BAI defaults.
metadata:
  argument-hint: "[name] [--type adapter|plugin|core|tool|app]"
---

# Create BAI Project

Wrapper over `dev:create-project` for Black Atom Industries repos. Loads org context first to understand the ecosystem, then applies BAI-specific defaults before delegating to the base skill.

## Before Invoking Base Skill

### 1. Load Org Context

Invoke `about:bai` to understand the Black Atom ecosystem:

- Theme system (collections, adapters, core)
- Adapter architecture
- Naming conventions
- Repository structure

### 2. Load BAI Skills

Read `bai:*` skills for org conventions:

- `bai:commit` — commit message conventions, GitHub issue integration
- `bai:status` / `bai:create` / `bai:update` — issue workflow patterns
- `bai:review` / `bai:close` — issue lifecycle

### 3. Detect BAI Project Type

Ask if ambiguous. Use `AskUserQuestion`:

| Type        | Description                                                            | Example                                                       |
| ----------- | ---------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Adapter** | Theme adapter repo — maps Black Atom tokens to a tool's theme format   | `black-atom-industries/ghostty`, `black-atom-industries/tmux` |
| **Plugin**  | Neovim/editor plugin (Lua, not TS — different ecosystem conventions)   | `radar.nvim`                                                  |
| **Core**    | `@black-atom/core` packages — theme definitions, color math, utilities | `core/` monorepo packages                                     |
| **Tool**    | Dev tooling for the BAI ecosystem                                      | `helm`, `livery`                                              |
| **App**     | Web or desktop app                                                     | `monitor`, `livery` (Tauri)                                   |

## BAI Defaults

Applied as overrides to `dev:create-project`:

| Setting       | Value                                                                                  |
| ------------- | -------------------------------------------------------------------------------------- |
| Path          | `~/repos/black-atom-industries/{name}`                                                 |
| GitHub org    | `black-atom-industries`                                                                |
| CLAUDE.md     | Include GitHub project reference (Black Atom V1, project #7)                           |
| settings.json | Include `Skill(bai:create)`, `Skill(bai:update)` in allowedTools                       |
| Commit skill  | Reference `bai:commit` in `.claude/` config                                            |
| .gitignore    | Add BAI-specific entries (e.g., `.luarocks/` for Lua plugins, adapter build artifacts) |

## Flow

1. Load org context (steps 1-3 above)
2. Ask BAI project type if not specified via `--type`
3. Apply BAI defaults as overrides
4. Invoke `dev:create-project` with:
   - Path set to `~/repos/black-atom-industries/{name}`
   - Project type mapped from BAI type (adapter→lib, plugin→lib, core→lib, tool→cli, app→web/desktop)
   - BAI defaults merged into scaffolding plan
5. After base skill completes, offer to setup GitHub issue handling for the repo.
6. Verify BAI-specific config is present:
   - GitHub project reference in CLAUDE.md
   - `bai:commit` referenced in settings
   - Org-specific .gitignore entries

## Cross-References

- `dev:create-project` — base skill invoked with org overrides
- `about:bai` — org ecosystem context (adapters, core, theme system)
- `bai:commit` — commit conventions with GitHub issue integration
- `bai:status` — issue tracking workflow
