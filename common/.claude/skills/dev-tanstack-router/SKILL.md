---
name: dev:tanstack-router
description: "TanStack Router patterns -- file-based routing, type-safe search params, data loading. Load when @tanstack/react-router is in dependencies."
user-invocable: false
---

# TanStack Router

## Core Principle: URL Is Application State

TanStack Router treats routing as state management. URLs represent application state, not just navigation targets. The router provides 100% inferred TypeScript via module declaration + auto-generated `routeTree.gen.ts` -- no manual type declarations needed.

**Version:** Stable v1 (v1.166.x as of March 2026). Check installed version.

## Key Concepts

- **File-based routing** with `__root.tsx`, `$param` dynamic segments, `_layout` pathless layouts, `(group)` route groups
- **Two-stage data loading**: `beforeLoad` (sequential, context-building) → `loader` (parallel, SWR-cached)
- **Type-safe search params** via `validateSearch` with Zod -- replaces `useState` for URL-worthy state
- **Route-scoped hooks**: `Route.useParams()`, `Route.useSearch()`, `Route.useLoaderData()`, `Route.useRouteContext()`
- **Auto code splitting**: `autoCodeSplitting: true` in bundler plugin config

## Integration with TanStack Query

Loaders bridge to Query via shared `queryOptions` objects:

```tsx
// Shared query options (used in both loader and component)
const postQueryOptions = (postId: string) => queryOptions({
  queryKey: ['posts', postId],
  queryFn: () => fetchPost(postId),
})

// Loader preloads during navigation
export const Route = createFileRoute('/posts/$postId')({
  loader: ({ params, context }) =>
    context.queryClient.ensureQueryData(postQueryOptions(params.postId)),
  component: PostDetail,
})

// Component reads from cache
function PostDetail() {
  const { postId } = Route.useParams()
  const { data } = useSuspenseQuery(postQueryOptions(postId))
}
```

Search params fill the URL state category from `dev:tanstack-query` state-separation.

## Sources of Truth

Always verify patterns against these references before implementation. Use Ref MCP to look up specific topics.

- **TanStack Router Docs**: https://tanstack.com/router/latest/docs/framework/react/overview
- **File-Based Routing Guide**: https://tanstack.com/router/latest/docs/framework/react/guide/file-based-routing
- **Data Loading Guide**: https://tanstack.com/router/latest/docs/framework/react/guide/data-loading
- **Search Params Guide**: https://tanstack.com/router/latest/docs/framework/react/guide/search-params

## Cross-References

- `dev:tanstack-query` -- data fetching patterns, state separation (URL state category)
- `dev:tanstack-start` -- server capabilities built on top of Router
- `dev:react` -- component architecture (loaders feed containers, not components)

## References

- For file naming conventions and code splitting, see `file-routing.md`
- For data loading patterns and auth guards, see `data-loading.md`
- For search param patterns, see `search-params.md`
