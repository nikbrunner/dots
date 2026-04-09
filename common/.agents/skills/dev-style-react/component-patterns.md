# Component Patterns

## Data Attributes

Every role's root element gets a `data-*` attribute for DOM inspection and debugging:

| Role             | Attribute        | Example                                 |
| ---------------- | ---------------- | --------------------------------------- |
| Dumb Component   | `data-component` | `data-component="UserCard"`             |
| Partial          | `data-partial`   | `data-partial="UserProfileHeader"`      |
| Layout Component | `data-layout`    | `data-layout="PageLayout"`              |
| Smart Container  | `data-container` | `data-container="UserProfileContainer"` |

## Dumb Component

```tsx
interface Props {
  name: string;
  avatarUrl: string;
  role: string;
  onEdit: () => void;
}

export function UserCard({ name, avatarUrl, role, onEdit }: Props) {
  return (
    <div data-component="UserCard" className={styles.card}>
      <img src={avatarUrl} alt={name} className={styles.avatar} />

      <h3>{name}</h3>

      <span>{role}</span>

      <button onClick={onEdit}>Edit</button>
    </div>
  );
}
```

- Receives only props (data + callbacks)
  - Simple prop data types to help React compare values isntead of reference equality of objects and arrays
  - If it is still needed to handover complex data, keep in mind that reference equality is handled (`React.memo` or `React.useMemo`)
- All styling is here
- No app dependencies, no store access, no fetching
- Rarely has own state -- when it does, it's pure UI state (hover, open/closed)

## Partial

```tsx
interface Props {
  name: string;
  avatarUrl: string;
  onEdit: () => void;
  canEdit: boolean;
}

export function UserProfileHeader({ name, avatarUrl, canEdit, onEdit }: Props) {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <Row data-partial="UserProfileHeader" gap="md">
      <Avatar url={avatarUrl} size="lg" />

      <UserName name={name} />

      {canEdit && (
        <EditButton
          onClick={onEdit}
          onMouseEnter={() => setIsHovered(true)}
          onMouseLeave={() => setIsHovered(false)}
          highlighted={isHovered}
        />
      )}
    </Row>
  );
}
```

- Composition of Dumb Components with light local logic
- **Zero styling** -- uses Layout Components (Row, Stack, etc.) for arrangement
- Typically has a Layout Component as root element (Row, Stack, etc.) to arrange its children
- Reusable or extracted because it forms a coherent unit
- Can have co-located utility hooks if needed
- Red flag: a partial with a CSS file

## Layout Component

```tsx
interface Props {
  children: React.ReactNode;
  sidebar: React.ReactNode;
}

export function PageLayout({ children, sidebar }: Props) {
  return (
    <div data-layout="PageLayout" className={styles.page}>
      <aside className={styles.sidebar}>{sidebar}</aside>
      <main className={styles.main}>{children}</main>
    </div>
  );
}
```

- Pure structural arrangement
- Accepts children/slots as props (nodes as props pattern)
- No data logic, no fetching

## Smart Container

For query patterns read the skill `dev:style:tanstack`.

```tsx
export function UserProfileContainer() {
  const userProfile = useUserProfile(); // Query Hook
  const updateUser = useUpdateUser(); // Mutation Hook

  const permissions = useUserPermissions(userProfile.data); // Utility hook that derives permissions from user profile

  if (userProfile.query.isPending) {
    return <LoadingSpinner />;
  }

  if (userProfile.query.isError) {
    return <ErrorDisplay error={userQuery.error} />;
  }

  return (
    <PageLayout data-container="UserProfileContainer">
      <UserProfileHeader
        name={userProfile.data.name}
        avatarUrl={userProfile.data.avatar}
        canEdit={permissions.canEdit}
        onEdit={() => updateUser.mutate(user.id)}
      />

      <ActivityFeedPartial userId={userProfile.data.id} />
    </PageLayout>
  );
}
```

- No DOM styling (small layout utility classes are acceptable)
- Provides data and callbacks to children
- Named `*Container` by convention
- Orchestrates -- delegates logic to topic hooks

## File-Local Subcomponents

Components defined in the same file as their parent — used to decompose without creating new files.

**In component files** — can be exported (co-located sub-components that belong together):

```tsx
// components/user-list/index.tsx

export function UserListItem({ name, role }: { name: string; role: string }) {
  return (
    <li data-component="UserListItem" className={styles.item}>
      <span>{name}</span>
      <span>{role}</span>
    </li>
  );
}

export function UserList({ users }: Props) {
  return (
    <ul data-component="UserList" className={styles.list}>
      {users.map((user) => (
        <UserListItem key={user.id} name={user.name} role={user.role} />
      ))}
    </ul>
  );
}
```

**In partials and containers** — not exported, private helpers to keep the main component readable:

```tsx
// containers/dashboard/index.tsx

function StatsSection({ stats }: { stats: Stats }) {
  return (
    <Row gap="sm">
      <StatCard label="Users" value={stats.users} />
      <StatCard label="Revenue" value={stats.revenue} />
    </Row>
  );
}

export function DashboardContainer() {
  const dashboard = useDashboard();

  return (
    <PageLayout data-container="DashboardContainer">
      <StatsSection stats={dashboard.data.stats} />
      <ActivityFeedPartial userId={dashboard.data.userId} />
    </PageLayout>
  );
}
```

**When to use:**

- The subcomponent is only used by one parent
- It's small enough that a separate file adds more overhead than clarity
- It helps readability by breaking up a long return block

**When to extract to its own file:**

- Used by multiple consumers
- Has its own styling (component) or grows beyond ~30-40 lines

## Broad vs Deep Split

**Prefer Broad Split** -- one Container (or Route) fans out to many Dumb Components directly, rather than passing props through a single proxy component (Deep Split).

When you notice components forwarding props they don't use, that's a signal to either:

- Introduce a Container/Partial closer to where the data is needed
- In route-based apps, let the route itself handle orchestration (see "Routes as Containers" in SKILL.md)

## Render-Prop Context

A context provider where `children` is a function receiving the context value. Cleanly scopes context consumption and avoids the need for a separate consumer component.

```tsx
interface FilterProviderProps {
  groupedFacets: GroupedFacet[];
  productPriceRange: PriceRange;
  children: (value: FilterContextValue) => React.ReactNode;
}

export const FilterContextProvider = ({
  groupedFacets,
  productPriceRange,
  children,
}: FilterProviderProps) => {
  const [mobileFiltersOpen, setMobileFiltersOpen] = useState(false);

  const value: FilterContextValue = {
    groupedFacets,
    productPriceRange,
    mobileFiltersOpen,
    setMobileFiltersOpen,
  };

  return (
    <FilterContext.Provider value={value}>
      {children(value)}
    </FilterContext.Provider>
  );
};

// Usage in a route/container:
<FilterContextProvider groupedFacets={facets} productPriceRange={range}>
  {(filterContext) => (
    <div>
      <FilterControls />
      <ProductGrid />
      <FiltersButton onClick={() => filterContext.setMobileFiltersOpen(true)} />
    </div>
  )}
</FilterContextProvider>;
```

- Provider receives static data as props, manages its own UI state internally
- Children function gives immediate access without `useContext` at the call site
- Still provides `useFilterContext()` hook for deeply nested consumers

## Anti-Patterns

- Component that imports and renders another component's styles
- Container with CSS classes beyond minor layout utilities
- Dumb Component that calls `useQuery` or accesses a store
- Hardcoded strings in a component when i18n exists
- Prop drilling through 3+ levels (introduce a Container or Partial or consider a higher level state or context)
