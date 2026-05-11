---
name: BAI Website Design System
description: Design system tokens, fonts, and visual identity implemented in the website. Source of truth for all styling decisions.
type: project
originSessionId: 13b2949e-ec14-4867-b875-c8f03bf32020
---

The website now uses the full Black Atom Industries brand design system, implemented from the claude.ai/design handoff bundle.

**Why:** Redesigned from an earlier brutalist/Open Props layout to match the official BAI identity.

**How to apply:** All future UI work on this site should follow the design system strictly.

## Colors (monochrome only)

- `--ink: #0a0a0a` — all foreground, strokes, marks
- `--paper: #f4f1ea` — all backgrounds
- Opacity scale: `--ink-05` through `--ink-90` (rgba)
- No accent colors, no gradients

## Typography

- **Display:** `Archivo Black` (400) — all caps, -0.01em tracking. Google Fonts.
- **Mono:** `JetBrains Mono` (400–700) — body, labels, UI, code. Google Fonts.
- No other typefaces permitted.

## Brand Mark

- **Sunburst** — primary mark. 96 rays, 1px hairlines, core ~9% radius. Hero/nav scale.
- Implemented as `SunburstMark.tsx` — pure React SVG, parametric (size, rays, coreRatio).
- Nav uses: size=28, rays=48, coreRatio=0.18
- Hero uses: size=320, rays=96, coreRatio=0.09

## Component Files

- `Nav.tsx` — top navigation with sunburst mark + links
- `Hero.tsx` — hero section with large sunburst + wordmark
- `Section.tsx` — § marker + Archivo Black heading + content
- `StatusBadge.tsx` — label + bordered value chip
- `PlatformLink.tsx` — uppercase name + → arrow, border-bottom
- `ResourceCard.tsx` — bordered card with label/title/url
- `SunburstMark.tsx` — parametric SVG sunburst

## Rules

- All strokes 1px, corners always squared (border-radius: 0)
- No rounded corners anywhere
- Copy style: ALL CAPS headlines, sentence case body, no emoji
