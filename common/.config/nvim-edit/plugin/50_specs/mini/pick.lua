local MP = require("mini.pick")
local ME = require("mini.extra")

require("mini.visits").setup()

ME.setup()

MP.setup({
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
		delete_left = "<C-u>",
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

MP.registry.smart_files = Edit.pickers.smart_files
MP.registry.git_changed = Edit.pickers.git_changed
MP.registry.project_switch = Edit.pickers.project_switch
MP.registry.worktree_switch = Edit.pickers.worktree_switch
MP.registry.related_documents = Edit.pickers.related_documents
MP.registry.buffer_jumps = Edit.pickers.buffer_jumps

-- Keymaps
local map = vim.keymap.set
local dots_path = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots"


-- stylua: ignore start
-- General
map("n", "<leader>.",   function() MP.builtin.resume() end, { desc = "Resume Picker" })
map("n", "<leader>;",   function() ME.pickers.commands() end, { desc = "Commands" })
map("n", "<leader>:",   function() ME.pickers.history({ scope = ":" }) end, { desc = "Command History" })
map("n", "<leader>'",   function() ME.pickers.registers() end, { desc = "Registers" })

-- App
map("n", "<leader><leader>", function() MP.registry.smart_files() end, { desc = "Files (smart)" })
map("n", "<leader>aa",  function() ME.pickers.commands() end, { desc = "[A]ctions" })
map("n", "<leader>ad",  function() MP.builtin.files() end, { desc = "[D]ocument (in project)" })
map("n", "<leader>ahh", function() ME.pickers.hl_groups() end, { desc = "[H]ighlights" })
map("n", "<leader>ahk", function() ME.pickers.keymaps() end, { desc = "[K]eymaps" })
map("n", "<leader>ahm", function() ME.pickers.manpages() end, { desc = "[M]anuals" })
map("n", "<leader>aht", function() MP.builtin.help() end, { desc = "[T]ags" })
map("n", "<leader>ar",  function() ME.pickers.oldfiles() end, { desc = "[R]ecent Documents (Anywhere)" })
map("n", "<leader>at",  function() ME.pickers.colorschemes() end, { desc = "[T]hemes" })
map("n", "<leader>aw",  function() MP.registry.project_switch() end, { desc = "[W]orkspace" })
map("n", "<leader>a,",  function() MP.builtin.files(nil, { source = { cwd = dots_path } }) end, { desc = "[,]Settings (Dots)" })

-- Workspace
map("n", "<leader>wd",  function() MP.builtin.files() end, { desc = "[D]ocuments" })
map("n", "<leader>wt",  function() MP.builtin.grep_live() end, { desc = "[T]ext" })
map("n", "<leader>wm",  function() MP.registry.git_changed() end, { desc = "[M]odified files" })
map("n", "<leader>wp",  function() ME.pickers.diagnostic() end, { desc = "[P]roblems" })
map("n", "<leader>wr",  function() ME.pickers.oldfiles({ current_dir = true }) end, { desc = "[R]ecent Documents" })
map("n", "<leader>ws",  function() ME.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "[S]ymbols" })
map("n", "<leader>wc",  function() ME.pickers.git_hunks() end, { desc = "[C]hanges" })
map("n", "<leader>wgb", function() ME.pickers.git_branches() end, { desc = "[B]ranches" })
map("n", "<leader>wgh", function() ME.pickers.git_commits() end, { desc = "[H]istory" })
map("n", "<leader>ww",  function() MP.registry.worktree_switch() end, { desc = "[W]orktrees" })

-- Document
map("n", "<leader>dr",  function() MP.registry.related_documents() end, { desc = "[R]elated Documents" })
map("n", "<leader>dc",  function() ME.pickers.git_hunks({ path = vim.fn.expand("%") }) end, { desc = "[C]hanges" })
map("n", "<leader>dj",  function() MP.registry.buffer_jumps() end, { desc = "[J]umps" })
map("n", "<leader>dp",  function() ME.pickers.diagnostic({ scope = "current" }) end, { desc = "[P]roblems" })
map("n", "<leader>ds",  function() ME.pickers.lsp({ scope = "document_symbol" }) end, { desc = "[S]ymbols" })
map("n", "<leader>dt",  function() ME.pickers.buf_lines({ scope = "current" }) end, { desc = "[T]ext" })

-- Symbol
map("n", "<leader>sr",  function() ME.pickers.lsp({ scope = "references" }) end, { desc = "[R]eferences" })
map("n", "<leader>si",  function() ME.pickers.lsp({ scope = "implementation" }) end, { desc = "[I]mplementations" })
-- stylua: ignore end
