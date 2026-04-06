---
name: No commits without real testing
description: Always verify changes end-to-end before committing — no assumptions, no "should work" commits
type: feedback
---

Never commit code changes without actually running and verifying the result. Don't assume a change works from reading it — run the code, check the output, confirm it does what's expected.

**Why:** Nik called out a pattern of committing fixes that weren't properly tested, leading to follow-up fixes. This wastes time and clutters git history.

**How to apply:** After every code change, run the relevant task/test AND manually verify the output matches expectations before staging. If the change affects CLI output, show the actual output. If it changes behavior, demonstrate the new behavior. No "checks pass, ship it."
