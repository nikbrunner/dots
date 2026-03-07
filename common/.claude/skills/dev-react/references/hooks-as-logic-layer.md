# Hooks as Logic Layer

## Topic Hooks

Complex logic gets its own hook, named after the topic it encapsulates:

```tsx
// hooks/use-user-profile.ts
function useUserProfile({ userId }: { userId: string }) {
  const userQuery = useUser({ userId });
  const permissionsQuery = usePermissions({ userId });

  const canEdit = permissionsQuery.data?.includes("edit") ?? false;

  return {
    query: userQuery,
    permissions: { canEdit },
  };
}
```

- Named after the domain topic, not the technical operation
- Composes multiple queries/state into a coherent API
- Container calls the hook, hook does the work

## Containers as Orchestrators

```tsx
// Bad -- logic in container
function UserContainer() {
  const userQuery = useUser({ userId });
  const permissionsQuery = usePermissions({ userId });
  const canEdit = permissionsQuery.data?.includes("edit") ?? false;
  // ... more logic
}

// Good -- container delegates to hook
function UserContainer() {
  const { query, permissions } = useUserProfile({ userId });
  // ... just orchestrates rendering
}
```

## Co-Location Rules

| Hook scope | Location |
|-----------|----------|
| Used by one component/container | Co-located in its folder |
| Used by multiple consumers | Top-level `hooks/` directory |
| Specific to a query topic | Co-located in `queries/` topic folder |

## When to Extract a Hook

- When a container has more than ~10 lines of non-rendering logic
- When the same logic appears in multiple places
- When the logic has a clear "topic" name (`useAuth`, `useSettings`)
- NOT for trivial one-liners (`useState` + toggle)
