# Folder Structure

## Default: Technical Separation

```
src/
├── components/          # Dumb Components
├── containers/          # Smart Containers
├── partials/            # Compositions
├── hooks/               # Shared logic hooks
├── lib/                 # Utilities, helpers
└── types/               # Shared type definitions
```

## Multi-File Components

When a component has multiple associated files, group them in a folder:

```
components/
├── button/
│   ├── index.tsx        # Exports the component
│   ├── style.css        # Component styles
│   └── stories.tsx      # Storybook stories
```

## Co-Located Sub-Components

Components that inherently belong together live in the same folder:

```
components/
├── data-grid/
│   ├── index.tsx        # Main DataGrid export
│   ├── style.css
│   ├── stories.tsx
│   ├── table.tsx
│   ├── table-header.tsx
│   ├── table-row.tsx
│   ├── table-cell.tsx
│   └── use-data-grid.ts # Component-specific hook
```

## Co-Located Hooks

Hooks specific to a single component or container live next to it:

```
containers/
├── user-profile/
│   ├── index.tsx
│   └── use-user-profile.ts   # Only used by this container
```

Shared hooks that serve multiple consumers go in the top-level `hooks/` directory.

## Naming Conventions

- **No dogma** -- evaluate per project (PascalCase vs kebab-case for directories)
- ShadCN uses lowercase, that's fine
- Be consistent within a project
- The folder name IS the component name
