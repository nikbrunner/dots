# dev:styling Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create the `dev:styling` skill and update cross-references in `dev:react` and `dev:planning`.

**Architecture:** New skill directory `dev-styling/` with 4 files following existing skill conventions. Plus updates to 3 existing files and 1 new file in `dev-react/`.

**Tech Stack:** Markdown skill files

---

### Task 1: Create dev-styling/SKILL.md

**Files:**

- Create: `common/.claude/skills/dev-styling/SKILL.md`

**Step 1: Create the file**

```markdown
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
│ ├── Button.tsx
│ ├── Button.css
│ └── Button.stories.tsx

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

To ensure best practices, always verify patterns against these references before implementation. Use Ref MCP to look up specific topics.

- **MDN CSS Reference**: https://developer.mozilla.org/en-US/docs/Web/CSS
- **CSS Modules spec**: https://github.com/css-modules/css-modules
- **CVA docs**: https://cva.style
- **OpenProps docs**: https://open-props.style
```

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-styling/SKILL.md
git commit -m "feat(skills): add dev:styling SKILL.md with anchors and principles"
```

---

### Task 2: Create dev-styling/css-modules.md

**Files:**

- Create: `common/.claude/skills/dev-styling/css-modules.md`

**Step 1: Create the file**

````markdown
# CSS Modules

## When to Use

- Default for any component with more than trivial styling
- When you need scoped class names without BEM naming overhead
- Works with any CSS framework (OpenProps, plain custom properties, etc.)

## Basic Pattern

```tsx
// Button.module.css
.root {
  padding: 0.5rem 1rem;
  border-radius: 4px;
  border: none;
  cursor: pointer;
}

.primary {
  background: var(--color-primary);
  color: white;
}
```
````

```tsx
// Button.tsx
import styles from "./Button.module.css";
import { cx } from "class-variance-authority";

interface Props {
  variant?: "primary" | "secondary";
  children: React.ReactNode;
}

export function Button({ variant = "primary", children }: Props) {
  return (
    <button className={cx(styles.root, styles[variant])}>{children}</button>
  );
}
```

## When Plain CSS Is Enough

- Global resets, font imports, CSS custom property definitions
- Single-use pages with no reusable components
- Very small projects where scoping adds no value

## File Naming

Convention depends on the project setup:

- `.module.css` -- explicit CSS Modules (Vite, Next.js default)
- `.css` with build tool configured for modules -- less common but valid

Be consistent within a project.

````

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-styling/css-modules.md
git commit -m "feat(skills): add css-modules patterns to dev:styling"
````

---

### Task 3: Create dev-styling/utility-patterns.md

**Files:**

- Create: `common/.claude/skills/dev-styling/utility-patterns.md`

**Step 1: Create the file**

````markdown
# Utility Patterns

## CVA — Class Variance Authority

Type-safe component variants. Works with CSS Modules, Tailwind, or plain classes.

```tsx
import { cva, cx, type VariantProps } from "class-variance-authority";
import styles from "./Button.module.css";

const buttonVariants = cva(styles.root, {
  variants: {
    variant: {
      primary: styles.primary,
      secondary: styles.secondary,
      ghost: styles.ghost,
    },
    size: {
      sm: styles.sm,
      md: styles.md,
      lg: styles.lg,
    },
  },
  defaultVariants: {
    variant: "primary",
    size: "md",
  },
});

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof buttonVariants> & {
    children: React.ReactNode;
  };

export function Button({
  variant,
  size,
  className,
  children,
  ...props
}: Props) {
  return (
    <button
      className={cx(buttonVariants({ variant, size }), className)}
      {...props}
    >
      {children}
    </button>
  );
}
```
````

## cx() — Class Merging

CVA exports `cx()` for conditional class composition. No need for a separate `clsx` or `classnames` dependency.

```tsx
import { cx } from "class-variance-authority";

cx(styles.root, isActive && styles.active, className);
```

## Modifier Patterns Compared

| Approach              | Example                                       | When                                |
| --------------------- | --------------------------------------------- | ----------------------------------- |
| **CVA variants**      | `variant: { primary: styles.primary }`        | Component has well-defined variants |
| **cx() conditionals** | `cx(styles.root, isOpen && styles.open)`      | Toggle based on state               |
| **Data attributes**   | `data-active={isActive}` + `[data-active] {}` | CSS-only state styling              |
| **BEM modifiers**     | `.block--active {}`                           | SCSS projects without CSS Modules   |

Prefer CVA variants for component APIs. Use `cx()` for internal state toggles. Data attributes work well for CSS-only interactivity.

````

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-styling/utility-patterns.md
git commit -m "feat(skills): add CVA and utility patterns to dev:styling"
````

---

### Task 4: Create dev-styling/alternatives.md

**Files:**

- Create: `common/.claude/skills/dev-styling/alternatives.md`

**Step 1: Create the file**

```markdown
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
```

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-styling/alternatives.md
git commit -m "feat(skills): add CSS alternatives reference to dev:styling"
```

---

### Task 5: Create dev-react/component-libraries.md

**Files:**

- Create: `common/.claude/skills/dev-react/component-libraries.md`

**Step 1: Create the file**

```markdown
# Component Libraries

Headless (unstyled) primitives for accessible, composable UI. Separate concern from styling — these provide behavior and accessibility, you bring the CSS.

## Default: Base UI

- **What:** Headless component library from the MUI team
- **Status:** Preferred default for new projects
- **Why:** Unstyled, accessible, composable. Pairs with any CSS approach (CSS Modules, Tailwind, plain CSS). ShadCN is migrating from Radix to Base UI.
- **Docs:** https://base-ui.com

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
```

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-react/component-libraries.md
git commit -m "feat(skills): add component-libraries reference to dev:react"
```

---

### Task 6: Update dev-react/SKILL.md cross-references

**Files:**

- Modify: `common/.claude/skills/dev-react/SKILL.md:37-39` (References section)

**Step 1: Add cross-references**

Add to the References section:

```markdown
- For component library choices (Base UI, ShadCN, Mantine), see `component-libraries.md`
- For styling conventions and CSS approach, see skill `dev:styling`
```

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-react/SKILL.md
git commit -m "chore(skills): add styling and component library cross-refs to dev:react"
```

---

### Task 7: Update dev-planning/SKILL.md cross-references

**Files:**

- Modify: `common/.claude/skills/dev-planning/SKILL.md:40-43` (References section)

**Step 1: Add to References section**

Add:

```markdown
- For styling approach decisions, see skill `dev:styling`
```

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-planning/SKILL.md
git commit -m "chore(skills): add styling cross-ref to dev:planning"
```

---

### Task 8: Update dev-react/folder-structure.md

**Files:**

- Modify: `common/.claude/skills/dev-react/folder-structure.md:17-25` (Multi-File Components)

**Step 1: Update the component file example to use consistent naming**

Update the multi-file component example to use `Button.css` naming (matching `dev:styling` co-location convention) instead of generic `style.css`:

```markdown
## Multi-File Components

When a component has multiple associated files, group them in a folder:
```

components/
├── button/
│ ├── index.tsx # Exports the component
│ ├── button.css # Component styles (see dev:styling)
│ └── stories.tsx # Storybook stories

```

```

**Step 2: Commit**

```bash
git add common/.claude/skills/dev-react/folder-structure.md
git commit -m "chore(skills): align folder-structure style file naming with dev:styling"
```

---

### Task 9: Update skills README TODO

**Files:**

- Modify: `common/.claude/skills/README.md:18` (Skills to create section)

**Step 1: Mark dev-styling as done**

Change `- [ ] **dev-styling**` to `- [x] **dev-styling**`

**Step 2: Commit**

```bash
git add common/.claude/skills/README.md
git commit -m "chore(skills): mark dev-styling as complete in README"
```
