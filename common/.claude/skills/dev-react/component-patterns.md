# Component Patterns

## Dumb Component

```tsx
interface UserCardProps {
  name: string;
  avatarUrl: string;
  role: string;
  onEdit: () => void;
}

function UserCard({ name, avatarUrl, role, onEdit }: UserCardProps) {
  return (
    <div className={styles.card}>
      <img src={avatarUrl} alt={name} className={styles.avatar} />
      <h3>{name}</h3>
      <span>{role}</span>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}
```

- Receives only props (data + callbacks)
- All styling is here
- No app dependencies, no store access, no fetching
- Rarely has own state -- when it does, it's pure UI state (hover, open/closed)

## Smart Container

```tsx
function UserProfileContainer() {
  const { query: userQuery, permissions } = useUserProfile();
  const { mutate: updateUser } = useUpdateUser();

  if (userQuery.isPending) return <LoadingSpinner />;
  if (userQuery.isError) return <ErrorDisplay error={userQuery.error} />;

  const user = userQuery.data;

  return (
    <PageLayout>
      <UserProfileHeader
        name={user.name}
        avatarUrl={user.avatar}
        canEdit={permissions.canEdit}
        onEdit={() => updateUser(user.id)}
      />
      <ActivityFeedPartial userId={user.id} />
    </PageLayout>
  );
}
```

- No DOM styling (small layout utility classes are acceptable)
- Provides data and callbacks to children
- Named `*Container` by convention
- Orchestrates -- delegates logic to topic hooks

## Partial

```tsx
function UserProfileHeader({
  name,
  avatarUrl,
  canEdit,
  onEdit,
}: UserProfileHeaderProps) {
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
function PageLayout({ children, sidebar }: PageLayoutProps) {
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

## Broad vs Deep Split

**Prefer Broad Split** -- one Container fans out to many Dumb Components directly, rather than passing props through a single proxy component (Deep Split). From Dan Abramov:

> "When you notice that some components don't use the props they receive but merely forward them down... it's a good time to introduce some container components."

## Anti-Patterns

- Component that imports and renders another component's styles
- Container with CSS classes beyond minor layout utilities
- Dumb Component that calls `useQuery` or accesses a store
- Hardcoded strings in a component when i18n exists
- Prop drilling through 3+ levels (introduce a Container or Partial)
