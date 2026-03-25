---
name: Visual verification for UI changes
description: UI/TUI changes must include actual visual verification (screenshot + review), not just build/lint checks
type: feedback
---

For UI/TUI changes, build + lint passing means nothing visually. Always verify by building, launching in tmux popup, capturing a screenshot, and reading it to check alignment and rendering.

**Why:** Subagent claimed "sidebar is rendering correctly" without seeing the output. Result had broken alignment, missing borders, redundant footer, clipped text, and poor button contrast — none caught until the user pointed it out.

**How to apply:** When delegating UI work to subagents, include in the prompt: "Build the binary, launch in tmux popup (`tmux display-popup -w60% -h35% -B -E`), screencapture, and Read the screenshot to verify visual output. List any alignment or rendering issues found." Load `dev-verification` skill before marking UI tasks done.
