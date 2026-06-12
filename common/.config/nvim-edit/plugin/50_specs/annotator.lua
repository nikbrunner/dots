-- Document annotations (add, suggest rewrites, list, export).

Edit.later(function()
	vim.pack.add({ "git@github.com:chpeters/annotator.nvim" })

	require("annotator").setup({
		mappings = false,
		storage = "state",
	})

	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "<leader>daa", function() require("annotator").add() end,            { desc = "[A]dd" })
	map("v", "<leader>daa", function() require("annotator").add_visual() end,     { desc = "[A]dd" })
	map("n", "<leader>das", function() require("annotator").suggest() end,        { desc = "[S]uggest rewrite" })
	map("v", "<leader>das", function() require("annotator").suggest_visual() end, { desc = "[S]uggest rewrite" })
	map("n", "<leader>dad", function() require("annotator").delete() end,         { desc = "[D]elete annotation" })
	map("n", "<leader>dae", function() require("annotator").edit() end,           { desc = "[E]dit annotation" })
	map("n", "<leader>dal", function() require("annotator").list() end,           { desc = "[L]ist annotations" })
	map("n", "<leader>day", function() require("annotator").export() end,         { desc = "[Y]ank annotations" })
	-- stylua: ignore end
end)
