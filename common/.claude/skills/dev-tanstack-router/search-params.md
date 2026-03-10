# Search Params

## Core Idea

Search params are the URL state category -- filters, pagination, sort order, active tabs. Type-safe via `validateSearch` with Zod. Replaces `useState` for any state that should survive page refresh or be shareable via URL.

See `dev:tanstack-query` state-separation for the full state categorization (server / client / URL).

## Defining Search Params

```tsx
import { z } from 'zod'

export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().default(1),
    sort: z.enum(['name', 'price', 'date']).default('name'),
    category: z.string().optional(),
    q: z.string().optional(),
  }),
  component: Products,
})
```

Zod provides defaults, validation, and TypeScript inference in one place.

## Reading Search Params

```tsx
function Products() {
  // Fully typed from validateSearch schema
  const { page, sort, category, q } = Route.useSearch()
}
```

## Writing / Updating Search Params

**Via Link (merge with previous):**

```tsx
<Link
  from={Route.fullPath}
  search={(prev) => ({ ...prev, page: prev.page + 1 })}
>
  Next Page
</Link>
```

**Via Link (replace all):**

```tsx
<Link search={{ page: 1, sort: 'name' }}>Reset Filters</Link>
```

**Programmatic:**

```tsx
const navigate = useNavigate({ from: Route.fullPath })

navigate({
  search: (prev) => ({ ...prev, category: 'electronics' }),
})
```

## Pattern: URL as Single Source of Truth

For filter/pagination state, search params are the source of truth. Don't duplicate in `useState`:

```tsx
// Bad: duplicated state
const [page, setPage] = useState(1)
const { page: urlPage } = Route.useSearch()
// page and urlPage can drift

// Good: URL is the truth
function Products() {
  const { page, sort } = Route.useSearch()
  const navigate = useNavigate({ from: Route.fullPath })

  const nextPage = () =>
    navigate({ search: (prev) => ({ ...prev, page: prev.page + 1 }) })

  // page drives both the query and the UI
  const { data } = useSuspenseQuery(productsQueryOptions({ page, sort }))
}
```
