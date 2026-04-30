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

Before starting, check which visual tools are available and OFFER them:

1. **Stitch MCP** — Check if `stitch` is a connected MCP server. If available, MUST OFFER for mockup generation — it produces higher-fidelity output. The user decides whether to use it.
2. **agent-browser** — For navigating URLs and capturing screenshots of web apps.
3. **screencapture** (macOS) — For capturing TUI/desktop apps.
4. **HTML fallback** — Write HTML fragments directly to the companion server.

## The Flow

### Phase 1: Capture Current State

For redesign work, establish what exists before generating mockups:

- **Web app running locally** -> `agent-browser navigate <url>` then `agent-browser screenshot /tmp/current-state.png`. Read the screenshot.
- **TUI/desktop app** -> `screencapture -w /tmp/current-state.png` (window capture). Read the screenshot.
- **User provides** -> Ask for a screenshot path or have them drag-drop.
- **Greenfield** -> Skip this phase.

### Phase 2: Start Companion Server

```bash
${CLAUDE_SKILL_DIR}/scripts/start-server.sh --project-dir $CWD
```

Returns JSON with `url` and `screen_dir`. Tell the user to open the URL.

### Phase 3: Iterate

1. **Write HTML fragment** to `$SCREEN_DIR/<name>.html`
   - Semantic filenames: `layout.html`, `sidebar-options.html`
   - Never reuse filenames — each screen is a new file
   - Fragments only — server wraps in frame template
   - Server auto-serves the newest file

2. **Tell the user** what's on screen, remind them of the URL, end your turn.

3. **On next turn** — read `$SCREEN_DIR/.events` for click selections. Merge with terminal feedback.

4. **Iterate** — `layout-v2.html` for revisions, advance when validated.

### Phase 4: Export Clean Reference

When the design is finalized:

1. Write the final design as a **full HTML document** (starting with `<!DOCTYPE html>`) — the server serves it without the companion frame. Name it `final-<name>.html`. **Important:** Make the design fill the full viewport (`width: 100vw; min-height: 100vh; margin: 0`) so the screenshot captures it edge-to-edge with no dead space.
2. Capture a clean screenshot:
   - Via agent-browser: `agent-browser navigate <url>` -> `agent-browser screenshot <path>`
   - Or ask the user to screenshot
3. Save to `design/` at project root (create if needed), with descriptive name: `design/helm-sidebar-v1.png`
4. Reference from spec/proposal: `![Sidebar design](../../design/helm-sidebar-v1.png)`

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
