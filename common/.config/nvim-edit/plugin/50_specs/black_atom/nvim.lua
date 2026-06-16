Edit.now(function()
	-- vim.pack.add({
	-- 	{
	-- 		src = "git@github.com:black-atom-industries/nvim.git",
	-- 		name = "black-atom",
	-- 	},
	-- })
	-- Development: comment line above, uncomment below — no other setup needed:
	vim.opt.rtp:prepend(vim.fn.expand("~/repos/black-atom-industries/nvim"))

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

	vim.cmd.colorscheme("black-atom-stations-research")
end)
