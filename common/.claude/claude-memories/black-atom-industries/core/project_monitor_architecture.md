---
name: Monitor architecture decisions
description: Non-obvious design decisions for the Monitor app — things not captured in monitor/CLAUDE.md or derivable from code
type: project
---

## Design Decisions (not in code)

- **Combobox rejection**: TanStack/Base UI Combobox was tried for theme selector but abandoned — filtering with grouped items was problematic. Custom implementation with Base UI Dialog works better.
- **CSS vars to `:root`**: Needed so portals (Dialog rendered outside React tree) can access theme colors. This is why `useEffect` syncs vars to `document.documentElement` instead of just scoping to `AppLayout`.
- **No containers/ pattern**: Routes are the orchestrators. `__root.tsx` is the app shell. Components are dumb (CSS Modules), partials compose (no styling).
- **Full `ThemeDefinition` everywhere**: No lightweight/summary endpoints or subset types. 34 themes is small enough to always fetch full data.

## Dependencies Added (DEV-312)

- `@base-ui/react` — NavigationMenu, Dialog
- `@tanstack/react-form` + `@tanstack/react-store` — form state in command palette
- `@tanstack/react-hotkeys` — `⌘K` shortcut

**Why:** `monitor/CLAUDE.md` covers day-to-day conventions. This file preserves the _why_ behind non-obvious choices so future sessions don't re-explore dead ends.

**How to apply:** Before proposing alternatives to the command palette, theme selector, or CSS var strategy, check these decisions first. The naive approaches were already tried.
