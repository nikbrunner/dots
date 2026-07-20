---
name: herdr-discussion-contribution-strategy
description: "Nik's evolving approach to posting GitHub Discussions as an external contributor to herdr, after discussion"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3e3398c0-1a58-462a-b63d-d083824bbba0
---

When Nik posts a GitHub Discussion proposing a fix/feature for herdr (per the
external contributor guardrail in repo CLAUDE.md), he wants to link his
branch/diff directly in the discussion post, not just describe the change
and screenshots. Reasoning: makes the implementation more visible and easy
for the maintainer to evaluate as-is.

**Why:** Discussion #1599 (session navigator tree rendering,
[[herdr-contributor-context]]) proposed a fix with before/after screenshots
but no linked diff, and phrased the offer permissively — "happy to open a PR
if you like the direction, equally fine if you'd rather take the idea and
style it your way." The maintainer (ogulcancelik) took the idea, extended it
himself (added workspace grouping + search auto-select), and closed the
issue with his own direct commit — never used Nik's branch, never invited a
PR. Nik was disappointed; his actual goal was getting `/approve`d and merged,
not just having the idea adopted.

**How to apply:** Two things to bring up if Nik is drafting a similar
discussion post in the future:
1. Link the branch/diff in the post itself (not just prose + screenshots).
2. If the real goal is landing a merged PR (not just idea-adoption), say so
   explicitly and directly in the post — e.g. "this is ready to go, happy to
   open a PR if you want to take it as-is" — rather than leaving the door
   open to "take the idea and style it your way," which invites exactly the
   outcome that happened here.

Linking the diff is a visibility improvement, not a guarantee — it doesn't
change a maintainer's preference for implementing things himself if that's
the pattern. Watch across the next 1-2 discussions whether this is a
one-off or a recurring maintainer habit before drawing a firm conclusion.
