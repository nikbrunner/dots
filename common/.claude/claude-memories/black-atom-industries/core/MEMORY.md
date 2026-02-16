# Black Atom Core - Memory

## Project State (as of 2026-02-12)

- **V1 target**: March 31, 2026
- **Linear project**: Black Atom - 1.0 (fully triaged and restructured)
- Helm and radar.nvim issues separated to "Core Creator" project
- 5 OPS issues from 2023-2024 canceled as outdated
- CRBN collection no longer exists; MNML is the newest collection

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

## V1 Milestones

1. Core Themes Finalized (Feb 28) — DEV-241 (naming) + DEV-242 (Default vs Stations) block DEV-186 (epic)
2. Adapters Complete (Mar 14) — blocked by themes
3. Branding (Mar 22) — logo + banner
4. Launch Ready (Mar 31) — READMEs, release workflows, license, contributions
