---
name: dev:typescript
description: "Nik's TypeScript conventions -- type safety, naming, function signatures. Load when working in any TypeScript project."
user-invocable: false
---

# TypeScript Conventions

## Type Safety

- `any` is forbidden -- use `unknown` as absolute last resort
- Generics and proper type annotations are valued and expected
- Lean on inference -- let TypeScript do the work when it's clear and unambiguous
- No temporal coupling -- never initialize to `null`/`undefined` and update later

## Type Derivation

Prefer deriving types from runtime values over defining them separately. Single source of truth.

- `as const` arrays → derive union type: `typeof keys[number]`
- `as const satisfies T` for validated constant objects that retain literal types
- `Record<UnionType, ...>` to ensure exhaustiveness -- compiler complains when keys change
- Zod schemas → `z.infer<typeof schema>` for runtime-validated types
- Interfaces for object contracts, type aliases for unions and computed types

```tsx
// Single source of truth: array → union type
const themeKeys = ["dark", "light", "dimmed"] as const;
type ThemeKey = typeof themeKeys[number];

// Validated constant with literal types preserved
const metaMap = { /* ... */ } as const satisfies Record<ThemeKey, ThemeMeta>;

// Exhaustive record -- breaks if ThemeKey changes
const labels: Record<ThemeKey, string> = {
  dark: "Dark Mode",
  light: "Light Mode",
  dimmed: "Dimmed",
};
```

## Function Design

- 1-2 positional args are fine: `useNav("/settings", { ...options })`
- 3+ parameters → object argument with destructuring
- Never more than 2 positional parameters

## Code Style

- Clean, minimal, self-documenting code
- Clear variable and function names -- naming is documentation
- Remove unused code immediately, don't comment it out
- Standard APIs over custom wrappers -- don't abstract what doesn't need abstraction
- Composition over classes -- prefer pure functions + object literals
- Pure functions for testability -- isolate logic from side effects
- Creator functions (`createPalette`, `createUser`) over constructors

## Anti-Patterns

- Init-to-null-then-update (temporal coupling)
- `as` type assertions to silence the compiler -- fix the types instead
- Overly clever type gymnastics when a simpler approach works
- `any` in any form -- function params, return types, generics, type assertions
- Classes when a function + object literal works
- Duplicating types that could be derived from a single source

## Sources of Truth

- **TypeScript Handbook**: https://www.typescriptlang.org/docs/handbook/
- **TypeScript Release Notes**: https://devblogs.microsoft.com/typescript/
- **Matt Pocock / Total TypeScript**: https://www.totaltypescript.com/
