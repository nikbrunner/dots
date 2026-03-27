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
