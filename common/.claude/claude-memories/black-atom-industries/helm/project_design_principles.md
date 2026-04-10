---
name: Helm Design Principles
description: Separation of concerns between helm and dots, dependency direction rules
type: project
---

- **helm** = general tmux session manager. Must NOT know about dots.
- **dots** can read helm's config (via yq) but not the other way around.
- `project_dirs` in config serves as clone target; if multiple, prompt user.
- Current session is now included in the TUI — pinned at top as `selfSession` with a visual separator. `ListSessions()` still excludes it, but Model fetches it separately via `GetSessionActivity()`. All actions (kill, lazygit, remote) work on it; Enter is a no-op.

**Why:** These constraints were established during DEV-197 (repos config migration) and reinforced across multiple sessions. The helm/dots boundary is a firm architectural decision.

**How to apply:** Never add dots-specific logic to helm. When adding features that cross repos, respect the one-way dependency.
