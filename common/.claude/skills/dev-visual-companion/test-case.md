# Visual Companion Test Case

## Test Prompt

Copy this into a fresh Claude Code session in any project with a running UI:

```
I want to redesign the main navigation of this app. Can you help me explore some layout options visually?
```

## Expected Behavior

1. **Claude invokes dev:brainstorm** (or dev:start → routes to brainstorm)
2. **Brainstorm offers visual companion** — "Some of this might be easier to show visually..."
3. **User accepts** → Claude invokes dev:visual-companion
4. **Tool detection** — Claude checks for Stitch MCP, offers if available
5. **Capture existing state** — Claude asks for a screenshot or URL of the current navigation, or captures it via agent-browser/screencapture
6. **Server starts** — Claude runs start-server.sh, provides URL
7. **First mockup** — Claude writes HTML fragment with 2-3 navigation layout options using `.options` + `.option` classes
8. **User selects** — clicks option in browser, Claude reads `.events`
9. **Iteration** — Claude refines based on selection, writes new file
10. **Export** — When design is locked, Claude writes full HTML document, captures clean screenshot, saves to `design/`
11. **Server stops** — Claude runs stop-server.sh

## Verification Checklist

- [ ] Visual companion server starts without errors
- [ ] Mockup renders in browser at the provided URL
- [ ] Click events are captured in `.events` file
- [ ] Clean export is a full HTML page (no companion chrome)
- [ ] Screenshot is saved to `design/` directory
- [ ] Server stops cleanly

## Quick Smoke Test

To verify the server works without a full session:

```bash
# Start server
~/.claude/skills/dev-visual-companion/scripts/start-server.sh --project-dir /tmp/test-companion

# Write a test mockup (use the screen_dir from the JSON output)
cat > <SCREEN_DIR>/test.html << 'EOF'
<h2>Pick a layout</h2>
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content"><h3>Sidebar</h3><p>Navigation in a left sidebar</p></div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content"><h3>Top bar</h3><p>Horizontal navigation at the top</p></div>
  </div>
</div>
EOF

# Open in browser, click an option, then check:
cat <SCREEN_DIR>/.events

# Stop
~/.claude/skills/dev-visual-companion/scripts/stop-server.sh <SCREEN_DIR>
```
