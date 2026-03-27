---
name: session-handover-2026-03-24
description: Current project status after v0.2.0 release — all base updaters shipped, architecture consolidated, next milestone is frontend/UI
type: project
---

## v0.2.0 Released (2026-03-24)

All "Base Updaters" milestone (v0.3.0 in Linear, released as v0.2.0) work is complete.

### Shipped since 2026-03-21

| PR  | What                                                       | Issue   |
| --- | ---------------------------------------------------------- | ------- |
| #19 | Split AGENTS.md into scoped fe/be structure                | DEV-324 |
| #20 | yaml-edit fork, removed ~120 lines workaround              | DEV-325 |
| #21 | Consolidated updaters into single `update_app` command     | DEV-327 |
| #22 | macOS/Linux system appearance toggle                       | DEV-291 |
| #23 | tauri-specta for type-safe invoke calls                    | DEV-329 |
| #24 | Zed updater with JSONC format-preserving editing           | DEV-289 |
| #25 | Obsidian updater                                           | DEV-330 |
| #26 | Consistent logging + duration tracking + benchmark         |         |
| #27 | Canonicalize yaml path validation + enabledApps filter fix |         |

### Next milestone: Frontend & UI (v0.4.0 in Linear)

Open items (as of 2026-03-24):

- DEV-318 — frontend architecture
- DEV-319 — progress indicator redesign
- DEV-299 — settings page UI design
- DEV-326 — setup wizard
- DES-25/DES-26 — logo and banner (design spec written to docs/)
- Global shortcut (Meh-T) — not yet an issue

### Tooling

- OpenSpec initialized 2026-03-24 — `openspec/` dir exists, `specs/` empty by design (populates via propose/archive cycle)
- **OpenSpec adoption decision (2026-03-24):** keep Nik's existing workflow skeleton (dev-start, dev-grill-me, review gates, Linear integration), replace PRD/plan artifact format with OpenSpec artifacts (proposal.md, design.md, tasks.md). Specs/ accumulation solves the stale-docs problem. Handover written to dots repo for another Claude instance to implement the skill modifications.
- nikbrunner/yaml-edit fork at `fix/sequence-indentation` branch — livery depends on this via git dep in Cargo.toml
- `UBIQUITOUS_LANGUAGE.md` created 2026-03-26 — formal domain glossary for the livery project
