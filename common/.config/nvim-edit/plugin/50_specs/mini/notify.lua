-- Notifications in a floating window (replaces vim.notify) + automatic
-- LSP progress reports. `now` so early startup messages are caught too.

Edit.now(function()
	require("mini.notify").setup()
end)
