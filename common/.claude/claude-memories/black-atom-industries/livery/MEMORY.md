# Livery Project Memory

## Project Status

- [warm-precision-epic-status.md](warm-precision-epic-status.md) — Epic #49 CLOSED + MERGED to main (1f8ac18, 07-05); dev-local.sh swap replaced by deno `links`, hooks installed, `deno check src/` (never shell globs), MSRV 1.82; backlog: 8 issues; settings-iteration issue still wanted (scope TBD)
- [design-brainstorm-2026-03-21.md](design-brainstorm-2026-03-21.md) — (historical) early UI rework phase, superseded by the Warm Precision epic
- [session-2026-03-19-20-handover.md](session-2026-03-19-20-handover.md) — (historical) status as of 2026-04-08

## Architecture

- [theme-provisioning-taxonomy.md](theme-provisioning-taxonomy.md) — 3-class provisioning model (External/Linked/Merged), why not 5; #34 MERGED 07-18; follow-ups #66 settings iteration, #65 GUI e2e, #35 wizard
- [architecture-decisions.md](architecture-decisions.md) — TS/Rust boundary, consolidated updaters, file_ops, tauri-specta, keymappings
- [tauri-learnings.md](tauri-learnings.md) — FS scoping gotchas, webview limitations, debugging tips
- [nvim-updater-research.md](nvim-updater-research.md) — Socket-based live reload, platform-specific paths

## UI Design

- [frontend-component-library-eval.md](frontend-component-library-eval.md) — Library deferred, Storybook abandoned for /dev route, visual dev via TanStack Router

## Feedback

- [feedback-naming-precision.md](feedback-naming-precision.md) — Nik cares about domain-accurate naming
- [feedback-css-modules.md](feedback-css-modules.md) — CSS Modules + CVA over Tailwind, migration actively underway
- [feedback-personal-config.md](feedback-personal-config.md) — Update Nik's dots config after adding new apps/fields
- [feedback-stitch-abandoned.md](feedback-stitch-abandoned.md) — Stitch/Google abandoned, no Google tool dependencies
- [feedback-wait-for-explicit-action.md](feedback-wait-for-explicit-action.md) — Don't act on follow-up questions; wait for explicit action requests
- [feedback-cheap-subagent-models.md](feedback-cheap-subagent-models.md) — Use haiku/sonnet for subagents; Fable-priced agents burn the session limit

## Git Workflow

Commit conventions are in the project-level `commit` skill (`.claude/skills/commit/SKILL.md`).
