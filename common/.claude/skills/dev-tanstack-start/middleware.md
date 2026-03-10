# Middleware

## createMiddleware

Middleware runs before server functions, passing typed context down the chain.

```tsx
import { createMiddleware } from '@tanstack/react-start'

const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await auth.api.getSession({ headers: request.headers })

    if (!session?.user) {
      throw redirect({ to: '/login' })
    }

    // Context is typed and available in handler
    return next({ context: { session } })
  })
```

## Using Middleware on Server Functions

```tsx
export const listItems = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    // context.session is typed from authMiddleware
    return db.items.findMany({
      where: { userId: context.session.user.id },
    })
  })
```

## Composing Middleware Chains

Multiple middleware run in order. Each can add to the context:

```tsx
const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const start = Date.now()
    const result = await next()
    console.log(`Request took ${Date.now() - start}ms`)
    return result
  })

export const protectedAction = createServerFn({ method: 'POST' })
  .middleware([loggingMiddleware, authMiddleware])
  .handler(async ({ context }) => {
    // Has both logging and auth context
  })
```

## Global vs Function-Level Middleware

**Global middleware** (runs for all requests):

```tsx
// src/start.ts
import { createStartHandler, defaultStreamHandler } from '@tanstack/react-start/server'

export default createStartHandler({
  createRouter,
  middleware: [loggingMiddleware],
})
```

**Function-level middleware** (runs for specific server functions):

```tsx
export const adminAction = createServerFn({ method: 'POST' })
  .middleware([authMiddleware, adminMiddleware])
  .handler(/* ... */)
```

## Middleware vs beforeLoad

| Aspect | Middleware | beforeLoad |
|-|-|-|
| **Runs on** | Server only | Both client + server |
| **Applies to** | Server functions | Route navigation |
| **Context passing** | `next({ context })` | Return value merges into route context |
| **Use case** | Server-side auth, logging, CORS | Route guards, redirects, preloading context |

Use `beforeLoad` for route-level guards (see `dev:tanstack-router` data-loading). Use middleware for server function-level concerns.
