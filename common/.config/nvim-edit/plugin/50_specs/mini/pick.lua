local mini_pick = require("mini.pick")
local mini_extra = require("mini.extra")

require("mini.visits").setup()

mini_extra.setup()

mini_pick.setup({
	mappings = {
		caret_left = "<Left>",
		caret_right = "<Right>",

		choose = "<CR>",
		choose_in_split = "<C-s>",
		choose_in_tabpage = "<C-t>",
		choose_in_vsplit = "<C-v>",
		choose_marked = "<M-CR>",

		delete_char = "<BS>",
		delete_char_right = "<Del>",
		delete_left = "<C-h>",
		delete_word = "<C-w>",

		mark = "<C-x>",
		mark_all = "<C-a>",

		move_down = "<C-n>",
		move_start = "<C-g>",
		move_up = "<C-p>",

		paste = "<C-r>",

		refine = "<C-Space>",
		refine_marked = "<M-Space>",

		scroll_down = "<C-d>",
		scroll_left = "<C-h>",
		scroll_right = "<C-l>",
		scroll_up = "<C-u>",

		stop = "<Esc>",

		toggle_info = "<S-Tab>",
		toggle_preview = "<Tab>",
	},
	window = {
		config = function()
			local win_height = vim.api.nvim_win_get_height(0)
			local win_width = vim.api.nvim_win_get_width(0)
			local height = math.floor(0.25 * win_height)
			local width = win_width >= 165 and math.floor(0.5 * vim.o.columns) or (win_width - 2)
			return {
				relative = "win",
				height = height,
				width = width,
				row = win_height - 1,
				col = 0,
				border = "solid",
			}
		end,
	},
})

mini_pick.registry.smart_files = Edit.pickers.smart_files
mini_pick.registry.git_changed = Edit.pickers.git_changed
mini_pick.registry.project_switch = Edit.pickers.project_switch
mini_pick.registry.worktree_switch = Edit.pickers.worktree_switch
mini_pick.registry.related_documents = Edit.pickers.related_documents
mini_pick.registry.buffer_jumps = Edit.pickers.buffer_jumps

-- Keymaps
local map = vim.keymap.set
local dots_path = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots"


-- stylua: ignore start
-- General
map("n", "<leader>.",   function() mini_pick.builtin.resume() end, { desc = "Resume Picker" })
map("n", "<leader>;",   function() mini_extra.pickers.commands() end, { desc = "Commands" })
map("n", "<leader>:",   function() mini_extra.pickers.history({ scope = ":" }) end, { desc = "Command History" })
map("n", "<leader>'",   function() mini_extra.pickers.registers() end, { desc = "Registers" })

-- App
map("n", "<leader><leader>", function() mini_pick.registry.smart_files() end, { desc = "Files (smart)" })
map("n", "<leader>aa",  function() mini_extra.pickers.commands() end, { desc = "[A]ctions" })
map("n", "<leader>ad",  function() mini_pick.builtin.files() end, { desc = "[D]ocument (in project)" })
map("n", "<leader>ahh", function() mini_extra.pickers.hl_groups() end, { desc = "[H]ighlights" })
map("n", "<leader>ahk", function() mini_extra.pickers.keymaps() end, { desc = "[K]eymaps" })
map("n", "<leader>ahm", function() mini_extra.pickers.manpages() end, { desc = "[M]anuals" })
map("n", "<leader>aht", function() mini_pick.builtin.help() end, { desc = "[T]ags" })
map("n", "<leader>ar",  function() mini_extra.pickers.oldfiles() end, { desc = "[R]ecent Documents (Anywhere)" })
map("n", "<leader>at",  function() mini_extra.pickers.colorschemes() end, { desc = "[T]hemes" })
map("n", "<leader>aw",  function() mini_pick.registry.project_switch() end, { desc = "[W]orkspace" })
map("n", "<leader>a,",  function() mini_pick.builtin.files(nil, { source = { cwd = dots_path } }) end, { desc = "[,]Settings (Dots)" })

-- Workspace
map("n", "<leader>wd",  function() mini_pick.builtin.files() end, { desc = "[D]ocuments" })
map("n", "<leader>wt",  function() mini_pick.builtin.grep_live() end, { desc = "[T]ext" })
map("n", "<leader>wm",  function() mini_pick.registry.git_changed() end, { desc = "[M]odified files" })
map("n", "<leader>wp",  function() mini_extra.pickers.diagnostic() end, { desc = "[P]roblems" })
map("n", "<leader>wr",  function() mini_extra.pickers.oldfiles({ current_dir = true }) end, { desc = "[R]ecent Documents" })
map("n", "<leader>ws",  function() mini_extra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "[S]ymbols" })
map("n", "<leader>wc",  function() mini_extra.pickers.git_hunks() end, { desc = "[C]hanges" })
map("n", "<leader>wgb", function() mini_extra.pickers.git_branches() end, { desc = "[B]ranches" })
map("n", "<leader>wgh", function() mini_extra.pickers.git_commits() end, { desc = "[H]istory" })
map("n", "<leader>ww",  function() mini_pick.registry.worktree_switch() end, { desc = "[W]orktrees" })

-- Document
map("n", "<leader>dr",  function() mini_pick.registry.related_documents() end, { desc = "[R]elated Documents" })
map("n", "<leader>dc",  function() mini_extra.pickers.git_hunks({ path = vim.fn.expand("%") }) end, { desc = "[C]hanges" })
map("n", "<leader>dj",  function() mini_pick.registry.buffer_jumps() end, { desc = "[J]umps" })
map("n", "<leader>dp",  function() mini_extra.pickers.diagnostic({ scope = "current" }) end, { desc = "[P]roblems" })
map("n", "<leader>ds",  function() mini_extra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "[S]ymbols" })
map("n", "<leader>dt",  function() mini_extra.pickers.buf_lines({ scope = "current" }) end, { desc = "[T]ext" })

-- Symbol
map("n", "<leader>sr",  function() mini_extra.pickers.lsp({ scope = "references" }) end, { desc = "[R]eferences" })
map("n", "<leader>si",  function() mini_extra.pickers.lsp({ scope = "implementation" }) end, { desc = "[I]mplementations" })
-- stylua: ignore end
