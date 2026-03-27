# Audit: Docs

**What this audits:** Staleness of documentation, skills, hooks, and knowledge artifacts relative to recent code changes.

## How

- **`doc-reviewer`** agent — scans for gaps, outdated content, quality issues (read-only, no edits)
- **`doc-implementer`** agent — applies fixes after review is confirmed
- **git log + diff** — detects what changed recently to compare against docs
- **PR knowledge sync** workflow — checks CLAUDE.md, skills, hooks, README against a specific PR diff

## Steps

1. Determine scope: if `$ARGUMENTS` names a PR number or branch, use that as the diff source. Otherwise, use recent commits (`git log --oneline -10` + `git diff HEAD~10`).
2. Categorize code changes: structural (new/moved/deleted files), behavioral (new commands, changed APIs), configuration (env vars, build), patterns (new conventions).
3. Scan each knowledge artifact against the diff:

   | Artifact          | Location                             | Check for                                   |
   | ----------------- | ------------------------------------ | ------------------------------------------- |
   | Project CLAUDE.md | `./CLAUDE.md` or `.claude/CLAUDE.md` | Commands, structure, architecture, env vars |
   | Skills            | `.claude/skills/`                    | Conventions, patterns, references, examples |
   | Hooks             | `.claude/hooks/`                     | Enforcement rules matching changed patterns |
   | README / docs     | `*.md` in project root               | Setup instructions, API docs, usage guides  |

4. For each artifact, flag: **stale** (invalidated by changes), **gap** (new thing not documented), **drift** (pattern described differently than implemented).
5. Present findings as a table. Wait for user confirmation before editing.
6. If confirmed, dispatch `doc-implementer` agent for minimal, style-matching edits.

## Output

Findings table:

| File                   | Issue                      | Action                  |
| ---------------------- | -------------------------- | ----------------------- |
| `CLAUDE.md:L42`        | New command not documented | Add to Commands section |
| `skills/dev-react/...` | Pattern changed in PR      | Update section          |

After confirmation: edits applied + single commit (`docs: sync project knowledge`).

## Rules

- Project-scoped only — never touch global/user-level config
- Minimal edits — update what's stale, don't rewrite what's fine
- No speculation — only document what actually changed
