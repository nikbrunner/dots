---
name: dev-style-tanstack
description: "TanStack ecosystem patterns -- CLI tools, Query, Form, doc verification, and my personal conventions. Load when any @tanstack/* package is in dependencies."
user-invocable: true
metadata:
  user-invocable: true
---

# TanStack Ecosystem

Entry point for working with TanStack libraries. This skill introduces the CLI for doc lookup and contains my personal patterns and preferences for Query and Form.

## TanStack CLI

The `tanstack` CLI is installed globally and is the **primary way to verify TanStack docs** -- prefer it over Ref MCP for TanStack-specific lookups.

### Key Commands

| Command       | Purpose                     | Example                                                         |
| ------------- | --------------------------- | --------------------------------------------------------------- |
| `search-docs` | Search docs by keyword      | `tanstack search-docs "search params" --library router --json`  |
| `doc`         | Read a specific doc page    | `tanstack doc router framework/react/guide/data-loading --json` |
| `libraries`   | List all TanStack libraries | `tanstack libraries --json`                                     |
| `ecosystem`   | Discover ecosystem tools    | `tanstack ecosystem --category auth --json`                     |

### Usage Notes

- Always use `--json` for deterministic parsing
- Use `--library <id>` to scope searches (e.g., `query`, `router`, `form`, `store`, `start`, `table`)
- Use `--framework react` when relevant
- `doc` takes a library ID and a path (e.g., `tanstack doc query framework/react/guides/query-keys`)

## Sub-Documents

This skill consolidates patterns for multiple TanStack libraries:

### Query

- For query organization examples, see `query-patterns.md`
- For fetch wrapper pattern, see `query-fetch-wrapper.md`

### Form

- For TanStack Form patterns and API, see `form-patterns.md`
- For SSR integration examples, see `form-ssr-patterns.md`

## Query: Core Principles

TanStack Query is an async state manager, not a fetch library. It manages state whose source of truth lies outside the client -- data that can go stale, needs caching, and is shared across users.

For the full state categorization (server / URL / client), see `dev:style:state`.

### Query Organization

Three complexity levels depending on API surface size. See `query-patterns.md` for detailed examples.

1. **One file per endpoint** -- smallest projects, queries + mutations co-located
2. **One folder per topic** -- medium projects, separate files per query/mutation
3. **API folder** -- large projects or GraphQL, additional separation for query definitions

### Key Patterns

- Topic-based query keys for automatic invalidation
- Query options passed through with `Omit<>` for type safety
- Never spread the query object -- return `{ query, derivedValue }` to avoid unnecessary re-renders
- Single source of truth fetch wrapper for auth, base URL, error handling

## Form: Core Principles

TanStack Form manages form state with full TypeScript inference -- field names, values, and validation errors are all type-safe. It's headless (no UI opinions), uses render props for fields, and integrates with Standard Schema validators (Zod, Valibot, ArkType).

See `form-patterns.md` for detailed patterns and API reference.

## Workflow

1. Identify which TanStack library is relevant to the task
2. Check sub-documents for my preferences on Query or Form
3. Use `tanstack search-docs` / `tanstack doc` to verify patterns against current docs before implementing
4. For libraries without a dedicated sub-document (Router, Store, Start, Table, Virtual, etc.), rely on CLI docs alone

## Sources of Truth

- **TanStack Query Docs**: https://tanstack.com/query/latest/docs/framework/react/
- **TKDodo's Practical React Query** (primary influence): https://tkdodo.eu/blog/practical-react-query
- **TanStack Form Docs**: https://tanstack.com/form/latest/docs/overview
- **TanStack Router Docs**: https://tanstack.com/router/latest/docs/framework/react/overview

Key Query articles to consult per topic:

- Render optimization → [Render Optimizations guide](https://tanstack.com/query/latest/docs/framework/react/guides/render-optimizations) + [TKDodo: Render Optimizations](https://tkdodo.eu/blog/react-query-render-optimizations)
- Query keys → [Query Keys guide](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
- Invalidation → [TKDodo: Automatic Query Invalidation](https://tkdodo.eu/blog/automatic-query-invalidation-after-mutations)
- Selectors → [TKDodo: Selectors Supercharged](https://tkdodo.eu/blog/react-query-selectors-supercharged)

## Cross-References

- `dev:style:state` -- state categorization, separation principle, decision flow
- `dev:style:react` -- containers orchestrate state, components receive it as props
- `dev:style:typescript` -- type-safe patterns align with Form's inference
