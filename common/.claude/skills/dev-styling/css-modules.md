# CSS Modules

## When to Use

- Default for any component with more than trivial styling
- When you need scoped class names without BEM naming overhead
- Works with any CSS framework (OpenProps, plain custom properties, etc.)

## Basic Pattern

```css
/* Button.module.css */
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
