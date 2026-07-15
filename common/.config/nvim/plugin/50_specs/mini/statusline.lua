require("mini.statusline").setup({
	content = {
		active = function()
			local m = require("mini.statusline")
			local fnamemodify = vim.fn.fnamemodify

			local project_name = function()
				local current_project_folder = fnamemodify(vim.fn.getcwd(), ":t")
				local parent_project_folder = fnamemodify(vim.fn.getcwd(), ":h:t")
				return parent_project_folder .. "/" .. current_project_folder
			end

			---@diagnostic disable-next-line: unused-local
			local _mode, mode_hl = m.section_mode({ trunc_width = 120 })
			local git = m.section_git({ trunc_width = 75 })

			return m.combine_groups({
				{ hl = mode_hl, strings = { " EDIT" } },
				{
					hl = "@function",
					strings = (m.is_truncated(100) and {} or { project_name() }),
				},
				{
					hl = "@variable.member",
					strings = { git },
				},

				"%<", -- Mark general truncate point

				"%=", -- End left alignment

				{
					hl = "@variable.parameter",
					strings = { "󰓩  " .. vim.fn.tabpagenr() .. ":" .. vim.fn.tabpagenr("$") .. "" },
				},
			})
		end,
	},
})
