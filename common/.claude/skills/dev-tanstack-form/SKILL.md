---
name: dev:tanstack-form
description: "Nik's TanStack Form patterns -- type-safe fields, validation, render props. Load when @tanstack/react-form is in dependencies or form handling is needed."
user-invocable: false
---

# TanStack Form Patterns

## Core Principle: Headless, Type-Safe Form State

TanStack Form manages form state with full TypeScript inference -- field names, values, and validation errors are all type-safe. It's headless (no UI opinions), uses render props for fields, and integrates with Standard Schema validators (Zod, Valibot, ArkType).

## Key Concepts

| Concept | API | Purpose |
|-|-|-|
| Form instance | `useForm({ defaultValues, onSubmit })` | Central form controller |
| Shared options | `formOptions({ defaultValues })` | Reuse shape across client/server |
| Field | `<form.Field name="x" children={...} />` | Type-safe render prop per field |
| Subscribe | `<form.Subscribe selector={...} />` | Granular re-renders for form state |
| Reactivity | `useStore(form.store, selector)` | Read form state outside fields |
| Array fields | `<form.Field name="items" mode="array" />` | Dynamic lists with push/remove/swap |

## Key Patterns

### Basic Form

```tsx
const form = useForm({
  defaultValues: { firstName: '', age: 0 },
  onSubmit: async ({ value }) => {
    await api.createUser(value)
  },
})

return (
  <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit() }}>
    <form.Field
      name="firstName"
      children={(field) => (
        <input
          value={field.state.value}
          onBlur={field.handleBlur}
          onChange={(e) => field.handleChange(e.target.value)}
        />
      )}
    />
  </form>
)
```

### Validation

Three approaches, can be combined:

```tsx
// 1. Inline validators (per-field)
<form.Field
  name="age"
  validators={{
    onChange: ({ value }) => value < 18 ? 'Must be 18+' : undefined,
    onChangeAsyncDebounceMs: 500,
    onChangeAsync: async ({ value }) => {
      const taken = await checkAge(value)
      return taken ? 'Invalid age' : undefined
    },
  }}
/>

// 2. Standard Schema (form-level) -- Zod, Valibot, ArkType
const form = useForm({
  defaultValues: { age: 0 },
  validators: {
    onChange: z.object({ age: z.number().gte(18) }),
  },
})

// 3. Server validation (TanStack Start / Next.js / Remix)
const serverValidate = createServerValidate({
  ...formOpts,
  onServerValidate: ({ value }) => {
    if (value.age < 12) return 'Server: Must be 12+'
  },
})
```

### Field Listeners (Side Effects)

React to field changes without validation -- e.g., resetting dependent fields.

```tsx
<form.Field
  name="country"
  listeners={{
    onChange: ({ value }) => {
      form.setFieldValue('province', '')
    },
  }}
/>
```

### Reactivity: Always Use a Selector

```tsx
// Correct
const firstName = useStore(form.store, (s) => s.values.firstName)
const errors = useStore(form.store, (s) => s.errorMap)

// Wrong -- re-renders on every form state change
const store = useStore(form.store)
```

### Submit Button Pattern

```tsx
<form.Subscribe
  selector={(s) => [s.canSubmit, s.isSubmitting]}
  children={([canSubmit, isSubmitting]) => (
    <button type="submit" disabled={!canSubmit}>
      {isSubmitting ? '...' : 'Submit'}
    </button>
  )}
/>
```

### Reset: Prevent Native HTML Reset

```tsx
<button type="button" onClick={() => form.reset()}>Reset</button>
```

Use `type="button"` or `e.preventDefault()` -- native `type="reset"` causes unexpected behavior with `<select>` elements.

## Field State Metadata

| Flag | Meaning |
|-|-|
| `isTouched` | Changed or blurred at least once |
| `isDirty` | Value changed (persistent -- stays true even if reverted) |
| `isPristine` | Opposite of isDirty |
| `isBlurred` | Lost focus at least once |
| `isDefaultValue` | Current value equals default (use for non-persistent dirty check) |

## SSR Integration

| Framework | Package | Key Imports |
|-|-|-|
| TanStack Start | `@tanstack/react-form-start` | `formOptions`, `createServerValidate`, `mergeForm`, `useTransform` |
| Next.js App Router | `@tanstack/react-form/nextjs` | `formOptions`, `createServerValidate`, `initialFormState` |
| Remix | `@tanstack/react-form-remix` | `formOptions`, `createServerValidate`, `initialFormState` |

Pattern: share `formOptions` between client/server, use `mergeForm` + `useTransform` to sync server validation state back to client form.

## Anti-Patterns

| Anti-Pattern | Instead |
|-|-|
| `useStore(form.store)` without selector | Always provide a selector |
| `useField` for reactivity | Use `useStore(form.store, selector)` |
| Native `type="reset"` button | `type="button"` with `form.reset()` |
| Hasty field abstractions | Render props are intentionally explicit -- embrace them |
| Mixing controlled inputs with form state | Let TanStack Form own the field value |

## Sources of Truth

- **TanStack Form Docs**: https://tanstack.com/form/latest/docs/overview
- **React Basic Concepts**: https://tanstack.com/form/latest/docs/framework/react/guides/basic-concepts
- **Validation Guide**: https://tanstack.com/form/latest/docs/framework/react/guides/validation
- **SSR Guide**: https://tanstack.com/form/latest/docs/framework/react/guides/ssr
- **API Reference**: https://tanstack.com/form/latest/docs/reference/classes/FormApi

## Cross-References

- `dev:tanstack-store` -- Form uses Store internally; same `useStore` + selector pattern
- `dev:tanstack-start` -- server-side validation via `createServerValidate`
- `dev:typescript` -- type-safe patterns align with Form's inference
- `dev:react` -- render prop pattern for fields fits component architecture

## References

- For SSR integration examples, see `ssr-patterns.md`
