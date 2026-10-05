-- Document annotations (add, suggest rewrites, list, export).

Edit.later(function()
	vim.pack.add({ "git@github.com:chpeters/annotator.nvim" })

	require("annotator").setup({
		mappings = false,
		storage = "state",
	})

	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "<leader>dna", function() require("annotator").add() end,            { desc = "[A]dd" })
	map("v", "<leader>dna", function() require("annotator").add_visual() end,     { desc = "[A]dd" })
	map("n", "<leader>dns", function() require("annotator").suggest() end,        { desc = "[S]uggest rewrite" })
	map("v", "<leader>dns", function() require("annotator").suggest_visual() end, { desc = "[S]uggest rewrite" })
	map("n", "<leader>dnd", function() require("annotator").delete() end,         { desc = "[D]elete annotation" })
	map("n", "<leader>dne", function() require("annotator").edit() end,           { desc = "[E]dit annotation" })
	map("n", "<leader>dnl", function() require("annotator").list() end,           { desc = "[L]ist annotations" })
	map("n", "<leader>dny", function() require("annotator").export() end,         { desc = "[Y]ank annotations" })
	-- stylua: ignore end
end)
