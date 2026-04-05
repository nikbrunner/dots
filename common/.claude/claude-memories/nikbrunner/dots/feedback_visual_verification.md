---
name: UI changes require visual verification
description: For any UI/visual change, verification must include rendering and inspecting a screenshot — build/lint passing is not sufficient.
type: feedback
---

For UI changes, "tests pass, build succeeds, lint clean" is NOT sufficient verification. The output must be visually inspected.

**Why:** A subagent claimed "sidebar rendering correctly" after build/lint passed, but obvious alignment issues, missing borders, and redundant elements were visible in a screenshot. Build/lint verify code correctness, not visual correctness.

**How to apply:**

- For any task involving visual output (TUI, web UI, terminal rendering), verification MUST include: build → launch → screenshot/screencapture → Read the image to inspect
- Subagent prompts for UI work must explicitly include visual verification steps
- Don't trust "it looks good" claims from subagents for visual work — always capture and inspect
- Load `dev:visual-companion` or use `screencapture -w` / `agent-browser screenshot` as part of the verification loop
