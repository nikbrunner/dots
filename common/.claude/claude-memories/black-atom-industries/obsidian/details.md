# Obsidian Adapter Details

## Core Theme Definition (what templates receive as `theme`)

- `theme.meta` — key, label, appearance ("dark"/"light"), collection
- `theme.primaries` — d10-d40, m10-m40, l10-l40 (oklch colors)
- `theme.palette` — 16 ANSI-style colors (black, red, green, yellow, blue, cyan, magenta, etc.)
- `theme.ui` — bg/fg semantic tokens (~16 each: default, hover, active, panel, float, accent, etc.)
- `theme.syntax` — per-category highlighting (comment, keyword, func, string, etc.)

## Default Collection Palette

- Default collection's `createPalette` maps most colors to primaries (grey tones)
- Only overridden accents (cyan/magenta) have chromatic values
- This is by design, not a bug

## Obsidian Base Color Scale

- Dark: `--color-base-00` (darkest/d10) → `--color-base-100` (lightest/l40)
- Light: `--color-base-00` (lightest/l40) → `--color-base-100` (darkest/d10)
- Template uses `theme.meta.appearance` to branch

## RGB Variants

- Obsidian uses `--color-*-rgb` format: `R, G, B` (no hex, no parens)
- Used in `rgba(var(--color-red-rgb), opacity)` patterns
- Template has inline `hexToRgb()` helper since core has no such utility
- Kept as defensive coverage even though not all are actively used
