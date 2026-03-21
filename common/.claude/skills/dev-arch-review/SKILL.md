---
name: dev:arch-review
user-invocable: false
description: Review architecture of specified path(s), or staged/unstaged git changes.
argument-hint: [path/to/directory]... (optional)
allowed-tools: Bash(git:diff)
---
Use the **architecture-reviewer** subagent to conduct a thorough architectural review.

Your analysis target is determined by the following rules:

1.  **If file or directory paths are provided as arguments**, your review must focus exclusively on them: **$ARGUMENTS**

2.  **If no arguments are provided**, your analysis MUST focus on the recent git changes provided below. Please prioritize the **'Staged Changes'**. If that section is empty, then analyze the **'Unstaged Changes'**.

### Context from Git (if no arguments provided)

**Staged Changes (Priority 1):**
```diff
!git diff --staged
```

**Unstaged Changes (Priority 2):**
```diff
!git diff HEAD
```
### Additional Evaluation Criteria

#### Deep Modules

Evaluate modules using John Ousterhout's depth metric: a deep module has a small interface relative to its implementation complexity. Flag shallow modules where the interface is as complex as the implementation — these add integration cost without hiding complexity.

#### Dependency Categories

Classify each dependency in the reviewed code:

| Category | Description | Test Strategy |
|-|-|-|
| In-process | Pure computation, no I/O | Test directly, no mocks needed |
| Local-substitutable | Has test stand-ins (in-memory DB, fake clock) | Use real substitutes in tests |
| Ports & Adapters | Owned remote services behind an interface | Mock at the port boundary |
| True External | Third-party APIs, SDKs | Mock at the outermost boundary only |

See `REFERENCE.md` for detailed dependency category guidance.

#### Replace, Don't Layer

When boundary tests already cover a module's behavior, flag redundant shallow unit tests for deletion. Layered tests that duplicate boundary coverage add maintenance cost without catching additional bugs.

### Cross-References

- `dev:tdd` — vertical slice testing, behavior-driven test design
- `dev:testing` — test strategy and tooling

---
*Your final report should evaluate the code against the principles of Separation of Concerns, SOLID, Scalability, Maintainability, Module Depth, and Dependency Classification.*