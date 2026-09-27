---
name: nbr-git-clean
description: Sort a dirty working tree into atomic commits, split by hunk where needed, with boy-scout findings on the touched code and an approval gate before anything is committed. Use when the user wants to clean up git status, commit scattered changes, or tidy the working tree into commits.
argument-hint: "[optional scope, or 'commit without asking']"
---

# nbr-git-clean

Turn a messy working tree into a clean run of atomic commits. You survey every change, read around it, sort it into **buckets** (one logical change each, down to single hunks), attach **boy-scout findings**, and present the lot as one report. Nothing is committed until the user approves.

Hunk-level staging goes through `scripts/hunks.py` in this skill's directory. It lists unstaged hunks of tracked files with stable IDs and stages any selection of them, all or nothing:

```sh
python3 <skill-dir>/scripts/hunks.py list [PATH...]
python3 <skill-dir>/scripts/hunks.py show ID...
python3 <skill-dir>/scripts/hunks.py stage ID...
```

Hunks come from a zero-context diff, so every separated change is its own hunk. An ID hashes the path and the changed lines, so it survives commits of other hunks; only a suffixed duplicate (`abc1234-2`) can shift. Untracked, binary and mode-only files have no hunks: stage those with `git add` / `git rm`.

## 1. Survey

```sh
git status --short
git diff --stat
git diff --cached --stat
git log --oneline -30
python3 <skill-dir>/scripts/hunks.py list
```

Anything already staged is invisible to `hunks.py` and would ride along with the first commit. Give it its own bucket in the report, marked as pre-staged.

Done when every changed path and every hunk ID is accounted for.

## 2. Conventions

Commit message grammar follows the lookup order in Phase 3 of `dev-commit/SKILL.md` (a sibling of this skill's directory): a project commit skill, then AGENTS.md / CLAUDE.md, then the dominant pattern in `git log`, then its default. Read that phase as a file rather than loading the skill; its other phases carry their own approval and audit steps that this workflow replaces. The lookup covers ticket or issue prefixes, their placement, and body style. Pull the ticket key from the branch name when the convention uses one.

While reading the project instructions, also look for a routine that commits on its own (a chores command). Such routines stage whole files, so run one only after the approved buckets are committed: by then the real edits in its files are gone, and it picks up only the routine churn left behind. Mark the files it will cover as held back with the routine's name, and put the routine on the report's last line.

## 3. Analyze

Read every hunk and every untracked file in full. Then read around each change: callers of a changed function, consumers of a changed config key, docs that describe the changed behaviour, references to a renamed or deleted file. You are looking for two things:

- **Side effects**: a change that breaks or silently changes something elsewhere. A deleted module still imported, a renamed key still read under its old name. Mark these ⚠.
- **Boy-scout findings**: small improvements in the code the change touches or sits right next to. An orphaned import the change created, a stale comment or doc line, a leftover debug print, a typo in a touched line. Mark these ⚑. Stay inside the blast radius of the diff: this is leaving the campsite cleaner, not auditing the codebase.

Each finding gets a location, a one-line problem, a concrete fix, and a proposed home: folded into bucket N, or a commit of its own.

Done when every hunk has been read in context and every finding has a proposed fix.

## 4. Bucket

- One bucket, one reason to exist. A config tweak, a feature and a refactor are three buckets even inside one file.
- Split a file across buckets by hunk whenever its hunks serve different changes.
- When one hunk mixes two changes (they touch adjacent lines, so the diff joins them), put it in the bucket it mostly serves and say so in the report. Offer to split it by editing it apart only if the user asks.
- Order buckets so each commit stands on its own: a dependency before its dependent.
- **Held back**: generated or machine-local churn with no matching source change, unfinished work, anything resembling a secret, anything you can't place with confidence. Held back stays unstaged unless the user opts it in.

## 5. Report and stop

Print the report in exactly this shape, then stop and wait:

```
Working tree: 14 files, 23 hunks → 4 buckets, 2 held back, 2 findings
Convention: dev-commit default ([#issue] prefix, imperative, no type:)

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

[2] add lazyjira copy keymap
    M  lazyjira/config.yml          be54c48, 70f4967
    M  nvim/ftplugin/markdown.lua   45f9ae4   ← other hunks than [1]

Held back
    M  mise/mise.lock       lockfile churn, no matching config change
    M  zoxide/seed.txt      machine-local state (dots chores)

Afterwards: `dots chores` commits the held-back routine files (from AGENTS.md)

Reply: "go" (all) · "go 1,2" · "F1 yes / F2 no" · "merge 1+2" ·
"move 45f9ae4 to [1]" · "reword 2: ..." · "drop 2" · "include mise.lock"
```

Each bucket shows its commit message exactly as it will be written (subject line; add the body indented below it when there is one) and every path with either "whole file" or its hunk IDs plus a short hint. Findings sit under the bucket they belong to. Leave out sections that are empty.

Unanswered findings count as declined. A prior approval does not carry to a re-planned report: after "merge", "move" or "reword", print the changed buckets again and wait.

**Autocommit.** Only when the user's invoking message explicitly says to commit without asking: still print the report, then commit every bucket that carries no finding. Buckets with findings wait for an answer.

## 6. Commit

The reply to the report approves every bucket it names: commit them in a row without asking again per commit. When the pre-staged bucket [0] is not approved, `git restore --staged` its paths before the first commit.

For each approved bucket, in order:

1. Apply the accepted findings for this bucket, then re-run `hunks.py list`. An edit next to an existing hunk merges into it and changes its ID, so map the bucket to the fresh IDs before staging.
2. Stage: `hunks.py stage` for hunks, `git add` / `git rm` for whole files.
3. Check `git diff --cached --stat` against the bucket. It must match exactly.
4. Commit with a heredoc so the message keeps its formatting:
   ```sh
   git commit -m "$(cat <<'EOF'
   [#42] switch file explorer from mini.files to oil
   EOF
   )"
   ```
5. Check `git show --stat HEAD` against the bucket, and that the remaining buckets' IDs still appear in `hunks.py list`. A hook that formats and re-adds whole files can pull other buckets' hunks into this commit.

Hooks run as configured. When one fails, fix the cause, re-stage, and commit again as a new commit; the failed commit never happened, so there is nothing to amend. When a hook changed files, or a check in step 3 or 5 doesn't match, stop and report what happened before the next bucket.

After the last bucket, run the routine from step 2 when the reply approved it ("go" for all, or naming it).

Finish with `git log --oneline -<n>` for the commits just made and `git status --short` for what is left.
