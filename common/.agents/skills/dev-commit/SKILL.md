---
name: dev-commit
description: "Commit workflow with staged docs audit, conventional commit format, approval gate, and pre-commit chain. Stages selectively, runs dev:audit docs --staged, drafts a message, waits for explicit approval, then commits."
argument-hint: "[optional message hint or scope hint]"
user-invocable: true
metadata:
  argument-hint: "[optional message hint or scope hint]"
  user-invocable: true
---

# dev:commit

A disciplined commit ritual. Combines selective staging, doc-audit-before-commit, Conventional Commits, an explicit approval gate, and the project's pre-commit chain.

Uses `dev:audit docs --staged` (built into dev-audit) for the docs audit phase.

## When to use

- Any time you intend to write a commit.
- Don't invoke if the user only asks for code changes — wait for "commit", "stage", "ship", or similar.

---

## Phase 0 — Survey the working tree

```sh
git status -s
git diff --stat            # unstaged
git diff --cached --stat   # already-staged
git log --oneline -5       # style reference for recent messages
```

Identify three buckets:

- **In scope** — files that belong to the current logical change.
- **Held back** — pre-existing modifications unrelated to this work. Always include `ROADMAP.md` unless the user explicitly asks for a roadmap commit.
- **Stray** — unexpected edits to files you didn't touch (formatter side-effects, editor auto-imports, generated files, lockfile changes). Surface these to the user; do not silently include them.

---

## Phase 1 — Stage selectively

- Add files by name: `git add <file> <file> ...`.
- Never use `git add -A` or `git add .` — they sweep up secrets, build artifacts, and unrelated edits.
- If a held-back file was already staged by a hook or prior operation, unstage it: `git restore --staged <file>`.
- If nothing meaningful is staged after this phase, stop and explain why.

---

## Phase 2 — Audit docs

Invoke `dev:audit docs --staged`. Read the findings. Three outcomes:

| Result        | Action                                                                                            |
| ------------- | ------------------------------------------------------------------------------------------------- |
| Docs in sync  | Continue.                                                                                         |
| STALE / DRIFT | Apply minimal edits to the flagged docs. Stage them. Fold into this commit, not a separate docs:. |
| GAP           | Document the new surface or convention. Stage. Fold into this commit.                             |

Do **not** skip Phase 2.

---

## Phase 3 — Draft the message

**Format:**

```
<type>(<scope>): <description>
```

**Type:** `feat`, `fix`, `refactor`, `chore`, `docs`, `perf`, `ci`, `test`.

**Scope** — determined by which files changed. Project-level scope rules (from AGENTS.md, CLAUDE.md) override these defaults:

- If changes are isolated to one module, package, or directory, use that as scope.
- Pick scope casing conventions from the project's prior commit log.
- If changes span multiple areas, omit scope.
- Config-only or docs-only changes: omit scope.

**Subject** — imperative mood ("add X", not "added X"), under 70 chars, focused on _why_ not _what_.

**Body** (optional) — use when the diff is large or non-obvious. Summarize the rationale or the moving parts in 2–4 lines. Never echo the file list.

---

## Phase 4 — Show & wait

Print three things and stop:

1. Final file list (with held-back / stray items called out explicitly).
2. The drafted commit message exactly as it will be written.
3. A single explicit ask: "Go-ahead to commit?"

Never commit without the user's explicit "yes", "go", "commit", or equivalent. A prior commit approval does not generalize.

---

## Phase 5 — Commit

Always use a heredoc to preserve formatting:

```sh
git commit -m "$(cat <<'EOF'
type(scope): subject line under 70 chars

Optional body. Wrapped around column 72. Explains the why.
EOF
)"
```

Run the project pre-commit chain (build, test, lint, typecheck — whatever `pre-commit` or the project's hook specifies). All must pass.

**If a hook step fails:** fix the underlying issue, re-stage, create a **new** commit. Never `--amend` after a hook failure — the prior commit didn't happen, and `--amend` would rewrite an unrelated commit.

After success, confirm with `git log --oneline -3` and `git status -s`.

---

## Strategies for re-touching history

| Situation                                                               | Strategy           | Command                                                           |
| ----------------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------- |
| Fix belongs to the **immediately prior** commit, already pushed nowhere | Amend              | `git commit --amend --no-edit`                                    |
| Fix belongs to an **older** local commit                                | Fixup + autosquash | `git commit --fixup=<sha>` + `git rebase -i --autosquash <sha>~1` |
| Distinct new unit of work                                               | New commit         | Normal flow above.                                                |

**Always ask before amending or fixup.** History rewrites can lose work; not worth a silent assumption.

---

## Rules

- **Conventional Commits.** Match the format above. The git history is read by humans and tools.
- **Atomic commits.** One logical change per commit. Tooling churn ≠ feature change ≠ doc sweep.
- **Approval required.** Stage and show; never commit on autopilot.
- **No `--no-verify`** unless the user explicitly requests it. Hook failures point at real problems.
- **Hold back what's not yours.** ROADMAP.md and any edit you didn't author stay unstaged unless the user opts them in.
- **No secrets staged.** Reject anything that looks like `.env`, credentials, tokens, or large binaries.
