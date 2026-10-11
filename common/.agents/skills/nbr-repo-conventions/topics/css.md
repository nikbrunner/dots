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
