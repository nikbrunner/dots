---
name: dev:tanstack-start
description: "TanStack Start patterns -- server functions, middleware, SSR. Load when @tanstack/react-start is in dependencies."
user-invocable: false
---

# TanStack Start

## Core Principle: Client-First with Explicit Server Capabilities

TanStack Start is a full-stack React framework built on TanStack Router + Vite + Nitro/Vinxi. Unlike Next.js's server-first approach with `"use server"` directives, Start uses explicit `createServerFn()` definitions -- no magic, clear server/client boundaries.

**Version:** Pre-v1 Release Candidate (0.x). API is stable but may change. Always verify against docs before implementation.

## Architecture

Start layers on top of TanStack Router:
- Same file-based routing, loaders, search params (see `dev:tanstack-router`)
- Adds: server functions (type-safe RPC), middleware, full-document SSR with streaming
- Powered by Vite (dev speed), Nitro/Vinxi (universal server runtime)
- Developers rarely interact with Nitro/Vinxi directly

## Key Patterns

- **`createServerFn`** -- explicit, type-safe RPC. GET for reads, POST for mutations. No codegen needed.
- **`createMiddleware`** -- typed context passing. Auth, logging, error handling.
- **SSR** -- full-document streaming. Server renders React tree, client hydrates, then SPA behavior.
- **Deployment** -- universal fetch handler. Vercel, Cloudflare, Node, Deno, self-hosted.

## Integration with TanStack Query

Server functions as the data layer, Query for client-side caching:

```tsx
// Server function (data access)
export const getPosts = createServerFn({ method: 'GET' })
  .handler(async () => {
    return db.posts.findMany()
  })

// Route loader (prefetch during navigation)
export const Route = createFileRoute('/posts')({
  loader: () => getPosts(),
  component: Posts,
})

// Component (with client caching via Query)
function Posts() {
  const { data } = useSuspenseQuery({
    queryKey: ['posts'],
    queryFn: () => getPosts(),
  })
}
```

## Sources of Truth

- **TanStack Start Docs**: https://tanstack.com/start/latest/docs/framework/react/overview
- **Server Functions Guide**: https://tanstack.com/start/latest/docs/framework/react/guide/server-functions
- **Middleware Guide**: https://tanstack.com/start/latest/docs/framework/react/guide/middleware
- **Authentication Guide**: https://tanstack.com/start/latest/docs/framework/react/guide/authentication

## Cross-References

- `dev:tanstack-router` -- routing foundation (file routing, loaders, search params)
- `dev:tanstack-query` -- client-side caching on top of server functions

## References

- For server function patterns, see `server-functions.md`
- For middleware patterns, see `middleware.md`
