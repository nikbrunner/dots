Edit.now(function()
	vim.pack.add({ { src = "git@github.com:black-atom-industries/nvim.git", name = "black-atom" } })

	require("black-atom").setup({
		styles = {
			transparency = "none",
			cmp_kind_color_mode = "bg",
			diagnostics = {
				background = true,
			},
			syntax = {
				comments = { italic = false },
				variables = {},
			},
		},
	})

	vim.cmd.colorscheme("black-atom-terra-summer-day")
end)
