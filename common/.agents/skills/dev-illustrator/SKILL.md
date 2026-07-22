---
name: dev-illustrator
description: Draw live visual previews for the user — diagrams, UI sketches, data visualizations, UI mockups, component designs, interactive explainers, code reviews. Publish to the sideshow surface and receive browser comments back. Use when the user asks to illustrate, visualize, sketch, draw, design a UI, or when a visual would explain your work better than text. Triggers for requests like "design me a component", "show me a mockup", "visualize this", "sketch", "illustrate".
allowed-tools: Bash(sideshow:*), Bash(npx sideshow*), Bash(pgrep -f sideshow*), Bash(nohup npx -y sideshow*), Bash(agent-browser:*), mcp__plugin_sideshow_sideshow__*
---

# dev-illustrator

Publish live visual previews to the user's browser and receive their comments. The sideshow surface renders instantly — diagrams, UI mockups, rendered markdown, code reviews, terminal output.

The MCP tool names are `mcp__plugin_sideshow_sideshow__<verb>` (e.g. `mcp__plugin_sideshow_sideshow__publish_post`) — the plugin id is doubled into the tool prefix. Don't guess a shorter `mcp__sideshow__*` name; it does not exist and silently fails permission matching.

## Server management

The `sideshow` binary is not guaranteed to be on PATH even though the plugin is installed — the plugin ships the MCP client/skill, not a linked CLI. Start it via `npx` instead of assuming a bare `sideshow` command resolves:

```sh
pgrep -f "sideshow serve" > /dev/null || (nohup npx -y sideshow@latest serve > /tmp/sideshow.log 2>&1 & disown)
sleep 3
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8228   # expect 200
```

Never wrap the background launch in `timeout` — that kills the long-running server process after the timeout elapses instead of just bounding the startup check.

Use `SIDESHOW_URL` for deployed instances, `SIDESHOW_TOKEN` for auth.

## Before first publish

```
mcp__plugin_sideshow_sideshow__get_design_guide
```

Fetches the design contract: surface parts (html, markdown, mermaid, diff, image, trace, terminal, json, code), HTML fragment rules, theme CSS variables, kits, and the interactivity bridge.

## Publishing

```
mcp__plugin_sideshow_sideshow__publish_post({ title: "...", surfaces: [...], sessionTitle: "Task name" })
```

- Set `sessionTitle` on first publish to name the task
- One concept per post — combine surfaces in one post only when they're genuinely one concept (e.g. `[html, diff]`)
- Use `mcp__plugin_sideshow_sideshow__update_post` to revise (same card, new version) instead of publishing a near-duplicate
- An `html` surface is a **body fragment only** — no `<!doctype>`/`<html>`/`<head>`/`<body>`. Scope your own CSS (prefix classes) since the fragment is inserted into a shared sandboxed document.

## Surface parts

- **html**: body fragment (no doctype/html/head/body), sandboxed iframe
- **markdown**: prose rendered in viewer typography
- **mermaid**: diagram source, prefer vertical `flowchart TD`/`TB`
- **diff**: patch rendered as code review
- **terminal**: ANSI-colored output
- **image**: uploaded asset (`upload_asset` first, then reference by `assetId`)
- **trace**: agent run timeline
- **json**: any JSON value, collapsible tree
- **code**: syntax-highlighted source with line numbers

## Feedback

Browser comments appear in `userFeedback` on any publish/update/reply response — treat as user instructions. You can also:

```
mcp__plugin_sideshow_sideshow__wait_for_feedback({ timeoutSeconds: 60 })
mcp__plugin_sideshow_sideshow__reply_to_user({ postId: "...", message: "..." })
```

## Self-verification before asking the user to look

sideshow itself has no screenshot/render tool — it only accepts publishes and returns typed user comments. To actually see what got published (catch layout bugs, bleed-through, clipping) before handing back to the user, drive it with `agent-browser` (see `dev-browser` skill) rather than guessing from the HTML source:

```sh
agent-browser batch "open http://localhost:8228/p/<postId>" "wait 500" "screenshot --full"
```

Then Read the resulting screenshot path. Don't reach for `chrome-devtools` MCP for this — if the user already has a Chrome instance under devtools-mcp's managed profile, a second `new_page`/`navigate_page` call errors on "browser already running" rather than opening a usable tab, and forcing it risks the user's existing session. `agent-browser` runs its own isolated instance and is the correct lane for this per the web-tool routing table.

To inspect a specific detail (alignment, spacing, a small glyph) rather than the whole card: `agent-browser screenshot [selector] [path]` takes the selector as a **positional** arg, not `-s`. It also can't reach into sideshow's html surface — that content renders inside a sandboxed `<iframe>`, and agent-browser's selector query doesn't pierce iframe boundaries, so any selector scoped to `.your-class` there fails with "Element not found" even though `snapshot -i` happily lists elements inside the frame. There's no ref-targeted screenshot either — passing a `@eN` ref as the selector fails ("0 width"), since refs are snapshot/interaction handles, not screenshot targets. The reliable zoom-in path: take a `--full` screenshot, then crop with `sips` (`sips -c <h> <w> --cropOffset <y> <x> in.png --out crop.png`, already on macOS) using pixel coordinates read off the full screenshot.

Use judgment on when to zoom in — there's no fixed checklist of parts to always crop. Look at the full screenshot first the way a person would: does anything read as slightly off — a mark that looks not-quite-centered in its box, edges that don't quite meet, spacing that looks uneven between otherwise-identical rows? Small interactive controls (checkboxes, toggles, icons, badges) are the most common place a few px of drift hides at full-page scale but reads as sloppy once cropped in. When something catches your eye like that, crop to it and check before publishing — don't wait for the user to spot it.

Self-verification also catches mechanical mistakes, not just design ones — e.g. publishing placeholder or copy-pasted-from-the-wrong-place HTML by accident. Actually looking at the rendered screenshot before telling the user it's ready is what catches this class of error; don't skip the screenshot step just because the publish call itself succeeded.

## Design reminders

- The design guide's own house style (flat, no gradients/shadows, two font weights) is for sideshow-native diagrams/boards. When the deliverable is a mockup of a component meant to live elsewhere (e.g. a skeuomorphic/industrial/retro UI for the user's own app), the mockup should look like the real target, not like a sideshow card — don't flatten it to match the viewer's chrome.
- html: use theme CSS variables for dark mode when the surface *is* sideshow-native chrome; a mockup previewing an external design system's look intentionally overrides them.
- mermaid: short wrapped labels, vertical layout for architecture
- Fetch `mcp__plugin_sideshow_sideshow__get_design_guide` fresh each session rather than trusting this summary for anything beyond the basics — it is the source of truth and evolves independently of this skill.