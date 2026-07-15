-- File marks radar (black-atom-industries/radar.nvim).
-- Data lives in ~/.local/share/nvim-edit/radar/ (symlinked into dots,
-- committed via `dots chores`).

Edit.later(function()
	vim.pack.add({ "git@github.com:black-atom-industries/radar.nvim" })

	require("radar").setup({
		keys = {
			tabs_toggle = "<leader>t",
		},
	})
end)
