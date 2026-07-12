---
name: known-bugs-and-investigation-notes
description: "Open bugs, intermittent issues, and investigation findings for future debugging"
metadata:
  node_type: memory
  type: project
  originSessionId: 3c805cd6-fccf-407c-aa8e-abaf23699f5e
---

## `--initial-view projects` does not load items — FIXED 2026-07-03

Root cause: `New()` set `mode = ModePickDirectory` but never called `scanProjectDirectories()`.
Fixed as part of the async-scan rework: `New()` now sets `projectsLoading = true` and
`Init()` dispatches `scanProjectsCmd()`; results arrive via `projectsLoadedMsg`.
Verified visually via `scripts/test-visual.sh projects` (list populates).

## Intermittent project filter failure (reported 2026-03-31)

User reported typing "ship" in projects view showed zero results despite "shiplog" being in the unfiltered list. Could not reproduce — filtering logic passes all unit and integration tests through the full Bubbletea Update chain. User later said it started working again, suggested caching.

**Investigation done:**

- ScrollList.applyFilter logic is correct
- filterFn uses `filepath.Base()` + `strings.Contains` — works in tests
- Key routing through Update → handleKey → handlePickDirectoryMode is correct
- No race conditions identified (Bubbletea is single-threaded for Update/View)

**Why:** Logged so future sessions don't repeat the same investigation from scratch.

**How to apply:** If this recurs, focus on environmental factors (terminal encoding, tmux version, filesystem state) rather than the filtering logic itself. Note: since 2026-07-03 the project scan is async — if the list seems empty right after opening, it may simply still be scanning ("Scanning projects..." empty state).
