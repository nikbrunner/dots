Edit.later(function()
	vim.pack.add({ "git@github.com:shellraining/hlchunk.nvim" })

	local exclude_ft = {
		dashboard = true,
		snacks_dashboard = true,
		alpha = true,
		help = true,
		lazy = true,
		mason = true,
		notify = true,
		checkhealth = true,
		lspinfo = true,
		qf = true,
		terminal = true,
	}

	local hl_accent = vim.api.nvim_get_hl(0, { name = "@function" })
	local hl_subtle = vim.api.nvim_get_hl(0, { name = "@comment" })

	require("hlchunk").setup({
		chunk = {
			enable = true,
			style = { hl_accent },
			priority = 15,
			use_treesitter = true,
			straight = false,
			error_sign = true,
			textobject = "ic",
			max_file_size = 1024 * 1024,
			delay = 50,
			duration = 0,
			chars = {
				horizontal_line = "─",
				left_top = "┌",
				vertical_line = "│",
				left_bottom = "└",
				right_arrow = "",
			},
			exclude_filetypes = exclude_ft,
		},

		indent = {
			enable = true,
			style = { hl_subtle },
			priority = 10,
			use_treesitter = false,
			ahead_lines = 8,
			delay = 50,
			chars = {
				"┊",
			},
			exclude_filetypes = exclude_ft,
		},

		line_num = {
			enable = true,
			style = { hl_accent },
			priority = 8,
			use_treesitter = false,
			exclude_filetypes = exclude_ft,
		},

		blank = {
			enable = false,
			style = { hl_subtle },
		},
	})
end)
