-- AST navigation: move between syntax nodes with arrow keys, swap nodes
-- with Shift + arrow keys.

Edit.later(function()
	vim.pack.add({ "git@github.com:aaronik/treewalker.nvim" })

	require("treewalker").setup()

	local map = vim.keymap.set
	map({ "n", "v" }, "<Up>", "<Cmd>Treewalker Up<CR>", { desc = "Treewalker Up" })
	map({ "n", "v" }, "<Down>", "<Cmd>Treewalker Down<CR>", { desc = "Treewalker Down" })
	map({ "n", "v" }, "<Left>", "<Cmd>Treewalker Left<CR>", { desc = "Treewalker Left" })
	map({ "n", "v" }, "<Right>", "<Cmd>Treewalker Right<CR>", { desc = "Treewalker Right" })

	map({ "n", "v" }, "<S-Up>", "<Cmd>Treewalker SwapUp<CR>", { desc = "Treewalker Swap Up" })
	map({ "n", "v" }, "<S-Down>", "<Cmd>Treewalker SwapDown<CR>", { desc = "Treewalker Swap Down" })
	map({ "n", "v" }, "<S-Left>", "<Cmd>Treewalker SwapLeft<CR>", { desc = "Treewalker Swap Left" })
	map({ "n", "v" }, "<S-Right>", "<Cmd>Treewalker SwapRight<CR>", { desc = "Treewalker Swap Right" })
end)
