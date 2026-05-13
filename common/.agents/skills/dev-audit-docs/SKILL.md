---
name: dev-audit-docs
description: "Audit project documentation against code changes — diff-driven, conservative. Flags staleness, gaps, drift, and schema violations. Use before every commit or as a periodic sweep."
argument-hint: "[--staged | --commits N]"
user-invocable: true
metadata:
  argument-hint: "[--staged | --commits N]"
  user-invocable: true
---

# dev:audit:docs

Surface documentation drift. Reads the diff, categorizes changes, discovers candidate docs by scanning the project tree, and flags what's out of sync.

Two invocation modes:

- **`--staged`** (default) — lightweight pre-commit gate, invoked by `dev-commit` Phase 2
- **`--commits N`** — deep periodic sweep for feature-landing cleanup or PR review

## Arguments

- `--staged` (default) — audit `git diff --cached` only.
- `--commits N` — audit the last N commits (`git diff HEAD~N`). Use for end-of-feature sweeps.
- If empty and nothing staged, fall back to `--commits 5` and note it.

---

## Steps

### 1. Read the diff

- `--staged`: `git diff --cached --name-status` then `git diff --cached`.
- `--commits N`: `git log --oneline -N` then `git diff HEAD~N`.

### 2. Categorize the changes

| Category        | What counts                                                                     |
| --------------- | ------------------------------------------------------------------------------- |
| **structural**  | Files added / moved / deleted, new public exports, directory layout changes     |
| **behavioral**  | Script/CLI/API changes, new components, new hooks, prop/knob/theme changes      |
| **configuration** | Env vars, package.json scripts, dependencies, tooling config, CI/CD changes   |
| **patterns**    | Folder conventions, CSS approach, state patterns, hook conventions, module design |

### 3. Discover candidate docs

Scan the worktree for documentation files (non-gitignored `.md` files, excluding `node_modules`, plans, tmp, and generated dirs):

```sh
find . -name '*.md' -not -path '*/node_modules/*' -not -path '*/plans/*' \
  -not -path '*/tmp/*' -not -path '*/.git/*' | sort
```

Group discovered docs by role:

| Doc role           | Match pattern (heuristic)                             |
| ------------------ | ----------------------------------------------------- |
| **Project config** | `(./|root/)AGENTS.md`, `CLAUDE.md`, `README.md`       |
| **Architecture**   | `docs/architecture*.md`, `**/docs/architecture*.md`   |
| **Component/API**  | `docs/components/*.md`, `docs/hooks/*.md`, `docs/*.md` |
| **Style**          | `docs/style*.md`, `**/docs/style*.md`, `docs/patterns*.md` |
| **Setup**          | `docs/setup*.md`, `docs/getting-started*.md`, `CONTRIBUTING.md` |
| **Package**        | `packages/*/docs/`, `apps/*/docs/` (deep per-package docs)    |

If no docs exist beyond root `README.md`, note the gap and proceed conservatively.

### 4. Map change categories to candidate docs

| Change type    | Likely doc roles                         |
| -------------- | ---------------------------------------- |
| structural     | Project config, Architecture             |
| behavioral     | Component/API, Package docs, README      |
| configuration  | Project config, Setup, README            |
| patterns       | Style, Architecture, Project config      |

### 5. Read only the relevant candidate docs

Use `grep` or `ffgrep` to check whether any changed symbol, path, or concept appears in the candidate docs. If it does, read that doc. If none match, skip — no drift possible.

Within matched docs, search for:
- The file path or component name being changed
- Related exports, function names, or CLI flags
- Previous patterns that the diff replaces

### 6. Flag each finding

| Finding | Meaning                                                                |
| ------- | ---------------------------------------------------------------------- |
| STALE   | Doc describes something now removed, renamed, or relocated.            |
| GAP     | New behavior or surface not mentioned anywhere.                        |
| DRIFT   | Pattern described in doc differs from implementation.                  |
| SCHEMA  | A doc violates its expected structure (see project-level schema rules). |

**Be conservative.** Minor wording deltas are not drift. When in doubt, don't flag.

### 7. Skip out-of-scope files

- `plans/*.md`, `tmp/*.md` — drafts, not published docs.
- `ROADMAP.md` (LOG section) — manually maintained; only flag if the diff itself changes it.
- `CHANGELOG.md` — release-managed; don't flag.
- `node_modules/**`, `dist/**`, `build/**`, generated files (`*.gen.css`, etc.).
- Skills (`~/.claude/skills/*`, `~/.pi/agent/skills/*`) — not project-scoped.

### 8. Present findings — wait before editing

| File                 | Issue  | Suggested fix                                              |
| -------------------- | ------ | ---------------------------------------------------------- |
| `AGENTS.md:L18`      | STALE  | Reference to old build command needs updating              |
| `docs/hooks.md:L42`  | GAP    | New `useThing` hook not documented                         |
| `docs/style.md:L30`  | DRIFT  | CSS Modules approach differs from described convention     |

If no drift: report **"Docs in sync."** and exit.

### 9. On confirmation

Apply minimal, style-matching edits. For multi-file fixes, delegate to a sub-agent. Fold the doc edits into the upcoming commit (the audit ran _before_ commit) rather than a separate `docs:` commit.

---

## Project-level extensions

Projects can extend this skill to add:

- **Custom doc paths** — override the discovery patterns with project-specific paths.
- **Schema checks** — define structural rules for component or API docs (e.g. required sections, heading order, prop table conventions). Flag violations as `SCHEMA` findings.
- **Skip rules** — add project-specific files to the skip list.

To extend, the project skill references `dev-audit-docs` and adds its own mapping table and schema checks.

---

## Rules

- **Project-scoped only** — never edit `~/.claude/*`, `~/.pi/*`, or other personal/global config.
- **Minimal edits** — change only what's stale; preserve existing tone and structure.
- **No speculation** — document only what actually changed in the diff.
- **Conservative flagging** — when in doubt, don't flag.
- **SCHEMA is opt-in** — only fires if a project skill provides schema rules.
