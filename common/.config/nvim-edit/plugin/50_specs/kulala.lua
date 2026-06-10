-- HTTP client for .http files. Requires the `http` treesitter parser
-- (eagerly installed via arborist's ensure_installed).
-- https://kulala.mwco.app/docs/getting-started/setup-options/

Edit.later(function()
	vim.pack.add({ "git@github.com:mistweaverco/kulala.nvim" })

	require("kulala").setup({
		default_env = "local",
		kulala_keymaps_prefix = ".",
	})

	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "[h",         function() require("kulala").jump_prev() end,        { desc = "Previous request" })
	map("n", "]h",         function() require("kulala").jump_next() end,        { desc = "Next request" })
	map("n", "<leader>he", function() require("kulala").set_selected_env() end, { desc = "Select env" })
	map("n", "<leader>hr", function() require("kulala").run() end,              { desc = "Run request" })
	map("n", "<leader>hs", function() require("kulala").search() end,           { desc = "Search" })
	map("n", "<leader>hc", function() require("kulala").copy() end,             { desc = "Copy request" })
	-- stylua: ignore end
end)
