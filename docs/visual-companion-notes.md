# Visual Companion — Design Notes (WIP)

Status: Exploring options. Not ready for PRD yet.

## Pain Points (from superpowers visual companion)

- Only triggered on completely new brainstorming sessions, not revisitable
- Didn't persist — couldn't return to it when making adjustments
- No screenshots before changes — no before/after comparison
- No incremental updates to existing layouts

## Design Requirements (resolved)

- **Always-available** — startable at any point, not gate-triggered
- **Persistent** — stays running across the session, new content pushed
- **Screenshot-before-change** — capture current state before visual mods
- **Standalone CLI** — not locked to Claude Code, works from any AI tool
- **Scope: A + B** — static HTML mockups (Claude writes) + screenshots of running apps (before/after)

## Options to Explore

### 1. OpenPencil (Penpot MCP)

- Already installed, 70+ tools
- Can create shapes, components, layouts, export images
- **Question:** Can it serve as an interactive visual companion? Write mockups, get feedback?
- **Action:** Stress-test with a real design session

### 2. Excalidraw CLI / Skill

- `@swiftlysingh/excalidraw-cli` — text DSL to .excalidraw + PNG/SVG
- Cole Medin's skill — creates diagrams, validates with Playwright screenshots
- **Question:** Good enough for architecture diagrams during planning?
- **Action:** Try the CLI on a real diagram

### 3. Simple HTML Server

- `npx live-server` — zero config, auto-reload on file change
- Claude writes HTML to a watched directory, browser shows it live
- **Question:** Is this 80% of the value with 0% custom code?
- **Action:** Try a brainstorming session using just live-server

### 4. agent-browser screenshots

- Already available via browser-automation skill
- Can screenshot localhost before/after changes
- **Question:** Can it display side-by-side comparisons?
- **Action:** Try screenshotting a running dev server during a change

### 5. Custom CLI (build our own)

- Based on superpowers server.cjs (~500 LOC, zero deps)
- WebSocket server, file watching, styled frame, click events feedback loop
- **Only build if options 1-4 don't cover the use cases**

## Superpowers Implementation Reference

- `server.cjs` (~338 lines) — Node.js HTTP + WebSocket, watches dir for HTML files
- `helper.js` (~88 lines) — client-side click capture, WebSocket reconnect
- `frame-template.html` — CSS theme (light/dark), layout classes (.options, .cards, .mockup)
- `start-server.sh` — random high port, session dir, idle timeout
- Feedback loop: Claude writes HTML → server serves → user clicks → .events JSONL → Claude reads
- Zero npm dependencies
