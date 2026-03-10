# URL State Patterns

## Simple Case: Filters & Pagination

The most common URL state pattern. Search params drive the query, no persistence needed.

```tsx
// Route definition with validated search params
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().default(1),
    sort: z.enum(['name', 'price', 'date']).default('name'),
    category: z.string().optional(),
  }),
  component: Products,
})

function Products() {
  const { page, sort, category } = Route.useSearch()
  const navigate = useNavigate({ from: Route.fullPath })

  // Search params drive the query directly
  const { data } = useSuspenseQuery(
    productsQueryOptions({ page, sort, category })
  )

  const nextPage = () =>
    navigate({ search: prev => ({ ...prev, page: prev.page + 1 }) })

  const setCategory = (cat: string) =>
    navigate({ search: prev => ({ ...prev, category: cat, page: 1 }) })

  return (/* ... */)
}
```

No `useState`, no state manager. The URL is the source of truth. Copy the URL, share it, bookmark it -- the view reproduces.

### Encapsulating in a Hook

When a param is used across multiple components, extract it into a reusable hook:

```tsx
// useCategory.ts
import { useNavigate, useSearch } from "@tanstack/react-router"

export function useCategory() {
  const { category } = useSearch({ strict: false })
  const navigate = useNavigate()

  const setCategory = (cat: string | undefined) =>
    navigate({
      to: ".",
      search: prev => ({ ...prev, category: cat }),
    })

  return { category, setCategory }
}
```

`strict: false` makes the hook usable from any route — it reads whatever search params exist without binding to a specific `Route`. Same pattern works for `useSort`, `usePage`, `useView`, etc.

## Advanced Case: Search Params + Storage Fallback

From nbr.haus -- URL state with localStorage persistence for user preferences. More complex because it handles SSR hydration and DOM side effects.

```tsx
// useColorMode.ts (simplified from nbr.haus)
import { useHydrated, useRouter, useSearch } from "@tanstack/react-router"
import { colorModeSchema, defaultColorMode, type ColorMode } from "@/types/style"

export function useColorMode() {
  const router = useRouter()
  const search = useSearch({ strict: false })
  const hydrated = useHydrated()

  // Priority: URL param > localStorage > default
  const colorMode =
    search.colorMode ?? getFromStorage(hydrated) ?? defaultColorMode

  useEffect(() => {
    if (!hydrated) return
    applyColorMode(colorMode)
  }, [hydrated, colorMode])

  const setColorMode = useCallback(
    (newColorMode: ColorMode) => {
      applyColorMode(newColorMode)
      persistToStorage(newColorMode)
      router.navigate({
        to: ".",
        search: prev => ({ ...prev, colorMode: newColorMode }),
        resetScroll: false,
        replace: true,       // Don't pollute history
        viewTransition: true // Smooth CSS transitions
      })
    },
    [router]
  )

  return { colorMode, setColorMode, colorModes: colorModeSchema.options }
}
```

### Why This Works

- **Shareable**: Send someone a URL with `?colorMode=dark` and they see the same thing
- **Persistent**: localStorage survives across sessions, URL params survive page refresh
- **Type-safe**: Zod schema validates both URL input and storage values
- **No state manager needed**: Router search params + localStorage cover it

### When to Use This Pattern

- User preferences that should be shareable (theme, color mode, layout)
- Filter/sort/pagination state
- Any state where "copy this URL" should reproduce the view

### When NOT to Use This Pattern

- Ephemeral UI state (hover, focus, animation progress)
- Sensitive data (auth tokens, form inputs with PII)
- High-frequency updates (mouse position, scroll offset)

## nuqs Adapter

For `useQueryState`-style ergonomics (individual param hooks instead of full `Route.useSearch()`):

```tsx
import { useQueryState, parseAsString } from "nuqs"
import { NuqsAdapter } from "nuqs/adapters/tanstack-router"

// Wrap app
<NuqsAdapter>
  <App />
</NuqsAdapter>

// Use individual param hooks
function Filters() {
  const [category, setCategory] = useQueryState("category", parseAsString)
}
```

- **nuqs docs**: https://nuqs.dev/docs/adapters#tanstack-router
- Note: TanStack Router may add native `useQueryState` in the future

## Pure Client State: Just useState

Not everything needs URL state. `useIsMobile` is a good example:

```tsx
export function useIsMobile(): boolean {
  const [isMobile, setIsMobile] = useState(() =>
    typeof window === "undefined" ? false : window.innerWidth < MOBILE_BREAKPOINT
  )

  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < MOBILE_BREAKPOINT)
    window.addEventListener("resize", handleResize)
    return () => window.removeEventListener("resize", handleResize)
  }, [])

  return isMobile
}
```

No URL needed. No storage needed. Local to the component lifecycle.
