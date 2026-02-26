---
name: react-patterns
description: Nik's React component patterns and TypeScript conventions. Load when working in React/TypeScript codebases.
user-invocable: false
---

# React Patterns

## Component Architecture

- **Dumb functional components** + **smart containers** + **partials**
- Components are independent — a component's CSS must never reference another component's classes
- If a component needs to know about another component, that's a code smell
- Styling should happen almost exclusively in components, containers and other consumers of the component should only use some styling if absolutely necessary. This implies the uses of layout components and partials.

## TypeScript Conventions

- Avoid `any` at all costs — use `unknown` as last resort
- Use explicit and implicit types where each makes sense — not absolutist
- Prefer object arguments for functions over positional parameters
- Use clear variable and function names
- Remove unused code as you go
- Values generics and proper type annotations

## Anti-Patterns

- **No temporal coupling** — never init to null/any and update later. Prefer clean initialization without circular dependencies. Order-of-operations dependencies are a maintenance nightmare.
