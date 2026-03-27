---
name: dev:style:state
description: "State categorization and management patterns -- server state, URL state, client state. Load when discussing state architecture or choosing state tools."
user-invocable: false
---

# State Management

## Core Principle: Separate State by Source of Truth

Not all state is the same. Where the source of truth lives determines the tool.

## Decision Flow

1. **Should this be shareable via URL?** → URL state (TanStack Router search params)
2. **Does it come from an API?** → Server state (TanStack Query)
3. **Is it scoped to a subtree and should reset on leave?** → React Context
4. **Is it shared across unrelated components and persists?** → Client state manager (RTK, Zustand, TanStack Store)
5. **Is it local to one component?** → `useState`

Most projects need far less client state management than they think. URL params often eliminate the need for a dedicated state manager entirely.

## The Categories

| Category         | Source of Truth  | Tool                         | Examples                                              |
| ---------------- | ---------------- | ---------------------------- | ----------------------------------------------------- |
| **URL State**    | URL              | Router search params         | Filters, pagination, sort, color mode, theme settings |
| **Server State** | Server/API       | TanStack Query               | User profiles, settings, lists                        |
| **Scoped State** | Context provider | React Context                | Multi-step wizard state, panel-local state            |
| **Client State** | Client store     | RTK, Zustand, TanStack Store | Modal queue, toast notifications, UI preferences      |
| **Local State**  | Component        | `useState`                   | Input value, hover, open/closed                       |

## Client State Libraries

No default library -- choose per project.

| Library            | Status              | Notes                                                                                    |
| ------------------ | ------------------- | ---------------------------------------------------------------------------------------- |
| **Redux Toolkit**  | Proven, used at DCD | Good for complex state with many reducers. Migration from vanilla Redux straightforward. |
| **Zustand**        | Not tried yet       | Lighter than RTK, minimal boilerplate.                                                   |
| **TanStack Store** | Available           | Preferred in TanStack ecosystem -- signals-based, tiny bundle. See `dev:tanstack-store`. |

The separation principle matters more than the specific library.

## Sources of Truth

- **TanStack Router** (URL state): https://tanstack.com/router/latest/docs/framework/react/guide/search-params
- **TanStack Query** (server state): https://tanstack.com/query/latest/docs/framework/react/
- **Redux Toolkit**: https://redux-toolkit.js.org/
- **Zustand**: https://zustand.docs.pmnd.rs/
- **TanStack Store**: https://tanstack.com/store/latest
- **nuqs** (useQueryState adapter): https://nuqs.dev/

## Cross-References

- `dev:style:tanstack` -- server state patterns, query organization
- `dev:tanstack-router` -- URL state via search params
- `dev:tanstack-store` -- client state with signals, derived stores
- `dev:style:tanstack` -- form state management (uses Store internally)
- `dev:style:react` -- containers orchestrate state, components receive it as props

## References

- For the migration pattern (Redux → separated state), see `state-separation.md`
- For URL state hook examples, see `url-state-patterns.md`
