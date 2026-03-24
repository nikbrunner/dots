# Inference Defaults

## Detection Signals

| Signal                                         | Indicates                                                       |
| ---------------------------------------------- | --------------------------------------------------------------- |
| No existing files                              | Fresh project — ask project type                                |
| `deno.json`                                    | Deno ecosystem                                                  |
| `package.json`                                 | Node ecosystem                                                  |
| `Cargo.toml`                                   | Rust (likely Tauri if combined with `deno.json`/`package.json`) |
| `vite.config.*`                                | Web app (React)                                                 |
| `tauri.conf.json`                              | Tauri desktop app                                               |
| Path contains `~/repos/black-atom-industries/` | BAI org — suggest `bai:create-project` instead                  |

## Ecosystem Defaults

### Deno CLI Tool

| Aspect            | Default                                                                     |
| ----------------- | --------------------------------------------------------------------------- |
| CLI framework     | Cliffy (`jsr:@cliffy/command`, `jsr:@cliffy/prompt`)                        |
| Config format     | TOML via `jsr:@std/toml`                                                    |
| Validation        | Zod v4 (`npm:zod`)                                                          |
| Entry point       | `src/main.ts`                                                               |
| Directory layout  | `src/commands/`, `src/config/`, `src/lib/`, `tests/`, `scripts/`            |
| Tasks             | `test`, `check`, `lint`, `fmt`, `fmt:check`, `checks`, `install`, `compile` |
| Global install    | Yes — `deno task install`                                                   |
| Auto-install hook | Yes — Stop hook that re-installs when source is stale                       |

### Deno Library

| Aspect           | Default                                               |
| ---------------- | ----------------------------------------------------- |
| Package registry | JSR                                                   |
| Entry point      | `src/mod.ts`                                          |
| Directory layout | `src/lib/`, `tests/`                                  |
| Tasks            | `test`, `check`, `lint`, `fmt`, `fmt:check`, `checks` |
| Global install   | No                                                    |

### React Web App

| Aspect             | Default                                                                         |
| ------------------ | ------------------------------------------------------------------------------- |
| Build tool         | Vite (via `deno run -A npm:vite` or `npx vite`)                                 |
| Styling            | Tailwind CSS v4 (Vite plugin)                                                   |
| Routing            | TanStack Router (file-based)                                                    |
| Data fetching      | TanStack Query                                                                  |
| Entry point        | `src/main.tsx`                                                                  |
| Directory layout   | `src/routes/`, `src/components/`, `src/containers/`, `src/lib/`, `src/queries/` |
| Dev skills to load | `dev:react`, `dev:styling`, `dev:state-management`, `dev:tanstack`              |

### Tauri Desktop App

| Aspect          | Default                                                             |
| --------------- | ------------------------------------------------------------------- |
| Combines        | React Web App defaults + Rust shell                                 |
| Additional dirs | `src-tauri/` (Cargo.toml, src/main.rs, src/lib.rs, tauri.conf.json) |
| Tasks           | Adds `dev` (Tauri dev), `build` (Tauri build)                       |

### Node/npm (Fallback)

Available when Deno is explicitly declined.

| Aspect          | Default                          |
| --------------- | -------------------------------- |
| Package manager | npm (ask if pnpm/bun preferred)  |
| Config          | `package.json` + `tsconfig.json` |
| Formatting      | Prettier                         |
| Linting         | ESLint                           |
| Entry point     | `src/index.ts`                   |

## Universal TypeScript Defaults

Always applied regardless of ecosystem:

| Setting                    | Value    |
| -------------------------- | -------- |
| Indent                     | 4 spaces |
| Line width                 | 100      |
| Semicolons                 | Yes      |
| Quotes                     | Double   |
| Strict mode                | Yes      |
| `noUncheckedIndexedAccess` | Yes      |

## Dev Skill Mappings

| Project type   | Skills to load                                                          |
| -------------- | ----------------------------------------------------------------------- |
| Any TypeScript | `dev:typescript`                                                        |
| React          | `dev:react`, `dev:styling`, `dev:state-management`                      |
| TanStack usage | `dev:tanstack`, `dev:tanstack-query`, `dev:tanstack-form` (as relevant) |
| Any project    | `dev:tdd`, `dev:planning`                                               |
