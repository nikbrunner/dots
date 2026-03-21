---
name: Release highlights go on GitHub Release, not PR
description: Release-please PRs regenerate their body on every push — manual edits get discarded
type: feedback
---

Don't add manual highlights to release-please PR descriptions — they get overwritten on the next commit to main. Add highlights to the GitHub Release notes after merging instead.

**Why:** Nik lost manually written highlights on PR #42 when new commits triggered release-please to regenerate the body.

**How to apply:** When Nik wants to add release highlights, remind him to save them for the GitHub Release post-merge, not the PR body.
