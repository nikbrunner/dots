-- Snacks subset: lazygit UI, terminal, and gitbrowse only.
-- The old config's other snacks features are covered by mini.* or dropped:
-- notifier → mini.notify, input → mini.input, picker → mini.pick,
-- statuscolumn/bigfile/toggles/words → dropped (see nvim-edit.md).

Edit.later(function()
	vim.pack.add({ "git@github.com:folke/snacks.nvim" })

	require("snacks").setup({
		bigfile = { enabled = false },
		statuscolumn = { enabled = false },
		notifier = { enabled = false },
		input = { enabled = false },
		scroll = { enabled = false },
		gitbrowse = { enabled = true },
		terminal = {
			win = {
				border = "solid",
				wo = { winbar = "" },
			},
		},
		lazygit = {
			configure = false,
			win = {
				backdrop = true,
				border = "solid",
				width = 0,
				height = 0,
			},
		},
	})

	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "<leader>ag",  function() Snacks.lazygit() end,          { desc = "[G]it" })
	map("n", "<leader>wgs", function() Snacks.lazygit() end,          { desc = "[S]tatus (Lazygit)" })
	map("n", "<leader>wgH", function() Snacks.lazygit.log() end,      { desc = "[H]istory (Lazygit)" })
	map("n", "<leader>dgH", function() Snacks.lazygit.log_file() end, { desc = "[H]istory (Lazygit)" })
	map("n", "<leader>wgr", function() Snacks.gitbrowse() end,        { desc = "[R]emote (GitHub)" })
	map("n", "<leader>sgb", function() Snacks.git.blame_line() end,   { desc = "[B]lame" })
	-- stylua: ignore end
end)
