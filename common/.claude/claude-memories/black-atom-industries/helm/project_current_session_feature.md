---
name: Feature Request - Show Current Session in List
description: Discussed 2026-03-24 — include current tmux session in helm TUI list so actions work on it
type: project
---

Nik requested including the current session in the TUI list (2026-03-24). Currently `ListSessions()` in `internal/tmux/tmux.go:47` explicitly excludes it.

**Problem:** Can't kill, rename, open lazygit, or open remote for the current session without switching to another session first.

**Agreed approach:** Option A — include current session in the list with a visual indicator (e.g., `*` or different color). Enter on it is a no-op (already there), but all other actions (Ctrl+x, Ctrl+r, Ctrl+g) work normally.

**Why:** helm evolved from a pure session-switcher to a session manager. Excluding the current session made sense for switching but not for the broader action set.

**How to apply:** When implementing, modify `ListSessions` to optionally include current session, mark it in the UI, and make Enter a no-op for it.
