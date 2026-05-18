---
name: dev-util-visual-companion
description: "Browser-based visual companion for design brainstorming — capture existing UI, iterate on mockups, export clean references. Use when design questions need visual answers."
user-invocable: true
metadata:
  user-invocable: true
---

# Visual Companion

Browser-based companion for visual design discussions. Supports the full loop: capture existing state -> iterate on mockups -> export clean reference for implementation.

## When to Use

Decide per-question, not per-session. The test: **would the user understand this better by seeing it than reading it?**

**Use the browser** for visual content: UI mockups, wireframes, layout comparisons, architecture diagrams, spatial relationships.

**Use the terminal** for text content: requirements, conceptual choices, tradeoff lists, technical decisions.

## Tool Detection

Before starting, check which visual tools are available:

1. **chrome-devtools MCP** — Primary tool for navigating URLs and capturing screenshots of web content.
2. **screencapture** (macOS) — For capturing TUI/desktop apps.
3. **HTML fallback** — Write HTML fragments directly to the companion server.

## The Flow

### Phase 1: Capture Current State

For redesign work, establish what exists before generating mockups:

- **Web app running locally** -> Navigate with `chrome_devtools_navigate_page`, capture with `chrome_devtools_take_screenshot`.
- **TUI/desktop app** -> `screencapture -w /tmp/current-state.png` (window capture). Read the screenshot.
- **User provides** -> Ask for a screenshot path or have them drag-drop.
- **Greenfield** -> Skip this phase.

### Phase 2: Start Companion Server

```bash
${CLAUDE_SKILL_DIR}/scripts/start-server.sh --project-dir $CWD
```

Returns JSON with `url` and `screen_dir`. Tell the user to open the URL.

### Phase 3: Iterate

Has two modes for collecting user feedback:

**Mode A — Blocking (Plannotator-style, preferred):** Write HTML → block on `wait-for-decision.sh` → get selection back in the same turn. No terminal typing needed from the user.

**Mode B — Turn-based (original):** Write HTML → tell user → they respond in terminal → read `.events` on next turn.

#### Mode A: Blocking Wait

1. **Set the design frame.** Before writing any screens, ask the user:

   > "Is this for desktop, tablet, or phone?"
   > → Select the matching preset in the companion header (Fluid, Phone 375×812, Tablet 768×1024, Desktop 1280×800).
   > → The design frame constrains the viewport so the design renders at the target device size.

2. **Write HTML fragment** to `$SCREEN_DIR/<name>.html`
   - Semantic filenames: `layout.html`, `sidebar-options.html`
   - Never reuse filenames — each screen is a new file
   - Fragments only — server wraps in frame template
   - Server auto-serves the newest file

3. **Block on selection:**

   ```bash
   result=$(scripts/wait-for-decision.sh "$SCREEN_DIR" --timeout 300)
   choice=$(echo "$result" | jq -r '.choice')
   feedback=$(echo "$result" | jq -r '.feedback // empty')
   ```

   This long-polls `/api/wait` on the companion server. The script blocks until the user clicks "Select" in the browser (or the timeout expires).

4. **Process the selection** — `$choice` is the `data-choice` value (e.g. `"A"`, `"B"`), `$feedback` is any notes the user typed in the sidebar textarea.

5. **Iterate** — `layout-v2.html` for revisions, then call `wait-for-decision.sh` again. Reset happens automatically per new screen file.

#### Mode B: Turn-based (fallback)

1. **Write HTML fragment** to `$SCREEN_DIR/<name>.html`
2. **Tell the user** what's on screen, remind them of the URL, end your turn.
3. **On next turn** — read `$SCREEN_DIR/.events` for click selections. Merge with terminal feedback.
4. **Iterate** — `layout-v2.html` for revisions, advance when validated.

### Phase 4: Export Clean Reference

The companion has two export modes that work with any screen file (not just `final-*`):

| Mode         | Description                                                                                                          |
| ------------ | -------------------------------------------------------------------------------------------------------------------- |
| `standalone` | Self-contained HTML — all design styles, no companion frame. Save as reference or starting point for implementation. |
| `screenshot` | Same as standalone but viewport-optimized for clean screenshots (fills the window, no dead space).                   |

Both modes accept an optional `&viewport=WxH` parameter (e.g. `&viewport=375x812`) that renders the content inside a constrained design frame at the target device dimensions. Without it, the design renders full width.

#### Via API (inline in agent workflow)

```bash
# Fetch standalone HTML and save to project
curl -s "${VC_URL}/api/export?file=layout-v3.html&mode=standalone" > design/layout-v3.html

# Capture screenshot via chrome-devtools MCP
#   chrome_devtools_navigate_page(url: "${VC_URL}/api/export?file=layout-v3.html&mode=screenshot")
#   chrome_devtools_take_screenshot(filePath: "design/layout-v3.png", fullPage: true)
```

The export URL renders:

- All companion CSS (typography, cards, mockups, options, etc.)
- No header, indicator bar, toggle button, or dialog
- Clean paper/grid background
- Design content only

#### Via CLI script

```bash
# Export any screen file as standalone HTML
${CLAUDE_SKILL_DIR}/scripts/export.sh "$SCREEN_DIR" layout-v3.html --standalone --output design/layout-v3.html

# Print the screenshot-ready URL (then capture with chrome-devtools)
${CLAUDE_SKILL_DIR}/scripts/export.sh "$SCREEN_DIR" final-layout.html --screenshot --open
```

#### Standard workflow

**Ask before saving.** The default is `design/` at project root, but confirm with the user first.

1. Save the design as a screen file (any name — doesn't have to be `final-*`):
   - Fragment: automatically wrapped with all companion CSS on export
   - Full document (`<!DOCTYPE html>`): served as-is

2. Ask the user where to save exports. Suggested default: `design/` in the repo root.

3. **Decide screenshot approach based on page type:**

   **Single design page** (layout, dashboard, final mockup, no `.option[data-choice]`):
   → Export the screen file directly with `fullPage: true`. The entire design is the intended output.

   **Multi-option page after user selected one** (has `.option[data-choice]` elements):
   → **Write a focused screen file** containing just the selected design first. `fullPage` on the original file would capture all options (including rejected ones), which is useless for documentation. A focused file gives a clean, targeted export.

   ```bash
   # After user picks option B: write a focused file with just that design
   cat > "$SCREEN_DIR/selected-option-b.html" << 'EOF'
   <div class="section">
     <h2>Selected: Option B</h2>
     ...only the chosen design...
   </div>
   EOF
   # Then export the focused file
   ```

4. **Include the design frame viewport in the export URL** — append `&viewport=WxH` matching the device preset selected earlier. This renders the content inside a constrained `#vc-design-frame` at exactly the target device dimensions. Without it, the design renders at full width.

5. Export as standalone HTML and/or screenshot:

   ```bash
   # Export HTML for coding reference (no viewport — full width)
   ${CLAUDE_SKILL_DIR}/scripts/export.sh "$SCREEN_DIR" selected-option-b.html --standalone --output design/option-b.html

   # Export screenshot via chrome-devtools MCP —
   # The design frame is the source of truth for dimensions.
   # The browser viewport must match it so the capture is exactly the design size:
   #
   #   1. chrome_devtools_navigate_page(
   #        url: "http://localhost:PORT/api/export?file=selected-option-b.html&mode=screenshot&viewport=375x812"
   #      )
   #   2. chrome_devtools_resize_page(
   #        width: <design-frame-width + small-padding>,
   #        height: <tall-enough-for-content>
   #      )
   #   3. chrome_devtools_take_screenshot(
   #        filePath: "design/option-b.png",
   #        format: "png",
   #        fullPage: true
   #      )
   ```

   **Why resize the viewport?** chrome-devtools `fullPage: true` captures at the browser viewport width — that's how the tool works. Resizing the viewport to match the design frame (e.g., 380px for a 375px-wide design) is the correct workflow: it sets the capture canvas to the design dimensions. No different from switching to device mode in browser DevTools.

   **Why fullPage:** Ensures all content is captured vertically, even if the design is taller than the viewport.

6. Create `design/` at project root if it doesn't exist

7. Reference from spec/proposal: `![Selected option](../../design/option-b.png)`

### Phase 5: Stop Server

```bash
${CLAUDE_SKILL_DIR}/scripts/stop-server.sh $SCREEN_DIR
```

## CSS Classes Available

See [visual-companion.md](visual-companion.md) for full CSS reference including:

- `.options` + `.option` — A/B/C clickable choices
- `.cards` + `.card` — visual design comparisons
- `.mockup` — wireframe container with header
- `.split` — side-by-side layout
- `.pros-cons` — pro/con columns
- Mock elements: `.mock-nav`, `.mock-sidebar`, `.mock-content`, `.mock-button`

## Integration with dev:flow start

When visual questions come up during brainstorming:

1. Offer the companion: "Some of this might be easier to show visually. Want me to start the visual companion?"
2. If accepted, follow the flow above
3. Per question, decide browser vs terminal
4. Export clean reference when design is locked
5. Stop server when brainstorming is done

## Test Case

See [test-case.md](test-case.md) for a ready-to-use test prompt and expected behavior.
