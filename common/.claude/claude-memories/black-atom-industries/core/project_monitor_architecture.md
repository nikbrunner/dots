---
name: Monitor app architecture conventions
description: Conventions for the Black Atom Monitor React app — routing, queries, types, components, and the boundary between core and monitor
type: project
---

## Monitor Architecture (as of 2026-03-16)

The monitor is a React + Vite app at `monitor/` that previews and analyzes themes.

### Routing

- Uses TanStack Router with **file-based routing** (`monitor/src/routes/`)
- Route components are **defined inline** in route files — no separate container imports
- `__root.tsx` is the app shell layout (nav, sidebar, stats bar) — the only "container" that stays in `containers/`
- Search params defined in `monitor/src/lib/search-params.ts` with Zod schema, defaults derived via `schema.parse({})`
- `retainSearchParams(true)` + `stripSearchParams(defaults)` on root route

### Types

- **Never duplicate core types** — use `ThemeDefinition` from `@core/types/theme.ts` directly
- Don't create parallel/subset types like `ThemeSummary` — if you need the full theme, fetch the full theme
- `ThemeKey` and `DEFAULT_THEME_KEY` are exported from core

### Queries

- Live in `monitor/src/queries/` (not `hooks/`)
- Follow TanStack Query conventions: topic-based keys, `Omit<>` for options passthrough
- Use `apiClient` from `monitor/src/lib/api-client.ts` — centralized fetch wrapper
- `useThemes()` returns `ThemeDefinition[]`, `useTheme(key)` returns single `ThemeDefinition`

### API

- `GET /api/themes` → `ThemeDefinition[]` (all themes, full data)
- `GET /api/themes/:key` → `ThemeDefinition` (single theme)
- No lightweight/summary endpoints — 34 themes is small enough for full data

### Stats & Color Analysis

- Stats functions (`themeContrast`, `collectionStats`, `orgStats`) live in **core** at `src/lib/stats.ts`
- WCAG constants and grading live in **core** at `src/lib/wcag.ts`
- Core uses `culori` for color calculations — monitor doesn't import culori directly
- `themeToCssVars()` in monitor converts a `ThemeDefinition` into CSS custom properties programmatically

### Components

- Layout components use `*Layout` suffix (`AppLayout`, `StatsBarLayout`, `DashboardPageLayout`)
- `ThemePreviewCard` receives full `ThemeDefinition` and creates its own CSS var scope via `themeToCssVars()`
- Transformation utilities (like `groupByCollection`) live in tested lib files, not inline in components

**Why:** Core owns the data and computation. Monitor owns the display. This separation enables the future CLI to reuse core's analytics without depending on React.

**How to apply:** When adding new analytics/stats features, add computation to core. When adding new UI, add to monitor. Don't put computation in monitor or React-specific code in core.
