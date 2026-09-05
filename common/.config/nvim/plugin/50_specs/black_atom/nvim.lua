Edit.now(function()
	-- vim.pack.add({
	-- 	{
	-- 		src = "git@github.com:nikbrunner/black-atom.git",
	-- 		name = "black-atom",
	-- 	},
	-- })
	-- Development: comment line above, uncomment below — no other setup needed:
	vim.opt.rtp:prepend(vim.fn.expand("~/repos/nikbrunner/black-atom/adapters/nvim"))

	---@type BlackAtom.Config
	vim.g.black_atom_core_config = {
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
	}

	vim.cmd.colorscheme("black-atom-jpn-sanshoku-dark")
end)
