Edit.now(function()
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

	vim.cmd.colorscheme("black-atom-minium-viridian-dark")
end)
