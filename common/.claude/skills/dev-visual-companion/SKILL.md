---
name: dev:visual-companion
description: "Browser-based visual companion for showing mockups, diagrams, and design options during brainstorming. Use when design questions need visual answers — layouts, wireframes, architecture diagrams, side-by-side comparisons."
user-invocable: true
---

# Visual Companion

Browser-based companion for showing mockups, diagrams, and options during design discussions.

## When to Use

Decide per-question, not per-session. The test: **would the user understand this better by seeing it than reading it?**

**Use the browser** for content that IS visual:
- UI mockups, wireframes, layouts, navigation structures
- Architecture diagrams, data flow, relationship maps
- Side-by-side comparisons of design directions
- Spatial relationships, state machines, flowcharts

**Use the terminal** for content that is text:
- Requirements and scope questions
- Conceptual A/B/C choices described in words
- Tradeoff lists, comparison tables
- Technical decisions, API design

## Starting a Session

```bash
${CLAUDE_SKILL_DIR}/scripts/start-server.sh --project-dir $CWD
```

Returns JSON with `url` and `screen_dir`. Tell the user to open the URL.

Save `screen_dir` for the session. Add `.visual-companion/` to `.gitignore` if not already there.

## The Loop

1. **Write HTML fragment** to `$SCREEN_DIR/<name>.html` using the Write tool
   - Use semantic filenames: `layout.html`, `nav-options.html`
   - Never reuse filenames — each screen is a new file
   - Write fragments, not full documents — the server wraps them in the frame template
   - Server auto-serves the newest file

2. **Tell the user** what's on screen and end your turn
   - Remind them of the URL
   - Brief text summary: "Showing 3 layout options for the dashboard"
   - Ask them to respond in the terminal

3. **On next turn** — read `$SCREEN_DIR/.events` if it exists
   - Contains JSON lines of user clicks/selections
   - Merge with terminal text for full picture

4. **Iterate or advance** — new file for revisions (`layout-v2.html`), move on when validated

5. **Unload when returning to terminal** — push a waiting screen when next question is text-only

## Stopping

```bash
${CLAUDE_SKILL_DIR}/scripts/stop-server.sh $SCREEN_DIR
```

## CSS Classes Available

See [visual-companion.md](visual-companion.md) for full CSS reference including:
- `.options` + `.option` — A/B/C clickable choices
- `.cards` + `.card` — visual design comparisons
- `.mockup` — wireframe container
- `.split` — side-by-side layout
- `.pros-cons` — pro/con columns
- Mock elements: `.mock-nav`, `.mock-sidebar`, `.mock-content`, `.mock-button`

## Integration with dev:grill-me

When visual questions come up during grilling:

1. Offer the companion: "Some of this might be easier to show visually. Want me to start the visual companion?"
2. If accepted, start the server
3. Per question, decide browser vs terminal
4. Stop the server when grilling is done or all remaining questions are text-only
