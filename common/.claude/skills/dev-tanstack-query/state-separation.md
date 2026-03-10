# State Separation

## Server State vs Client State

| Aspect | Server State | Client State |
|--------|-------------|-------------|
| **Source of truth** | Server/API | Client itself |
| **Can go stale?** | Yes | No |
| **Shared across users?** | Yes | No |
| **Tool** | TanStack Query | Redux Toolkit, Zustand, useState |
| **Examples** | User profiles, settings, lists | Modal open/closed, form drafts, UI preferences, toasts |

## The Migration Pattern

Before (everything in Redux):
```
Redux Store
├── users (fetched from API)        # server state misplaced
├── settings (fetched from API)     # server state misplaced
├── currentModal                    # actual client state
└── uiPreferences                   # actual client state
```

After (separated):
```
TanStack Query              Redux Toolkit (shrunk)
├── users                   ├── currentModal
├── settings                └── uiPreferences
```

Redux shrinks dramatically and contains only genuine client state.

## URL State (Third Category)

Filters, pagination, sort order, active tabs -- state that belongs in the URL for shareability and browser navigation.

TanStack Router makes this type-safe with search params. See `dev:tanstack-router` search-params for patterns.

## No Default Library

- **Client state**: Redux Toolkit (proven), Zustand (lighter), TanStack Store (alpha)
- Choose per project based on complexity and team familiarity
- The separation principle matters more than the specific library
