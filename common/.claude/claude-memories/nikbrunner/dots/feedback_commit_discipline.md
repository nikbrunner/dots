---
name: No trash commits during debug cycles
description: When iterating on a fix (debug → test → adjust → test), batch changes into one meaningful commit instead of committing each iteration separately.
type: feedback
---

When debugging or iterating on a fix, don't create small throwaway commits for each adjustment. Batch the entire debug cycle into one commit that tells a coherent story.

**Why:** Three commits like "strengthen language" → "wrap in tags" → "add table entry" are meaningless individually. One commit like "fix meta-enforcement to match superpowers' proven patterns" captures the actual change.

**How to apply:** During debug/iterate cycles, hold off on committing until the fix is validated. Use `git add` to stage incrementally, but only `git commit` when the change is complete and tested. If you already committed prematurely, offer to squash before pushing.
