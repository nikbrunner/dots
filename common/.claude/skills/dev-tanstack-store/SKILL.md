---
name: dev:tanstack-store
description: "Nik's TanStack Store patterns -- signals-based state, derived stores, effects. Load when @tanstack/store is in dependencies or client state management is needed."
user-invocable: false
---

# TanStack Store Patterns

## Core Principle: Signals for Client State

TanStack Store is a framework-agnostic signals implementation. It powers TanStack internals (Form, Router) and works as a standalone client state manager. Preferred over Zustand/RTK when already in the TanStack ecosystem -- one mental model for everything.

For when to reach for a client state manager at all, see `dev:state-management`.

## Key Primitives

| Primitive | Purpose | Example |
|-|-|-|
| `createStore(value)` | Reactive state container | `createStore(0)` |
| `createStore(fn)` | Derived value from other stores | `createStore(() => count.state * 2)` |
| `store.subscribe(fn)` | Listen for changes | Side effects, logging |
| `batch(fn)` | Group updates, single notification | Multiple `setState` calls |
| `useStore(store, selector)` | React binding | Always pass a selector |

## Key Patterns

### Basic Store

```typescript
import { createStore } from '@tanstack/store'

const countStore = createStore(0)

countStore.setState(() => 1)
console.log(countStore.state) // 1
```

### Derived Stores

Automatically recompute when dependencies change. Can access previous value via `prev` argument.

```typescript
const count = createStore(1)
const doubled = createStore(() => count.state * 2)
const runningSum = createStore<number>((prev) => count.state + (prev ?? 0))
```

### Batching

Subscribers fire once at the end, not per `setState` call.

```typescript
import { batch } from '@tanstack/store'

batch(() => {
  countStore.setState(() => 1)
  countStore.setState(() => 2)
})
// Subscribers called once with final state (2)
```

### React: Always Use a Selector

```tsx
import { useStore } from '@tanstack/react-store'

// Correct -- only re-renders when selected value changes
const count = useStore(countStore, (state) => state)
const name = useStore(userStore, (state) => state.name)

// Wrong -- re-renders on every store change
const store = useStore(userStore)
```

## Anti-Patterns

| Anti-Pattern | Instead |
|-|-|
| `useStore(store)` without selector | Always pass a selector function |
| Store for server state | Use TanStack Query for async/cached data |
| Store for URL state | Use TanStack Router search params |
| Giant single store | Multiple focused stores, derive relationships |

## Sources of Truth

- **TanStack Store Docs**: https://tanstack.com/store/latest/docs/overview
- **Quick Start**: https://tanstack.com/store/latest/docs/quick-start
- **React Adapter**: https://tanstack.com/store/latest/docs/framework/react/reference/functions/useStore

## Cross-References

- `dev:state-management` -- decision flow for when to use a client state manager
- `dev:tanstack-form` -- Form uses Store internally; `useStore(form.store, selector)` for form reactivity
- `dev:tanstack-query` -- server state; Store handles client state only
