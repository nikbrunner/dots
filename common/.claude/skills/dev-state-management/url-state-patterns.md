# URL State Patterns

## The Pattern: Search Params + Storage Fallback

From nbr.haus -- URL state hooks that are shareable, persistent, and type-safe.

The shape: read from search params → fallback to localStorage → fallback to default. Setter updates DOM/effect, persists to storage, and navigates with `replace: true`.

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
