---
name: dev:typescript
description: "Nik's TypeScript conventions -- type safety, naming, function signatures. Load when working in any TypeScript project."
user-invocable: false
---

# TypeScript Conventions

## Type Safety

- `any` is forbidden -- use `unknown` as absolute last resort
- Generics and proper type annotations are valued and expected
- Explicit types for function signatures, implicit where inference is clear and unambiguous
- No temporal coupling -- never initialize to `null`/`undefined` and update later. Prefer clean initialization without circular dependencies.

## Code Style

- Clean, minimal, self-documenting code
- Clear variable and function names -- naming is documentation
- Remove unused code immediately, don't comment it out
- Standard APIs over custom wrappers -- don't abstract what doesn't need abstraction

## Function Design

- Prefer object arguments over positional parameters for functions with 2+ params
- Example: `function createUser({ name, email, role }: CreateUserParams)` over `function createUser(name: string, email: string, role: Role)`
- This makes call sites readable and parameter order irrelevant

## Anti-Patterns

- Init-to-null-then-update (temporal coupling)
- `as` type assertions to silence the compiler -- fix the types instead
- Overly clever type gymnastics when a simpler approach works
- `any` in any form -- function params, return types, generics, type assertions
