# Design: dev:styling Skill

## Summary

A skill capturing Nik's CSS/styling preferences, anchors, and explored alternatives. Not a prescriptive framework guide — reflects firm opinions (CSS Modules, CVA, co-location) alongside an evolving exploration of CSS frameworks.

## Anchors (firm defaults)

- **CSS Modules** for scoping — co-located `.css` files next to components
- **CVA** (Class Variance Authority) for typed component variants + `cx()` for class merging
- **Co-located file convention** — `Button.css` lives next to `Button.tsx`
- **Style components, not containers** — containers have no DOM styling (cross-ref with `dev:react`)
- **No runtime CSS-in-JS** — prefer zero-runtime or static approaches
- **Adapt to project** — if a project uses Tailwind/SCSS/whatever, adapt; defaults are for new personal projects

## Background

- SCSS + BEM at DCD/BikeCenter with custom `cn()` modifier function
- BEM is a respected pattern on its own but redundant when combined with CSS Modules
- Explored OpenProps (liked it, missed spacing utils, uncertain about maintenance)
- Tried ShadCN (liked own-your-code philosophy, disliked Tailwind lock-in)
- Tailwind accepted as industry default, wouldn't choose it but adapts when present

## No framework default yet

Nik is actively exploring. The skill should document what's been tried with honest notes, not prescribe a framework. Current candidates:

| Framework | Status | Notes |
|---|---|---|
| OpenProps | Explored, liked | Real CSS custom props, good defaults, missing utility classes |
| Vanilla Extract | Curious | TypeScript-first, zero runtime, `.css.ts` is a new paradigm |
| Panda CSS | Curious | Type-safe utilities, zero runtime, config-heavy |
| Tailwind | Tolerated | Industry default, accepted when project uses it |
| Plain CSS + custom props | Current default | Full control, no dependencies |

## Skill Structure

```
dev-styling/
├── SKILL.md               # Anchors, principles, decision logic, cross-refs
├── css-modules.md          # CSS Modules patterns, co-located file convention
├── utility-patterns.md     # CVA variants, cx() usage, modifier patterns
└── alternatives.md         # OpenProps, Vanilla Extract, Panda CSS, Tailwind, BEM
```

### SKILL.md sections

1. Default anchors (CSS Modules, CVA, co-location)
2. Principles (style components not containers, no runtime CSS-in-JS, adapt to project)
3. Co-located file convention with example
4. References to topic files
5. Cross-references to `dev:react`, `dev:planning`
6. Sources of Truth (MDN, CVA docs, CSS Modules spec)

### css-modules.md

- Scoped styles pattern
- File naming (`Component.module.css` vs `Component.css` — project convention)
- Import and usage pattern
- When plain CSS is sufficient vs. when Modules add value

### utility-patterns.md

- CVA for typed component variants with code examples
- `cx()` for conditional class composition
- Modifier pattern comparison (BEM `&--active` vs CVA variants vs data attributes)

### alternatives.md

- Each framework with: what it is, Nik's experience, honest status
- Not a recommendation engine — a reference for what's been explored

## Changes to Other Skills

### dev:react — new component-libraries.md

- Base UI as default headless primitive layer
- ShadCN as reference (copy-paste philosophy, migrating from Radix to Base UI)
- Mantine as alternative worth noting
- Cross-reference back to `dev:styling`

### dev:react — SKILL.md update

- Add cross-reference to `dev:styling` for styling conventions

### dev:planning — update

- Add note: "Styling approach should be decided during planning phase — see `dev:styling`"
