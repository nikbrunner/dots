# research

Research a topic thoroughly before implementation, grounded in project context.

## Usage

Use this command when you need to understand a library, API, pattern, or solution before writing code. Research is contextual - understand the project first, then research how to extend it.

## Arguments

`$ARGUMENTS` - The topic, library, or problem to research (e.g., "tanstack form validation", "neovim floating windows", "bubbletea list component")

## Steps

### 1. Understand Project Context First

Before external research, understand what you're working with:

- **Check existing patterns** - How does the project already solve similar problems?
  ```
  Use: Grep/Glob to find related code in the codebase
  ```
- **Review dependencies** - What's already installed? (package.json, go.mod, etc.)
- **Read project docs** - Check README, CLAUDE.md, or docs/ folder
- **Check existing implementations** - Are there similar features to reference?

### 2. Check Ref MCP for Documentation

Search for official docs relevant to project dependencies:
```
Use: mcp__Ref__ref_search_documentation
Then: mcp__Ref__ref_read_url for relevant results
```

### 3. Search Exa for Real-World Examples

Look for implementations that match the project's stack:
```
Use: mcp__exa__get_code_context_exa for code-specific searches
Use: mcp__exa__web_search_exa for broader context
```

### 4. Check Reference Repos (if applicable)

Look at how similar libraries/plugins implement this:
```
Use: WebFetch for GitHub repos or gists
```

### 5. Synthesize Findings

Connect external research back to project context:
- How does this fit with existing patterns?
- What needs to adapt to match project conventions?
- Are there conflicts with current dependencies?

## Output Format

Present findings as:

```markdown
# Research: [Topic]

## Project Context
- Current stack/dependencies relevant to this
- Existing patterns in codebase that relate
- Constraints or conventions to respect

## TL;DR
One sentence recommendation that fits the project.

## Key Concepts
- What you learned from docs/examples
- How it maps to this project's needs

## Recommended Approach
1. Step-by-step that respects existing patterns
2. ...

## Resources
- Links for reference
```

## Example

```
/research bubbletea viewport scrolling

# Research: Bubbletea Viewport Scrolling

## Project Context
- Project uses bubbletea v0.25 (from go.mod)
- Existing TUI uses tea.Model pattern with Update/View
- Other components already handle WindowSizeMsg

## TL;DR
Use the viewport bubble with SetContent(), following existing WindowSizeMsg handling pattern.

## Key Concepts
- viewport.Model handles scrollable content
- Must call viewport.New() with initial dimensions
- Update dimensions on tea.WindowSizeMsg (already handled in main model)

## Recommended Approach
1. Add viewport.Model to existing model struct
2. Initialize in existing Init() alongside other components
3. Delegate WindowSizeMsg in Update() like other components
4. Render in View() at appropriate position

## Resources
- https://github.com/charmbracelet/bubbles/tree/master/viewport
```

## Important

- **Don't skip this step** - 5 minutes of research prevents hours of debugging
- Index the docs before suggesting solutions
- If docs are unclear, search for examples
- Admit when research is inconclusive
