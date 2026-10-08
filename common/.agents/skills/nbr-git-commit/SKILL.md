---
name: nbr-git-commit
description: "Commit workflow: repo conventions resolved per field, selective staging down to single hunks, a review for stale docs, side effects and boy-scout fixes, the repo's checks, and an approval gate. Use for any commit. nbr-git-commit-buckets and nbr-git-commit-rebuild run its review and commit steps for several commits at once."
argument-hint: "[optional message hint or scope hint]"
user-invocable: true
metadata:
  argument-hint: "[optional message hint or scope hint]"
  user-invocable: true
---

# nbr-git-commit

One logical change in, one commit out. The workflow has two halves around an approval gate: **review** reads the diff and produces findings and a check result, **commit** stages, commits and verifies. Run directly, this skill does both for one commit. `nbr-git-commit-buckets` runs the review once over the whole working tree, holds one gate for all its buckets, then runs the commit half per bucket.

Commit messages are published under Nik's name. Apply the voice and anti-AI-ism rules from the active agent instructions to the subject and body.

## Conventions

Repo-local conventions win. Resolve each field on its own; the first source that answers it wins, and a source that is silent on a field passes it down the list.

| Field         | Lookup order                                                                                                                                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Grammar**   | project commit skill → `AGENTS.md` / `CLAUDE.md` / `CONTRIBUTING.md` → tool config (`commitlint.config.*`, `.gitmessage`; a release-please config means Conventional Commits) → `git log --oneline -30` → the default below |
| **Checks**    | project commit skill → `AGENTS.md` / `CLAUDE.md` → hook config (`lefthook.yml`, `.githooks/`, `.husky/`; pre-push first) → a `check` or `verify` task in `package.json`, `Makefile`, `mise.toml` → the CI workflow → none |
| **Docs list** | project commit skill → `AGENTS.md` / `CLAUDE.md` → every tracked `.md` file                                                                                                                                         |

A **project commit skill** is any `SKILL.md` under `.agents/skills/` or `.claude/skills/` whose name or description is about committing (`repo-commit`, `<project>-commit`, `ship`). With two candidates, ask which one applies. A workflow-kit `repo-commit` holds the docs list in its section 3, the checks in section 4 and the grammar in section 5.

Grammar covers the whole message: type list, scope vocabulary, ticket-key placement (leading `[ABC-123]` vs. trailing `(ABC-123)`), body style. Pull the ticket key from the branch name when the grammar uses one. Where a project skill and the log disagree, the skill wins; mention the divergence.

Show the resolved values with their sources, so a wrong guess is caught at the gate:

```
Grammar: Conventional Commits   (commitlint.config.ts)
Checks:  make check             (lefthook.yml pre-push)
Docs:    README.md, docs/       (AGENTS.md)
```

### Default grammar

Used when no source names one.

```
[<ticket>] <summary>
```

**Subject**: imperative mood ("add X", not "added X"), under 70 chars, focused on _why_ not _what_. No `type(scope):` prefix.

**Ticket or issue**: when the commit is tied to one, prepend its key in square brackets: `[WEBSDK-123] add X`. For a GitHub issue, keep the hash inside the brackets: `[#22] add X`, never `[22] add X`. Omit the brackets when none applies.

**Breaking change**: `BREAKING:` after the optional ticket: `[WEBSDK-123] BREAKING: remove the v1 API`.

**Body** (optional): for a large or non-obvious diff. Bullets, each stating what changed and why in the same breath, wrapped at 72 characters, never echoing the file list. Link related tickets, PRs, or other resources when useful.

## 1. Survey

```sh
git status --short
git diff --stat
git diff --cached --stat
git log --oneline -5
```

Sort every path into:

- **In scope**: belongs to the current logical change.
- **Held back**: unrelated pre-existing modifications. `ROADMAP.md` is held back unless the user asks for a roadmap commit.
- **Stray**: edits you didn't make (formatter side effects, editor auto-imports, generated files, lockfile churn). Surface them; include them only when the user opts in.

## 2. Stage

Stage by name: `git add <file> <file>`. When only part of a file belongs to the change, stage its hunks with `scripts/hunks.py` in this skill's directory:

```sh
python3 <skill-dir>/scripts/hunks.py list [PATH...]
python3 <skill-dir>/scripts/hunks.py show ID...
python3 <skill-dir>/scripts/hunks.py stage ID...
```

Hunks come from a zero-context diff, so every separated change is its own hunk. An ID hashes the path and the changed lines, so it survives commits of other hunks; only a suffixed duplicate (`abc1234-2`) can shift. Untracked, binary and mode-only files have no hunks: stage those with `git add` / `git rm`. `stage` is all or nothing.

Unstage held-back files a hook or earlier operation staged: `git restore --staged <file>`. Stage named paths only, so secrets, build artifacts and unrelated edits stay out. When nothing meaningful is staged, stop and say why.

## 3. Review

Review the diff in front of you: `git diff --cached` for a single commit, the whole working tree when `nbr-git-commit-buckets` runs this step. Read every hunk and every new file in full, then read around each change: callers of a changed function, consumers of a changed config key, docs describing the changed behaviour, references to a renamed or deleted file. Three kinds of finding come out:

- **Docs** ⚑: load `nbr-audit-docs` (a skill, not a Bash command) with `--staged`, or `--worktree` for the whole tree. Every doc on the resolved docs list is among its candidates. Each STALE, DRIFT, GAP or SCHEMA result is a finding; fixes follow `documentation-writer`.
- **Side effects** ⚠: a change that breaks or silently changes something elsewhere. A deleted module still imported, a renamed key still read under its old name.
- **Boy-scout** ⚑: small improvements in the code the change touches or sits right next to. An orphaned import the change created, a stale comment, a leftover debug print, a typo in a touched line. Stay inside the blast radius of the diff: leave the campsite cleaner, don't audit the codebase.

Each finding gets a location, a one-line problem, a concrete fix, and a proposed home: folded into this commit, or a commit of its own.

Then run the resolved checks. A docs-only change may skip them; say that it did. A failing check is a finding: fix the cause, or put it in front of the user at the gate.

Done when every hunk has been read in context, every finding has a fix, and the check result is known.

## 4. Gate

Print and stop:

1. The resolved conventions with sources.
2. The staged paths, with held-back and stray paths called out.
3. The findings, numbered (`F1`, `F2`).
4. The commit message exactly as it will be written.
5. The check result.
6. One ask: "Go-ahead to commit?"

Commit only on an explicit "yes", "go", "commit" or equivalent. Accepted findings are applied before the commit; unanswered findings count as declined. A prior approval does not carry over to a changed plan. A caller with its own gate (`nbr-git-commit-buckets`) replaces this step.

## 5. Commit

1. Apply the accepted findings and stage them. After edits next to staged hunks, re-run `hunks.py list` and stage by the fresh IDs.
2. Check `git diff --cached --stat` against the approved paths. It must match exactly.
3. Commit with a heredoc so the message keeps its formatting:
   ```sh
   git commit -m "$(cat <<'EOF'
   [WEBSDK-123] subject line under 70 chars

   - Moving part and why it changed, wrapped around column 72.
   EOF
   )"
   ```
4. Check `git show --stat HEAD` against the approved paths. A hook that formats and re-adds whole files can pull in other changes.

Hooks run as configured. When one fails, fix the cause, re-stage, and commit again as a new commit: the failed commit never happened, so there is nothing to amend. When a hook changed files, or a check in step 2 or 4 doesn't match, stop and report.

Confirm with `git log --oneline -3` and `git status --short`.

## Re-touching history

| Situation                                                               | Strategy           | Command                                                           |
| ----------------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------- |
| Fix belongs to the **immediately prior** commit, already pushed nowhere | Amend              | `git commit --amend --no-edit`                                    |
| Fix belongs to an **older** local commit                                | Fixup + autosquash | `git commit --fixup=<sha>` + `git rebase -i --autosquash <sha>~1` |
| A whole run of commits needs rewriting                                  | Rebuild            | `nbr-git-commit-rebuild`                                          |
| Distinct new unit of work                                               | New commit         | Normal flow above.                                                |

Ask before amending, fixing up or rebuilding: history rewrites can lose work.

## Rules

- **Atomic commits.** One logical change per commit. Tooling churn, a feature change and a doc sweep are three commits.
- **Hooks always run.** `--no-verify` only when the user explicitly asks for it.
- **No secrets.** Reject anything that looks like `.env`, credentials, tokens, or large binaries.
