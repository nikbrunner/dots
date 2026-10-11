# Tooling

The default tool per job in a TypeScript web project. A working choice in an existing repo stays.

| Need                  | Default                                                       |
| --------------------- | ------------------------------------------------------------- |
| Build                 | Vite                                                          |
| Routing and URL state | TanStack Router                                               |
| Server state          | TanStack Query                                                |
| Forms                 | TanStack Form                                                 |
| Data grids            | TanStack Table                                                |
| Client store          | TanStack Store, only after URL, server, and local state       |
| Schema validation     | Zod at the boundary                                           |
| Tests                 | Vitest                                                        |
| Format                | Prettier, with a config file                                  |
| Lint                  | ESLint flat config with type-aware rules                      |
| Types                 | `tsc --noEmit`                                                |
| Dead code             | Knip                                                          |
| Hooks                 | Lefthook (see [git](git.md))                                  |

- Use the library that already owns a problem instead of rebuilding its layer: Form for form rules, Query for caching and
  refetching, Router for URL state, Table for sorting and pagination.
- Each TanStack library with a devtools package gets it, mounted only in development. A new TanStack dependency is checked
  for one.
- Look up tool behavior in its current docs, not from memory: the `tanstack` CLI for TanStack, the official docs otherwise.

## TypeScript and ESLint

- Strict TypeScript with bundler module resolution, `verbatimModuleSyntax`, unused-value checks, and the `#/` path alias.
  Type-only imports use `import type`.
- ESLint bans `as` and non-null `!` outside tests, and requires the `#/` alias over parent-relative imports. An assertion at
  an untyped third-party boundary gets one inline disable with the reason beside it.
