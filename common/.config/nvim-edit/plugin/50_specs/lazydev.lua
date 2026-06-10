-- lua_ls type support for Neovim config/plugin development.
-- (Dropped the old 'lazy.nvim' library entry — no lazy.nvim anymore.)

Edit.later(function()
	vim.pack.add({ "git@github.com:folke/lazydev.nvim" })

	require("lazydev").setup({
		library = {
			"black-atom",
			"radar.nvim",
			{ path = "snacks.nvim", words = { "Snacks" } },
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})
end)
