-- Treesitter-aware 'commentstring' — correct comments in JSX, embedded
-- languages, etc. Works with any comment plugin (incl. mini.comment).

Edit.later(function()
	vim.pack.add({ "git@github.com:folke/ts-comments.nvim" })

	require("ts-comments").setup({})
end)
