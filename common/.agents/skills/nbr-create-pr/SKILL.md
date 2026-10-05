---
name: nbr-create-pr
description: "Write or update a pull request description in Nik's shape: slice title, short nested bullets for what changed, tests added (e2e per scenario), how to test, optional screenshots and design-file changes, open decisions. Drafts locally, waits for approval, then publishes."
argument-hint: "[optional PR number or URL]"
user-invocable: true
metadata:
  argument-hint: "[optional PR number or URL]"
  user-invocable: true
---

# nbr-create-pr

A PR description is **durable**: it states what the PR is and does, and still reads true after merge. Everything in it is a
short nested bullet a reviewer scans top to bottom.

## Steps

1. **Gather.** Read the branch's commits against the base, the diff stat, the ticket (key, title, link), the test files the
   diff adds or changes, and the existing PR body if there is one (`bkt pr view <n>` on Bitbucket, `gh pr view <n>` on
   GitHub). Done when you can name every user-visible change and every added test scenario.
2. **Close the gaps.** List anything transient the draft would have to admit: a known bug, a missing spec, a decided but
   unbuilt change, unpushed commits. Fix what was already decided, ask about the rest. Done when the list holds only genuine
   open decisions for reviewers.
3. **Draft** into a gitignored scratch file (the project's `tmp/` or the session scratchpad) using the template below, then
   run the `humanizer` skill on it in embedded mode. Done when every section is filled or deliberately omitted.
4. **Show and wait.** Give Nik the file path and stop. Apply his edits until he approves the text.
5. **Publish** only after explicit approval: push the branch if commits are local (ask first), set the title and body with
   the platform CLI, and give the PR link.

## Template

```markdown
# [TICKET] <what this PR delivers; for a slice, name the slice>

- <Slice of | Implements> [TICKET <ticket title>](<ticket link>)
- Scope: <what is in>
- Later PRs: <what follows> (slices only)
- <Review hint, e.g. review commit by commit; which commits are mechanical>

## What changed

- <Area>
  - <short point>

## Tests added

End to end, <n> tests in `<dir>` (`<command>`):

- <Area or project>
  - <case>: <result>

Unit: <one line on what they cover>

## How to test

Setup

- <command or URL per line>

Steps

1. <Area>
   - <action>: <result>

## Screenshots

- <state or before/after>: <image>

## Design file

- <frame or row>: <what changed on the design source>

## Open decision

<Topic>

- <current state>
- <option>: <consequence>
```

## Section rules

- **Bullets**: one idea each, about a line long, grouped under a parent bullet by area. Results read `case: result`.
- **What changed**: user-visible behaviour and the conventions a reviewer must know, in the product's language. Code shape
  stays in the commits: write lists, never diffs, file trees or call graphs.
- **Tests added**: every new end-to-end scenario, named by what the user does and sees. Unit tests get one line.
- **How to test**: a setup block, then numbered steps a tester can follow without reading code.
- **Screenshots**: only for a visual change with images at hand (attach them on the platform). Omit the heading otherwise.
- **Design file**: only when the design source (Figma, Claude Design board) changed with this PR. Link it in the intro.
- **Open decision**: only questions reviewers or colleagues still have to settle. Settled choices belong in What changed.
