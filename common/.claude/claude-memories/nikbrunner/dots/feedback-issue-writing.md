---
name: feedback-issue-writing
description: "How Nik contributes to OSS via issues — UX expectation firm, implementation deliberately open"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: aff35672-3f99-4b1d-970e-074b73a0f035
  modified: 2026-07-26T19:10:50.881Z
---

Nik values contributing to open source through well-written issues, not only code. He sees his contribution as coming from the app-developer/UX side: he knows what the behaviour *should* be, and is explicit that he is not a Rust (or other language) expert.

**Why:** A report that states the UX expectation firmly and leaves the fix open respects the maintainer's ownership of their design. Prescribing a solution "pressures him in the solution direction" — Nik's words. He liked that a draft omitted a proposed fix entirely.

**How to apply:** When drafting an issue for him:

- Ground it in real use — what he actually hit, not a code audit
- Dig into the source far enough to name the mechanism (file, function, the line that does it)
- Report code findings as observation ("there is a `launch_workspace_id()` that already knows this"), never as instruction ("you should use X")
- Hedge the implementation out loud: "no idea if that's the right lever", "I don't know that code well enough to say"
- State the UX expectation without hedging — that is the part he does know
- Place him when useful: "I'm coming at this from the UX side, I'm no Rust person"
- Include exact versions and a copy-pasteable repro; reproduce it live first so numbers are real, not invented
- Use a concrete example with enough elements to show the problem (4 workspaces, not 2)
- Follow [[my-voice]] — no emoji in issues, plain language, current state then expected state

Verify a matching issue does not already exist, and check the installed version against upstream HEAD before reporting — no point filing something already fixed.

Also worth noticing what *not* to file: drop findings that become moot when the approach changes, rather than filing for completeness.

Five issues filed this way on thanhdat77/herdr-navigator (2026-07-26): #13, #14, #15, #16, #17.
