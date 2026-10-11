# Validation

Validate data when it crosses into code the frontend owns. The schema is both the runtime check and the TypeScript source.

## Boundaries

Validate once at the edge:

- network responses on entry;
- URL path and search values;
- persisted browser data when read;
- user input when it becomes a submitted domain or request value.

After the boundary, use the parsed value. A generic on a typed client only tells TypeScript what you hope the response looks
like; it validates nothing.

## Schema first, type derived

```ts
export const userSchema = z.object({
  id: z.string(),
  email: z.email()
});

export type User = z.infer<typeof userSchema>;
```

The same holds for request and response shapes the frontend owns at runtime.

## Search params

Pass a Zod schema to `validateSearch`; the route's search types come from it. Use `.catch()` for malformed values that can
safely fall back, and `.default()` only for missing ones.

```tsx
const searchSchema = z.object({
  page: z.number().int().positive().catch(1),
  filter: z.string().catch("")
});
```

## Failure handling

- `parse` when invalid data is a contract failure that should reach the error boundary.
- `safeParse` when failure is expected and the caller shows a validation message.
- Trimming, coercion, transforms, and defaults live in the boundary schema.

## Locked fields

A value the user cannot change here (an invited email, a generated ID) is `readOnly`: focusable, copyable, and submitted.
A control that does not apply until something else changes is `disabled`, with the reason shown next to it. The server
re-derives a read-only value instead of trusting the submitted copy.
