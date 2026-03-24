# Black Atom Core - Memory

## Project State (as of 2026-03-24)

- **Current version**: v0.4.0 (released 2026-03-22)
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

## Collections & Themes

- Collections: `default`, `stations`, `jpn`, `terra`, `mnml` — defined in `src/types/theme.ts`
- **34 themes** total: default(4), stations(4), jpn(4), terra(8), mnml(14)
- All creator functions use unified `ThemeCreatorOptions` interface (primaries, palette, feedback, accents)
- Collections destructure different fields: Default/MNML use `{primaries, feedback, accents}`, Stations uses all four

## Linear Query Pattern

- Don't fetch all issues at once — returns 122K+ chars
- Query by state separately: `state: "In Progress"`, `state: "Todo"`, `state: "Backlog"`

## Workflow Preferences

- **Worktrees**: Nik likes worktrees but prefers them as sibling folders next to the main repo, not nested inside `.claude/worktrees/`. Always ask before creating a worktree.
- **Git**: [Amend failing commits](feedback_amend_failing_commits.md) — don't create fix commits for broken predecessors
- **Releases**: [Highlights go on GitHub Release](feedback_release_highlights.md) — release-please PRs overwrite manual edits

## Monitor App

- [Architecture decisions](project_monitor_architecture.md) — non-obvious design choices (Combobox rejection, CSS var portal strategy, etc.)
- [DEV-312 Handover](project_dev312_handover.md) — resolved items + remaining known issues (light theme hover, mobile responsiveness)
- Day-to-day conventions are in `monitor/CLAUDE.md` (checked into repo)

## V1 Restructure (2026-03-19)

- [V1 restructure details](project_v1_restructure.md)
