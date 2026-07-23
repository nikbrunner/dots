# Query Patterns

## Orchestration / Topic Hooks

Hooks that compose multiple queries into a domain API (e.g. `useUserProfile` calling `useUser` + `usePermissions`) live in the same topic folder as the query hooks they orchestrate — not in `hooks/`.

```
api/
├── user/
│   ├── query-key.ts
│   ├── use-user.ts
│   ├── use-permissions.ts
│   └── use-user-profile.ts   # composes the above, derives canEdit etc.
```

If consumed by only one container, co-locate it there instead. See `dev:style:react` co-location rules.

---

## Complexity 1: One File Per Endpoint

Best for small API surfaces. Co-locates queries and mutations per topic.

```
api/
├── use-brands.ts
├── use-env.ts
└── use-settings.ts
```

### Full Example: `useBrands`

Single query + derived memoized values + multiple mutations. Returns `{ query, ...derived, ...mutations }`.

```tsx
// api/use-brands.ts
const TOPIC = "brands" as const;
const queryKey = (keys: string[] = []) => [TOPIC, ...keys] as const;

type UseBrandsOptions = Omit<
  Partial<UseQueryOptions<Brand[]>>,
  "queryKey" | "queryFn"
>;

export const useBrands = (options: UseBrandsOptions = {}) => {
  const query = useQuery({
    ...options,
    queryKey: queryKey(),
    queryFn: getBrands,
    staleTime: Infinity,
  });

  // Derived values -- memoized for reference stability
  const all = query.data ?? [];
  const brandsMap = useMemo(() => keyBy(all, (b) => b.key), [all]);
  const active = useMemo(() => all.filter((b) => b.active), [all]);
  const promoted = useMemo(() => all.filter((b) => b.promoted), [all]);

  // Mutations -- share queryKey for auto-invalidation
  const activate = useMutation({
    mutationKey: queryKey(["activate"]),
    mutationFn: activateBrand,
  });

  const deactivate = useMutation({
    mutationKey: queryKey(["deactivate"]),
    mutationFn: deactivateBrand,
  });

  return {
    query, // Don't spread -- stable reference

    // Derived data
    all,
    active,
    promoted,
    brandsMap,
    activeCount: active.length,

    // Mutations
    activate,
    deactivate,
  };
};
```

Key conventions:

- `query` returned as-is (never spread) for render optimization
- Derived values memoized with `useMemo` for reference stability
- Mutations share the same `queryKey` root for automatic invalidation via `MutationCache`

### Scaling a Single Topic: File Splitting

When a topic hook grows large (many mutations, complex derived logic), split into co-located files:

```
api/
├── use-settings.ts          # Main hook + query + orchestration
├── use-settings.types.ts    # Shared types (query/mutation options)
├── use-settings.lib.ts      # Pure logic (derivations, selectors -- testable without hooks)
├── use-settings.lib.spec.ts # Tests for pure logic
```

**Pattern: Namespaced mutation collection** -- when a topic has many mutations, export them as a structured object:

```tsx
// use-settings.ts

// Individual mutation hooks (not exported directly)
const useSetCustomization = (options = {}) => {
  return useMutation({
    ...options,
    mutationKey: queryKey(["customization"]),
    mutationFn: (customization) =>
      storeSetting(["customization"], customization),
  });
};

const useSetMail = (options = {}) => {
  return useMutation({
    ...options,
    mutationKey: queryKey(["mail"]),
    mutationFn: (mail) => storeSetting(["mail"], mail),
  });
};

// Exported as namespaced collection
export const useSetSettings = {
  customization: { set: useSetCustomization },
  mail: { set: useSetMail },
  bookmarks: { set: useSetBookmarks },
  toolSettings: {
    set: useSetToolSettings,
    reset: useResetToolSettings,
  },
} as const satisfies { [K in keyof Settings]?: unknown };

// Usage:
// const setCustomization = useSetSettings.customization.set();
// setCustomization.mutate({ logo: "new-logo.png" });
```

**Pattern: Extract pure logic to `.lib.ts`** -- keep hooks thin, test derivations independently:

```tsx
// use-settings.lib.ts -- pure functions, no hooks
const assortmentPriceSettings = (
  settings: Settings,
): AssortmentPriceSettings => {
  const hasAutomatic = settings.assortment.type === AssortmentType.Automatic;
  return hasAutomatic ? settings.assortment.priceSettings : fallbackSettings;
};

export default { assortmentPriceSettings };
```

```tsx
// use-settings.ts -- getter delegates to lib
return {
  query,
  get assortmentPriceSettings() {
    return lib.assortmentPriceSettings(this.initialized);
  },
};
```

### Automatic Invalidation via MutationCache

Use the first entry in mutation keys (the topic) to auto-invalidate related queries.
Configure this globally in the QueryClient via `MutationCache`.

Based on: https://tkdodo.eu/blog/automatic-query-invalidation-after-mutations

```tsx
const queryClient = new QueryClient({
  defaultOptions: {
    mutations: {
      meta: { autoInvalidate: true },
    },
  },
  mutationCache: new MutationCache({
    onSuccess: async (_data, _variables, _context, mutation) => {
      if (!mutation.meta?.autoInvalidate) return;

      if (mutation.options.mutationKey) {
        const topics = mutation.options.mutationKey as ApiTopic[];
        const mainTopic = topics[0];

        await queryClient.invalidateQueries({ queryKey: [mainTopic] });
      }
    },
  }),
});
```

Any mutation with a key like `["products", "update"]` automatically invalidates all `["products", ...]` queries on success. Opt out per-mutation with `meta: { autoInvalidate: false }`.

### Render Optimization: Don't Spread, Do Memoize

Two rules for custom query hooks:

**1. Don't spread the query object.** Rest-destructuring (`...rest`) breaks React Query's tracked property optimization (Proxy-based, on by default since v4). It also creates a new object reference every render.

```tsx
// Bad -- breaks tracked properties, new object every render
const { data, isLoading, ...rest } = useQuery(/* ... */);
return { ...rest, data, isLoading, derivedValue };

// Good -- tracked properties work, clean API surface
const query = useQuery(/* ... */);
return { query, derivedValue: query.data?.something };
```

**2. Memoize derived values.** Structural sharing keeps `query.data` referentially stable when data hasn't changed. But `.filter()`, `.map()`, etc. always create new arrays — breaking the reference chain. `useMemo` preserves it:

```tsx
const all = query.data ?? [];

// Bad -- new array every render, even if `all` hasn't changed
const active = all.filter((b) => b.active);

// Good -- cached result when `all` reference is stable
const active = useMemo(() => all.filter((b) => b.active), [all]);
```

The chain: structural sharing → stable `query.data` → stable dep → `useMemo` returns cached derived value.

See: https://tanstack.com/query/latest/docs/framework/react/guides/render-optimizations

## Complexity 2: One Folder Per Topic

For medium API surfaces. Separate files per query/mutation with shared key definitions.

Default root is `src/api/` (technical separation — see `dev:style:react`
`folder-structure.md`), not nested under a `features/` domain folder.

```
api/
├── settings/
│   ├── query-key.ts
│   ├── use-settings.ts
│   ├── use-settings.fn.ts       # fetch function
│   ├── use-set-settings.ts
│   └── use-set-settings.fn.ts
├── users/
│   ├── query-key.ts
│   ├── use-users.ts
│   └── use-create-user.ts
```

### Entity file: the reusable layer

Within a topic folder, `queryOptions()`/`mutationOptions()` factories are the
thing that actually gets reused — a route `loader` calls
`ensureQueryData(factory())` directly, a component calls
`useQuery(factory())`/`useMutation(factory())` through a thin hook. Pull that
factory layer into its own file, named after the **entity it covers** (not
generically `api.ts`, and not one file per hook):

```
api/licenses/
├── users.ts                     # queryOptions/mutationOptions for user-scoped licenses
├── organizations.ts             # queryOptions/mutationOptions for org-scoped licenses + org members
├── use-user-licenses.ts         # useQuery(usersQueries.licenses())
├── use-organization-licenses.ts # useQuery(organizationsQueries.licenses())
├── use-organization-members.ts  # useQuery(organizationsQueries.members())
└── use-assign-user-license.ts   # useMutation(usersQueries.assignLicense())
```

A topic folder is one file per **entity**, not one file per topic and not
one file per hook:

- If every query/mutation in a topic concerns one entity, one file
  (`licenses.ts`) covers the whole topic.
- If a topic spans multiple entities (e.g. licenses scoped to users vs.
  licenses scoped to organizations), split into one file per entity
  (`users.ts`, `organizations.ts`) — still inside the topic folder.
- Hooks stay thin siblings that import the factory and wrap it in
  `useQuery`/`useMutation`. Don't inline the raw fetch call or the
  `queryOptions` factory into the hook file — that breaks loader prefetch,
  since a loader can't call a hook.

Raw fetch functions themselves are _not_ a reuse boundary in practice —
audit shows they're called from exactly one factory each. Don't default to
a shared `api.ts`/`queries.ts` file "in case" a fetch function gets reused;
add that split only if a raw fetch function actually gets a second
independent caller.

## Complexity 3: API Folder with Query Option Factories

For large API surfaces or GraphQL. Instead of `useQuery` hooks, export **query option factories** — plain functions that return query options. Consumers (route loaders, components) call `useSuspenseQuery(factory())` or `ensureQueryData(factory())`.

```
api/
├── topics.ts              # Shared topic enum + createApiKeys factory
├── products/
│   ├── keys.ts            # Topic-specific key definitions
│   ├── queryFns.ts        # Query option factories
│   ├── mutationFns.ts     # Mutation option factories
│   ├── queries.ts         # GraphQL query documents
│   └── fragments.ts       # Reusable GraphQL fragments
├── orders/
│   ├── keys.ts
│   ├── queryFns.ts
│   └── mutationFns.ts
```

### Topic Key Factory

Centralized, type-safe key creation per domain:

```tsx
// api/topics.ts
export const API_TOPICS = {
  PRODUCTS: "products",
  ORDERS: "orders",
  CUSTOMER: "customer",
} as const;

export type ApiTopic = (typeof API_TOPICS)[keyof typeof API_TOPICS];

export function createApiKeys<
  Topic extends ApiTopic,
  QueryKeys extends Record<string, QueryKey<Topic> | QueryKeyFactory<Topic>>,
  MutationKeys extends Record<string, QueryKey<Topic>>,
>(topic: Topic, keys: { queries: QueryKeys; mutations: MutationKeys }) {
  return { topic: [topic], queries: keys.queries, mutations: keys.mutations };
}
```

```tsx
// api/products/keys.ts
export const keys = createApiKeys("products", {
  queries: {
    byFilter: (input: SearchVariables) => ["products", "filter", input],
    bySlug: (slug: string) => ["products", "slug", slug],
    byId: (id: string) => ["products", "id", id],
  },
  mutations: {
    update: ["products", "update"],
  },
});
```

### Query Option Factories

Return `queryOptions()` objects instead of wrapping in hooks — decouples from React, usable in loaders:

```tsx
// api/products/queryFns.ts
import { queryOptions } from "~/utils/query";
import { keys } from "./keys";
import * as QUERIES from "./queries";

export function getBySlug(args: {
  variables: { slug: string };
  options?: Omit<QueryOptions<Product>, "queryKey" | "queryFn">;
}) {
  return queryOptions({
    ...args.options,
    queryKey: keys.queries.bySlug(args.variables.slug),
    queryFn: async () => {
      const result = await request(QUERIES.GET_PRODUCT, {
        slug: args.variables.slug,
      });
      return result.product ?? null;
    },
  });
}
```

### Usage: Route Loader + Component

```tsx
// routes/products.$slug.tsx
export const Route = createFileRoute("/products/$slug")({
  loader: async ({ params, context }) => {
    // Prefetch in loader — data ready before component renders
    await context.queryClient.ensureQueryData(
      context.api.products.getBySlug({ variables: { slug: params.slug } }),
    );
  },
});

function RouteComponent() {
  const params = Route.useParams();
  const { api } = Route.useRouteContext();

  // Suspense query — guaranteed data, no loading states
  const { data } = useSuspenseQuery(
    api.products.getBySlug({ variables: { slug: params.slug } }),
  );

  return <ProductDetail product={data} />;
}
```

### API Object

Aggregate all topic factories into one `api` object for route context:

```tsx
// api/index.ts
import * as products from "./products/queryFns";
import * as orders from "./orders/queryFns";

export const api = { products, orders } as const;
export type API = typeof api;
```
