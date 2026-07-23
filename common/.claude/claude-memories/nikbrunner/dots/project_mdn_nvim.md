---
name: project-mdn-nvim
description: mdn.nvim stays a separate plugin repo (tests are the reason); loading race fixed 2026-07-16
metadata:
  node_type: memory
  type: project
  originSessionId: 42aeaf9b-9db2-417f-9b99-34b744082ab4
---

mdn.nvim (~repos/nikbrunner/mdn.nvim) is Nik's minimal Markdown plugin: list continuation + four-state checkbox cycle (`<C-CR>`). Insert-mode indent/outdent was removed 2026-07-16 in favor of built-in `i_CTRL-T`/`i_CTRL-D`.

**Decision (2026-07-16): keep it a separate repo, don't absorb into the nvim config.** Core logic is ~370 lines, but the 88-case busted test suite is the reason to keep the repo — list continuation regresses silently and the config repo has no test infrastructure. Don't propose absorbing it again.

The old "bindings sometimes don't attach" flakiness had two causes, both fixed: the dots spec deferred loading past VimEnter session restore (now `Edit.on_filetype("markdown", ...)`, which re-sources ftplugins for already-open buffers), and the plugin's ftplugin used `vim.schedule` + `buffer = true` (now synchronous with a captured buffer). Plugin loads via vim.pack from GitHub, so plugin changes need push + `vim.pack.update()`; the commented `rtp:prepend` line in the spec is the local-dev escape hatch.
