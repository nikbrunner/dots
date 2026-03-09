# Component Patterns

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

export function UserProfileHeader({
  name,
  avatarUrl,
  canEdit,
  onEdit,
}: Props) {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <div className={styles.header}>
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
    </div>
  );
}
```

- Composition of Dumb Components with light local logic
- Has its own styling for composition/layout
- Reusable or extracted because it forms a coherent unit
- Can have co-located utility hooks if needed

## Layout Component

```tsx
interface Props {
  children: React.ReactNode;
  sidebar: React.ReactNode;
}

export function PageLayout({ children, sidebar }: Props) {
  return (
    <div className={styles.page}>
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

For query patterns read the skill `dev-tanstack-query`.

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
    <PageLayout>
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

## Broad vs Deep Split

**Prefer Broad Split** -- one Container fans out to many Dumb Components directly, rather than passing props through a single proxy component (Deep Split). From Dan Abramov:

> "When you notice that some components don't use the props they receive but merely forward them down... it's a good time to introduce some container components."

## Anti-Patterns

- Component that imports and renders another component's styles
- Container with CSS classes beyond minor layout utilities
- Dumb Component that calls `useQuery` or accesses a store
- Hardcoded strings in a component when i18n exists
- Prop drilling through 3+ levels (introduce a Container or Partial or consider a higher level state or context)
