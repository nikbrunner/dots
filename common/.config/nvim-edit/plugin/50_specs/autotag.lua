-- Auto-close and auto-rename HTML/JSX/XML tags (treesitter-based).

Edit.later(function()
	vim.pack.add({ "git@github.com:windwp/nvim-ts-autotag" })

	require("nvim-ts-autotag").setup({})
end)
