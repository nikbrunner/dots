---
name: nbr-git-commit-buckets
description: Sort a dirty working tree into atomic commits, split by hunk where needed, with docs, side-effect and boy-scout findings and one approval gate before anything is committed. Use when the user wants to clean up git status, commit scattered changes, or tidy the working tree into commits.
argument-hint: "[optional scope, or 'commit without asking']"
---

# nbr-git-commit-buckets

Turn a messy working tree into a clean run of atomic commits. You survey every change, review it once as a whole, sort it into **buckets** (one logical change each, down to single hunks), and present the lot as one report. Nothing is committed until the user approves.

Each bucket is one `nbr-git-commit`. Read `nbr-git-commit/SKILL.md` (a sibling of this skill's directory) as a file rather than loading the skill: this workflow runs its Conventions, Review and Commit sections, and this skill's report replaces its gate. Hunk staging goes through its `scripts/hunks.py`.

## 1. Survey

```sh
git status --short
git diff --stat
git diff --cached --stat
git log --oneline -30
python3 <skills-dir>/nbr-git-commit/scripts/hunks.py list
```

Anything already staged is invisible to `hunks.py` and would ride along with the first commit. Give it its own bucket in the report, marked as pre-staged.

Done when every changed path and every hunk ID is accounted for.

## 2. Conventions

Resolve grammar, checks and docs list as nbr-git-commit's Conventions section describes.

While reading the project instructions, also look for a routine that commits on its own (a chores command). Such routines stage whole files, so run one only after the approved buckets are committed: by then the real edits in its files are gone, and it picks up only the routine churn left behind. Mark the files it will cover as held back with the routine's name, and put the routine on the report's last line.

## 3. Review

Run nbr-git-commit's Review section once over the whole working tree, with `nbr-audit-docs --worktree`. Every hunk and every untracked file is read in context, and every finding gets a proposed home: folded into bucket N, or a commit of its own.

The checks run once here, against the full tree: that proves the final state, and each commit's hooks still run on its own content.

Done when every hunk has been read in context, every finding has a proposed fix, and the check result is known.

## 4. Bucket

- One bucket, one reason to exist. A config tweak, a feature and a refactor are three buckets even inside one file.
- Split a file across buckets by hunk whenever its hunks serve different changes.
- When one hunk mixes two changes (they touch adjacent lines, so the diff joins them), put it in the bucket it mostly serves and say so in the report. Offer to split it by editing it apart only if the user asks.
- Order buckets so each commit stands on its own: a dependency before its dependent.
- **Held back**: generated or machine-local churn with no matching source change, unfinished work, anything resembling a secret, anything you can't place with confidence. Held back stays unstaged unless the user opts it in.

## 5. Report and stop

Print the report in exactly this shape, then stop and wait:

```
Working tree: 14 files, 23 hunks → 4 buckets, 2 held back, 3 findings
Grammar: nbr-git-commit default ([#issue] prefix, imperative)   (no project source)
Checks:  make check   (lefthook.yml pre-push) → pass
Docs:    every tracked .md

[0] pre-staged
    M  src/api.ts                                  (whole index)

[1] [#42] switch file explorer from mini.files to oil
    D  nvim/plugin/50_specs/mini/files.lua         whole file
    ?? nvim/plugin/50_specs/oil.lua                whole file
    M  nvim/ftplugin/markdown.lua   4232362  -40 +40,2  keymap -> oil
    ⚠ F1 nvim/init.lua:12 still requires "mini.files".
         Fix: drop the require. Fold into [1].
    ⚑ F2 markdown.lua:8 comment still says "mini.files".
         Fix: update the comment. Fold into [1].
    ⚑ F3 README.md:40 STALE: names mini.files as the explorer.
         Fix: name oil. Fold into [1].

[2] add lazyjira copy keymap
    M  lazyjira/config.yml          be54c48, 70f4967
    M  nvim/ftplugin/markdown.lua   45f9ae4   ← other hunks than [1]

Held back
    M  mise/mise.lock       lockfile churn, no matching config change
    M  zoxide/seed.txt      machine-local state (dots chores)

Afterwards: `dots chores` commits the held-back routine files (from AGENTS.md)

Reply: "go" (all) · "go fix" (all + every finding) · "go 1,2" · "F1 yes / F2 no" ·
"merge 1+2" · "move 45f9ae4 to [1]" · "reword 2: ..." · "drop 2" · "include mise.lock"
```

Each bucket shows its commit message exactly as it will be written (subject line; add the body indented below it when there is one) and every path with either "whole file" or its hunk IDs plus a short hint. Findings sit under the bucket they belong to. Leave out sections that are empty.

Unanswered findings count as declined; "go fix" accepts every finding along with every bucket. A prior approval does not carry to a re-planned report: after "merge", "move" or "reword", print the changed buckets again and wait.

**Autocommit.** Only when the user's invoking message explicitly says to commit without asking: still print the report, then commit every bucket that carries no finding. Buckets with findings wait for an answer.

## 6. Commit

The reply to the report approves every bucket it names: commit them in a row without asking again per commit. When the pre-staged bucket [0] is not approved, `git restore --staged` its paths before the first commit.

For each approved bucket, in order, run nbr-git-commit's Commit section with the bucket as the approved paths. Stage hunks with `hunks.py stage`, whole files with `git add` / `git rm`. After each commit, also check that the remaining buckets' IDs still appear in `hunks.py list`; a missing one means a hook pulled it in, so stop and report before the next bucket.

After the last bucket, run the routine from step 2 when the reply approved it ("go" or "go fix" for all, or naming it).

Finish with `git log --oneline -<n>` for the commits just made and `git status --short` for what is left.
