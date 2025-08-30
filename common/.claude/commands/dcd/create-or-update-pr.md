# Create or Update PR 

If the PR already exists, update its description. Otherwise, create a new PR with a proper description.
Fill out a PR description template using GitHub CLI

## Usage

Use this command when you need to create or  update or fill out a PR with its description on GitHub.

## Steps

1. First, identify the PR number (if not provided, list current PRs):

```bash
gh pr list
```

2. View the current PR to understand the template:

```bash
gh pr view <PR_NUMBER>
```

3. Prepare the filled template based on:

- The work completed in the branch
- Testing steps that verify the changes
- Any side effects or breaking changes
- Checklist items relevant to the changes

4. Update the PR description:

Check whats already prefilled, and update as needed.

## Template to Fill

```markdown
### Which YouTrack tasks are related to this PR?

- BCD-

### How can this be tested?

1. First do this...
2. ... then that.

### This PR has possible side effects in…

... Setup.

### Checklist

- [ ] I verified on a device that the code is working as expected.
- [ ] I left the code quality in a better state than it was before (Boy Scout Rule).
- [ ] I made sure that the 'Update Snapshots' workflow was triggered (tag PR with 'needs review' label), if I made changes to components, or styles.
- [ ] I have respected our coding rules: ([Frontend](https://github.com/dealercenter-digital/bc-web-client-poc/blob/master/frontend/README.md) & [Backend](https://github.com/dealercenter-digital/bc-web-client-poc/blob/master/backend/README.md))
  - [ ] I added all new components/modifiers to storybook.
  - [ ] I added tests for new libs.
  - [ ] I didn't commit `package-lock.json` without changes to `package.json`.
  - [ ] I commented odd-looking pieces of code to clarify beforehand.
```

### Checklist Items

Mark items as completed `[x]` based on:

- What was actually done
- What's applicable to the changes
- Frontend vs Backend specific items

## Tips

- Always test the commands locally before including in PR description
- Be specific about version requirements when relevant
- Include both happy path and edge cases in testing steps
- Mark only genuinely completed checklist items
- Use code blocks for commands to improve readability
- Keep testing instructions concise but complete
- Consider the reviewer's perspective - what do they need to know?

