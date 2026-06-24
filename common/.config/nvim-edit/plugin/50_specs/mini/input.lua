-- Deferred via `Edit.later`: mini.input replaces vim.ui.input (rename/dialog
-- prompts), which only ever fires on a user-initiated prompt — never on the
-- first frame. vim.schedule completes before any user input is processed.
Edit.later(function()
	require("mini.input").setup({
		scope = "cursor",
	})
end)
