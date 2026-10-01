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

| Category         | Source of Truth  | Tool                         | Examples                                                           |
| ---------------- | ---------------- | ---------------------------- | ------------------------------------------------------------------ |
| **URL State**    | URL              | Router search params         | Filters, pagination, sort; a theme when a link should reproduce it |
| **Server State** | Server/API       | TanStack Query               | User profiles, settings, lists                                     |
| **Scoped State** | Context provider | React Context                | Multi-step wizard state, panel-local state                         |
| **Client State** | Client store     | RTK, Zustand, TanStack Store | Modal queue, toasts, per-user UI preferences (persisted)           |
| **Local State**  | Component        | `useState`                   | Input value, hover, open/closed                                    |

Theme and color mode sit on that line and go either way. The deciding question is whether a link should reproduce the view:
yes puts it in the URL with storage as fallback (`state/url-state-patterns.md`), no keeps it a persisted per-user preference
in the client store.

## Client State Libraries

No default library -- choose per project.

| Library            | Status              | Notes                                                                                    |
| ------------------ | ------------------- | ---------------------------------------------------------------------------------------- |
| **Redux Toolkit**  | Proven, used at DCD | Good for complex state with many reducers. Migration from vanilla Redux straightforward. |
| **Zustand**        | Not tried yet       | Lighter than RTK, minimal boilerplate.                                                   |
| **TanStack Store** | Available           | Preferred in TanStack ecosystem -- signals-based, tiny bundle.                           |

The separation principle matters more than the specific library.

## Sources of Truth

- **TanStack Router** (URL state): https://tanstack.com/router/latest/docs/framework/react/guide/search-params
- **TanStack Query** (server state): https://tanstack.com/query/latest/docs/framework/react/
- **Redux Toolkit**: https://redux-toolkit.js.org/
- **Zustand**: https://zustand.docs.pmnd.rs/
- **TanStack Store**: https://tanstack.com/store/latest
- **nuqs** (useQueryState adapter): https://nuqs.dev/

## Cross-References

- the `tanstack` topic -- server state patterns, query organization
- the `tanstack` topic -- Router search params for URL state, Store for client state
- the `tanstack` topic -- form state management (uses Store internally)
- the `react` topic -- containers orchestrate state, components receive it as props

## References

- For the migration pattern (Redux → separated state), see `state/state-separation.md`
- For URL state hook examples, see `state/url-state-patterns.md`
