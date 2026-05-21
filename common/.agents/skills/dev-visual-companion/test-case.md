# Visual Companion Test Case

## Test Prompt

Copy this into a fresh Claude Code session in any project with a running UI:

```
I want to redesign the main navigation of this app. Can you help me explore some layout options visually?
```

## Expected Behavior

1. **Agent invokes visual-companion skill**
2. **Capture existing state** — asks for a screenshot or URL of the current navigation, or captures via chrome-devtools
3. **Server starts** — runs `start-server.sh`, provides URL to user
4. **Ask about target device** — "Is this for desktop, tablet, or phone?" Selects the matching preset in the companion header (Fluid, Phone 375×812, Tablet 768×1024, Desktop 1280×800)
5. **First mockup** — writes HTML fragment with 2-3 navigation layout options using `.options` + `.option` classes
6. **Iteration via Mode A** — blocks on `wait-for-decision.sh`, user selects option in browser, agent refines
7. **Finalize** — when design is locked, writes a focused screen file with just the selected option
8. **Export** — exports standalone HTML via `export.sh` and/or takes screenshot via chrome-devtools:
   - Standalone: `./scripts/export.sh "$SCREEN_DIR" final.html --standalone --output design/nav.html`
   - Screenshot: navigates to `/api/export?file=final.html&mode=screenshot&viewport=WxH`, captures with `chrome_devtools_take_screenshot(filePath, fullPage: true)`
9. **Server stops** — runs `stop-server.sh`

## Verification Checklist

- [ ] Companion server starts without errors
- [ ] Design frame device presets constrain width and height correctly
- [ ] Fluid mode shows design on paper-raised background with visible border
- [ ] Mockup renders in browser, click events captured in `.events`
- [ ] `wait-for-decision.sh` blocks and returns selection JSON
- [ ] `/api/export?file=X.html&mode=standalone` returns clean HTML with companion CSS, no frame chrome
- [ ] `/api/export?file=X.html&mode=screenshot&viewport=375x812` renders content at 375px wide
- [ ] Chrome-devtools fullPage screenshot captures design at correct dimensions (no browser chrome, no companion frame)
- [ ] Both standalone HTML and screenshot saved to `design/` directory
- [ ] Server stops cleanly

## Quick Smoke Test

Run from the project root. Creates a `design/` directory for exports.

```bash
SKILL_DIR="common/.agents/skills/dev-util-visual-companion"
SCRIPT_DIR="$SKILL_DIR/scripts"
mkdir -p design
```

### Part 1 — Start & iterate (multi-option with manual selection)

**Start the companion:**

```bash
$SCRIPT_DIR/start-server.sh --project-dir .
# Save the screen_dir from the JSON output
SCREEN_DIR="<paste-here>"
SERVER_URL="<paste-url-here>"
```

**Write a multi-option design:**

```bash
cat > "$SCREEN_DIR/nav-options.html" << 'EOF'
<h2>Navigation Layouts</h2>
<p class="subtitle">Pick an option below</p>
<div class="options">
  <div class="option" data-choice="a" data-title="Sidebar">
    <div class="option-mockup" style="display:flex;min-height:60vh;">
      <div class="mock-sidebar" style="min-width:200px;padding:1rem;display:flex;flex-direction:column;gap:0.5rem;">
        <div style="font-weight:600;margin-bottom:1rem;">Logo</div>
        <div style="padding:0.3rem 0.5rem;background:var(--blueprint);color:white;border-radius:4px;font-size:0.85rem;">Dashboard</div>
        <div style="padding:0.3rem 0.5rem;color:var(--ink-faded);font-size:0.85rem;">Projects</div>
        <div style="padding:0.3rem 0.5rem;color:var(--ink-faded);font-size:0.85rem;">Settings</div>
      </div>
      <div class="mock-content" style="flex:1;padding:1rem;">
        <div style="font-size:1.2rem;font-weight:600;margin-bottom:0.5rem;">Dashboard</div>
        <div class="cards" style="grid-template-columns:repeat(2,1fr);">
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">142</div><div style="font-size:0.75rem;color:var(--ink-faded);">Active tasks</div></div>
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">12</div><div style="font-size:0.75rem;color:var(--ink-faded);">Projects</div></div>
        </div>
      </div>
    </div>
  </div>
  <div class="option" data-choice="b" data-title="Top bar">
    <div class="option-mockup" style="min-height:60vh;">
      <div class="mock-nav" style="padding:0.75rem 1rem;display:flex;gap:1.5rem;font-size:0.9rem;">
        <span style="font-weight:600;">Logo</span>
        <span style="border-bottom:2px solid white;">Dashboard</span>
        <span style="opacity:0.7;">Projects</span>
        <span style="opacity:0.7;">Settings</span>
      </div>
      <div class="mock-content" style="padding:2rem;">
        <div style="font-size:1.2rem;font-weight:600;margin-bottom:0.5rem;">Dashboard</div>
        <div class="cards" style="grid-template-columns:repeat(3,1fr);">
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">142</div><div style="font-size:0.75rem;color:var(--ink-faded);">Tasks</div></div>
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">12</div><div style="font-size:0.75rem;color:var(--ink-faded);">Projects</div></div>
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">8</div><div style="font-size:0.75rem;color:var(--ink-faded);">Team</div></div>
        </div>
      </div>
    </div>
  </div>
  <div class="option" data-choice="c" data-title="Split">
    <div class="option-mockup" style="min-height:60vh;">
      <div class="mock-nav" style="padding:0.75rem 1rem;display:flex;gap:1.5rem;font-size:0.9rem;">
        <span style="font-weight:600;">Logo</span>
        <span style="border-bottom:2px solid white;">Dashboard</span>
        <span style="opacity:0.7;">Projects</span>
        <span style="opacity:0.7;">Settings</span>
      </div>
      <div style="display:flex;min-height:40vh;">
        <div class="mock-sidebar" style="min-width:180px;padding:1rem;display:flex;flex-direction:column;gap:0.3rem;">
          <div style="font-weight:600;margin-bottom:0.5rem;font-size:0.85rem;">Quick Nav</div>
          <div style="padding:0.2rem 0.5rem;font-size:0.8rem;color:var(--ink-faded);">Overview</div>
          <div style="padding:0.2rem 0.5rem;font-size:0.8rem;color:var(--ink-faded);">Recent</div>
          <div style="padding:0.2rem 0.5rem;font-size:0.8rem;color:var(--ink-faded);">Favorites</div>
        </div>
        <div class="mock-content" style="flex:1;padding:2rem;">
          <div style="font-size:1.2rem;font-weight:600;margin-bottom:0.5rem;">Dashboard</div>
          <div style="color:var(--ink-faded);font-size:0.85rem;">Split layout: top nav + sub-sidebar</div>
        </div>
      </div>
    </div>
  </div>
</div>
EOF
```

**Wait for manual selection:**

Open `$SERVER_URL` in a browser. You'll see three options (A: Sidebar, B: Top bar, C: Split). Scroll through them and click "Select" on your preferred one.

```bash
# Block until the user makes a selection in the browser
result=$($SCRIPT_DIR/wait-for-decision.sh "$SCREEN_DIR" --timeout 120)
echo "$result" | jq .
choice=$(echo "$result" | jq -r '.choice')
echo "Selected: $choice"
```

**Verify the selection was recorded:**

```bash
cat "$SCREEN_DIR/.events"
```

### Part 2 — Export

**Write a focused file with just the selected design:**

The agent would normally do this. For the smoke test, extract it from the full options file or write it manually based on the selection.

```bash
# Example: user picked sidebar (a)
cat > "$SCREEN_DIR/final-nav.html" << 'EOF'
<div class="section">
  <h2>Navigation — Sidebar Layout</h2>
  <p class="subtitle">Selected option</p>
  <div class="mockup">
    <div class="mockup-header">Final Design</div>
    <div class="mockup-body" style="display:flex;gap:1rem;min-height:300px;">
      <div class="mock-sidebar" style="min-width:200px;padding:1rem;display:flex;flex-direction:column;gap:0.5rem;">
        <div style="font-weight:600;margin-bottom:1rem;">Logo</div>
        <div style="padding:0.3rem 0.5rem;background:var(--blueprint);color:white;border-radius:4px;font-size:0.85rem;">Dashboard</div>
        <div style="padding:0.3rem 0.5rem;color:var(--ink-faded);font-size:0.85rem;">Projects</div>
        <div style="padding:0.3rem 0.5rem;color:var(--ink-faded);font-size:0.85rem;">Settings</div>
      </div>
      <div class="mock-content" style="flex:1;padding:1rem;">
        <div style="font-size:1.2rem;font-weight:600;margin-bottom:0.5rem;">Dashboard</div>
        <div class="cards" style="grid-template-columns:repeat(2,1fr);">
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">142</div><div style="font-size:0.75rem;color:var(--ink-faded);">Active tasks</div></div>
          <div class="card" style="padding:1rem;"><div style="font-weight:600;">12</div><div style="font-size:0.75rem;color:var(--ink-faded);">Projects</div></div>
        </div>
      </div>
    </div>
  </div>
</div>
EOF
```

**Export standalone HTML:**

```bash
$SCRIPT_DIR/export.sh "$SCREEN_DIR" final-nav.html --standalone --output design/nav-final.html
```

**Export screenshot via chrome-devtools:**

```
# In the agent session, navigate to the screenshot-ready export URL,
# resize the viewport to match the design frame, and capture:
#
# chrome_devtools_navigate_page(
#   url: "http://localhost:PORT/api/export?file=final-nav.html&mode=screenshot&viewport=375x812"
# )
# chrome_devtools_resize_page(width: 380, height: 900)
# chrome_devtools_take_screenshot(
#   filePath: "design/nav-final.png",
#   format: "png",
#   fullPage: true
# )
```

### Cleanup

```bash
$SCRIPT_DIR/stop-server.sh "$SCREEN_DIR"
```

The exported files are in `design/nav-final.html` and `design/nav-final.png`.
