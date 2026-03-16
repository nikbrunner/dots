---
name: Amend failing predecessor commits
description: When the previous commit has issues (type errors, lint failures), amend it rather than creating a new fix commit
type: feedback
---

When the immediately preceding commit is broken (e.g., fails stricter checks, has type errors), amend it rather than creating a separate fix commit.

**Why:** A broken commit in history is noise — squash the fix into the original so the history stays clean.

**How to apply:** Before committing a fix for something just committed, check if the previous commit is the one with the issue. If so, amend or squash instead of creating a new commit.
