# useEffect Anti-Patterns

Reference catalog for scanning React codebases. See [the main skill](../SKILL.md) for the audit workflow.

## 1. Derived State

State computed from other state/props, updated via useEffect.

**Detect:** `useEffect` body calls a setter, value is a pure function of state/props already available during render.

**Fix:** Compute inline. `const fullName = firstName + " " + lastName;`

## 2. Expensive Derived Computation

Same as #1 but with expensive transforms (.filter, .map, .sort, .reduce).

**Fix:** Use `useMemo`.

## 3. Reset All State on Prop Change

useEffect resets state when an identity prop (userId, itemId) changes.

**Fix:** Extract into child component and use `key={userId}`.

## 4. Adjust Some State on Prop Change

useEffect partially updates state when props change.

**Fix:** Derive during render instead. `const selection = items.find(i => i.id === selectedId) ?? null;`

## 5. Event Logic in Effect

toast, navigation, analytics in useEffect instead of the event handler.

**Fix:** Move into the event handler.

## 6. POST / Mutation in Effect

Network request in useEffect triggered by a state variable set in an event handler.

**Fix:** Call from the event handler directly.

## 7. Effect Chains

Multiple useEffects where one sets state triggering the next.

**Fix:** Derive what you can, consolidate the rest into event handlers.

## 8. App Initialization in Effect

One-time setup in `useEffect([], [])` that breaks under Strict Mode double-mount.

**Fix:** Guard with module-level `didInit` flag.

## 9. Notify Parent via Effect

Calling parent callback (onChange) inside useEffect after state update.

**Fix:** Call in the event handler alongside the state setter.

## 10. Pass Data to Parent via Effect

Child fetches data, pushes it up through an effect callback.

**Fix:** Lift data fetching to parent, pass data down.

## 11. External Store Subscription

Window/document event listeners or subscribe/unsubscribe in useEffect.

**Fix:** Use `useSyncExternalStore`.

## 12. Initialize State from Props via Effect

useEffect sets state from props on first render.

**Fix:** Pass prop directly to `useState`.

## 13. Fetch Without Cleanup

Data fetching in useEffect without handling stale responses.

**Fix:** Add ignore flag or AbortController. Better: use TanStack Query.

---

## Legitimate useEffect Usages (Do NOT flag)

- Ref-scoped DOM events with proper cleanup (ResizeObserver, IntersectionObserver on a ref)
- Animations/timers scoped to component mount
- Synchronizing with truly external systems (WebSocket, third-party widgets)
- Analytics/logging on component display
- Focus management on mount
