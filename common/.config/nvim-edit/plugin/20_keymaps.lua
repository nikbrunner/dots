-- Global, cross-cutting keymaps only.
-- Plugin-specific keymaps live in the respective `plugin/50_specs/<name>.lua`.

local map = vim.keymap.set

-- Helpers ====================================================================

local function close_all_floating_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative ~= "" then
			vim.api.nvim_win_close(win, true)
		end
	end
end

local function copy(value)
	vim.fn.setreg("+", value)
	vim.notify('Copied "' .. value .. '" to the clipboard!', vim.log.levels.INFO)
end

-- General ====================================================================

map("n", "Q", "<nop>", { desc = "Disable Ex Mode" })

-- Escape clears search highlight, saves, hides notifications
map("n", "<Esc>", function()
	vim.cmd.nohlsearch()
	vim.cmd.wa()
	require("mini.notify").clear()
end, { desc = "Escape, clear hlsearch, save" })

map("n", "<S-Esc>", function()
	require("mini.notify").clear()
	close_all_floating_windows()
end, { desc = "Clear notifications and floating windows" })

-- Center screen when moving through jump list / search results
map("n", "<C-o>", "<C-o>zz", { desc = "Move back in jump list" })
map("n", "<C-i>", "<C-i>zz", { desc = "Move forward in jump list" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result" })
map("n", "n", "nzzzv", { desc = "Next Search Result" })

-- Better up/down movement that respects wrapped lines.
-- (Plain <Up>/<Down> belong to treewalker — see 50_specs/treewalker.lua.)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Open buffer in new tab, tab again to close
map("n", "<C-e>", function()
	local current_buf = vim.api.nvim_get_current_buf()
	local tabs = vim.api.nvim_list_tabpages()
	local pos = vim.api.nvim_win_get_cursor(0)

	if #tabs > 1 then
		for _, tab in ipairs(tabs) do
			local win = vim.api.nvim_tabpage_get_win(tab)
			local buf = vim.api.nvim_win_get_buf(win)

			if buf == current_buf and tab ~= vim.api.nvim_get_current_tabpage() then
				vim.api.nvim_win_set_cursor(win, pos)
				vim.cmd("tabclose")
				return
			end
		end
	end

	vim.cmd("tabedit %")

	local win = vim.api.nvim_get_current_win()
	local line_count = vim.api.nvim_buf_line_count(0)
	local line = math.min(pos[1], line_count)
	vim.api.nvim_win_set_cursor(win, { line, pos[2] })
end, { desc = "Toggle buffer in new tab" })

-- Navigate tabs
map("n", "H", vim.cmd.tabprevious, { desc = "Previous Tab" })
map("n", "L", vim.cmd.tabnext, { desc = "Next Tab" })

-- Save and Quit
map("n", "<C-s>", vim.cmd.wa, { desc = "Save" })
map("n", "<C-q>", ":q!<CR>", { desc = "Quit (force)" })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Split resizing: <C-arrows> via mini.basics (see 50_specs/mini/basics.lua).
-- Shift-arrows belong to treewalker node swaps.

-- Editing ====================================================================

-- Keep cursor position when joining lines
map("n", "J", "mzJ`z", { desc = "Join Lines" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selected Lines Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selected Lines Up" })

-- Indenting in visual mode keeps selection
map("v", "<", "<gv", { desc = "Indent Selected Lines" })
map("v", ">", ">gv", { desc = "Outdent Selected Lines" })

-- Make undo points for common punctuation in insert mode
map("i", ",", ",<c-g>u", { desc = "Undo Comma" })
map("i", ".", ".<c-g>u", { desc = "Undo Dot" })
map("i", ";", ";<c-g>u", { desc = "Undo Semicolon" })

-- Delete without yanking ("black hole register")
map("n", "x", '"_x', { desc = "Delete without yanking" })

-- Duplicate line
map("n", "yp", function()
	local col = vim.fn.col(".")
	vim.cmd("norm yy")
	vim.cmd("norm p")
	vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Duplicate line" })

-- Duplicate line and comment out the original
map("n", "yc", function()
	local col = vim.fn.col(".")
	vim.cmd("norm yy")
	vim.cmd("norm gcc")
	vim.cmd("norm p")
	vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Duplicate line (comment out original)" })

map("n", "yA", "mzggVGy`z", { desc = "Yank All" })
map("n", "vA", "ggVG", { desc = "Select All" })

-- Insert current date
map("i", "<M-t>", function()
	local date = tostring(os.date("## [[%Y.%m.%d - %A]]"))
	vim.api.nvim_put({ date }, "c", true, true)
end, { desc = "Insert current date" })

-- German umlauts in insert mode
map("i", "<A-u>", "ü")
map("i", "<A-o>", "ö")
map("i", "<A-a>", "ä")
map("i", "<A-U>", "Ü")
map("i", "<A-O>", "Ö")
map("i", "<A-A>", "Ä")

-- Copy file meta (<leader>dy*) ===============================================

map({ "n", "v" }, "<leader>dyn", function()
	copy(vim.fn.expand("%:t"))
end, { desc = "[N]ame" })

map({ "n", "v" }, "<leader>dyr", function()
	copy(vim.fn.fnamemodify(vim.fn.expand("%"), ":~:."))
end, { desc = "[R]elative" })

map({ "n", "v" }, "<leader>dyR", function()
	copy(vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") .. "#L" .. vim.fn.line("."))
end, { desc = "[R]elative /w Line Number" })

map({ "n", "v" }, "<leader>dyh", function()
	copy(vim.fn.expand("%:~"))
end, { desc = "[H]ome" })

map({ "n", "v" }, "<leader>dya", function()
	copy(vim.fn.expand("%:p"))
end, { desc = "[A]bsolute" })

-- Workspace / app ============================================================

map("n", "<leader>dl", "<cmd>e #<cr>", { desc = "[L]ast document" })

-- Open current file in Zed editor at the current cursor position
map("n", "<leader>z", function()
	local current_file = vim.fn.expand("%:p")
	local current_line = vim.fn.line(".")
	local current_column = vim.fn.col(".")

	vim.cmd("silent !zed " .. current_file .. ":" .. current_line .. ":" .. current_column)
end, { desc = "[Z]ed" })

-- Change directory to Git root
map("n", "<leader>w.", function()
	local git_root = vim.fs.root(0, ".git")
	if git_root then
		vim.cmd("cd " .. git_root)
		vim.notify("Changed directory to " .. git_root, vim.log.levels.INFO, { title = "Git Root" })
	else
		vim.notify("No Git root found", vim.log.levels.ERROR, { title = "Git Root" })
	end
end, { desc = "[.] Set Root" })

map("n", "<leader>ali", "<cmd>checkhealth vim.lsp<CR>", { desc = "LSP [I]nfo" })
map("n", "<leader>all", function()
	vim.cmd("tabedit " .. vim.lsp.log.get_filename())
end, { desc = "LSP [L]og" })
map("n", "<leader>am", "<CMD>messages<CR>", { desc = "[M]essages" })

map("n", "<leader>i", vim.show_pos, { desc = "[I]nspect Position" })
