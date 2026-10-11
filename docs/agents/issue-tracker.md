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

GitHub shares issue and PR numbers. For an ambiguous reference, resolve it with `gh pr view <number>`, falling back to `gh issue view <number>`.
