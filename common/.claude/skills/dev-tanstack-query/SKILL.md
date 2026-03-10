---
name: dev:tanstack-query
description: "Nik's TanStack Query patterns -- topic-based keys, query/mutation co-location, server state separation. Load when working with TanStack Query or data fetching in React."
user-invocable: false
---

# TanStack Query Patterns

## Core Principle: Server State != Client State

- **Server State**: Source of truth lies outside the client. The client holds a cache that can go stale. Managed by TanStack Query (an async state manager, not a fetch library).
- **Client State**: Source of truth lies in the client itself. Only the client knows the current value. Managed by Redux Toolkit, Zustand, useState, or similar.
- **URL State** (optional third category): Filters, pagination, active tabs. TanStack Router with type-safe search params.

No default library -- choose per project. The separation principle is what matters.

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

To ensure best practices, always verify patterns against these references before implementation. Use Ref MCP to look up specific topics.

- **TanStack Query Docs**: https://tanstack.com/query/latest/docs/framework/react/
- **TKDodo's Practical React Query** (primary influence): https://tkdodo.eu/blog/practical-react-query

Key articles to consult per topic:
- Render optimization → [Render Optimizations guide](https://tanstack.com/query/latest/docs/framework/react/guides/render-optimizations) + [TKDodo: Render Optimizations](https://tkdodo.eu/blog/react-query-render-optimizations)
- Query keys → [Query Keys guide](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
- Invalidation → [TKDodo: Automatic Query Invalidation](https://tkdodo.eu/blog/automatic-query-invalidation-after-mutations)
- Selectors → [TKDodo: Selectors Supercharged](https://tkdodo.eu/blog/react-query-selectors-supercharged)

## Cross-References

- `dev:tanstack-router` -- URL state via search params, loader integration with `ensureQueryData`
- `dev:tanstack-start` -- server functions as data layer, Query for client-side caching on top

## References

- For query organization examples, see `query-patterns.md`
- For fetch wrapper pattern, see `fetch-wrapper.md`
- For state separation details, see `state-separation.md`
