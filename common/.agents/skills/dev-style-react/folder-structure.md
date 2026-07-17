# Folder Structure

## Default: Technical Separation

```
src/
├── components/          # Dumb Components
├── containers/          # Smart Containers
├── partials/            # Compositions
├── hooks/               # UI utilities, shared event hooks (no server state)
├── api/                 # TanStack Query hooks + queryOptions/mutationOptions factories → see dev:style:tanstack
├── lib/                 # Utilities, helpers
└── types/               # Shared type definitions
```

### hooks/ vs api/

- `hooks/` — UI utilities and shared event hooks: `useDebounce`, `useMediaQuery`, `useClickOutside`, `useKeyboardShortcut`. No server state, no TanStack Query.
- `api/` — All TanStack Query hooks, including orchestration hooks that compose multiple queries (e.g. `useUserProfile`), plus the `queryOptions`/`mutationOptions` factories a route loader prefetches with. Organized by topic, one file per entity within a topic. See `dev:style:tanstack` for structure. Not nested under a `features/` domain folder — kept at the technical-separation root alongside `components/`, `hooks/`, etc.

## Multi-File Components

When a component has multiple associated files, group them in a folder.

### Preferred: Named files + re-export index

Each file in the folder is named after the component (or sub-component) with a semantic suffix. A thin `index.ts` re-exports the public API so imports stay clean. This avoids "editor tab hell" (6 tabs all reading `index.tsx`) while keeping short import paths.

```
components/
├── button/
│   ├── Button.tsx             # Component implementation
│   ├── Button.module.css      # Styles (see dev:style:css)
│   ├── Button.stories.tsx     # Storybook stories
│   └── index.ts               # Re-export only: export { default } from './Button'
```

Why this over `index.tsx` as the component file:

- Every open file has a **meaningful name** in editor tabs and file search
- `index.ts` is a one-liner you never open — it exists only for clean imports
- Semantic suffixes (`.module.css`, `.stories.tsx`, `.helpers.ts`, `.types.ts`) make purpose obvious at a glance

### Alternative: Flat files (small projects)

For simple projects or single-file components, folders are optional:

```
components/
├── Button.tsx
├── Button.module.css
├── Button.stories.tsx
```

## Co-Located Sub-Components

Components that inherently belong together live in the same folder. Sub-components use their own name, not the parent's:

```
components/
├── data-grid/
│   ├── DataGrid.tsx           # Main component
│   ├── DataGrid.module.css
│   ├── DataGrid.stories.tsx
│   ├── TableHeader.tsx        # Sub-component
│   ├── TableHeader.module.css
│   ├── TableRow.tsx
│   ├── TableRow.module.css
│   ├── TableCell.tsx
│   ├── TableCell.module.css
│   ├── use-data-grid.ts       # Component-specific hook
│   └── index.ts               # Re-exports DataGrid (sub-components stay internal)
```

## Co-Located Hooks

Hooks specific to a single component live next to it in that component's folder:

```
components/
├── data-grid/
│   ├── DataGrid.tsx
│   ├── use-data-grid.ts       # Only used by DataGrid
│   └── index.ts
```

Shared hooks that serve multiple consumers go in the top-level `hooks/` directory:

```
hooks/
├── use-debounce.ts
├── use-media-query.ts
```

Note: Don't colocate hooks in route directories — file-based routers (TanStack Router, Next.js, Remix) will interpret non-route files as routes.

## Naming Conventions

- **No dogma** -- evaluate per project (PascalCase vs kebab-case for directories)
- ShadCN uses lowercase, that's fine
- Be consistent within a project
- The folder name IS the component name
