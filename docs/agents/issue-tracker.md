# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `nikbrunner/dots`. Use the `gh` CLI from this clone.

## Operations

- Create: `gh issue create --title "..." --body-file -`, supplying the body through a heredoc.
- Read: `gh issue view <number> --json number,title,body,labels,comments`.
- List: `gh issue list --state open --json number,title,body,labels,comments`, adding label filters as needed.
- Comment: `gh issue comment <number> --body "..."`.
- Label: `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- Close: `gh issue close <number> --comment "..."`.

Use `--repo nikbrunner/dots` when running outside this clone.

When a skill says "publish to the issue tracker", create a GitHub issue. When it says "fetch the relevant ticket", read the issue, including labels and comments.

## Pull requests as a triage surface

**PRs as a request surface: no.**

GitHub shares issue and PR numbers. For an ambiguous reference, resolve it with `gh pr view <number>`, falling back to `gh issue view <number>`.

## Wayfinding operations

- Map: one issue labelled `wayfinder:map`, containing Notes, Decisions-so-far, and Fog.
- Children: link tickets as GitHub sub-issues. Where unavailable, use a task list in the map and a `Part of #<map>` line in each child.
- Types: label children `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`, or `wayfinder:task`.
- Blocking: use GitHub's native issue dependencies. Where unavailable, record `Blocked by: #<number>` in the child body. Every blocker must be closed before work starts.
- Frontier: select the first open, unassigned child in map order with no open blockers.
- Claim: `gh issue edit <number> --add-assignee @me` as the session's first write.
- Resolve: comment with the answer, close the child, and append a short summary and link to the map's Decisions-so-far.
