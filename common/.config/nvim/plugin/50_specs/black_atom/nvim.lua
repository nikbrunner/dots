Edit.now(function()
	---@type BlackAtom.Config
	vim.g.black_atom_core_config = {
		styles = {
			transparency = "partial",
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

	vim.cmd.colorscheme("black-atom-minium-sienna-light")
end)
