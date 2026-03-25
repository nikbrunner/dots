## Why

The visual companion's current option layout (side-by-side cards) cramps each mockup into half the viewport. Previews are too small to evaluate at the scale they'll actually be used — a tmux popup mockup shouldn't be thumbnailed to 300px wide. This makes design decisions harder and produces reference screenshots that future Claude instances may struggle to read.

## What Changes

- Redesign the frame template's option layout: stack options vertically, each taking full available screen width
- Add a fixed sidebar for option metadata (letter, title, description, pros/cons) that anchors while scrolling
- No scroll-spy needed — selection is explicit via sidebar button
- Add a "Select" button at the bottom of the sidebar (toggleable, overlays the design via z-index — no layout shift)
- Add a text input field in the sidebar for user feedback/notes — written to `.events` alongside the selection
- Sidebar is toggleable via a small floating button in the bottom-right corner (like TanStack DevTools). Default state: collapsed. Click to expand the sidebar overlay.
- Maintain `.events` file format — selection + user text are both captured
- CSS scroll-snap (`scroll-snap-type: y mandatory`) on the options container — scrolling snaps to each full-viewport option for a clean, intentional feel
- Update the `.options` and `.option` CSS classes in `frame-template.html`
- Keep backward compatibility — `.cards`, `.mockup`, `.split` classes stay unchanged

## Capabilities

### New Capabilities

- `vertical-option-layout`: Full-width stacked options with toggleable fixed sidebar (option metadata + select button + feedback text field)
- `viewport-responsive-mockups`: Mockups fill available width, enabling browser resize to simulate different viewport sizes (terminal widths, mobile, tablet)
- `user-feedback-capture`: Text input in sidebar captured to `.events` alongside selection, giving Claude written context for the next iteration

### Modified Capabilities

<!-- No existing specs — this is the first openspec change for visual companion -->

## Impact

- **Files affected**: `frame-template.html` (CSS + layout), `helper.js` (scroll-spy + selection logic)
- **Server**: No changes to `server.cjs` — layout is purely template-level
- **Skill**: `dev-visual-companion/SKILL.md` may need updated CSS class reference
- **Backward compat**: Existing `.cards`, `.mockup`, `.split` classes work as before. Only `.options` layout changes.

## Testing

1. Start companion server, push an HTML fragment with 3 `.option` items
2. Verify: options stack vertically, each fills viewport width
3. Verify: floating button visible in bottom-right corner (default: sidebar collapsed)
4. Click floating button → sidebar expands over design (no layout shift)
5. Scroll between options → sidebar shows correct option metadata
6. Type feedback in text field → click Select → verify `.events` contains both selection and text
7. Resize browser window → verify mockups adapt to new width
8. Verify: `.cards`, `.mockup`, `.split` classes still render correctly (backward compat)
