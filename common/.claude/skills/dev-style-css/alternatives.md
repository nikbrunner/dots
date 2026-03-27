# CSS Framework Alternatives

No framework default yet. These are Nik's notes from exploration.

## Explored

### OpenProps

- **What:** CSS custom properties library — design tokens as native CSS variables
- **Status:** Liked it
- **Notes:** Feels like real CSS. Good defaults for colors, spacing, typography. Missing utility classes like Tailwind's `p-3` — but can build spacing utilities on top. Uncertain about long-term maintenance.
- **Docs:** https://open-props.style

### BEM

- **What:** Block-Element-Modifier naming convention
- **Status:** Respected, used extensively at DCD
- **Notes:** Solid pattern on its own. Redundant when combined with CSS Modules (scoping replaces the B and E). Still valid for SCSS projects without modules.

## Curious About

### Vanilla Extract

- **What:** TypeScript-first, zero-runtime stylesheets
- **Status:** Curious
- **Notes:** Write styles in `.css.ts` files, compiled to static CSS at build. Type-safe theming. The file extension paradigm (`.css.ts`) is a mental shift.
- **Docs:** https://vanilla-extract.style

### Panda CSS

- **What:** Type-safe CSS-in-JS that outputs static CSS at build time
- **Status:** Curious
- **Notes:** Similar mental model to Tailwind but with TypeScript type safety and zero runtime. Config-heavy setup. Reached 1.0.
- **Docs:** https://panda-css.com

## Tolerated

### Tailwind CSS

- **What:** Utility-first CSS framework
- **Status:** Accepted as industry default
- **Notes:** Wouldn't choose it for personal projects — feels like learning a new language. But adapts when a project uses it. Pairs well with CVA via `tailwind-merge`.
- **Docs:** https://tailwindcss.com

## Plain CSS + Custom Properties

- **What:** No framework, just native CSS with `var()` tokens
- **Status:** Current fallback default
- **Notes:** Full control, no dependencies. Build your own design tokens. More work upfront but no abstractions to fight.
