# SSR Patterns

## TanStack Start Integration

The pattern: share `formOptions` between client and server, validate on server via `createServerValidate`, merge server state back into client form.

### 1. Shared Form Options

```typescript
// app/routes/index.tsx (or extracted to shared file)
import { formOptions } from '@tanstack/react-form-start'

export const formOpts = formOptions({
  defaultValues: {
    firstName: '',
    age: 0,
  },
})
```

### 2. Server Validation + Handler

```typescript
import { createServerValidate, ServerValidateError } from '@tanstack/react-form-start'

const serverValidate = createServerValidate({
  ...formOpts,
  onServerValidate: ({ value }) => {
    if (value.age < 12) return 'Must be at least 12 to sign up'
  },
})

export const handleForm = createServerFn({ method: 'POST' })
  .inputValidator((data: unknown) => {
    if (!(data instanceof FormData)) throw new Error('Invalid form data')
    return data
  })
  .handler(async (ctx) => {
    try {
      const validatedData = await serverValidate(ctx.data)
      // Persist to database
    } catch (e) {
      if (e instanceof ServerValidateError) return e.response
      throw e
    }
    return 'Form validated successfully'
  })
```

### 3. Loader for Server State

```typescript
import { getFormData } from '@tanstack/react-form-start'

export const getFormDataFromServer = createServerFn({ method: 'GET' })
  .handler(async () => getFormData())
```

### 4. Client Component with Merged State

```tsx
import { mergeForm, useForm, useStore, useTransform } from '@tanstack/react-form-start'

export const Route = createFileRoute('/')({
  component: Home,
  loader: async () => ({ state: await getFormDataFromServer() }),
})

function Home() {
  const { state } = Route.useLoaderData()
  const form = useForm({
    ...formOpts,
    transform: useTransform((baseForm) => mergeForm(baseForm, state), [state]),
  })

  const formErrors = useStore(form.store, (s) => s.errors)

  return (
    <form action={handleForm.url} method="post" encType="multipart/form-data">
      {formErrors.map((error) => <p key={error as string}>{error}</p>)}
      {/* fields... */}
    </form>
  )
}
```

## Key Takeaways

- `formOptions` is the bridge between client and server type safety
- Server validation runs in `createServerValidate`, client validation in `validators` prop
- `mergeForm` + `useTransform` sync server errors back to client form state
- Both client and server validation can coexist -- client for UX, server for security
