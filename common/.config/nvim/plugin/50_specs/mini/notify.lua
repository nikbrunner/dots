-- Notifications in a floating window (replaces vim.notify) + automatic
-- LSP progress reports. `now` so early startup messages are caught too.

Edit.now(function()
	require("mini.notify").setup()

	vim.keymap.set("n", "<leader>an", function()
		MiniNotify.show_history()
	end, { desc = "[N]otifications" })
end)
