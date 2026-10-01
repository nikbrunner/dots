# Component Libraries

Headless (unstyled) primitives for accessible, composable UI. Separate concern from styling — these provide behavior and accessibility, you bring the CSS.

## Default: Base UI

- **What:** Headless component library from the MUI team
- **Status:** Preferred default for new projects
- **Why:** Unstyled, accessible, composable. Pairs with any CSS approach (CSS Modules, Tailwind, plain CSS). ShadCN is migrating from Radix to Base UI.
- **Docs:** (Sources of Truth)
  - https://base-ui.com
  - https://base-ui.com/llms.txt

## References

### ShadCN/UI

- **What:** Copy-paste component collection built on headless primitives
- **Status:** Tried it, liked the philosophy
- **Notes:** "Own your components" approach — copies code into your project, not a dependency. Currently Tailwind-locked. Migrating from Radix to Base UI.
- **Docs:** https://ui.shadcn.com

### Mantine

- **What:** Full-featured React component library with built-in styling
- **Status:** Heard good things, not tried yet
- **Notes:** More opinionated / batteries-included than headless approach. Worth evaluating for projects that need speed over customization.
- **Docs:** https://mantine.dev
