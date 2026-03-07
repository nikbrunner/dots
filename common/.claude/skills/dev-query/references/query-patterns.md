# Query Patterns

## Complexity 1: One File Per Endpoint

Best for small API surfaces. Co-locates queries and mutations per topic.

```
queries/
├── use-settings.ts
├── use-env.ts
└── use-users.ts
```

```tsx
// queries/use-settings.ts
import { getSettings, setSettings } from "@/lib/api";

const TOPIC = "settings" as const;

function queryKey(keys: string[]) {
  return [TOPIC, ...keys];
}

// -- Query --

type UseSettingsQueryOptions = Omit<
  UseQueryOptions<Settings>,
  "queryKey" | "queryFn"
>;

export function useSettings(queryOptions?: UseSettingsQueryOptions) {
  return useQuery({
    queryKey: queryKey(["get"]),
    queryFn: getSettings,
    ...queryOptions,
  });
}

// With additional params and derived values:
export function useSettings({
  section,
  queryOptions,
}: {
  section: string;
  queryOptions?: UseSettingsQueryOptions;
}) {
  const query = useQuery({
    queryKey: queryKey(["get", section]),
    queryFn: () => getSettings(section),
    ...queryOptions,
  });

  // Derive convenience values, but don't spread the query
  const toolSettings = query.data?.toolSettings;

  return {
    query, // IMPORTANT: don't spread -- avoids new object on every render
    toolSettings,
  };
}

// -- Mutation --

type UseSetSettingsMutationOptions = Omit<
  UseMutationOptions<Settings>,
  "mutationFn"
>;

export function useSetSettings(
  mutationOptions?: UseSetSettingsMutationOptions,
) {
  return useMutation({
    mutationKey: queryKey(["set"]),
    mutationFn: setSettings,
    ...mutationOptions,
  });
}
```

### Automatic Invalidation

Use the first entry in mutation keys (the topic) to auto-invalidate related queries.
Configure this globally in the QueryClient.

Based on: https://tkdodo.eu/blog/automatic-query-invalidation-after-mutations

### Render Optimization: Don't Spread

```tsx
// Bad -- creates new object every render
const { data, isLoading, ...rest } = useQuery(/* ... */);
return { ...rest, data, isLoading, derivedValue };

// Good -- stable reference
const query = useQuery(/* ... */);
return { query, derivedValue: query.data?.something };
```

See: https://tanstack.com/query/latest/docs/framework/react/guides/render-optimizations

## Complexity 2: One Folder Per Topic

For medium API surfaces. Separate files per query/mutation with shared key definitions.

```
queries/
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

## Complexity 3: API Folder (GraphQL)

For large API surfaces or GraphQL, where query definitions need their own files.

```
api/
├── settings/
│   ├── query-key.ts
│   ├── queries/
│   │   ├── get-settings.graphql
│   │   └── get-settings.ts
│   ├── mutations/
│   │   ├── set-settings.graphql
│   │   └── set-settings.ts
│   └── hooks/
│       ├── use-settings.ts
│       └── use-set-settings.ts
```
