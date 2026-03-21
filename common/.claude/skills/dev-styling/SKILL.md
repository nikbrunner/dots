---
name: dev:styling
description: "Nik's CSS/styling preferences -- defaults, anchors, and explored alternatives. Load when working on styling in web projects."
user-invocable: false
---

# Styling

## Anchors (firm defaults)

| Anchor               | What                                 | Why                                           |
| -------------------- | ------------------------------------ | --------------------------------------------- |
| **CSS Modules**      | Scoped `.module.css` or `.css` files | Real CSS, zero runtime, local scope           |
| **CVA**              | Typed component variants             | Type-safe variants + `cx()` for class merging |
| **Co-located files** | `Button.css` next to `Button.tsx`    | Styles belong to their component              |

## Principles

- **Style components, not containers** -- containers orchestrate, components own their appearance
- **No runtime CSS-in-JS** -- prefer zero-runtime or static approaches
- **Adapt to project** -- if a project uses Tailwind/SCSS/other, adapt; anchors are for new personal projects
- **No CSS framework default yet** -- actively exploring, see `alternatives.md`

## Co-Located File Convention

```
components/
├── Button/
│   ├── Button.tsx
│   ├── Button.css
│   └── Button.stories.tsx
```

Style file lives next to the component, same name. See `dev:react` → `folder-structure.md` for full conventions.

## Background

- SCSS + BEM at DCD/BikeCenter with custom `cn()` modifier function
- BEM is a solid pattern on its own but redundant when combined with CSS Modules (scoping is built in)

## References

- For CSS Modules patterns, see `css-modules.md`
- For CVA and class merging patterns, see `utility-patterns.md`
- For CSS framework alternatives explored, see `alternatives.md`

## Cross-References

- `dev:react` -- component architecture (style components, not containers)
- `dev:react` → `component-libraries.md` -- headless UI primitives (Base UI)
- `dev:planning` -- styling approach should be decided during planning phase

## Sources of Truth

- **MDN CSS Reference**: https://developer.mozilla.org/en-US/docs/Web/CSS
- **CSS Modules spec**: https://github.com/css-modules/css-modules
- **CVA docs**: https://cva.style
- **OpenProps docs**: https://open-props.style
