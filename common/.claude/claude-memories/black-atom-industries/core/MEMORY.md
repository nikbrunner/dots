# Black Atom Core - Memory

## Project State (as of 2026-03-19)

- **V1 target**: No fixed date — dates set per sub-project instead
- **Livery** is part of V1 scope (differentiator for the ecosystem)
- **V1 = core themes (fine-tuned via monitor) + livery + adapters + branding**
- Active parallel tracks: livery development + monitor development
- Theme fine-tuning consolidated into [DEV-322](project_v1_restructure.md) (replaces DEV-186 epic + DEV-233-237)
- DEV-241 (naming) and DEV-242 (Default vs Stations) still open blockers

## Linear Projects (active)

- **Black Atom - 1.0** — core themes, adapters, branding, launch items
- **livery** — theme management desktop app (Tauri v2 + React)
- **Black Atom - Monitor** — preview/analysis web app inside core repo
- **helm** — tmux session manager (low priority, post-V1)
- **radar.nvim** — Neovim file navigation plugin (low priority, post-V1)

## Collections (current)

`default`, `stations`, `jpn`, `terra`, `mnml` — defined in `src/types/theme.ts`

## Key Architecture Notes

- Default and Stations have incompatible UI/syntax creator signatures:
  - Default: `(primaries, feedback, accents)` pattern
  - Stations: `(primaries, palette)` pattern
  - MNML: Uses `accents` pattern (similar to Default)
- No shared UI/syntax files between collections — each has its own
- Dark ranges (d10-d40) are very similar between Default and Stations

## Linear Query Pattern

- Don't fetch all issues at once — returns 122K+ chars
- Query by state separately: `state: "In Progress"`, `state: "Todo"`, `state: "Backlog"`

## Workflow Preferences

- **Worktrees**: Nik likes worktrees but prefers them as sibling folders next to the main repo, not nested inside `.claude/worktrees/`. Always ask before creating a worktree.
- **Git**: [Amend failing commits](feedback_amend_failing_commits.md) — don't create fix commits for broken predecessors
- **Releases**: [Highlights go on GitHub Release](feedback_release_highlights.md) — release-please PRs overwrite manual edits

## Monitor App

- [Architecture conventions](project_monitor_architecture.md) — routing, queries, types, core/monitor boundary
- [DEV-312 Handover](project_dev312_handover.md) — contrast analysis, layout redesign, command palette, next steps (DEV-309 syntax preview)

## V1 Restructure (2026-03-19)

- [V1 restructure details](project_v1_restructure.md)
