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

| Hook scope                                | Location                                           |
| ----------------------------------------- | -------------------------------------------------- |
| Used by one component/container           | Co-located in its folder                           |
| UI utility or shared event hook           | Top-level `hooks/` directory                       |
| Query wrapper or topic orchestration hook | `queries/` topic folder (see `dev:style:tanstack`) |

## When to Extract a Hook

- When a container has more than ~10 lines of non-rendering logic
- When the same logic appears in multiple places
- When the logic has a clear "topic" name (`useAuth`, `useSettings`)
- NOT for trivial one-liners (`useState` + toggle)

## Named Effects

<!-- Source: https://neciudan.dev/name-your-effects -->

Always use **named function expressions** in `useEffect` instead of anonymous arrows:

```tsx
// Bad -- anonymous, intent unclear without reading body
useEffect(() => {
  const ws = new WebSocket(url);
  ws.onmessage = handleMessage;
  return () => ws.close();
}, [url]);

// Good -- name reveals purpose at a glance
useEffect(
  function connectToWebSocket() {
    const ws = new WebSocket(url);
    ws.onmessage = handleMessage;

    return function disconnectFromWebSocket() {
      ws.close();
    };
  },
  [url],
);
```

### Why

- **Scannable** -- effect names reveal a component's side-effect story without reading implementations
- **Better stack traces** -- named functions show up in error monitoring instead of `(anonymous)`
- **Design smell detector** -- if the name contains "and" or you can't name it cleanly, the effect does too much and should be split
- **Named cleanups** -- setup/teardown symmetry makes intent explicit

### Rules

- Name the effect after **what it does**, not what triggers it
- Name cleanup functions after the **inverse action** (connect/disconnect, subscribe/unsubscribe, start/stop)
- If you struggle to name it, question whether it should be an effect at all (see [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect))
