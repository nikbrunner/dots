---
name: dev:bugs
user-invocable: false
description: Use bug-finder agent to hunt for logical errors and potential runtime issues
argument-hint: [optional: specific file, directory, or function to focus on]
---

# Bug Finder Command

## Context

Current working directory: !`pwd`

Recent changes: !`git log --oneline -5`

Modified files (unstaged): !`git diff --name-only`

Staged files: !`git diff --cached --name-only`

## Your task

$ARGUMENTS

Use the bug-finder agent to perform a thorough bug hunt and code analysis.

The bug-finder agent will:
- Hunt for logical errors and runtime issues
- Identify race conditions and concurrency problems
- Find unhandled edge cases and error conditions
- Detect potential null pointer dereferences
- Analyze error handling and exception paths
- Look for off-by-one errors and boundary conditions
- Check for resource leaks and memory issues

**Focus Area:**
- If arguments are provided, focus the analysis on the specified files, directories, or functions
- If no arguments provided, analyze recent changes from git diff and staged files
- If no recent changes, perform a broader analysis of critical code paths

**Analysis Scope:**
The agent will go beyond syntax and style to focus on:
- Logic correctness and potential runtime behavior
- Edge cases that could cause failures
- Error handling completeness
- Security vulnerabilities
- Performance bottlenecks that could cause issues

Use the Task tool to launch the bug-finder agent with appropriate context about what code to analyze.

## Investigation-First

Explore the codebase deeply before asking the user questions. Read related modules, trace call chains, check git blame for context. The only question worth asking the user is "what's the problem?" — and only if not already clear from arguments or context. Everything else should be discoverable from code.

## Fix Plan as TDD Cycles

When recommending fixes, structure each fix as a RED-GREEN cycle:

1. **RED** — Describe a failing test that reproduces the bug
2. **GREEN** — Describe the minimal code change that makes it pass
3. **Refactor** — Note any cleanup opportunities

Reference `dev:tdd` for vertical slice discipline. Never recommend a fix without a corresponding test.

## Issue Output

When the bug is confirmed, offer to create a trackable issue:

- **GitHub issue** for open-source / personal repos
- **Linear issue** for BAI projects (use `bai:create` skill)

Issue should contain: root cause analysis, reproduction steps, and TDD fix plan (failing test + minimal fix per cycle).

## Durability

Describe behaviors and contracts in reports, not file paths or line numbers. A good bug report should survive a refactor — "the cart total calculation ignores quantity-based discounts" not "line 47 of cart.ts has a bug".