---
name: Known Bugs and Investigation Notes
description: Open bugs, intermittent issues, and investigation findings for future debugging
type: project
---

## `--initial-view projects` does not load items (confirmed 2026-03-31)

When `New()` sets `mode = ModePickDirectory` via `--initial-view projects`, `scanProjectDirectories()` is never called. The project list starts empty. Items are only loaded when entering via Ctrl+P (session.go) or Ctrl+A (bookmarks.go).

**Status:** Confirmed bug, not yet fixed.

## Intermittent project filter failure (reported 2026-03-31)

User reported typing "ship" in projects view showed zero results despite "shiplog" being in the unfiltered list. Could not reproduce — filtering logic passes all unit and integration tests through the full Bubbletea Update chain. User later said it started working again, suggested caching.

**Investigation done:**

- ScrollList.applyFilter logic is correct
- filterFn uses `filepath.Base()` + `strings.Contains` — works in tests
- Key routing through Update → handleKey → handlePickDirectoryMode is correct
- No race conditions identified (Bubbletea is single-threaded for Update/View)

**Why:** Logged so future sessions don't repeat the same investigation from scratch.

**How to apply:** If this recurs, focus on environmental factors (terminal encoding, tmux version, filesystem state) rather than the filtering logic itself.
