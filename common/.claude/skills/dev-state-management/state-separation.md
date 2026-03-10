# State Separation

## Server State vs Client State

| Aspect | Server State | Client State |
|-|-|-|
| **Source of truth** | Server/API | Client itself |
| **Can go stale?** | Yes | No |
| **Shared across users?** | Yes | No |
| **Tool** | TanStack Query | Redux Toolkit, Zustand, useState |
| **Examples** | User profiles, settings, lists | Modal open/closed, form drafts, UI preferences, toasts |

## The Migration Pattern

Before (everything in Redux):
```
Redux Store
├── users (fetched from API)        # server state misplaced
├── settings (fetched from API)     # server state misplaced
├── currentModal                    # actual client state
└── uiPreferences                   # actual client state
```

After (separated into two layers):
```
TanStack Query              Redux Toolkit (shrunk)
├── users                   ├── currentModal
├── settings                └── uiPreferences
```

After (separated into three layers with Router):
```
TanStack Query    TanStack Router (URL)    Redux Toolkit (minimal)
├── users         ├── filters              ├── currentModal
├── settings      ├── pagination           └── toastQueue
├── posts         ├── sortOrder
                  └── activeTab
```

Client state often shrinks to almost nothing.

## React Context as Scoped State

Context providers are natural state boundaries. When the provider unmounts, state resets automatically -- no cleanup logic needed.

```tsx
// Multi-step form wizard -- state resets when leaving the wizard
function WizardProvider({ children }: { children: React.ReactNode }) {
  const [step, setStep] = useState(0)
  const [formData, setFormData] = useState<Partial<FormData>>({})

  return (
    <WizardContext.Provider value={{ step, setStep, formData, setFormData }}>
      {children}
    </WizardContext.Provider>
  )
}

// When the user navigates away, WizardProvider unmounts → state gone
```

Use Context when:
- State is scoped to a subtree (not global)
- State should reset when the user leaves that area
- You don't want to manage cleanup/reset logic manually
