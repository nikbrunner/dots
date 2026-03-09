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

When a component has multiple associated files, group them in a folder.

Style file naming depends on project convention (see `dev:styling`):

```
# The folder name is the component name, while the file names represent the purpose.
# Using `index.tsx` as the file name, avoid imports like `import Button from '@components/Button/Button';`, and instead use `import Button from '@components/Button';`.
components/
├── Button/
│   ├── index.tsx          # Exports the component
│   ├── styles.module.css  # CSS Modules (Vite, Next.js)
│   └── stories.tsx        # Storybook stories

# Or a flat structure insteaq component folders:
# Of course these could still be nested inside a `components/Button/` folder
components/
├── Button.tsx
├── Button.stories.tsx
├── Button.module.css
```

## Co-Located Sub-Components

Components that inherently belong together live in the same folder:

```
components/
├── data-grid/
│   ├── index.tsx        # Main DataGrid export
│   ├── index.css        # Glue CSS
│   ├── stories.tsx
│   ├── table.tsx
│   ├── table.css
│   ├── table-header.tsx
│   ├── table-header.css
│   ├── table-row.tsx
│   ├── table-row.css
│   ├── table-cell.tsx
│   ├── table-cell.css
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
