local M = {}

-- =============================================================================
-- Helper Functions
-- =============================================================================

--- Centralized key mapping function
---@param mode string|table Mode(s) to set the mapping for (e.g., "n", "v", "i", {"n", "v"})
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts table Optional parameters for vim.keymap.set (e.g., {desc = "Description"})
function M.map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    opts.silent = opts.silent == nil and true or opts.silent
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Disable Ex mode mapping
M.map("n", "Q", "<nop>", { desc = "Disable Ex Mode" })

-- Restart
M.map("n", "<leader>r", function()
    vim.cmd.wa({ bang = true })
    vim.cmd.restart()
end, { desc = "[R]estart" })

-- Escape clears search highlight, saves, hides notifier
M.map("n", "<Esc>", function()
    vim.cmd.nohlsearch()
    vim.cmd.wa()
    require("snacks.notifier").hide()
end, { desc = "Escape and clear hlsearch" })

-- Shift+Escape clears notifier and floating windows
M.map("n", "<S-Esc>", function()
    require("snacks.notifier").hide()
    require("lib.ui").close_all_floating_windows()
end, { desc = "Clear Notifier and Trouble" })

-- Center screen when moving through jump list
M.map("n", "<C-o>", "<C-o>zz", { desc = "Move back in jump list" })
M.map("n", "<C-i>", "<C-i>zz", { desc = "Move forward in jump list" })

-- Center screen when searching
M.map("n", "N", "Nzzzv", { desc = "Previous Search Results" })
M.map("n", "n", "nzzzv", { desc = "Next Search Results" })

-- Better up/down movement that respects wrapped lines
M.map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
M.map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
M.map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
M.map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Keep cursor position when joining lines
M.map("n", "J", "mzJ`z", { desc = "Join Lines" })

-- Move selected lines up/down in visual mode
M.map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selected Lines Up" })
M.map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selected Lines Down" })

-- Indenting in visual mode keeps selection
M.map("v", "<", "<gv", { desc = "Indent Selected Lines" })
M.map("v", ">", ">gv", { desc = "Outdent Selected Lines" })

-- Make undo points for common punctuation in insert mode
M.map("i", ",", ",<c-g>u", { desc = "Undo Comma" })
M.map("i", ".", ".<c-g>u", { desc = "Undo Dot" })
M.map("i", ";", ";<c-g>u", { desc = "Undo Semicolon" })

-- Delete without yanking ("black hole register")
M.map("n", "x", '"_x', { desc = "Delete without yanking" })

-- Duplicate line
M.map("n", "yp", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Duplicate line" })

-- Duplicate line and comment out the original
M.map("n", "yc", function()
    local col = vim.fn.col(".")
    vim.cmd("norm yy")
    vim.cmd("norm gcc")
    vim.cmd("norm p")
    vim.fn.cursor(vim.fn.line("."), col)
end, { desc = "Dupe line (Comment out old one)" })

-- Select All
M.map("n", "vA", "ggVG", { desc = "Select All" })

-- Yank entire buffer content
M.map("n", "<leader>dya", function()
    -- Save current cursor position
    local current_pos = vim.fn.getpos(".")
    -- Yank entire buffer
    vim.cmd("norm ggVGy")
    -- Restore cursor position
    vim.fn.setpos(".", current_pos)
end, { desc = "[A]ll" })

-- Yank current file path(s) (uses lib function)
M.map({ "n", "v" }, "<leader>dyp", function()
    require("lib.copy").list_paths()
end, { desc = "[P]ath" })

-- Navigate tabs
M.map("n", "H", vim.cmd.tabprevious, { desc = "Previous Tab" })
M.map("n", "L", vim.cmd.tabnext, { desc = "Next Tab" })

-- Resize splits using Shift + Arrow keys
-- M.map({ "n", "v", "x" }, "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize Split Down" })
-- M.map({ "n", "v", "x" }, "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize Split Up" })
-- M.map({ "n", "v", "x" }, "<S-Left>", "<cmd>vertical resize +5<cr>", { desc = "Resize Split Right" }) -- Note: Left arrow increases width to the right
-- M.map({ "n", "v", "x" }, "<S-Right>", "<cmd>vertical resize -5<cr>", { desc = "Resize Split Left" }) -- Note: Right arrow decreases width from the right

-- Save and Quit
M.map("n", "<C-s>", vim.cmd.wa, { desc = "Save" })
M.map("n", "<C-q>", ":q!<CR>", { desc = "Quit" }) -- Force quit

-- Open last edited file
M.map("n", "<leader>dl", "<cmd>e #<cr>", { desc = "[L]ast document" })

M.map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Open current file in Zed editor at the current cursor position
M.map("n", "<leader>z", function()
    local current_file = vim.fn.expand("%:p")
    local current_line = vim.fn.line(".")
    local current_column = vim.fn.col(".")

    vim.cmd("silent !zed " .. current_file .. ":" .. current_line .. ":" .. current_column)
end, { desc = "[Z]ed" })

-- Change directory to Git root
M.map("n", "<leader>w.", function()
    local git_root = require("snacks").git.get_root() -- Assumes 'snacks' plugin/module
    if git_root then
        vim.cmd("cd " .. git_root)
        vim.notify("Changed directory to " .. git_root, vim.log.levels.INFO, { title = "Git Root" })
    else
        vim.notify("No Git root found", vim.log.levels.ERROR, { title = "Git Root" })
    end
end, { desc = "[.] Set Root" })

-- Plugins & Language Management
M.map("n", "<leader>ap", "<cmd>Lazy<CR>", { desc = "[P]lugins" })
M.map("n", "<leader>als", "<cmd>Mason<CR>", { desc = "[S]erver" })
M.map("n", "<leader>ali", require("lib.lsp").info, { desc = "[I]nfo" })
M.map("n", "<leader>all", require("lib.lsp").open_log, { desc = "[L]og" })

M.map("n", "sI", vim.show_pos, { desc = "[I]nspect Position" })

-- For insert mode
vim.keymap.set("i", "<M-t>", function()
    local date = tostring(os.date("## [[%Y.%m.%d - %A]]"))
    vim.api.nvim_put({ date }, "c", true, true)
end, { desc = "Insert current date" })

-- German umlauts in insert mode
vim.keymap.set("i", "<A-u>", "ü")
vim.keymap.set("i", "<A-o>", "ö")
vim.keymap.set("i", "<A-a>", "ä")
vim.keymap.set("i", "<A-U>", "Ü")
vim.keymap.set("i", "<A-O>", "Ö")
vim.keymap.set("i", "<A-A>", "Ä")
