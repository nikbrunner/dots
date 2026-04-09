# Plan: Migrate Claude Code Config to Pi

> **Note:** This file will be moved to `plans/migrate-claude-to-pi.md` as the first execution step.

## Context

Migrating from Claude Code to Pi as the primary coding agent. Skills are already consolidated under `common/.agents/skills/` (done in c20a51cc). The goal is to:

1. Create a single source-of-truth global instructions file (`AGENTS.md`) that both Pi and Claude Code read natively
2. Port the 5 Claude Code hooks to a Pi extension
3. Wire everything up in `symlinks.yml` so new machines get it all automatically
4. Clean up stale Claude Code references

Pi reads `~/.pi/agent/AGENTS.md` natively. Claude Code reads `~/.claude/CLAUDE.md` natively. One file, two symlinks.

## Approach

- **Single source of truth:** `common/.agents/AGENTS.md` (moved/rewritten from `common/.claude/CLAUDE.md`)
- **Symlink to both tools** via `symlinks.yml`
- **Pi extension** at `common/.pi/agent/extensions/enforce.ts` to replace the 5 hooks
- **No Claude Code deletions yet** — keep `.claude/` intact while transitioning

## Files to Modify / Create

| File                                     | Action                                                                       |
| ---------------------------------------- | ---------------------------------------------------------------------------- |
| `common/.agents/AGENTS.md`               | **Create** — rewritten, tool-agnostic version of CLAUDE.md                   |
| `common/.pi/agent/extensions/enforce.ts` | **Create** — ports all 5 hooks to Pi extension events                        |
| `symlinks.yml`                           | **Update** — add `AGENTS.md` symlinks, add `extensions/` symlink             |
| `common/.claude/CLAUDE.md`               | **Update** — become a symlink target (no content change needed if symlinked) |

## Steps

- [ ] **1. Create `common/.agents/AGENTS.md`**
  - File lives in `common/.agents/` (alongside `skills/`) — the unified agent home
  - Two external symlinks in `symlinks.yml` point the tools at it (repo → `~` only, same as all other entries)
  - Move content from `common/.claude/CLAUDE.md`
  - Make it tool-agnostic:
    - Remove Claude Code-specific language ("Use the Skill tool", "Skill tool BEFORE any response")
    - Replace "Ref MCP" / "Exa MCP" references → `fetch_content`, `web_search`, `code_search` tools
    - Replace "subagent" / `AskUserQuestion` Claude Code tool references with neutral language
    - Keep: identity, communication style, development philosophy, code intelligence, context efficiency, self-improvement awareness

- [ ] **2. Create `common/.pi/agent/extensions/` directory and `enforce.ts`**

  Ports these hooks to Pi extension events:

  | Hook                  | Pi event                        | Behavior                                                           |
  | --------------------- | ------------------------------- | ------------------------------------------------------------------ |
  | `current-datetime.sh` | `before_agent_start`            | Inject current date/time into system prompt                        |
  | `session-start.sh`    | `session_start`                 | Inject `meta-enforcement` skill content                            |
  | `skills-check.sh`     | `input`                         | Keyword-match prompt → suggest relevant skills via `ctx.ui.notify` |
  | `semantic-commits.sh` | `tool_call` on `bash`           | Block `git commit` without semantic prefix                         |
  | `warn-any-type.sh`    | `tool_result` on `write`/`edit` | Warn when `: any` / `as any` appears in `.ts`/`.tsx` files         |

- [ ] **3. Update `symlinks.yml`**
  - `symlinks.yml` is strictly repo → `~` external symlinks (confirmed from `scripts/dots/symlinks.sh`)
  - Repo-internal symlinks (like `common/.claude/skills → ../.agents/skills`) are created manually and tracked in git

  Add to `symlinks.yml`:

  ```yaml
  common/.agents/AGENTS.md: ~/.pi/agent/AGENTS.md
  common/.agents/AGENTS.md: ~/.claude/CLAUDE.md
  common/.pi/agent/extensions: ~/.pi/agent/extensions
  ```

  Remove from `symlinks.yml`:

  ```yaml
  common/.claude/CLAUDE.md: ~/.claude/CLAUDE.md # ← replaced by .agents/AGENTS.md symlinks
  ```

- [ ] **4. Rename and generalize `dev-setup-claude` → `dev-setup-llm`**
  - Rename `common/.agents/skills/dev-setup-claude/` → `common/.agents/skills/dev-setup-llm/`
  - Update `SKILL.md` frontmatter: `name: dev-setup-llm`, description updated
  - Add tool-specific guide files within the skill directory:
    - `guides/pi.md` — Pi-specific: `AGENTS.md` location, extensions, `~/.pi/agent/` structure, `pi install` for packages
    - `guides/claude-code.md` — Claude Code-specific: hooks, `settings.json`, plugins
  - Main `SKILL.md` stays tool-agnostic: covers `AGENTS.md` as canonical source, skills structure, shared conventions
  - Update cross-references in other skills that mention `dev-setup-claude`

- [ ] **5. Commit**
  - `refactor(agents): consolidate global instructions into AGENTS.md`
  - `feat(pi): add enforce extension porting Claude Code hooks`
  - `chore(dots): update symlinks for AGENTS.md and pi extensions`

## Reuse

- Existing hook logic (all 5 scripts in `common/.claude/hooks/enforce/`) — port 1:1 as TypeScript
- `meta-enforcement` skill path: `~/.agents/skills/meta-enforcement/SKILL.md`
- Pi extension API: `session_start`, `before_agent_start`, `input`, `tool_call`, `tool_result` events from `@mariozechner/pi-coding-agent`

## Follow-up Tasks (out of scope for this plan)

- **Plugins via skills.sh** — `impeccable` and `readwise-skills` are Claude Code plugins but both exist on skills.sh. Install after migration is stable:
  - `impeccable`: `npx skills add pbakaus/impeccable@teach-impeccable` (43.6K installs)
  - `readwise`: `npx skills add readwiseio/readwise-skills@<skill>` (multiple skills available)
- **Update repo `AGENTS.md`** — `dots/AGENTS.md` at the repo root currently says "guidance to Claude Code". Update to be tool-agnostic and mention Pi.
- **Migrate `agents/` subagents** — audit which are actively referenced from skills: keep, inline, or delete (flagged in `.claude/README.md` TODOs)
- **Migrate `claude-memories/`** — project-specific memory files; Claude Code-specific concept, low priority
- **Delete `common/.claude/`** — once fully migrated off Claude Code and nothing is lost
- **Add Pi sessions to `dots chores`** — `~/.pi/agent/sessions/` accumulates session files like nvim sessions do. Add a `dots_commit_pi_sessions` function to `scripts/dots/lib.sh` (mirroring `dots_commit_sessions` for nvim) and wire it into `cmd_chores` in `common/.local/bin/dots`. Should clean up old sessions and commit changes.
- **Overhaul `dev-flow` skill for Pi** — `dev-flow` currently bakes in Claude Code-specific concepts (subagents, `context: fork`). After migration, review the full skill pipeline and integrate Plannotator (`pi --plan`, `/plannotator`) into the planning phase. The whole skill may need restructuring now that Pi's tree navigation, session forking, and plan mode are available.

## Verification

- [ ] `cat ~/.pi/agent/AGENTS.md` — resolves to new content
- [ ] `cat ~/.claude/CLAUDE.md` — resolves to same content (symlink works)
- [ ] Start pi, confirm date/time appears in context
- [ ] Start pi, confirm meta-enforcement content is injected
- [ ] Attempt `git commit bad message` — confirm it gets blocked
- [ ] Write `: any` in a `.ts` file — confirm warning fires
- [ ] `pi list` — confirm extension is loaded (no errors)
- [ ] On a clean machine: `dots link` → `pi` starts with all settings, skills, extension auto-installed
