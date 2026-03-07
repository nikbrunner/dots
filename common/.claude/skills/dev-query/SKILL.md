---
name: dev:query
description: "Nik's TanStack Query patterns -- topic-based keys, query/mutation co-location, server state separation. Load when working with TanStack Query or data fetching in React."
user-invocable: false
---

# Data Fetching & State Separation

## Core Principle: Server State != Client State

- **Server State**: Source of truth lies outside the client. The client holds a cache that can go stale. Managed by TanStack Query (an async state manager, not a fetch library).
- **Client State**: Source of truth lies in the client itself. Only the client knows the current value. Managed by Redux Toolkit, Zustand, useState, or similar.
- **URL State** (optional third category): Filters, pagination, active tabs. TanStack Router with type-safe search params.

No default library -- choose per project. The separation principle is what matters.

## Query Organization

Three complexity levels depending on API surface size. See `references/query-patterns.md` for detailed examples.

1. **One file per endpoint** -- smallest projects, queries + mutations co-located
2. **One folder per topic** -- medium projects, separate files per query/mutation
3. **API folder** -- large projects or GraphQL, additional separation for query definitions

## Key Patterns

- Topic-based query keys for automatic invalidation
- Query options passed through with `Omit<>` for type safety
- Never spread the query object -- return `{ query, derivedValue }` to avoid unnecessary re-renders
- Single source of truth fetch wrapper for auth, base URL, error handling

## Primary Influence

TKDodo's Practical React Query blog: https://tkdodo.eu/blog/practical-react-query

## References

- For query organization examples, see `references/query-patterns.md`
- For fetch wrapper pattern, see `references/fetch-wrapper.md`
- For state separation details, see `references/state-separation.md`
