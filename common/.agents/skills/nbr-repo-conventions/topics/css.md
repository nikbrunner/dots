# CSS

## Anchors (firm defaults)

| Anchor               | What                                     | Why                                           |
| -------------------- | ---------------------------------------- | --------------------------------------------- |
| **CSS Modules**      | Scoped `.module.css` or `.css` files     | Real CSS, zero runtime, local scope           |
| **CVA**              | Typed component variants                 | Type-safe variants + `cx()` for class merging |
| **Co-located files** | `button.module.css` next to `button.tsx` | Styles belong to their component              |

## Principles

- **Style components, not containers** -- containers orchestrate, components own their appearance
- **No runtime CSS-in-JS** -- prefer zero-runtime or static approaches
- **Adapt to project** -- if a project uses Tailwind/SCSS/other, adapt; anchors are for new personal projects
- **No CSS framework default yet** -- actively exploring, see `css/alternatives.md`

## Authoring

- CSS Modules with native nesting: states, pseudo-elements, and child selectors nest under the root. No Sass for ordinary
  component styles.
- Repeated values become custom properties, especially when a state or variant changes several descendants. Structurally
  different rules stay explicit.
- A component has no outer margin. The parent sets the distance between children with a flex or grid `gap`; a margin inside
  a gap adds to it instead of collapsing.
- Override a component through its own class, a wrapper, or its documented state attributes. Generated CSS Module class
  names are never targeted, and `!important` never fights the cascade.
- CSS the project's browser floor lacks, such as relative color syntax `oklch(from …)`, gets an `@supports` guard with a
  fallback.

## Class Names

- CVA maps variant props to CSS Module references, never string class names. No `clsx`, `tailwind-merge`, or local `cn`.
- A boolean axis is `{ false: null, true: classes.axisOn }`. Defaults sit in the function's destructuring.
- A component that accepts `className` merges it through CVA's `className` slot, or `cx` without CVA. A closed component
  omits `className` instead of accepting and ignoring it.
- Components sharing the same variant axes put their CVA call in a `{name}.cva.ts` next to them.

See `css/utility-patterns.md` for the CVA and `cx()` patterns.

## Co-Located File Convention

```
components/
├── button/
│   ├── button.tsx
│   ├── button.module.css
│   ├── button.stories.tsx
│   └── index.ts
```

Style file lives next to the component, same name. See the `react` topic, `react/folder-structure.md` for full conventions.

## Background

- SCSS + BEM at DCD/BikeCenter with custom `cn()` modifier function
- BEM is a solid pattern on its own but redundant when combined with CSS Modules (scoping is built in)

## References

- For CSS Modules patterns, see `css/css-modules.md`
- For CVA and class merging patterns, see `css/utility-patterns.md`
- For CSS framework alternatives explored, see `css/alternatives.md`

## Cross-References

- the `react` topic -- component architecture (style components, not containers)
- the `react` topic, `react/component-libraries.md` -- headless UI primitives (Base UI)

## Sources of Truth

- **MDN CSS Reference**: https://developer.mozilla.org/en-US/docs/Web/CSS
- **CSS Modules spec**: https://github.com/css-modules/css-modules
- **CVA docs**: https://cva.style
- **OpenProps docs**: https://open-props.style
