# Server Functions

## createServerFn Anatomy

```tsx
import { createServerFn } from '@tanstack/react-start'

// GET for reads
export const getUser = createServerFn({ method: 'GET' })
  .validator((data: { id: string }) => data)
  .handler(async ({ data }) => {
    return db.users.findFirst({ where: eq(users.id, data.id) })
  })

// POST for mutations
export const createUser = createServerFn({ method: 'POST' })
  .validator(CreateUserSchema)  // Zod, Valibot, ArkType, or custom
  .handler(async ({ data }) => {
    return db.users.create(data)
  })
```

**Method semantics:** GET for reads (cacheable, safe), POST for mutations (side effects).

**Validator is optional** but recommended -- provides runtime type safety on top of TypeScript's compile-time checks.

## Calling Contexts

**From route loaders** (prefetch during navigation):

```tsx
export const Route = createFileRoute('/users/$userId')({
  loader: ({ params }) => getUser({ data: { id: params.userId } }),
})
```

**From components** (via `useServerFn` hook, typically with TanStack Query):

```tsx
function UserForm() {
  const mutation = useMutation({
    mutationFn: useServerFn(createUser),
  })

  return <form onSubmit={() => mutation.mutate(formData)} />
}
```

**From other server functions** (composition):

```tsx
export const getUserWithPosts = createServerFn({ method: 'GET' })
  .validator((data: { id: string }) => data)
  .handler(async ({ data }) => {
    const user = await getUser({ data })
    const posts = await getPostsByUser({ data: { userId: data.id } })
    return { user, posts }
  })
```

## Type Safety

Input and output types are inferred end-to-end without codegen. The validator schema defines the input type, the handler return type flows to the caller.

## Pattern: Keep Server Functions Thin

Server functions should do validation + data access. Business logic belongs in shared utilities that can be tested independently:

```tsx
// lib/users.ts -- testable business logic
export function canUserPublish(user: User): boolean {
  return user.role === 'author' && user.emailVerified
}

// server function -- thin orchestration
export const publishPost = createServerFn({ method: 'POST' })
  .validator(PublishPostSchema)
  .handler(async ({ data, context }) => {
    const user = context.session.user
    if (!canUserPublish(user)) throw new Error('Not authorized')
    return db.posts.update({ id: data.postId, status: 'published' })
  })
```

## Environment Safety

- Server functions run exclusively on the server -- database credentials and secrets stay server-side
- `.server.ts` files are tree-shaken by the bundler (never sent to client)
- Server functions can be imported in client components -- the build process handles the boundary
