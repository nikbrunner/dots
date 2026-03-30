# Black Atom Core - Memory

## Project State (as of 2026-03-28)

- **Current version**: v0.4.0 (released 2026-03-22)
- **V1 target**: No fixed date — dates set per sub-project instead
- **Livery** is part of V1 scope (differentiator for the ecosystem)
- **V1 = core themes (fine-tuned via monitor) + livery + adapters + branding**
- Active parallel tracks: livery development + monitor development
- Theme fine-tuning consolidated into core#53 (replaces DEV-186 epic + DEV-233-237)
- core#50 (naming) and core#51 (Default vs Stations) still open blockers

## Issue Tracking (migrated to GitHub 2026-03-28)

- **Org Project**: [Black Atom V1](https://github.com/orgs/black-atom-industries/projects/7) — cross-repo board
- **Cross-cutting issues**: in `black-atom-industries/.github` repo
- **Repo-specific issues**: in each repo (core, livery, helm, etc.)
- **Milestones**: livery v1.0.0, helm v1.0.0, radar.nvim v1.0.0, core/Monitor, ui v1.0.0
- **Issue Types** (org-level): Bug, Feature, Design, Enhancement, Refactor, Documentation, Infrastructure, Task
- **Status workflow**: Todo → In Progress → In Review → Done
- Linear workspace preserved as archive — do not create new issues there
- Migration mapping: `/Users/nbr/repos/black-atom-industries/core/migration-mapping.md`

## Collections & Themes

- Collections: `default`, `stations`, `jpn`, `terra`, `mnml` — defined in `src/types/theme.ts`
- **34 themes** total: default(4), stations(4), jpn(4), terra(8), mnml(14)
- All creator functions use unified `ThemeCreatorOptions` interface (primaries, palette, feedback, accents)
- Collections destructure different fields: Default/MNML use `{primaries, feedback, accents}`, Stations uses all four

## GitHub Issues Query Pattern

- Use `gh issue list --repo black-atom-industries/<repo>` for repo-specific issues
- Use `gh project item-list <number> --owner black-atom-industries` for org project view
- Filter by state: `--state open`, `--state closed`

## Workflow Preferences

- **Worktrees**: Nik likes worktrees but prefers them as sibling folders next to the main repo, not nested inside `.claude/worktrees/`. Always ask before creating a worktree.
- **Git**: [Amend failing commits](feedback_amend_failing_commits.md) — don't create fix commits for broken predecessors
- **Releases**: [Highlights go on GitHub Release](feedback_release_highlights.md) — release-please PRs overwrite manual edits

## Monitor App

- [Architecture decisions](project_monitor_architecture.md) — non-obvious design choices (Combobox rejection, CSS var portal strategy, etc.)
- [Monitor handover](project_dev312_handover.md) — resolved items + remaining known issues (light theme hover, mobile responsiveness)
- Day-to-day conventions are in `monitor/CLAUDE.md` (checked into repo)

## V1 Restructure (2026-03-19)

- [V1 restructure details](project_v1_restructure.md)
