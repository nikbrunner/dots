---
name: dev:tanstack-query
description: "Nik's TanStack Query patterns -- topic-based keys, query/mutation co-location, server state separation. Loaded via dev:tanstack when Query is relevant."
user-invocable: false
---

# TanStack Query Patterns

## Core Principle: TanStack Query Manages Server State

TanStack Query is an async state manager, not a fetch library. It manages state whose source of truth lies outside the client -- data that can go stale, needs caching, and is shared across users.

For the full state categorization (server / URL / client), see `dev:state-management`.

## Query Organization

Three complexity levels depending on API surface size. See `query-patterns.md` for detailed examples.

1. **One file per endpoint** -- smallest projects, queries + mutations co-located
2. **One folder per topic** -- medium projects, separate files per query/mutation
3. **API folder** -- large projects or GraphQL, additional separation for query definitions

## Key Patterns

- Topic-based query keys for automatic invalidation
- Query options passed through with `Omit<>` for type safety
- Never spread the query object -- return `{ query, derivedValue }` to avoid unnecessary re-renders
- Single source of truth fetch wrapper for auth, base URL, error handling

## Sources of Truth

- **TanStack Query Docs**: https://tanstack.com/query/latest/docs/framework/react/
- **TKDodo's Practical React Query** (primary influence): https://tkdodo.eu/blog/practical-react-query

Key articles to consult per topic:
- Render optimization → [Render Optimizations guide](https://tanstack.com/query/latest/docs/framework/react/guides/render-optimizations) + [TKDodo: Render Optimizations](https://tkdodo.eu/blog/react-query-render-optimizations)
- Query keys → [Query Keys guide](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
- Invalidation → [TKDodo: Automatic Query Invalidation](https://tkdodo.eu/blog/automatic-query-invalidation-after-mutations)
- Selectors → [TKDodo: Selectors Supercharged](https://tkdodo.eu/blog/react-query-selectors-supercharged)

## Cross-References

- `dev:tanstack` -- CLI for doc lookup, ecosystem entry point
- `dev:state-management` -- state categorization, separation principle, decision flow
- `dev:tanstack-form` -- form state; can coexist with Query for form submissions

## References

- For query organization examples, see `query-patterns.md`
- For fetch wrapper pattern, see `fetch-wrapper.md`
