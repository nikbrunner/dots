# fill-pr-description

Fill out a PR description template using GitHub CLI

## Usage

Use this command when you need to update or fill out a PR description template on GitHub.

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

## Template Fields to Fill

### Testing Instructions

Include specific steps like:

- Environment setup requirements
- Commands to run
- Expected outcomes
- How to verify success
- Edge cases to test

### Side Effects

Consider mentioning:

- Component/module impacts
- API changes
- Database changes
- Configuration changes
- Performance implications
- Breaking changes

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

