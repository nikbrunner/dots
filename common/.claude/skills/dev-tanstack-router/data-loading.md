# Data Loading

## Two-Stage Loading

### Stage 1: beforeLoad (Sequential)

Runs parent-to-child, each must complete before the next starts. Used for preconditions.

```tsx
export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }
    // Return values merge into context for child routes
    return { user: context.auth.user }
  },
})
```

**Use for:** auth checks, redirects, lightweight context setup. Not for heavy data fetching.

### Stage 2: loader (Parallel)

Runs after all `beforeLoad` complete. Loaders across sibling routes run in parallel. Built-in SWR caching.

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params, context }) => {
    return context.queryClient.ensureQueryData(
      postQueryOptions(params.postId)
    )
  },
  component: PostDetail,
})
```

**Use for:** data fetching. Results available before component renders.

## Auth Guard Pattern

Use a pathless layout route with `beforeLoad`:

```
src/routes/
├── _authenticated.tsx            # Guard: checks auth, redirects if not
├── _authenticated/
│   ├── dashboard.tsx             # Protected: /dashboard
│   └── settings.tsx              # Protected: /settings
```

```tsx
// _authenticated.tsx
export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
  },
})
```

## Integration with TanStack Query

Share `queryOptions` between loader and component. The loader prefetches during navigation, the component reads from cache.

```tsx
// Shared query options
const postQueryOptions = (postId: string) => queryOptions({
  queryKey: ['posts', postId],
  queryFn: () => fetchPost(postId),
})

// Route definition
export const Route = createFileRoute('/posts/$postId')({
  loader: ({ params, context }) =>
    context.queryClient.ensureQueryData(postQueryOptions(params.postId)),
  component: PostDetail,
})

// Component reads from cache (no loading state needed)
function PostDetail() {
  const { postId } = Route.useParams()
  const { data: post } = useSuspenseQuery(postQueryOptions(postId))
  return <PostView post={post} />
}
```

See `dev:tanstack-query` query-patterns for the hook organization side.

## Search-Param-Dependent Loading

Use `loaderDeps` to explicitly declare which search params the loader depends on:

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().default(1),
    category: z.string().optional(),
  }),
  loaderDeps: ({ search }) => ({ page: search.page, category: search.category }),
  loader: ({ deps }) => fetchProducts(deps.page, deps.category),
})
```

Without `loaderDeps`, the loader won't re-run when search params change.
