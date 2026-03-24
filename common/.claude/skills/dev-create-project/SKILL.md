---
name: dev:create-project
description: Bootstrap a new project with Nik's conventions — wizard flow that detects, infers, asks, plans, scaffolds, then invokes dev-claude-setup.
argument-hint: [path] [--type cli|lib|web|desktop]
---

# Create Project

Interactive wizard that bootstraps new projects with consistent conventions. Detects context, infers defaults from `dev-*` skills and past project patterns, asks only genuinely ambiguous questions, presents a scaffolding plan, then executes.

## Arguments

- `<path>` — Optional. Target directory. Defaults to cwd.
- `--type` — Optional. Skip detection: `cli`, `lib`, `web`, `desktop`

## Phase 1: DETECT

Scan for signals to determine project state and ecosystem. See `defaults.md` for the full detection signal table.

1. **Repo exists?** — Check for `.git/` directory
2. **Org** — Infer from path (`~/repos/nikbrunner/` vs `~/repos/black-atom-industries/`)
   - If BAI path detected, suggest using `bai:create-project` instead
3. **Ecosystem** — Scan for `deno.json`, `package.json`, `Cargo.toml`, etc.
4. **Project type** — CLI tool, library, web app, desktop app

If no repo exists:

1. Ask for project name and one-line description via `AskUserQuestion`
2. `mkdir -p <path> && cd <path> && git init`
3. Ask if user wants a GitHub remote — if yes, `gh repo create`

## Phase 2: INFER

Load defaults from `defaults.md` based on detected/specified project type.

Load relevant `dev-*` skills for conventions (see Dev Skill Mappings in `defaults.md`):

- `dev:typescript` — always for TS projects
- `dev:react`, `dev:styling`, `dev:state-management` — for web/desktop
- `dev:tanstack` — when TanStack libs are relevant
- `dev:tdd`, `dev:planning` — always
- `dev:openspec-init` — offer to initialize OpenSpec for medium+ projects

Present inferred configuration summary to user. Example:

> **Inferred setup:**
>
> - Ecosystem: Deno
> - Type: CLI tool
> - Framework: Cliffy
> - Config: TOML + Zod v4
> - Formatting: 4-space, 100 width, double quotes
> - Git hooks: pre-commit (fmt + lint + check + test)

## Phase 3: ASK

Use `AskUserQuestion` for genuinely ambiguous choices only. Skip questions when the answer is inferrable.

Contextual questions (ask only when relevant):

- **Project type** (if not detected or specified): CLI tool, library, web app, desktop app
- **Ecosystem** (if user declines Deno): Node with npm/pnpm/bun
- **Framework** (if web/desktop): React (default), or none
- **Additional tooling**: Zod, TanStack libs, etc.
- **Global install** (CLI tools): Does this need `deno task install`?

**Never ask about:** conventional commits (always yes), formatting settings (always the same), strict mode (always yes).

## Phase 4: PLAN

Present a complete scaffolding plan as a table. Wait for user approval before executing.

Example:

| File                         | Action     | Content summary                 |
| ---------------------------- | ---------- | ------------------------------- |
| `deno.json`                  | Create     | Tasks, imports, fmt/lint config |
| `src/main.ts`                | Create     | Entry point with Cliffy setup   |
| `src/commands/`              | Create dir | CLI command stubs               |
| `src/config/`                | Create dir | Config loading + Zod schema     |
| `src/lib/`                   | Create dir | Core logic                      |
| `tests/`                     | Create dir | Test directory                  |
| `scripts/setup-git-hooks.sh` | Create     | Pre-commit hook installer       |
| `README.md`                  | Create     | Name, install, usage, dev       |
| `.gitignore`                 | Create     | Deno ignores                    |
| `.claude/`                   | Delegate   | → `dev-claude-setup`            |

## Phase 5: EXECUTE

Scaffold files using templates from `templates.md`. Each file write goes through normal tool approval.

- Create directories first, then files
- Use `{name}` and `{description}` placeholder substitution from Phase 1/3 answers
- Make scripts executable (`chmod +x`)

### Optional: Pre-commit Hooks

Offer to set up pre-commit hooks when scaffolding is complete:

1. Detect package manager (deno, npm, pnpm, bun)
2. For Node projects: install `husky` + `lint-staged` + `prettier` as devDeps
3. For Deno projects: use `deno task` with a git hook script
4. Configure pre-commit hook chain: lint-staged -> typecheck -> test
5. Create `.lintstagedrc` and `.prettierrc` if missing

### Optional: Git Guardrails

Offer to set up Claude Code PreToolUse hooks that block dangerous git commands:

- `git push` (without explicit approval)
- `git reset --hard`
- `git clean -f`
- `git branch -D`
- `git checkout .`
- `git restore .`

Reference the existing enforce hooks pattern at `common/.claude/hooks/enforce/` for implementation style. Create as a `enforce/git-guardrails.sh` hook script.

## Phase 5.5: OpenSpec (optional)

Offer to initialize OpenSpec for medium+ projects. If accepted, invoke `dev:openspec-init` to scaffold the `openspec/` directory with project-level specs.

## Phase 6: CLAUDE

Invoke `dev-claude-setup` to handle `.claude/` configuration. Pass context so it makes informed decisions:

- Project name and type
- Ecosystem (Deno/Node)
- Whether it's a globally-installed CLI (triggers auto-install hook)
- Which `dev-*` skills are relevant

`dev-claude-setup` will create:

- `CLAUDE.md` (lean, ~50 lines max)
- `settings.json` (allowedTools, PostToolUse hooks)
- Hooks (`postwrite.sh` for fmt+lint, `auto-install.sh` for CLI tools)
- Skills (`about:{project-name}` knowledge skill)

## Conventions

- **Deno is the default ecosystem.** Node/npm available as explicit fallback only.
- **Conventional commits always.** Never ask.
- **All TS settings from `dev:typescript` skill.** 4-space, 100 width, double quotes, strict, `noUncheckedIndexedAccess`.
- **Minimal scaffolding.** Create structure and config, not boilerplate code. Entry points get a minimal stub, not full implementations.

## Cross-References

- `dev-claude-setup` — invoked in Phase 6 for `.claude/` scaffolding
- `dev:typescript` — TS conventions loaded in Phase 2
- `dev:react` — React patterns loaded for web/desktop projects
- `dev:tdd` — test strategy loaded in Phase 2
- `dev:styling` — CSS/Tailwind preferences loaded for web/desktop projects
- `dev:state-management` — state architecture loaded for web/desktop projects
- `bai:create-project` — BAI-specific wrapper that invokes this skill

## References

- For inference defaults, see `defaults.md`
- For file templates, see `templates.md`
